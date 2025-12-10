import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
//import '../../core/theme_app.dart';
import '../../providers/medication_provider.dart';
import '../../models/medication_model.dart';
import '../../models/history_model.dart';
import '../medication/add_medication_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;
  final String name;

  const PatientDetailScreen({
    super.key,
    required this.patientId, 
    required this.name,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Column(
        children: [
          // 1. HEADER (Hijau Emerald untuk Keluarga)
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF34D399)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                 BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
              ]
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Monitoring Pasien",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // 1. AVATAR (Tetap)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white30,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text(
                          widget.name.isNotEmpty ? widget.name[0].toUpperCase() : "?",
                          style: const TextStyle(fontSize: 24, color: Color(0xFF059669), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // 2. KOLOM NAMA & STATUS (DIBUNGKUS EXPANDED)
                    Expanded( // <--- TAMBAHKAN WIDGET INI
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: const TextStyle(
                              color: Colors.white, 
                              fontSize: 20, 
                              fontWeight: FontWeight.bold
                            ),
                            // Agar teks panjang jadi "Muhamm..." bukan error
                            overflow: TextOverflow.ellipsis, 
                            maxLines: 2, 
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "Status: Dipantau", 
                              style: TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: const Color(0xFF059669),
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              padding: const EdgeInsets.all(6),
              indicator: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFF059669).withOpacity(0.3)),
              ),
              tabs: const [
                Tab(text: "Daftar Obat"), // GANTI DARI STATUS KE DAFTAR OBAT
                Tab(text: "Analitik"), 
                Tab(text: "Riwayat"),    
              ],
            ),
          ),

          // 3. Konten
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _MedicationListTab(patientId: widget.patientId), // WIDGET BARU
                _AnalyticsTab(patientId: widget.patientId),
                _HistoryListTab(patientId: widget.patientId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 1: DAFTAR OBAT (INVENTORY VIEW)
// ============================================================================
class _MedicationListTab extends StatelessWidget {
  final String patientId;
  const _MedicationListTab({required this.patientId});

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
    final provider = Provider.of<MedicationProvider>(context, listen: false);

    return Scaffold( // Bungkus dengan Scaffold agar bisa pakai FAB di dalam tab
      backgroundColor: Colors.transparent,
      
      // TOMBOL TAMBAH OBAT UNTUK KELUARGA
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Buka Screen Add Medication dengan membawa ID PASIEN
          // Agar obat tersimpan di akun pasien, bukan di akun keluarga
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMedicationScreen(
                targetUserId: patientId, // INI KUNCINYA
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF059669),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Obat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      
      body: StreamBuilder<List<MedicationModel>>(
        // ... (StreamBuilder tetap sama seperti sebelumnya) ...
        stream: provider.getMedicationsByUserId(patientId),
        builder: (context, snapshot) {
           // ... (Logic Loading, Empty, Listview SAMA) ...
           if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
           final meds = snapshot.data ?? [];
           
           if (meds.isEmpty) {
             return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text("Pasien belum memiliki daftar obat.", style: TextStyle(color: Colors.grey[500])),
                    // Tidak perlu tombol di sini karena sudah ada FAB
                  ],
                ),
              );
           }
           
           return ListView.builder(
             padding: const EdgeInsets.fromLTRB(20, 20, 20, 80), // Padding bawah lebih besar agar tidak tertutup FAB
             itemCount: meds.length,
             itemBuilder: (context, index) {
               // ... (Widget Item List Obat SAMA seperti sebelumnya) ...
               // Gunakan kode ExpansionTile yang sudah Anda miliki
               final med = meds[index];
               String scheduleText = med.frequency;
               if (med.timeSlots.isNotEmpty) {
                 scheduleText = med.timeSlots.join(', ');
               }
               
               return Container(
                 margin: const EdgeInsets.only(bottom: 12),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(16),
                   boxShadow: [
                     BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
                   ],
                 ),
                 child: ExpansionTile(
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide.none),
                   collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide.none),
                   leading: Container(
                     width: 50,
                     height: 50,
                     decoration: BoxDecoration(
                       color: Color(med.color).withOpacity(0.15),
                       shape: BoxShape.circle,
                     ),
                     child: Icon(_getIconByType(med.type), color: Color(med.color)),
                   ),
                   title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                   subtitle: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text("${med.dosage} • ${med.instruction}", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                       const SizedBox(height: 4),
                       // Badge Stok
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                         decoration: BoxDecoration(
                           color: med.stock < 5 ? Colors.red[50] : Colors.blue[50],
                           borderRadius: BorderRadius.circular(6),
                           border: Border.all(color: med.stock < 5 ? Colors.red[200]! : Colors.blue[200]!),
                         ),
                         child: Text(
                           "Sisa Stok: ${med.stock}",
                           style: TextStyle(
                             fontSize: 10, 
                             fontWeight: FontWeight.bold,
                             color: med.stock < 5 ? Colors.red[800] : Colors.blue[800],
                           ),
                         ),
                       )
                     ],
                   ),
                   children: [
                     Padding(
                       padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           const Divider(),
                           _detailRow(Icons.access_time, "Jadwal", scheduleText),
                           const SizedBox(height: 8),
                           _detailRow(Icons.notes, "Catatan", med.notes.isNotEmpty ? med.notes : "-"),
                           const SizedBox(height: 8),
                           _detailRow(Icons.calendar_today, "Durasi", med.duration),
                         ],
                       ),
                     )
                   ],
                 ),
               );
             },
           );
        },
      ),
    );
  }
  
  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
      ],
    );
  }
}

