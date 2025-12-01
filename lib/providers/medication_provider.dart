import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medication_model.dart';

class MedicationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection Reference
  CollectionReference get _medCollection => _firestore.collection('medications');

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 1. Fungsi Tambah Obat (Create)
  Future<void> addMedication({
    required String name,
    required String dosage,
    required String frequency,
    required String duration,
    required String notes,
  }) async {
    _isLoading = true;
    notifyListeners(); // Beritahu UI untuk show loading

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User tidak login");

      final newMed = MedicationModel(
        id: '', // ID akan digenerate Firestore
        userId: user.uid,
        name: name,
        dosage: dosage,
        frequency: frequency,
        duration: duration,
        notes: notes,
      );

      await _medCollection.add(newMed.toMap());
      
    } catch (e) {
      rethrow; 
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  // 2. Stream Get Obat (Read) - Realtime!
  Stream<List<MedicationModel>> getMedications() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    // Ambil data hanya milik user yang login
    return _medCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MedicationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // ... di dalam class MedicationProvider ...

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
    } catch (e) {
      rethrow;
    }
  }
}