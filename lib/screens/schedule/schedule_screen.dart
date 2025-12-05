  import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme_app.dart';
import '../../providers/medication_provider.dart';
import '../../models/medication_model.dart';
import '../../widgets/gradient_app_bar.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medProvider = Provider.of<MedicationProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: const GradientAppBar(title: "Jadwal Minum Obat"),
      body: StreamBuilder<List<MedicationModel>>(
        stream: medProvider.getMedications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final meds = snapshot.data ?? [];

          if (meds.isEmpty) {
            return const Center(child: Text("Tidak ada jadwal obat hari ini"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: meds.length,
            itemBuilder: (context, index) {
              final med = meds[index];
              return _ScheduleCard(med: med);
            },
          );
        },
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final MedicationModel med;

  const _ScheduleCard({required this.med});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Icon Obat
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medication, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          
          // Info Obat
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text("${med.dosage} • ${med.frequency}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),

          // Tombol CHECK (Minum)
          ElevatedButton(
            onPressed: () {
              // Panggil Fungsi Log
              _showConfirmDialog(context, med);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text("Minum", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, MedicationModel med) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: Text("Apakah Anda sudah meminum ${med.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Tutup dialog
              
              // Simpan ke History via Provider
              await Provider.of<MedicationProvider>(context, listen: false).logMedicationIntake(
                medicationId: med.id,
                medicationName: med.name,
                dosage: med.dosage,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${med.name} tercatat sudah diminum!")),
                );
              }
            },
            child: const Text("Ya, Sudah"),
          ),
        ],
      ),
    );
  }
}