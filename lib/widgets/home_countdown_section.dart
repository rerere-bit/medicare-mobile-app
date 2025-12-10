import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medicare_mobile/core/theme_app.dart'; 
import 'package:medicare_mobile/providers/medication_provider.dart';
import 'package:medicare_mobile/models/medication_model.dart';
import 'package:medicare_mobile/widgets/next_medication_countdown.dart';

class HomeCountdownSection extends StatelessWidget {
  const HomeCountdownSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Dengarkan perubahan data obat secara realtime
    return StreamBuilder<List<MedicationModel>>(
      stream: Provider.of<MedicationProvider>(context, listen: false).getMedications(),
      builder: (context, snapshot) {
        
        final provider = Provider.of<MedicationProvider>(context, listen: false);
        final medications = snapshot.data ?? [];
        
        // Hitung jadwal berikutnya
        NextScheduleData? nextSchedule = provider.calculateNextSchedule(medications);

        // --- VARIABEL TAMPILAN ---
        String titleText = "Tidak ada jadwal";
        Widget subtitleWidget = const Text("Anda bebas obat hari ini", style: TextStyle(color: Colors.grey));
        Color iconColor = Colors.grey;
        Color boxColor = Colors.grey.shade100;
        IconData iconData = Icons.check_circle_outline;

        // Jika ada jadwal obat
        if (nextSchedule != null) {
          titleText = "Minum ${nextSchedule.medName}";
          iconColor = AppTheme.primaryColor; // Atau Colors.blue
          boxColor = const Color(0xFFEFF6FF); // Biru muda
          iconData = Icons.medication;
          
          // Gunakan Widget Countdown Anda yang sudah canggih
          subtitleWidget = NextMedicationCountdown(targetTime: nextSchedule.time);
        }

        // --- RENDER UI (CARD PUTIH) ---
        return Container(
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
              // Icon Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: boxColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              
              // Teks Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pengingat Berikutnya",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Widget Countdown Realtime
                    DefaultTextStyle(
                      style: TextStyle(
                        color: nextSchedule != null ? Colors.redAccent : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Roboto', // Sesuaikan font default
                      ),
                      child: subtitleWidget, 
                    ),
                    const SizedBox(height: 2),
                    Text(
                      titleText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}