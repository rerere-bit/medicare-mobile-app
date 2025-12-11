import 'package:flutter/material.dart';


class MedicationCard extends StatelessWidget {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final int color; // NEW: Terima Warna
  final String type; // NEW: Terima Tipe
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MedicationCard({
    super.key,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.color, // Wajib
    required this.type, // Wajib
    this.onEdit,
    this.onDelete,
  });

  // Helper untuk mengubah String tipe menjadi IconData
  IconData _getIconByType(String type) {
    switch (type) {
      case 'syrup': return Icons.local_drink;
      case 'injection': return Icons.vaccines;
      case 'powder': return Icons.grain;
      case 'pill':
      default: return Icons.medication;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Lebih bulat
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // --- VISUALISASI OBAT (UPDATED) ---
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(color).withOpacity(0.15), // Background transparan warna obat
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(color).withOpacity(0.3), width: 1),
                ),
                child: Icon(
                  _getIconByType(type),
                  color: Color(color), // Icon sesuai warna obat
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Detail Teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "$dosage • $frequency",
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Menu Options (Edit/Delete)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit?.call();
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')]),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))]),
                  ),
                ],
                child: const Icon(Icons.more_vert, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}