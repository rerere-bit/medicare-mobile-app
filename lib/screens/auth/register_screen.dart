import 'package:flutter/material.dart';
import '../../widgets/custom_textfield.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  
  String _selectedRole = 'Pasien';
  bool _isLoading = false;

  void _handleRegister() async {
    // 1. Validasi Input Dasar
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

    // 2. Validasi Password Match
    if (_passwordController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password konfirmasi tidak sama')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 3. Panggil Firebase Auth Create User
      await AuthService().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(), // Kirim Nama
        role: _selectedRole,               // Kirim Role (Pasien/Keluarga)
      );
      
      // Note: Di tahap selanjutnya, kita akan simpan "Nama" dan "Role" ke Firestore Database
      // Karena Auth hanya menyimpan Email & Password. 
      // Tapi untuk sekarang, kita fokus Auth dulu.

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi Berhasil! Silakan Login.')),
        );
        Navigator.pop(context); // Kembali ke Login Screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal Daftar: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kembali"), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ... Header sama seperti sebelumnya ...
              const Center(
                child: Icon(Icons.person_add_alt_1, size: 50, color: Colors.teal),
              ),
              const SizedBox(height: 16),
              const Text('Daftar Akun Baru', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),

              // Form
              CustomTextField(
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap',
                icon: Icons.person_outline,
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Email',
                hint: 'masukkan@email.com',
                icon: Icons.email_outlined,
                controller: _emailController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Password',
                hint: 'Buat password',
                isPassword: true,
                icon: Icons.lock_outline,
                controller: _passwordController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Konfirmasi Password',
                hint: 'Ketik ulang password',
                isPassword: true,
                icon: Icons.lock_outline,
                controller: _confirmPassController,
              ),
              const SizedBox(height: 16),

              // Role Dropdown
              Text('Daftar Sebagai', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    isExpanded: true,
                    items: <String>['Pasien', 'Keluarga'].map((String value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                    onChanged: (newValue) => setState(() => _selectedRole = newValue!),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}