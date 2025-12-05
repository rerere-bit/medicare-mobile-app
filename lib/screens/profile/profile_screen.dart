import 'package:flutter/material.dart';
import '../../core/theme_app.dart';
import '../auth/login_screen.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER CUSTOM (Lebih Pendek & Berpola)
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Background Gradient
                Container(
                  height: 160, // KITA KURANGI TINGGINYA (Tadi 220)
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryColor, Color(0xFF60A5FA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Dekorasi Lingkaran 1 (Biar tidak polos)
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Dekorasi Lingkaran 2
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      
                      // Judul & Tombol Back
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const Text(
                                "Profil Saya",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Spacer kosong biar teks benar-benar di tengah (karena ada icon back di kiri)
                              const SizedBox(width: 48), 
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Foto Profil Melayang (Circle Avatar)
                Positioned(
                  bottom: -50, 
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                         BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
                      ]
                    ),
                    child: Stack(
                      children: [
                        const CircleAvatar(
                          radius: 55, // Ukuran sedikit disesuaikan
                          backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                          backgroundColor: Colors.grey,
                        ),
                        // Tombol Edit Kecil
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppTheme.secondaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                              ]
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Spacer disesuaikan agar konten tidak tertabrak foto
            const SizedBox(height: 60),

            // Nama & Email
            const Text(
              "Bunda Sari",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "sari@example.com",
              style: TextStyle(color: Colors.grey),
            ),
            
            const SizedBox(height: 24),

            // 2. KONTEN MENU (Card Groups) - SAMA SEPERTI SEBELUMNYA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // CARD 1: Info Pribadi
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildProfileItem(Icons.phone, "Nomor Telepon", "081234567890"),
                        const Divider(height: 1, indent: 60, color: Color(0xFFF3F4F6)),
                        _buildProfileItem(Icons.cake, "Tanggal Lahir", "15 Mei 1960"),
                        const Divider(height: 1, indent: 60, color: Color(0xFFF3F4F6)),
                        _buildProfileItem(Icons.location_on, "Alamat", "Jl. Mawar No. 12, Jakarta"),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // CARD 2: Pengaturan
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.text_fields, color: Colors.blue),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Text("Ukuran Teks", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text("Normal", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, indent: 60, color: Color(0xFFF3F4F6)),
                        _buildSwitchItem(Icons.notifications_active, "Notifikasi Obat", true),
                        const Divider(height: 1, indent: 60, color: Color(0xFFF3F4F6)),
                        _buildSwitchItem(Icons.dark_mode, "Mode Gelap", false),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Tombol Logout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false, // false artinya: hapus semua halaman sebelumnya
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE2E2),
                        foregroundColor: AppTheme.errorColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text("Keluar dari Akun"),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
      trailing: const Icon(Icons.edit, size: 16, color: Colors.grey),
    );
  }

  Widget _buildSwitchItem(IconData icon, String title, bool value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: value ? Colors.green[50] : Colors.grey[100], borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: value ? AppTheme.secondaryColor : Colors.grey),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: Switch(
        value: value, 
        activeColor: AppTheme.secondaryColor,
        onChanged: (val) {},
      ),
    );
  }
}