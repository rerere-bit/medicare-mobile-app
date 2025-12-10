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

class MedicationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _historyCollection =>
      _firestore.collection('medication_history');

  CollectionReference get _medCollection =>
      _firestore.collection('medications');

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _generateNotificationId(String medId, int index) {
    return (medId.hashCode + index).abs(); 
  }

  // 1. TAMBAH OBAT (UPDATED)
  Future<void> addMedication({
    required String name,
    required String dosage,
    required String frequency,
    required String duration,
    required String notes,
    // Params Baru
    required int color,
    required String type,
    required int stock,
    required String instruction,
    required List<String> timeSlots,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User tidak login");

      DocumentReference docRef = _medCollection.doc(); 
      
      final newMed = MedicationModel(
        id: docRef.id,
        userId: user.uid,
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
      );

      await docRef.set(newMed.toMap());
      await _scheduleNotificationsForMedication(newMed);

    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. UPDATE OBAT (UPDATED)
  Future<void> updateMedication({
    required String id,
    required String name,
    required String dosage,
    required String frequency,
    required String duration,
    required String notes,
    // Params Baru
    required int color,
    required String type,
    required int stock,
    required String instruction,
    required List<String> timeSlots,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User tidak login");

      // Cancel notif lama
      DocumentSnapshot oldDoc = await _medCollection.doc(id).get();
      if (oldDoc.exists) {
         MedicationModel oldMed = MedicationModel.fromMap(
            oldDoc.data() as Map<String, dynamic>, id);
         await _cancelNotificationsForMedication(oldMed);
      }

      final updatedMed = MedicationModel(
        id: id,
        userId: user.uid,
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
      );

      await _medCollection.doc(id).update(updatedMed.toMap());
      await _scheduleNotificationsForMedication(updatedMed);

    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Hapus Obat
  Future<void> deleteMedication(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      DocumentSnapshot doc = await _medCollection.doc(id).get();
      if (doc.exists) {
        MedicationModel med = MedicationModel.fromMap(
            doc.data() as Map<String, dynamic>, id);
        await _cancelNotificationsForMedication(med);
      }
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
    // List<int> alarmHours = _calculateAlarmTimes(med.frequency);
    for (int i = 0; i < med.timeSlots.length; i++) {
      final timeParts = med.timeSlots[i].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      int notifId = _generateNotificationId(med.id, i);

      await NotificationService().scheduleDailyNotification(
        id: notifId,
        title: "Waktunya Minum Obat",
        body: "${med.name} ${med.dosage}\n${med.instruction}", // Tambah instruksi di notif
        hour: hour,
        minute: minute,
        payload: med.id,
      );
    }
  }

  Future<void> _cancelNotificationsForMedication(MedicationModel med) async {
    // List<int> alarmHours = _calculateAlarmTimes(med.frequency);
    for (int i = 0; i < med.timeSlots.length; i++) {
      int notifId = _generateNotificationId(med.id, i);
      await NotificationService().cancelNotification(notifId);
    }
  }

  // --- READ DATA ---
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

  // --- RIWAYAT ---
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
      
      // TODO: Bisa ditambahkan logika pengurangan stok di sini
      
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

  // --- HOME HELPER ---
  DateTime getNextTimeForMedication(MedicationModel med) {
    final now = DateTime.now();
    // List<int> scheduleHours = _calculateAlarmTimes(med.frequency);
    DateTime? nearestTime;

    for (var timeString in med.timeSlots) {
       final timeParts = timeString.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      DateTime scheduleTime = DateTime(now.year, now.month, now.day, hour, minute, 0);
      if (now.isAfter(scheduleTime)) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }
      if (nearestTime == null || scheduleTime.isBefore(nearestTime)) {
        nearestTime = scheduleTime;
      }
    }
    return nearestTime ?? DateTime.now().add(const Duration(days: 1));
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