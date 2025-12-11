import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medication_model.dart';
import '../models/history_model.dart';
import '../services/notification_service.dart';

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

// Tambahkan Return Type khusus agar UI tahu kondisi stok
class IntakeResult {
  final bool success;
  final int remainingStock;
  final bool isStockLow;
  final String message;

  IntakeResult({required this.success, required this.remainingStock, required this.isStockLow, required this.message});
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

  // ... (Logic Waktu & ID Notifikasi tetap sama, copy paste dari sebelumnya jika perlu) ...
  List<TimeOfDay> _getAlarmTimes(MedicationModel med) {
    if (med.timeSlots.isNotEmpty) {
      return med.timeSlots.map((timeStr) {
        final parts = timeStr.split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }).toList();
    }
    String f = med.frequency;
    if (f.contains('1x')) return const [TimeOfDay(hour: 8, minute: 0)];
    if (f.contains('2x')) return const [TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 20, minute: 0)];
    if (f.contains('3x')) return const [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 13, minute: 0), TimeOfDay(hour: 19, minute: 0)];
    if (f.contains('4x')) return const [TimeOfDay(hour: 6, minute: 0), TimeOfDay(hour: 12, minute: 0), TimeOfDay(hour: 18, minute: 0), TimeOfDay(hour: 23, minute: 0)];
    return const [TimeOfDay(hour: 8, minute: 0)];
  }

  int _generateNotificationId(String medId, int index) {
    return (medId.hashCode + index).abs(); 
  }

  // 1. TAMBAH OBAT (UPDATED: Support Remote Add)
  Future<void> addMedication({
    required String name,
    required String dosage,
    required String frequency,
    required String duration,
    required String notes,
    required int color,
    required String type,
    required int stock,
    required String instruction,
    required List<String> timeSlots,
    String? targetUserId, // PARAM BARU (Optional)
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception("User tidak login");

      // Tentukan siapa pemilik obat ini (Diri sendiri atau Pasien?)
      final String ownerId = targetUserId ?? currentUser.uid;

      DocumentReference docRef = _medCollection.doc(); 
      
      final newMed = MedicationModel(
        id: docRef.id,
        userId: ownerId, // Simpan ke ID Pasien jika remote
        name: name,
        dosage: dosage,
        frequency: frequency,
        duration: duration,
        notes: notes,
        color: color,
        type: type,
        stock: stock,
        instruction: instruction,
        timeSlots: timeSlots,
        createdAt: DateTime.now(),
      );

      await docRef.set(newMed.toMap());

      // LOGIC NOTIFIKASI:
      // Hanya jadwalkan alarm di HP ini jika obat ini untuk SAYA.
      // Jika saya menambah untuk pasien, HP saya tidak perlu bunyi (atau opsional).
      // Pasien akan mendapat alarm saat membuka aplikasinya (perlu sync).
      if (ownerId == currentUser.uid) {
        await _scheduleNotificationsForMedication(newMed);
      }

    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. UPDATE OBAT (UPDATED: Support Remote)
  Future<void> updateMedication({
    required String id,
    required String name,
    required String dosage,
    required String frequency,
    required String duration,
    required String notes,
    required int color,
    required String type,
    required int stock,
    required String instruction,
    required List<String> timeSlots,
    String? targetUserId, // PARAM BARU
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception("User tidak login");
      
      final String ownerId = targetUserId ?? currentUser.uid;

      DocumentSnapshot oldDoc = await _medCollection.doc(id).get();
      if (!oldDoc.exists) {
        throw Exception("Medication not found");
      }
      MedicationModel oldMed = MedicationModel.fromMap(
          oldDoc.data() as Map<String, dynamic>, id);

      // Cancel notif lama (Hanya jika obat saya)
      if (ownerId == currentUser.uid) {
           await _cancelNotificationsForMedication(oldMed);
      }

      final updatedMed = MedicationModel(
        id: id,
        userId: ownerId, // Pastikan ID tetap konsisten
        name: name,
        dosage: dosage,
        frequency: frequency,
        duration: duration,
        notes: notes,
        color: color,
        type: type,
        stock: stock,
        instruction: instruction,
        timeSlots: timeSlots,
        createdAt: oldMed.createdAt, // Preserve the original creation date
      );

      await _medCollection.doc(id).update(updatedMed.toMap());

      // Jadwalkan ulang (Hanya jika obat saya)
      if (ownerId == currentUser.uid) {
        await _scheduleNotificationsForMedication(updatedMed);
      }

    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. HAPUS (Tetap Sama)
  Future<void> deleteMedication(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Cek dulu apakah ini obat saya (untuk cancel alarm)
      final currentUser = _auth.currentUser;
      DocumentSnapshot doc = await _medCollection.doc(id).get();
      
      if (doc.exists) {
        MedicationModel med = MedicationModel.fromMap(doc.data() as Map<String, dynamic>, id);
        
        // Hanya cancel alarm jika obat milik user yang login
        if (currentUser != null && med.userId == currentUser.uid) {
          await _cancelNotificationsForMedication(med);
        }
      }
      await _medCollection.doc(id).delete();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ... (Sisa fungsi helpers notifikasi, read, history, home helper SAMA SEPERTI SEBELUMNYA) ...
  // Silakan copy paste sisa fungsi dari file medication_provider.dart terakhir Anda.
  // Pastikan _scheduleNotificationsForMedication dan lainnya ada.
  
  // --- HELPERS NOTIFIKASI ---
  Future<void> _scheduleNotificationsForMedication(MedicationModel med) async {
    List<TimeOfDay> times = _getAlarmTimes(med);
    for (int i = 0; i < times.length; i++) {
      TimeOfDay t = times[i];
      int notifId = _generateNotificationId(med.id, i);
      String timeString = "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

      await NotificationService().scheduleDailyNotification(
        id: notifId,
        title: "Waktunya Minum Obat",
        body: "${med.name} ${med.dosage}\n${med.instruction} - Pukul $timeString",
        hour: t.hour,
        minute: t.minute,
        payload: med.id,
      );
    }
  }

  Future<void> _cancelNotificationsForMedication(MedicationModel med) async {
    List<TimeOfDay> times = _getAlarmTimes(med);
    for (int i = 0; i < times.length; i++) {
      int notifId = _generateNotificationId(med.id, i);
      await NotificationService().cancelNotification(notifId);
    }
  }
  
  Stream<List<MedicationModel>> getMedications() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _medCollection.where('userId', isEqualTo: user.uid).orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MedicationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  Stream<List<MedicationModel>> getMedicationsByUserId(String targetUid) {
    return _medCollection.where('userId', isEqualTo: targetUid).orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MedicationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }
  
  // ... (Fungsi logHistory, getHistory, getHistoryByUserId, calculateNextSchedule TETAP SAMA) ...
  // Jangan lupa sertakan fungsi canTakeNow dan isScheduleTaken yang baru saja kita buat.
  
  bool isScheduleTaken(String medId, DateTime scheduleTime, List<HistoryModel> todayLogs) {
    return todayLogs.any((log) {
      if (log.medicationId != medId) return false;
      final difference = log.takenAt.difference(scheduleTime).inMinutes.abs();
      return difference <= 120; 
    });
  }

  String? canTakeNow(DateTime scheduleTime) {
    final now = DateTime.now();
    final startWindow = scheduleTime.subtract(const Duration(minutes: 60));
    final endWindow = scheduleTime.add(const Duration(hours: 4));
    if (now.isBefore(startWindow)) return "Terlalu cepat! Tunggu jadwal.";
    if (now.isAfter(endWindow)) return "Jadwal sudah lewat jauh."; 
    return null; 
  }
  
  // --- LOGIC BARU: KURANGI STOK SAAT MINUM ---
  // Ubah return type dari Future<void> menjadi Future<IntakeResult>
  Future<IntakeResult> logMedicationIntake({
    required String medicationId,
    required String medicationName,
    required String dosage,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User tidak login");

      // 1. Ambil data obat saat ini untuk cek stok
      final medDoc = await _medCollection.doc(medicationId).get();
      if (!medDoc.exists) throw Exception("Obat tidak ditemukan");
      
      final medData = medDoc.data() as Map<String, dynamic>;
      int currentStock = medData['stock'] ?? 0;

      // 2. Logic Pengurangan Stok
      int newStock = currentStock;
      if (currentStock > 0) {
        newStock = currentStock - 1;
        // Update Stok di Firestore
        await _medCollection.doc(medicationId).update({'stock': newStock});
      }

      // 3. Catat Riwayat
      await _historyCollection.add({
        'userId': user.uid,
        'medicationId': medicationId,
        'medicationName': medicationName,
        'dosage': dosage,
        'takenAt': DateTime.now().toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      notifyListeners(); // Refresh UI stok di Home/List

      // 4. Return Info ke UI (Untuk Trigger Alert)
      return IntakeResult(
        success: true,
        remainingStock: newStock,
        isStockLow: newStock <= 3, // Alert jika sisa 3 atau kurang
        message: newStock == 0 ? "Stok obat HABIS!" : (newStock <= 3 ? "Stok menipis ($newStock lagi)" : "Berhasil dicatat"),
      );

    } catch (e) {
      rethrow;
    }
  }

  // --- LOGIC BARU: CEK VALIDITAS TANGGAL (FIXED) ---
  
  // Helper parsing (Sama)
  int _parseDurationDays(String durationStr) {
    if (durationStr == 'Seumur Hidup' || durationStr.toLowerCase().contains('rutin')) {
      return 365 * 50; 
    }
    final numericString = durationStr.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericString.isEmpty) return 365 * 10;
    return int.tryParse(numericString) ?? 365 * 10;
  }

  // FUNGSI UTAMA: Cek apakah obat aktif pada tanggal tertentu
  bool isMedicationActiveOnDate(MedicationModel med, DateTime dateToCheck) {
    // 1. Normalisasi Tanggal (Buang Jam/Menit agar adil)
    final check = DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);
    final start = DateTime(med.createdAt.year, med.createdAt.month, med.createdAt.day);
    
    // 2. CEK MASA LALU: Jika tanggal cek < tanggal buat, sembunyikan.
    if (check.isBefore(start)) {
      return false; 
    }

    // 3. CEK DURASI:
    final int days = _parseDurationDays(med.duration);
    
    // Hitung tanggal berakhir.
    // Konsep: Jika mulai tgl 11, durasi 2 hari -> Tgl 11 dan 12.
    // Start (11) + 2 hari = Tgl 13.
    // Jadi batasnya adalah < Tgl 13.
    final end = start.add(Duration(days: days));

    // Jika tanggal cek >= tanggal akhir, berarti sudah expired.
    // (Gunakan isAtSameMomentAs untuk menangkap hari ke-3 pas di perbatasan)
    if (check.isAfter(end) || check.isAtSameMomentAs(end)) {
      return false;
    }

    return true; // Obat Aktif
  }

  // Helper untuk cek apakah obat sudah lewat durasi pada tanggal tertentu (DIPERTAHANKAN untuk schedule_screen)
  bool isMedicationExpired(MedicationModel med, DateTime checkDate) {
    // Logikanya dibalik: obat "expired" di suatu tanggal jika TIDAK aktif.
    return !isMedicationActiveOnDate(med, checkDate);
  }

  // Helper lama (bisa dihapus atau diganti memanggil fungsi baru di atas)
  List<MedicationModel> getExpiredMedications(List<MedicationModel> meds) {
    final now = DateTime.now();
    // Kita cari yang TIDAK aktif hari ini, tapi start-nya sudah lewat (bukan obat masa depan)
    return meds.where((med) {
      final start = DateTime(med.createdAt.year, med.createdAt.month, med.createdAt.day);
      final check = DateTime(now.year, now.month, now.day);
      
      // Expired artinya: Sudah lewat tanggal start DAN sudah tidak aktif
      return !isMedicationActiveOnDate(med, now) && (check.isAfter(start) || check.isAtSameMomentAs(start));
    }).toList();
  }
  
  Stream<List<HistoryModel>> getHistory() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return getHistoryByUserId(user.uid);
  }

  Stream<List<HistoryModel>> getHistoryByUserId(String targetUid) {
    return _historyCollection.where('userId', isEqualTo: targetUid).orderBy('takenAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => HistoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }
  
  DateTime getNextTimeForMedication(MedicationModel med) {
    final now = DateTime.now();
    List<TimeOfDay> times = _getAlarmTimes(med);
    DateTime? nearestTime;
    for (var t in times) {
      DateTime scheduleTime = DateTime(now.year, now.month, now.day, t.hour, t.minute, 0);
      if (now.isAfter(scheduleTime)) scheduleTime = scheduleTime.add(const Duration(days: 1));
      if (nearestTime == null || scheduleTime.isBefore(nearestTime)) nearestTime = scheduleTime;
    }
    return nearestTime!;
  }

  NextScheduleData? calculateNextSchedule(List<MedicationModel> medications) {
    if (medications.isEmpty) return null;
    NextScheduleData? nearestData;
    for (var med in medications) {
      DateTime nextTime = getNextTimeForMedication(med);
      if (nearestData == null || nextTime.isBefore(nearestData.time)) {
        nearestData = NextScheduleData(time: nextTime, medName: med.name, dosage: med.dosage);
      }
    }
    return nearestData;
  }

  // --- FITUR SYNC: JADWALKAN ULANG SEMUA ALARM (Dipanggil di main.dart) ---
  Future<void> rescheduleAllAlarms() async {
    final user = _auth.currentUser;
    if (user == null) return;

    print("🔄 SYNC: Memulai sinkronisasi alarm untuk user: ${user.uid}...");

    try {
      // 1. Ambil semua data obat dari Firestore
      final snapshot = await _medCollection
          .where('userId', isEqualTo: user.uid)
          .get();

      final meds = snapshot.docs.map((doc) {
        return MedicationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // 2. Batalkan semua notifikasi lama (Reset)
      // Pastikan NotificationService punya method cancelAllNotifications()
      await NotificationService().cancelAllNotifications();

      // 3. Jadwalkan ulang satu per satu
      int count = 0;
      for (var med in meds) {
        // Hanya jadwalkan jika ada instruksi waktu
        await _scheduleNotificationsForMedication(med);
        count++;
      }
      
      print("✅ SYNC BERHASIL: $count obat dijadwalkan ulang.");
      
    } catch (e) {
      print("❌ SYNC GAGAL: $e");
    }
  }
}