import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/theme_app.dart';

class SummaryChart extends StatelessWidget {
  const SummaryChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Data Dummy: [Sen, Sel, Rab, Kam, Jum, Sab, Min]
    final List<int> weeklyData = [2, 4, 3, 5, 4, 2, 5]; 

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 6,
          // 1. Tambahkan Grid (Garis Bantu)
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1, // Garis setiap kelipatan 1
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            ),
          ),
          
          titlesData: FlTitlesData(
            show: true,
            // 2. Judul Bawah (Hari)
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                  if (value.toInt() < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        days[value.toInt()],
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            // 3. Judul Kiri (Angka Jumlah Obat) - KITA AKTIFKAN
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1, // Angka muncul setiap kelipatan 1
                reservedSize: 28, // Ruang untuk angka
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox(); // Hilangkan angka 0 biar bersih
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: weeklyData.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: AppTheme.secondaryColor,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  // Background abu-abu di belakang bar
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 6,
                    color: Colors.grey[100],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}