import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getter User saat ini
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Fungsi Login (Tetap sama)
  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // --- FUNGSI REGISTER DIUPDATE ---
  // Sekarang menerima nama dan role untuk disimpan ke Firestore
  Future<void> signUp({
    required String email, 
    required String password,
    required String name,
    required String role,
  }) async {
    // 1. Buat Akun Auth
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = result.user;
    if (user == null) return;

    // 2. Simpan Data Profil ke Firestore collection 'users'
    await _firestore.collection('users').doc(user.uid).set({
      'email': email,
      'displayName': name,
      'role': role, // Penting: Menyimpan status Pasien/Keluarga
      'createdAt': DateTime.now().toIso8601String(),
    });

    // 3. Update Display Name di Auth (Opsional, agar mudah diakses)
    await user.updateDisplayName(name);
  }

  // Fungsi Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- BARU: Ambil Data Lengkap User dari Firestore ---
  Future<UserModel?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data() as Map<String, dynamic>, user.uid);
  }
}