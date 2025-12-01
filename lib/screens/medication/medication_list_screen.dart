import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme_app.dart';
import '../../widgets/medication_card.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../models/medication_model.dart';
import '../../providers/medication_provider.dart';
import 'add_medication_screen.dart';

class MedicationListScreen extends StatelessWidget {
  const MedicationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Akses stream dari Provider
    final medProvider = Provider.of<MedicationProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: const GradientAppBar(
        title: "Manajemen Obat",
      ),
      body: Column(
        children: [
          // Bagian Header & Tombol (Tidak perlu discroll)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Daftar Obat Anda",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Kelola obat yang rutin Anda minum di sini.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddMedicationScreen()),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Tambah Obat Baru"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<MedicationModel>>(
              stream: medProvider.getMedications(), // Mengambil data realtime
              builder: (context, snapshot) {
                // 1. Kondisi Error
                if (snapshot.hasError) {
                  return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
                }

                // 2. Kondisi Loading (Saat awal buka)
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 3. Kondisi Kosong (Belum ada obat)
                final medications = snapshot.data ?? [];
                if (medications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.medication_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          "Belum ada obat",
                          style: TextStyle(color: Colors.grey[500], fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                // 4. Kondisi Ada Data -> Tampilkan List
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: medications.length,
                  itemBuilder: (context, index) {
                    final med = medications[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: MedicationCard(
                        name: med.name,
                        dosage: med.dosage,
                        frequency: med.frequency,
                        duration: med.duration,
                        onEdit: () {
                          // Buka halaman Add tapi bawa data (Mode Edit)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddMedicationScreen(medication: med),
                            ),
                          );
                        },
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Hapus Obat?"),
                              content: Text("Apakah Anda yakin ingin menghapus ${med.name}?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context), // Batal
                                  child: const Text("Batal"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Panggil Provider Delete
                                    Provider.of<MedicationProvider>(context, listen: false)
                                        .deleteMedication(med.id);
                                    Navigator.pop(context); // Tutup dialog
                                    
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Obat dihapus")),
                                    );
                                  },
                                  child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}