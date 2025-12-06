import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medication_model.dart';
import '../models/history_model.dart';
import '../services/notification_service.dart';

// Class bantuan untuk menampung hasil kalkulasi
class NextScheduleData {
  final DateTime time;
  final String medName;
  final String dosage;

  NextScheduleData({
    required this.time,
    required this.medName,
    required this.dosage,
  });
}

class MedicationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _historyCollection =>
      _firestore.collection('medication_history');

  CollectionReference get _medCollection =>
      _firestore.collection('medications');

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- LOGIKA MAPPING WAKTU ---
  List<int> _calculateAlarmTimes(String frequency) {
    if (frequency.contains('1x')) return [8];
    if (frequency.contains('2x')) return [8, 20];
    if (frequency.contains('3x')) return [7, 13, 19];
    if (frequency.contains('4x')) return [6, 12, 18, 23];
    return [8];
  }

  // 1. Tambah Obat
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

  // 1.5. Fungsi Update Obat
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
      // Note: This simple update does not reschedule notifications.
      // For a full implementation, one would need to cancel old notifications
      // and create new ones based on the updated frequency.
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Stream Get Obat
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

  // 3. Log Intake
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

  // 4. Update & Delete (Simplified for context)
  Future<void> deleteMedication(String id) async {
    await _medCollection.doc(id).delete();
  }

  // --- LOGIKA HITUNG MUNDUR (UPDATED) ---

  // A. Helper untuk mendapatkan jadwal berikutnya dari SATU obat
  DateTime getNextTimeForMedication(MedicationModel med) {
    final now = DateTime.now();
    List<int> scheduleHours = _calculateAlarmTimes(med.frequency);
    DateTime? nearestTime;

    for (var hour in scheduleHours) {
      DateTime scheduleTime = DateTime(now.year, now.month, now.day, hour, 0, 0);
      
      // Jika waktu sudah lewat, cek besok
      if (now.isAfter(scheduleTime)) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }

      if (nearestTime == null || scheduleTime.isBefore(nearestTime)) {
        nearestTime = scheduleTime;
      }
    }
    return nearestTime!;
  }

  // B. Mencari jadwal terdekat dari SEMUA obat (Untuk Home)
  NextScheduleData? calculateNextSchedule(List<MedicationModel> medications) {
    if (medications.isEmpty) return null;

    NextScheduleData? nearestData;

    for (var med in medications) {
      // Gunakan helper di atas
      DateTime nextTime = getNextTimeForMedication(med);

      if (nearestData == null || nextTime.isBefore(nearestData.time)) {
        nearestData = NextScheduleData(
          time: nextTime,
          medName: med.name,
          dosage: med.dosage,
        );
      }
    }

    return nearestData;
  }

  // --- LOGIKA DATA PASIEN LAIN (UNTUK KELUARGA) ---

  // Ambil Obat milik Pasien berdasarkan UID
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

  // --- LOGIKA RIWAYAT ---

  // Ambil Riwayat milik Pasien berdasarkan UID
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

  // Ambil Riwayat untuk user yang sedang login
  Stream<List<HistoryModel>> getHistory() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return getHistoryByUserId(user.uid);
  }
}