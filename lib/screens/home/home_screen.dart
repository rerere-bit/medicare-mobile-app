import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import 'patient_home_screen.dart'; 
import 'family_home_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variabel untuk menampung data user & status loading
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  // Fungsi untuk mengecek Role dari Firestore
  void _checkUserRole() async {
    final user = await AuthService().getUserData();
    
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Tampilkan Loading saat sedang mengambil data
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. Jika Data Kosong (Error), kembalikan ke UI Pasien sebagai default/fallback
    if (_currentUser == null) {
       return const PatientHomeScreen(); 
    }

    // 3. LOGIKA UTAMA: Pilih Layar berdasarkan Role
    if (_currentUser!.role == 'Keluarga') {
      return const FamilyHomeScreen();
    } else {
      // Default: Pasien
      return const PatientHomeScreen();
    }
  }
}