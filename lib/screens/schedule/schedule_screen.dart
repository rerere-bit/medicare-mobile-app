import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
              // Menggunakan Card yang sudah dimodifikasi
              return _ScheduleCardWithTimer(med: med);
            },
          );
        },
      ),
    );
  }
}

// Widget Baru: Kartu dengan Mini Timer
class _ScheduleCardWithTimer extends StatefulWidget {
  final MedicationModel med;

  const _ScheduleCardWithTimer({required this.med});

  @override
  State<_ScheduleCardWithTimer> createState() => _ScheduleCardWithTimerState();
}

class _ScheduleCardWithTimerState extends State<_ScheduleCardWithTimer> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;
  DateTime? _nextTime;

  @override
  void initState() {
    super.initState();
    _calculateNextTime();
    // Update timer setiap menit (agar tidak terlalu berat) atau detik
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) _updateCountdown();
    });
  }

  void _calculateNextTime() {
    final provider = Provider.of<MedicationProvider>(context, listen: false);
    setState(() {
      _nextTime = provider.getNextTimeForMedication(widget.med);
    });
    _updateCountdown();
  }

  void _updateCountdown() {
    if (_nextTime == null) return;
    
    final now = DateTime.now();
    final diff = _nextTime!.difference(now);

    if (diff.isNegative) {
      // Jika waktu lewat, hitung ulang jadwal berikutnya
      _calculateNextTime();
    } else {
      setState(() => _timeLeft = diff);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Format timer mini
    String hours = _timeLeft.inHours.toString().padLeft(2, '0');
    String minutes = _timeLeft.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = _timeLeft.inSeconds.remainder(60).toString().padLeft(2, '0');

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
      child: Column(
        children: [
          Row(
            children: [
              // Icon Obat
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.medication, color: Colors.blueAccent),
              ),
              const SizedBox(width: 16),
              
              // Info Obat
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.med.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text("${widget.med.dosage} • ${widget.med.frequency}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),

              // Tombol Check
              ElevatedButton(
                onPressed: () => _showConfirmDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981), // Warna hijau
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text("Minum", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          const Divider(),
          
          // --- BAGIAN COUNTDOWN BARU ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Jadwal Berikutnya:",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      "$hours : $minutes : $seconds",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: Text("Apakah Anda sudah meminum ${widget.med.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              
              await Provider.of<MedicationProvider>(context, listen: false).logMedicationIntake(
                medicationId: widget.med.id,
                medicationName: widget.med.name,
                dosage: widget.med.dosage,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${widget.med.name} tercatat sudah diminum!")),
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