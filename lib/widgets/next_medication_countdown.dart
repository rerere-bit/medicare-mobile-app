import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medicare_mobile/models/medication_model.dart';
import 'package:medicare_mobile/providers/medication_provider.dart';

class NextMedicationCountdown extends StatefulWidget {
  const NextMedicationCountdown({super.key});

  @override
  State<NextMedicationCountdown> createState() => _NextMedicationCountdownState();
}

class _NextMedicationCountdownState extends State<NextMedicationCountdown> {
  @override
  Widget build(BuildContext context) {
    // Gunakan StreamProvider atau Consumer untuk mendapatkan data dari stream
    return StreamBuilder<List<MedicationModel>>(
      stream: Provider.of<MedicationProvider>(context, listen: false).getMedications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Memuat jadwal...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("Tidak ada jadwal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
        }

        final medications = snapshot.data!;
        final medicationProvider = Provider.of<MedicationProvider>(context, listen: false);
        final nextSchedule = medicationProvider.calculateNextSchedule(medications);

        if (nextSchedule == null) {
          return const Text("Tidak ada jadwal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
        }

        // Widget yang akan menampilkan countdown secara real-time
        return CountdownTimer(targetTime: nextSchedule);
      },
    );
  }
}

// Widget terpisah untuk menangani logika timer
class CountdownTimer extends StatefulWidget {
  final DateTime targetTime;
  const CountdownTimer({super.key, required this.targetTime});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  late Duration _remainingTime;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    // Update setiap detik
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemainingTime());
  }

  void _updateRemainingTime() {
    final now = DateTime.now();
    if (widget.targetTime.isAfter(now)) {
      setState(() {
        _remainingTime = widget.targetTime.difference(now);
      });
    } else {
      // Jika waktu target sudah lewat, hentikan timer
      _timer?.cancel();
      setState(() {
        _remainingTime = Duration.zero;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remainingTime == Duration.zero) {
      return const Text(
        "Waktunya minum obat!",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
      );
    }
    
    final hours = _remainingTime.inHours;
    final minutes = _remainingTime.inMinutes.remainder(60);
    final seconds = _remainingTime.inSeconds.remainder(60);

    String countdownText = '';
    if (hours > 0) {
      countdownText += '${hours}j ';
    }
    if (minutes > 0) {
      countdownText += '${minutes}m ';
    }
    countdownText += '${seconds}d';

    return Text(
      countdownText,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }
}
