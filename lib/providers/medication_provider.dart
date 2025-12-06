import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medication_model.dart';
import '../models/history_model.dart';
import '../services/notification_service.dart';

class MedicationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection Reference for history
  CollectionReference get _historyCollection =>
      _firestore.collection('medication_history');

  // Collection Reference
  CollectionReference get _medCollection =>
      _firestore.collection('medications');

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- LOGIKA MAPPING WAKTU ---
  List<int> _calculateAlarmTimes(String frequency) {
    if (frequency.contains('1x')) return [8];             // Jam 08:00
    if (frequency.contains('2x')) return [8, 20];         // Jam 08:00, 20:00
    if (frequency.contains('3x')) return [7, 13, 19];     // Jam 07:00, 13:00, 19:00
    if (frequency.contains('4x')) return [6, 12, 18, 23]; // Jam 06, 12, 18, 23
    return [8]; // Default
  }

  // 1. Fungsi Tambah Obat (Create)
  Future<void> addMedication({
    required String name,
    required String dosage,
    required String frequency,
    required String duration,
    required String notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User tidak login");

      final newMed = MedicationModel(
        id: '', 
        userId: user.uid,
        name: name,
        dosage: dosage,
        frequency: frequency,
        duration: duration,
        notes: notes,
      );

      DocumentReference docRef = await _medCollection.add(newMed.toMap());

      List<int> alarmHours = _calculateAlarmTimes(frequency);
      int baseId = docRef.id.hashCode; 

      for (int i = 0; i < alarmHours.length; i++) {
        int hour = alarmHours[i];
        int uniqueNotificationId = baseId + i; 

        await NotificationService().scheduleDailyNotification(
          id: uniqueNotificationId,
          title: "Waktunya Minum Obat",
          body: "Saatnya minum $name ($dosage) - Jadwal Pukul $hour:00",
          hour: hour,
          minute: 0,
        );
      }

    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Stream Get Obat (Read)
  Stream<List<MedicationModel>> getMedications() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _medCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MedicationModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // 3. Fungsi Update Obat
  Future<void> updateMedication({
    required String id,
    required String name,
    required String dosage,
    required String frequency,
    required String duration,
    required String notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _medCollection.doc(id).update({
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'duration': duration,
        'notes': notes,
      });
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 4. Fungsi Hapus Obat
  Future<void> deleteMedication(String id) async {
    try {
      await _medCollection.doc(id).delete();
      int baseId = id.hashCode;
      for (int i = 0; i < 5; i++) {
        await NotificationService().cancelNotification(baseId + i);
      }
    } catch (e) {
      rethrow;
    }
  }

  // 5. Fungsi Log Medication Intake
  Future<void> logMedicationIntake({
    required String medicationId,
    required String medicationName,
    required String dosage,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User tidak login");

      await _historyCollection.add({
        'userId': user.uid,
        'medicationId': medicationId,
        'medicationName': medicationName,
        'dosage': dosage,
        'takenAt': DateTime.now().toIso8601String(), 
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // 6. KHUSUS KELUARGA: Ambil Obat milik Pasien Lain
  Stream<List<MedicationModel>> getMedicationsByUserId(String targetUid) {
    return _medCollection
        .where('userId', isEqualTo: targetUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MedicationModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // 7. KHUSUS KELUARGA: Ambil Riwayat milik Pasien Lain
  Stream<List<HistoryModel>> getHistoryByUserId(String targetUid) {
    return _historyCollection
        .where('userId', isEqualTo: targetUid)
        .orderBy('takenAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return HistoryModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // 8. Stream Riwayat untuk user yang sedang login
  Stream<List<HistoryModel>> getHistory() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return getHistoryByUserId(user.uid);
  }

  // ---------------------------------------------------------
  // FITUR BARU: CALCULATE NEXT SCHEDULE (FINISHING TOUCH)
  // ---------------------------------------------------------
  
  DateTime? calculateNextSchedule(List<MedicationModel> medications) {
    if (medications.isEmpty) return null;

    final now = DateTime.now();
    DateTime? nearestTime;

    for (var med in medications) {
      // 1. Ambil jam-jam jadwal obat ini berdasarkan frekuensi
      List<int> scheduleHours = _calculateAlarmTimes(med.frequency);

      for (var hour in scheduleHours) {
        // 2. Buat objek DateTime untuk jadwal HARI INI
        DateTime scheduleTime = DateTime(now.year, now.month, now.day, hour, 0, 0);

        // 3. Jika waktu sudah lewat, anggap jadwalnya BESOK
        // (Gunakan isAfter biar lebih presisi menghindari waktu sekarang pas)
        if (now.isAfter(scheduleTime)) {
          scheduleTime = scheduleTime.add(const Duration(days: 1));
        }

        // 4. Bandingkan: Apakah ini lebih dekat dibanding yang sudah ditemukan?
        if (nearestTime == null || scheduleTime.isBefore(nearestTime)) {
          nearestTime = scheduleTime;
        }
      }
    }

    return nearestTime;
  }
}