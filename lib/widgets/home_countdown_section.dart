import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medicare_mobile/providers/medication_provider.dart';
import 'package:medicare_mobile/models/medication_model.dart';
import 'package:medicare_mobile/widgets/next_medication_countdown.dart'; // Pastikan path ini benar

class HomeCountdownSection extends StatelessWidget {
  const HomeCountdownSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MedicationModel>>(
      stream: Provider.of<MedicationProvider>(context, listen: false).getMedications(),
      builder: (context, snapshot) {
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text(
            "Belum ada jadwal obat",
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          );
        }

        final medications = snapshot.data!;
        final provider = Provider.of<MedicationProvider>(context, listen: false);
        
        // Dapatkan data lengkap (Waktu + Nama)
        NextScheduleData? nextSchedule = provider.calculateNextSchedule(medications);

        if (nextSchedule == null) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // UPDATE: Menampilkan Nama Obat
            Row(
              children: [
                const Icon(Icons.label_important, size: 16, color: Colors.blueAccent),
                const SizedBox(width: 4),
                Text(
                  nextSchedule.medName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                Text(
                  " (${nextSchedule.dosage})",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Widget Countdown lama Anda
            NextMedicationCountdown(targetTime: nextSchedule.time),
          ],
        );
      },
    );
  }
}