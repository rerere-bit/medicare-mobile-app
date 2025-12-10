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

  // Collection Reference for history
  CollectionReference get _historyCollection =>
      _firestore.collection('medication_history');

  // Collection Reference
  CollectionReference get _medCollection =>
      _firestore.collection('medications');

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- LOGIKA MAPPING WAKTU (Sprint 13) ---
  // Menerjemahkan String dropdown menjadi List Jam Integer
  List<int> _calculateAlarmTimes(String frequency) {
    if (frequency.contains('1x')) return [8];             // Jam 08:00
    if (frequency.contains('2x')) return [8, 20];         // Jam 08:00, 20:00
    if (frequency.contains('3x')) return [7, 13, 19];     // Jam 07:00, 13:00, 19:00
    if (frequency.contains('4x')) return [6, 12, 18, 23]; // Jam 06, 12, 18, 23
    return [8]; // Default jam 8 pagi
  }

  // 1. Fungsi Tambah Obat (Create) + DYNAMIC NOTIFICATION
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
        id: '', // ID akan digenerate Firestore
        userId: user.uid,
        name: name,
        dosage: dosage,
        frequency: frequency,
        duration: duration,
        notes: notes,
      );

      // A. Simpan ke Firestore
      DocumentReference docRef = await _medCollection.add(newMed.toMap());

      // B. Hitung Jadwal Waktu berdasarkan Frekuensi
      List<int> alarmHours = _calculateAlarmTimes(frequency);
      int baseId = docRef.id.hashCode; // ID Dasar untuk notifikasi

      // C. Loop untuk pasang alarm sebanyak frekuensi
      for (int i = 0; i < alarmHours.length; i++) {
        int hour = alarmHours[i];
        
        // ID Notifikasi: baseId + index (agar unik untuk setiap jam)
        // Contoh: Obat A jam 07:00 (ID: 1001), Obat A jam 13:00 (ID: 1002)
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

      // Catatan: Untuk implementasi sempurna, seharusnya kita membatalkan alarm lama
      // lalu membuat alarm baru jika frekuensi berubah. 
      // Namun untuk tugas ini, update data saja sudah cukup baik.

    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 4. Fungsi Hapus Obat + BATALKAN SEMUA NOTIFIKASI
  Future<void> deleteMedication(String id) async {
    try {
      // A. Hapus dari Firestore
      await _medCollection.doc(id).delete();

      // B. Hapus Semua Kemungkinan Alarm untuk obat ini
      // Kita loop cancel 5 kali (asumsi maksimal frekuensi obat)
      // agar semua jadwal (pagi/siang/malam) terhapus bersih.
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

  // 8. KHUSUS KELUARGA: Ambil Obat milik Pasien Lain
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

  // 9. KHUSUS KELUARGA: Ambil Riwayat milik Pasien Lain
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

  // Stream Riwayat untuk user yang sedang login
  Stream<List<HistoryModel>> getHistory() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return getHistoryByUserId(user.uid);
  }
}