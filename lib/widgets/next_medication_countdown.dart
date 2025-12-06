import 'dart:async';
import 'package:flutter/material.dart';

/// A widget that displays a real-time countdown to a specific target time.
class NextMedicationCountdown extends StatefulWidget {
  final DateTime targetTime;
  const NextMedicationCountdown({super.key, required this.targetTime});

  @override
  State<NextMedicationCountdown> createState() => _NextMedicationCountdownState();
}

class _NextMedicationCountdownState extends State<NextMedicationCountdown> {
  Timer? _timer;
  late Duration _remainingTime;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    // Update the countdown every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemainingTime());
  }

  void _updateRemainingTime() {
    final now = DateTime.now();
    // Ensure the target time is in the future
    if (widget.targetTime.isAfter(now)) {
      if (mounted) {
        setState(() {
          _remainingTime = widget.targetTime.difference(now);
        });
      }
    } else {
      // If the target time has passed, stop the timer and set duration to zero
      _timer?.cancel();
      if (mounted) {
        setState(() {
          _remainingTime = Duration.zero;
        });
      }
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

    // Build the countdown string
    String countdownText = 'Dalam ';
    if (hours > 0) {
      countdownText += '${hours}j ';
    }
    if (minutes > 0) {
      countdownText += '${minutes}m ';
    }
    // Always show seconds for a live feel
    countdownText += '${seconds}d';

    return Text(
      countdownText,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }
}
