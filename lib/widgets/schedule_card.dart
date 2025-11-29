import 'package:flutter/material.dart';
import '../core/theme_app.dart';

class ScheduleCard extends StatelessWidget {
  final String medicineName;
  final String dosage;
  final String time;
  final String instruction; // "Sesudah makan" / "Sebelum makan"
  final bool isCompleted;
  final VoidCallback onTap;

  const ScheduleCard({
    super.key,
    required this.medicineName,
    required this.dosage,
    required this.time,
    required this.instruction,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: isCompleted ? AppTheme.secondaryColor : AppTheme.primaryColor,
            width: 6,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicineName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$dosage • $time",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline, size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        instruction,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isCompleted ? AppTheme.secondaryColor.withOpacity(0.1) : AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isCompleted ? AppTheme.secondaryColor : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.circle_outlined,
                    color: isCompleted ? AppTheme.secondaryColor : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCompleted ? "Selesai" : "Tandai",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? AppTheme.secondaryColor : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}