import 'package:flutter/material.dart';
import '../core/theme_app.dart';

class FamilyCard extends StatelessWidget {
  final String name;
  final String role; // "Ayah", "Ibu"
  final int compliance; // 0 - 100
  final String status; // Info peringatan (misal: "2 dosis terlewat")
  final bool isWarning; // Jika true, background jadi agak merah
  final VoidCallback onRemind;

  const FamilyCard({
    super.key,
    required this.name,
    required this.role,
    required this.compliance,
    required this.status,
    required this.isWarning,
    required this.onRemind,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isWarning ? Border.all(color: AppTheme.errorColor, width: 1) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: const Icon(Icons.person, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(role, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              // Tombol Ingatkan
              OutlinedButton.icon(
                onPressed: onRemind,
                icon: const Icon(Icons.notifications_active_outlined, size: 16),
                label: const Text("Ingatkan"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isWarning ? AppTheme.errorColor : AppTheme.primaryColor,
                  side: BorderSide(color: isWarning ? AppTheme.errorColor : AppTheme.primaryColor),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar Kepatuhan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tingkat Kepatuhan", style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text("$compliance%", style: TextStyle(
                fontWeight: FontWeight.bold,
                color: compliance < 50 ? AppTheme.errorColor : AppTheme.secondaryColor
              )),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: compliance / 100,
            backgroundColor: Colors.grey[200],
            color: compliance < 50 ? AppTheme.errorColor : AppTheme.secondaryColor,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          
          // Status Text (Jika Warning)
          if (isWarning) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      status,
                      style: const TextStyle(color: AppTheme.errorColor, fontSize: 12),
                    ),
                  ),
                ],
              ),
            )
          ]
        ],
      ),
    );
  }
}