import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FamilyProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 1. Cari Pasien via Email & Tambahkan ke List Pemantauan
  Future<void> addPatientByEmail(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // A. Cari User berdasarkan Email di collection 'users'
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('role', isEqualTo: 'Pasien') // Pastikan dia Pasien
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("Email pasien tidak ditemukan atau bukan akun Pasien.");
      }

      final patientData = querySnapshot.docs.first.data();
      final patientId = querySnapshot.docs.first.id;

      // B. Simpan ke Sub-collection 'monitored_patients' di akun Keluarga
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('monitored_patients')
          .doc(patientId) // Gunakan ID Pasien sebagai ID Dokumen agar tidak duplikat
          .set({
        'uid': patientId,
        'displayName': patientData['displayName'],
        'email': patientData['email'],
        'addedAt': DateTime.now().toIso8601String(),
      });

    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Ambil Daftar Pasien yang Dipantau
  Stream<QuerySnapshot> getMonitoredPatients() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('monitored_patients')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }
}