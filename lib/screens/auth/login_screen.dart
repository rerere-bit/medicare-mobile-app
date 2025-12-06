import 'package:flutter/material.dart';
import '../../core/theme_app.dart';
import '../../widgets/custom_textfield.dart';
import 'register_screen.dart'; 
import '../../services/auth_service.dart';
import '../home/home_screen.dart'; // Gerbang utama (Controller Role)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email dan Password wajib diisi')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Login ke Firebase Auth
      await AuthService().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. JANGAN MEMILIH HALAMAN SECARA MANUAL DI SINI.
      // Biarkan HomeScreen yang mengecek Role ke Database.
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Container(
                  height: 100, width: 100,
                  decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                  child: const Icon(Icons.monitor_heart, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Medicare', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Masuk untuk melanjutkan', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 48),

              CustomTextField(
                label: 'Email', hint: 'email@contoh.com', icon: Icons.email_outlined, controller: _emailController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Password', hint: '********', isPassword: true, icon: Icons.lock_outline, controller: _passwordController,
              ),
              
              const SizedBox(height: 32),

              // Tombol Masuk
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                  : const Text('Masuk'),
              ),
              
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Daftar Akun Baru'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}