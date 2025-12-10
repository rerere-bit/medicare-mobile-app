import 'dart:async'; // Tambahan untuk Timer refresh UI
import 'package:flutter/material.dart';
import '../../core/theme_app.dart';
import '../../widgets/home_menu_card.dart';

import '../medication/medication_list_screen.dart';
import '../schedule/schedule_screen.dart';
import '../history/history_screen.dart';
// Import Profile Screen agar bisa dinavigasikan
import '../profile/profile_screen.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER DENGAN LOGIC COUNTDOWN
            Container(
              padding: const EdgeInsets.only(
                top: 60,
                left: 24,
                right: 24,
                bottom: 30,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
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
                    spreadRadius: -10,
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
                                Icon(Icons.verified_user, color: Colors.white, size: 14),
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
                            "Halo, Sehat Selalu!", // Bisa diganti dinamis nanti
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Tetap pantau obat Anda",
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileScreen()),
                          );
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
                            child: Icon(Icons.person, color: AppTheme.primaryColor),
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
                            color: const Color(0xFFEFF6FF),
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
                                "Cek Jadwal", // Placeholder text
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. GRID MENU (Tetap sama)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Menu Utama",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
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
                                builder: (context) => const MedicationListScreen()),
                          );
                        },
                      ),
                      HomeMenuCard(
                        title: "Jadwal",
                        icon: Icons.calendar_today_outlined,
                        color: Colors.lightBlue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ScheduleScreen()),
                          );
                        },
                      ),
                      HomeMenuCard(
                        title: "Riwayat",
                        icon: Icons.history,
                        color: AppTheme.secondaryColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HistoryScreen()),
                          );
                        },
                      ),
                      HomeMenuCard(
                        title: "Profil Saya",
                        icon: Icons.person,
                        color: Colors.orangeAccent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProfileScreen()),
                          );
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