// ============================================================================
// TAB 2: ANALITIK (KEPATUHAN & PERINGATAN)
// ============================================================================
class _AnalyticsTab extends StatelessWidget {
  final String patientId;
  const _AnalyticsTab({required this.patientId});

  // Helper Logic (Sama seperti sebelumnya)
  Map<String, dynamic> _calculateStats(List<MedicationModel> meds, List<HistoryModel> history) {
    int totalSchedule = 0;
    int totalTaken = 0;
    int totalMissed = 0;
    List<Map<String, String>> missedLogList = [];

    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final dateToCheck = now.subtract(Duration(days: i));
      
      for (var med in meds) {
        List<TimeOfDay> dailySchedules = [];
        if (med.timeSlots.isNotEmpty) {
          dailySchedules = med.timeSlots.map((s) {
            final p = s.split(':');
            return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
          }).toList();
        } else {
           if (med.frequency.contains('1x')) dailySchedules = [const TimeOfDay(hour: 8, minute: 0)];
           else if (med.frequency.contains('2x')) dailySchedules = [const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 20, minute: 0)];
           else dailySchedules = [const TimeOfDay(hour: 8, minute: 0)]; 
        }

        for (var time in dailySchedules) {
          final scheduleTime = DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day, time.hour, time.minute);
          
          if (scheduleTime.isAfter(now)) continue;

          totalSchedule++;

          int logsToday = history.where((h) => 
            h.medicationId == med.id && 
            h.takenAt.year == dateToCheck.year && 
            h.takenAt.month == dateToCheck.month && 
            h.takenAt.day == dateToCheck.day
          ).length;

          int scheduleIndex = dailySchedules.indexOf(time) + 1;
          
          if (logsToday >= scheduleIndex) {
            totalTaken++;
          } else {
            totalMissed++;
            missedLogList.add({
              'medName': med.name,
              'date': DateFormat('EEE, d MMM').format(dateToCheck),
              'time': "${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}",
              'isToday': (i == 0).toString(),
            });
          }
        }
      }
    }

    double adherenceRate = totalSchedule == 0 ? 0 : (totalTaken / totalSchedule) * 100;

    return {
      'rate': adherenceRate,
      'taken': totalTaken,
      'missed': totalMissed,
      'missedList': missedLogList,
    };
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicationProvider>(context, listen: false);

    return StreamBuilder<List<MedicationModel>>(
      stream: provider.getMedicationsByUserId(patientId),
      builder: (context, snapMeds) {
        return StreamBuilder<List<HistoryModel>>(
          stream: provider.getHistoryByUserId(patientId),
          builder: (context, snapHistory) {
            
            if (!snapMeds.hasData) return const Center(child: CircularProgressIndicator());
            
            final meds = snapMeds.data ?? [];
            final history = snapHistory.data ?? [];
            final stats = _calculateStats(meds, history);

            final double rate = stats['rate'];
            final int missedCount = stats['missed'];
            final List<Map<String, String>> missedList = stats['missedList'];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. DASHBOARD CARD
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      children: [
                        const Text("Kepatuhan 7 Hari Terakhir", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        // Circular Chart
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: rate / 100,
                                strokeWidth: 12,
                                backgroundColor: Colors.grey[100],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  rate > 80 ? const Color(0xFF059669) : (rate > 50 ? Colors.orange : Colors.red)
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Text("${rate.toStringAsFixed(0)}%", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                                const Text("Adherence", style: TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statItem("Diminum", "${stats['taken']}", Colors.green),
                            Container(width: 1, height: 30, color: Colors.grey[300]),
                            _statItem("Terlewat", "$missedCount", Colors.red),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text("Detail Lupa Minum", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // 2. LIST TERLEWAT
                  if (missedList.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.emoji_events, color: Colors.green[700], size: 40),
                          const SizedBox(height: 8),
                          Text("Luar Biasa!", style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold)),
                          Text("Tidak ada obat terlewat minggu ini.", style: TextStyle(color: Colors.green[600], fontSize: 12)),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: missedList.length,
                      itemBuilder: (context, index) {
                        final item = missedList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border(left: BorderSide(color: Colors.red[400]!, width: 4)),
                            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5)],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['medName']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text("${item['date']} • Jam ${item['time']}", style: TextStyle(color: Colors.grey[600])),
                                    ],
                                  ),
                                ],
                              ),
                              if (item['isToday'] == 'true')
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                                  child: const Text("HARI INI", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                              else
                                const Icon(Icons.close, color: Colors.red),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

// ============================================================================
// TAB 3: RIWAYAT (Existing)
// ============================================================================
class _HistoryListTab extends StatelessWidget {
  final String patientId;
  const _HistoryListTab({required this.patientId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<HistoryModel>>(
      stream: Provider.of<MedicationProvider>(context, listen: false).getHistoryByUserId(patientId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final logs = snapshot.data ?? [];
        if (logs.isEmpty) return Center(child: Text("Belum ada riwayat minum", style: TextStyle(color: Colors.grey[500])));

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(log.medicationName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormat('EEE, d MMM HH:mm', 'id_ID').format(log.takenAt)),
              ),
            );
          },
        );
      },
    );
  }
}