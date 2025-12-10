import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
//import '../../core/theme_app.dart';
import '../../providers/medication_provider.dart';
import '../../models/medication_model.dart';
import '../../models/history_model.dart';
import '../../widgets/schedule_card.dart'; // Pastikan widget ini ada

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicationProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Jadwal Minum Obat", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                    });
                  },
                ),
                Text(
                  DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.add(const Duration(days: 1));
                    });
                  },
                ),
              ],
            ),
          ),
          
          Expanded(
            child: StreamBuilder<List<MedicationModel>>(
              stream: provider.getMedications(),
              builder: (context, snapMeds) {
                // ... (StreamBuilder History SAMA) ...
                return StreamBuilder<List<HistoryModel>>(
                  stream: provider.getHistory(),
                  builder: (context, snapHistory) {
                    
                    if (snapMeds.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final meds = snapMeds.data ?? [];
                    final history = snapHistory.data ?? [];
                    final dailyLogs = history.where((h) => 
                      h.takenAt.year == _selectedDate.year &&
                      h.takenAt.month == _selectedDate.month &&
                      h.takenAt.day == _selectedDate.day
                    ).toList();

                    List<Map<String, dynamic>> scheduleItems = [];

                    for (var med in meds) {
                      // --- LOGIC 1: CEK DURASI (STOP LOOP INFINITE) ---
                      // Jika tanggal yang dipilih (_selectedDate) sudah lewat durasi obat, SKIP.
                      if (provider.isMedicationExpired(med, _selectedDate)) {
                        continue; // Jangan buat jadwal untuk obat ini
                      }

                      // ... (Logic Generate Times SAMA) ...
                      List<TimeOfDay> times = [];
                      if (med.timeSlots.isNotEmpty) {
                         times = med.timeSlots.map((s) {
                           final p = s.split(':');
                           return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
                         }).toList();
                      } else {
                         // Fallback logic
                         if (med.frequency.contains('1x')) times = [const TimeOfDay(hour: 8, minute: 0)];
                         else if (med.frequency.contains('2x')) times = [const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 20, minute: 0)];
                         else times = [const TimeOfDay(hour: 8, minute: 0)];
                      }

                      for (var t in times) {
                        // ... (Logic DateTime & Completed Check SAMA) ...
                        final scheduleDateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, t.hour, t.minute);
                        bool isCompleted = provider.isScheduleTaken(med.id, scheduleDateTime, dailyLogs);
                        bool isToday = DateFormat('yyyyMMdd').format(DateTime.now()) == DateFormat('yyyyMMdd').format(_selectedDate);
                        String? lockReason;
                        if (isToday && !isCompleted) {
                           lockReason = provider.canTakeNow(scheduleDateTime);
                        } else if (!isToday && !isCompleted) {
                           lockReason = "Bukan jadwal hari ini";
                        }

                        scheduleItems.add({
                          'med': med,
                          'time': t,
                          'dateTime': scheduleDateTime,
                          'isCompleted': isCompleted,
                          'lockReason': lockReason,
                        });
                      }
                    }

                    // ... (Sort & Empty Check SAMA) ...
                    scheduleItems.sort((a, b) => (a['dateTime'] as DateTime).compareTo(b['dateTime'] as DateTime));

                    if (scheduleItems.isEmpty) {
                      return Center(child: Text("Tidak ada jadwal obat pada tanggal ini", style: TextStyle(color: Colors.grey[500])));;
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: scheduleItems.length,
                      itemBuilder: (context, index) {
                        final item = scheduleItems[index];
                        final MedicationModel med = item['med'];
                        // ... (Vars Lainnya SAMA) ...

                        return Opacity(
                          opacity: (item['isCompleted'] || item['lockReason'] != null) ? 0.7 : 1.0,
                          child: ScheduleCard(
                            // ... (Params SAMA) ...
                            medicineName: med.name,
                            dosage: med.dosage,
                            time: "${item['time'].hour.toString().padLeft(2,'0')}:${item['time'].minute.toString().padLeft(2,'0')}",
                            instruction: med.instruction,
                            isCompleted: item['isCompleted'],
                            onTap: () async {
                              // ... (Lock Check SAMA) ...
                              if (item['isCompleted']) return;
                              if (item['lockReason'] != null) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(item['lockReason']!), backgroundColor: Colors.orange, duration: const Duration(seconds: 1)));
                                return;
                              }

                              // --- EKSEKUSI MINUM DENGAN CEK STOK (BARU) ---
                              try {
                                // Panggil fungsi provider yang baru (return IntakeResult)
                                final result = await provider.logMedicationIntake(
                                  medicationId: med.id,
                                  medicationName: med.name,
                                  dosage: med.dosage,
                                );

                                if (mounted) {
                                  // Tampilkan Pesan Sukses
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result.message),
                                      backgroundColor: result.isStockLow ? Colors.red : Colors.green, // Merah jika stok tipis/habis
                                      duration: const Duration(seconds: 2),
                                    )
                                  );

                                  // Jika Stok Habis/Menipis -> Tampilkan Dialog Peringatan Keras
                                  if (result.isStockLow) {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text(result.remainingStock == 0 ? "Stok Habis!" : "Stok Menipis"),
                                        content: Text(
                                          result.remainingStock == 0 
                                            ? "Obat ${med.name} telah habis. Segera lakukan pengisian ulang agar jadwal tidak terlewat."
                                            : "Sisa stok ${med.name} tinggal ${result.remainingStock}. Siapkan stok baru."
                                        ),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Baik, Saya Mengerti"))
                                        ],
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                                }
                              }
                            },
                          ),
                        );
                      },
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
