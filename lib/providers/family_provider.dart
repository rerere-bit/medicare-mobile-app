import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Model sederhana untuk Connection
class ConnectionModel {
  final String id;
  final String familyId;
  final String familyName; // Nama Keluarga
  final String familyEmail;
  final String patientId;
  final String patientName; // Nama Pasien
  final String patientEmail;
  final String status; // 'pending', 'active', 'rejected'

  ConnectionModel({
    required this.id,
    required this.familyId,
    required this.familyName,
    required this.familyEmail,
    required this.patientId,
    required this.patientName,
    required this.patientEmail,
    required this.status,
  });

  factory ConnectionModel.fromMap(Map<String, dynamic> map, String id) {
    return ConnectionModel(
      id: id,
      familyId: map['familyId'] ?? '',
      familyName: map['familyName'] ?? '',
      familyEmail: map['familyEmail'] ?? '',
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      patientEmail: map['patientEmail'] ?? '',
      status: map['status'] ?? 'pending',
    );
  }
}

class FamilyProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _connCollection => _firestore.collection('connections');

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- SISI KELUARGA: KIRIM REQUEST ---
  Future<void> sendConnectionRequest(String patientEmail) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User tidak login");

      // 1. Cari data diri (Keluarga)
      final familyDoc = await _firestore.collection('users').doc(user.uid).get();
      final familyData = familyDoc.data()!;

      // 2. Cari data Pasien berdasarkan Email
      final patientQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: patientEmail)
          .where('role', isEqualTo: 'Pasien')
          .get();

      if (patientQuery.docs.isEmpty) {
        throw Exception("Email pasien tidak ditemukan.");
      }

      final patientDoc = patientQuery.docs.first;
      
      // 3. Cek apakah sudah ada request sebelumnya
      final existingCheck = await _connCollection
          .where('familyId', isEqualTo: user.uid)
          .where('patientId', isEqualTo: patientDoc.id)
          .get();

      if (existingCheck.docs.isNotEmpty) {
        throw Exception("Anda sudah mengirim permintaan ke pasien ini.");
      }

      // 4. Buat Dokumen Connection (Status: Pending)
      await _connCollection.add({
        'familyId': user.uid,
        'familyName': familyData['displayName'] ?? 'Keluarga',
        'familyEmail': user.email,
        'patientId': patientDoc.id,
        'patientName': patientDoc['displayName'] ?? 'Pasien',
        'patientEmail': patientDoc['email'],
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- SISI KELUARGA: AMBIL LIST PASIEN ---
  Stream<List<ConnectionModel>> getMyPatients() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    // Ambil yang statusnya 'active' saja untuk Home Screen
    return _connCollection
        .where('familyId', isEqualTo: user.uid)
        //.where('status', isEqualTo: 'active') // Bisa difilter di UI jika ingin lihat pending juga
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConnectionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // --- SISI PASIEN: AMBIL REQUEST MASUK ---
  Stream<List<ConnectionModel>> getIncomingRequests() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _connCollection
        .where('patientId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConnectionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // --- SISI PASIEN: TERIMA / TOLAK ---
  Future<void> respondToRequest(String connectionId, bool accept) async {
    if (accept) {
      await _connCollection.doc(connectionId).update({'status': 'active'});
    } else {
      await _connCollection.doc(connectionId).delete(); // Hapus jika tolak
    }
  }
  
  // --- SISI PASIEN: HAPUS KELUARGA (UNLINK) ---
  Future<void> removeCaregiver(String connectionId) async {
     await _connCollection.doc(connectionId).delete();
  }
}