import 'package:flutter/material.dart';
import 'package:medicare_mobile/models/user_model.dart';
import 'package:medicare_mobile/services/auth_service.dart';
import 'package:medicare_mobile/screens/home/patient_home_screen.dart';
import 'package:medicare_mobile/screens/home/family_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkRoleAndNavigate();
  }

  Future<void> _checkRoleAndNavigate() async {
    try {
      final UserModel? user = await _authService.getUserData();
      if (mounted && user != null) {
        if (user.role == 'Pasien') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PatientHomeScreen()),
          );
        } else if (user.role == 'Keluarga') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FamilyHomeScreen()),
          );
        } else {
          // Fallback or error handling if role is not recognized
          // For now, let's navigate to a generic error screen or login
          // To prevent loops, let's just show an error in the UI
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Peran pengguna tidak dikenali.')),
          );
        }
      }
    } catch (e) {
      // Handle error, e.g., show a snackbar or navigate to login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data pengguna: $e')),
        );
        // Optionally, navigate back to login
        // Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while checking the user's role
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
