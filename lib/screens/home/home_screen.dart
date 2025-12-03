import 'package:flutter/material.dart';
import '../../core/theme_app.dart';
import '../../widgets/home_menu_card.dart';

import '../medication/medication_list_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER BARU (Level-up Design)
            Container(
              padding: const EdgeInsets.only(
                top: 60,
                left: 24,
                right: 24,
                bottom: 30,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  // Biru yang lebih dalam dan premium
                  colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                    spreadRadius: -10, // Efek bayangan halus
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge Status (Mirip Family Screen)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.verified_user,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Mode Pasien",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            "Halo, Bunda Sari!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Kamis, 27 November 2025",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      // Foto Profil (Navigasi ke Profile)
                      GestureDetector(
                        onTap: () {
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(
                              'https://i.pravatar.cc/300',
                            ), // Dummy Foto
                            child: Icon(
                              Icons.person,
                              color: AppTheme.primaryColor,
                            ), // Fallback jika gagal load
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Card Pengingat Berikutnya (Floating Effect)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF), // Biru sangat muda
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.medication,
                            color: AppTheme.primaryColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Pengingat Berikutnya",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Amlodipine - 5mg",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "Sesudah makan",
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "20:00",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Ringkasan Jadwal & Menu (Sisa Body tetap sama)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Status Hari Ini",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Progress Bar yang lebih cantik
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "1 dari 3 Obat Diminum",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "33%",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: 0.33,
                            backgroundColor: Colors.grey[100],
                            color: AppTheme.secondaryColor,
                            minHeight: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Grid Menu Utama
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      HomeMenuCard(
                        title: "Obat Saya",
                        icon: Icons.medical_services_outlined,
                        color: Colors.blueAccent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MedicationListScreen(),
                            ),
                          );
                        },
                      ),
                      HomeMenuCard(
                        title: "Jadwal",
                        icon: Icons.calendar_today_outlined,
                        color: Colors.lightBlue,
                        onTap: () {
                  
                        },
                      ),
                      HomeMenuCard(
                        title: "Riwayat",
                        icon: Icons.history,
                        color: AppTheme.secondaryColor,
                        onTap: () {
                          
                        },
                      ),
                      HomeMenuCard(
                        title: "Keluarga",
                        icon: Icons.family_restroom,
                        color: Colors.orangeAccent,
                        onTap: () {
                        
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
