import 'package:flutter/material.dart';
import '../../core/theme_app.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _userModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Ambil data user dari Firestore via AuthService
  Future<void> _loadUserData() async {
    final data = await AuthService().getUserData();
    if (mounted) {
      setState(() {
        _userModel = data;
        _isLoading = false;
      });
    }
  }

  // Fungsi Edit Nama
  void _showEditNameDialog() {
    final nameController = TextEditingController(text: _userModel?.displayName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ubah Nama"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Nama Lengkap"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (nameController.text.trim().isEmpty) return;

              // Proses Update
              setState(() => _isLoading = true);
              try {
                await AuthService().updateProfile(name: nameController.text.trim());
                await _loadUserData(); // Refresh data setelah update
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil diperbarui!")));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // Fungsi Logout
  void _handleLogout() async {
    // Tampilkan konfirmasi
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Keluar Aplikasi?"),
        content: const Text("Anda harus login kembali untuk mengakses data."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Tutup dialog
              await AuthService().signOut();
              
              if (mounted) {
                // Reset ke halaman Login & hapus semua route belakang
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Fallback jika data gagal load
    if (_userModel == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profil")),
        body: const Center(child: Text("Gagal memuat data profil")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Profil Saya"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. FOTO & NAMA
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: Text(
                          _userModel!.displayName.isNotEmpty ? _userModel!.displayName[0].toUpperCase() : "?",
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showEditNameDialog,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppTheme.secondaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userModel!.displayName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _userModel!.role == 'Keluarga' ? Colors.orange[100] : Colors.blue[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Role: ${_userModel!.role}",
                      style: TextStyle(
                        color: _userModel!.role == 'Keluarga' ? Colors.orange[800] : Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // 2. DATA AKUN
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  _ProfileInfoRow(icon: Icons.email, label: "Email", value: _userModel!.email),
                  const Divider(height: 32),
                  _ProfileInfoRow(icon: Icons.badge, label: "User ID", value: _userModel!.uid.substring(0, 8).toUpperCase()),
                  const Divider(height: 32),
                  _ProfileInfoRow(icon: Icons.calendar_today, label: "Bergabung", value: "Member Medicare"),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 3. TOMBOL KELUAR & VERSI
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                label: const Text("Keluar Aplikasi"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Versi Aplikasi 1.0.0", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// Widget Kecil Helper
class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.grey[600], size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ],
    );
  }
}