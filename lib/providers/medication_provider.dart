import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medication_model.dart';
import '../models/history_model.dart';
import '../services/notification_service.dart';

// Class bantuan untuk menampung hasil kalkulasi jadwal
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

  // --- LOGIKA MAPPING WAKTU & ID NOTIFIKASI ---
  
  // Mengubah frekuensi teks menjadi jam spesifik (Integer)
  List<int> _calculateAlarmTimes(String frequency) {
    if (frequency.contains('1x')) return [8]; // 08:00
    if (frequency.contains('2x')) return [8, 20]; // 08:00, 20:00
    if (frequency.contains('3x')) return [7, 13, 19]; // 07:00, 13:00, 19:00
    if (frequency.contains('4x')) return [6, 12, 18, 23]; // Per 6 jam
    return [8]; // Default
  }

  // Menghasilkan ID notifikasi unik berdasarkan ID Obat dan index jam
  // Ini penting agar kita bisa membatalkan notifikasi spesifik nanti
  int _generateNotificationId(String medId, int index) {
    // Mengambil hashcode dari string ID + index agar unik
    return (medId.hashCode + index).abs(); 
  }

  // --- CRUD OBAT ---

  // 1. Tambah Obat & Jadwalkan Alarm
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

      // A. Simpan ke Firestore
      // Kita buat docRef dulu agar dapat ID-nya sebelum save
      DocumentReference docRef = _medCollection.doc(); 
      
      final newMed = MedicationModel(
        id: docRef.id, // Gunakan ID dari docRef
        userId: user.uid,
        name: name,
        dosage: dosage,
        frequency: frequency,
        duration: duration,
        notes: notes,
      );

      // Gabungkan data model dengan server timestamp
      final data = newMed.toMap();
      data['createdAt'] = FieldValue.serverTimestamp();

      await docRef.set(data);

      // B. Jadwalkan Notifikasi
      await _scheduleNotificationsForMedication(newMed);

    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Update Obat (Hapus Alarm Lama -> Update Data -> Buat Alarm Baru)
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
      final user = _auth.currentUser;
      if (user == null) throw Exception("User tidak login");

      // A. Ambil data lama untuk tahu frekuensi sebelumnya (untuk cancel notif)
      DocumentSnapshot oldDoc = await _medCollection.doc(id).get();
      if (!oldDoc.exists) throw Exception("Data obat tidak ditemukan");
      
      MedicationModel oldMed = MedicationModel.fromMap(
          oldDoc.data() as Map<String, dynamic>, id);

      // B. Batalkan Notifikasi Lama
      await _cancelNotificationsForMedication(oldMed);

      // C. Update Firestore
      final updatedMed = MedicationModel(
        id: id,
        userId: user.uid,
        name: name,
        dosage: dosage,
        frequency: frequency,
        duration: duration,
        notes: notes,
      );

      await _medCollection.doc(id).update(updatedMed.toMap());

      // D. Jadwalkan Notifikasi Baru
      await _scheduleNotificationsForMedication(updatedMed);

    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Hapus Obat & Batalkan Alarm
  Future<void> deleteMedication(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
       // A. Ambil data dulu untuk cancel notifikasi
      DocumentSnapshot doc = await _medCollection.doc(id).get();
      if (doc.exists) {
        MedicationModel med = MedicationModel.fromMap(
            doc.data() as Map<String, dynamic>, id);
        
        // B. Batalkan Notifikasi
        await _cancelNotificationsForMedication(med);
      }

      // C. Hapus dari Firestore
      await _medCollection.doc(id).delete();
      
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- HELPERS NOTIFIKASI ---

  Future<void> _scheduleNotificationsForMedication(MedicationModel med) async {
    List<int> alarmHours = _calculateAlarmTimes(med.frequency);
    
    for (int i = 0; i < alarmHours.length; i++) {
      int hour = alarmHours[i];
      int notifId = _generateNotificationId(med.id, i);

      await NotificationService().scheduleDailyNotification(
        id: notifId,
        title: "Waktunya Minum Obat",
        body: "${med.name} ${med.dosage} - Jadwal Pukul $hour:00",
        hour: hour,
        minute: 0,
        payload: med.id, // Kita kirim ID obat sebagai payload untuk navigasi nanti
      );
    }
  }

  Future<void> _cancelNotificationsForMedication(MedicationModel med) async {
    List<int> alarmHours = _calculateAlarmTimes(med.frequency);
    
    for (int i = 0; i < alarmHours.length; i++) {
      int notifId = _generateNotificationId(med.id, i);
      await NotificationService().cancelNotification(notifId);
    }
  }

  // --- BAGIAN READ DATA (Sama seperti sebelumnya) ---

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

  Stream<List<HistoryModel>> getHistory() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return getHistoryByUserId(user.uid);
  }

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

  // --- LOGIKA HITUNG MUNDUR (HOME) ---
  
  DateTime getNextTimeForMedication(MedicationModel med) {
    final now = DateTime.now();
    List<int> scheduleHours = _calculateAlarmTimes(med.frequency);
    DateTime? nearestTime;

    for (var hour in scheduleHours) {
      DateTime scheduleTime = DateTime(now.year, now.month, now.day, hour, 0, 0);
      if (now.isAfter(scheduleTime)) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }
      if (nearestTime == null || scheduleTime.isBefore(nearestTime)) {
        nearestTime = scheduleTime;
      }
    }
    return nearestTime!;
  }

  NextScheduleData? calculateNextSchedule(List<MedicationModel> medications) {
    if (medications.isEmpty) return null;
    NextScheduleData? nearestData;

    for (var med in medications) {
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
}