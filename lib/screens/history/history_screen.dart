import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Pastikan sudah add intl di pubspec.yaml
import '../../core/theme_app.dart';
import '../../providers/medication_provider.dart';
import '../../models/history_model.dart';
import '../../widgets/gradient_app_bar.dart';
g
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicationProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: const GradientAppBar(title: "Riwayat Minum Obat"),
      body: StreamBuilder<List<HistoryModel>>(
        stream: provider.getHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Error: ${snapshot.error}"),
            ));
          }

          final logs = snapshot.data ?? [];

          if (logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text("Belum ada riwayat", style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return _HistoryCard(log: log);
            },
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryModel log;

  const _HistoryCard({required this.log});

  @override
  Widget build(BuildContext context) {
    // Format Tanggal & Jam (Memerlukan package intl)
    final dateStr = DateFormat('EEEE, d MMM yyyy', 'id_ID').format(log.takenAt);
    final timeStr = DateFormat('HH:mm').format(log.takenAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: AppTheme.secondaryColor, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(log.medicationName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(log.dosage, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 8),
              Text(
                dateStr, // Tanggal
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
            ],
          ),
          Column(
            children: [
              const Icon(Icons.check_circle, color: AppTheme.secondaryColor),
              const SizedBox(height: 4),
              Text(
                timeStr, // Jam
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}