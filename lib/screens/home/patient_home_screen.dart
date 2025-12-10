import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme_app.dart';
import '../../models/medication_model.dart';
import '../../providers/medication_provider.dart';
import '../../widgets/home_menu_card.dart';
// Import Widget Countdown
import '../../widgets/home_countdown_section.dart';

// Import Screen Navigasi
import '../medication/medication_list_screen.dart';
import '../schedule/schedule_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart'; 
import 'patient_caregiver_screen.dart'; // Import Screen Keluarga

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  
  @override
  void initState() {
    super.initState();
    // Cek Obat Kadaluarsa setelah build selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExpiredMeds();
    });
  }

  void _checkExpiredMeds() async {
    final provider = Provider.of<MedicationProvider>(context, listen: false);
    // Ambil data snapshot sekali saja
    // (Dalam app real, mungkin lebih baik listen stream, tapi ini cukup untuk check on open)
    // Kita gunakan data yang sudah ada di stream atau fetch manual simple
    // Karena provider.getMedications() return Stream, kita tidak bisa await list-nya langsung di sini dengan mudah tanpa listen.
    // Solusi simple: Kita tidak blocking UI, biarkan user berinteraksi.
    // Atau kita bisa panggil fungsi helper di Provider jika ada.
    
    // Tapi karena kita tidak mau logic rumit di initState, 
    // kita bisa pasang logic ini di dalam StreamBuilder widget di bawah,
    // ATAU biarkan user yang sadar saat melihat list obat (fitur ini opsional tapi bagus).
    
    // Alternatif: Gunakan StreamSubscription di initState (Cleanest way)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER (Gradient Blue)
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
                            "Halo, Sehat Selalu!",
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
                      
                      // --- FOTO PROFIL (KEMBALI KE PROFILE SCREEN) ---
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

                  // --- WIDGET PENGINGAT DINAMIS ---
                  const HomeCountdownSection(),
                  // --------------------------------
                ],
              ),
            ),

            // --- LOGIC CEK EXPIRED (DISISIPKAN DI SINI) ---
            StreamBuilder<List<MedicationModel>>(
              stream: Provider.of<MedicationProvider>(context).getMedications(), // Listen realtime
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                
                final provider = Provider.of<MedicationProvider>(context, listen: false);
                final expiredMeds = provider.getExpiredMedications(snapshot.data!);

                if (expiredMeds.isEmpty) return const SizedBox.shrink();

                // Jika ada obat expired, tampilkan Card Alert di Home
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange),
                          SizedBox(width: 8),
                          Text("Pengobatan Selesai", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("Obat berikut telah melewati durasi pengobatan (${expiredMeds.length} obat).", style: TextStyle(fontSize: 12, color: Colors.orange[800])),
                      const SizedBox(height: 12),
                      ...expiredMeds.map((med) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("• ${med.name}", style: const TextStyle(fontWeight: FontWeight.w600)),
                            TextButton(
                              onPressed: () {
                                // Dialog Konfirmasi Hapus
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Hapus Obat?"),
                                    content: Text("Apakah Anda ingin menghapus ${med.name} dari daftar karena durasi pengobatan telah selesai?"),
                                    actions: [
                                      TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text("Batal")),
                                      TextButton(
                                        onPressed: () {
                                          provider.deleteMedication(med.id);
                                          Navigator.pop(ctx);
                                        },
                                        child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                foregroundColor: Colors.red
                              ),
                              child: const Text("Hapus"),
                            )
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                );
              },
            ),
            // -----------------------------------------------

            // 2. GRID MENU UTAMA
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
                      // MENU 1: OBAT
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
                      // MENU 2: JADWAL
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
                      // MENU 3: RIWAYAT
                      HomeMenuCard(
                        title: "Riwayat",
                        icon: Icons.history,
                        color: AppTheme.secondaryColor, // Hijau Teal
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HistoryScreen()),
                          );
                        },
                      ),
                      
                      // MENU 4: PENDAMPING (MENGGANTIKAN PROFIL SAYA)
                      HomeMenuCard(
                        title: "Pendamping",
                        icon: Icons.family_restroom_rounded, 
                        color: Colors.purpleAccent, // Ganti warna agar beda
                        onTap: () {
                          // Membuka Layar Keluarga/Caregiver
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PatientCaregiverScreen()),
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
