// Lokasi: lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream status user
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login
  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Register
  Future<void> signUp({required String email, required String password}) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}