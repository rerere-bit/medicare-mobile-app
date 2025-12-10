import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme_app.dart';
import '../../providers/medication_provider.dart';
import '../../services/notification_service.dart';

class AlarmScreen extends StatelessWidget {
  // Kita menerima payload (ID Obat) dari notifikasi
  final String? payload; 

  const AlarmScreen({super.key, this.payload});

  @override
  Widget build(BuildContext context) {
    // Parsing payload. Format payload kita set di Provider sebagai: "MedID"
    // Di sini kita bisa fetch detail obat jika mau, tapi untuk cepat kita tampilkan pesan umum.
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEF4444), Color(0xFFF87171)], // Merah Alert
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animasi Icon Lonceng (Sederhana)
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.elasticOut,
              builder: (context, double val, child) {
                return Transform.scale(
                  scale: val,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 10,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.notifications_active,
                  size: 80,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            const Text(
              "WAKTUNYA MINUM OBAT!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Jaga kesehatan Anda dengan meminum obat tepat waktu.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 60),

            // Tombol Aksi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  // Tombol SUDAH MINUM
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
                         // Aksi: Tutup Alarm & Log (Opsional bisa auto log di sini)
                         // Karena kita belum tahu detail obat di screen ini, kita arahkan ke Home
                         // atau sekadar tutup alarm.
                         Navigator.pop(context); 
                         // Jika mau log otomatis, harus fetch data obat by ID (payload) dulu.
                      },
                      icon: const Icon(Icons.check_circle, color: Color(0xFFEF4444)),
                      label: const Text(
                        "SAYA AKAN MINUM", 
                        style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 16)
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Tombol NANTI SAJA
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Ingatkan Nanti (Tutup)",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
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