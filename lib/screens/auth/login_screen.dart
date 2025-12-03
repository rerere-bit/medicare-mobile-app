import 'package:flutter/material.dart';
import '../../core/theme_app.dart';
import '../../widgets/custom_textfield.dart';
import 'register_screen.dart'; 
import '../../services/auth_service.dart';
import '../../screens/home/home_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Siapkan Controller untuk mengambil text input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // 2. State untuk loading & Role
  bool _isLoading = false;
  String _selectedRole = 'Pasien'; 

  // 3. Fungsi Login
void _handleLogin() async {
    // 1. Validasi Input
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan Password tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Proses Login ke Firebase
      await AuthService().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 3. JIKA SUKSES -> PINDAH HALAMAN (Bagian ini yang mungkin hilang)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Berhasil!')),
        );

        // Navigasi ke HomeScreen dan hapus riwayat Login agar tidak bisa di-back
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }

    } catch (e) {
      // Jika Gagal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal Login: ${e.toString()}')),
        );
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
              const SizedBox(height: 40),
              // Logo & Header (Sama seperti sebelumnya)
              Center(
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.monitor_heart, size: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Medicare',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pengingat Obat untuk Kesehatan Anda',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Form Input dengan Controller
              CustomTextField(
                label: 'Email',
                hint: 'masukkan@email.com',
                icon: Icons.email_outlined,
                controller: _emailController, // Pasang controller
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Password',
                hint: 'Masukkan password',
                isPassword: true,
                icon: Icons.lock_outline,
                controller: _passwordController, // Pasang controller
              ),
              const SizedBox(height: 20),

              // Dropdown Role
              Text('Masuk Sebagai', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    isExpanded: true,
                    items: <String>['Pasien', 'Keluarga'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) => setState(() => _selectedRole = newValue!),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Tombol Masuk dengan Loading Indicator
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin, // Disable jika loading
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white)) 
                  : const Text('Masuk'),
              ),
              
              const SizedBox(height: 16),
              
              // Tombol Daftar (Sudah dinavigasikan)
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Daftar Akun Baru', style: TextStyle(color: Colors.black87)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}