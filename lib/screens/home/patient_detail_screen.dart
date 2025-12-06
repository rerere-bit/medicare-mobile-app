import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme_app.dart';
import '../../providers/medication_provider.dart';
import '../../models/medication_model.dart';
import '../../models/history_model.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId; // KUNCI UTAMA: ID Pasien
  final String name;

  const PatientDetailScreen({
    super.key,
    required this.patientId, // Wajib ada untuk request ke Firebase
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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Column(
        children: [
          // 1. HEADER CUSTOM (Tetap menggunakan desain Anda yang bagus)
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
                      "Detail Kesehatan",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white30,
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 40, color: Color(0xFF059669)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Status: Dalam Pantauan",
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Tab Bar (Menu)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: const Color(0xFF059669),
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              padding: const EdgeInsets.all(6),
              indicator: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFF059669).withOpacity(0.3)),
              ),
              tabs: const [
                Tab(text: "Daftar Obat"), // Kita dahulukan Obat
                Tab(text: "Riwayat"),     // Kita ganti Statistik jadi Riwayat
              ],
            ),
          ),

          // 3. Isi Konten (Logika Realtime Provider)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: DAFTAR OBAT (Realtime)
                _MedicationListTab(patientId: widget.patientId),

                // TAB 2: RIWAYAT (Realtime)
                _HistoryListTab(patientId: widget.patientId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET PENDUKUNG (Extracted Logic) ---

class _MedicationListTab extends StatelessWidget {
  final String patientId;
  const _MedicationListTab({required this.patientId});

  @override
  Widget build(BuildContext context) {
    // Menggunakan Stream Provider untuk ambil data pasien lain
    return StreamBuilder<List<MedicationModel>>(
      stream: Provider.of<MedicationProvider>(context, listen: false)
          .getMedicationsByUserId(patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final meds = snapshot.data ?? [];

        if (meds.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medication_outlined, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text("Pasien belum ada obat", style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: meds.length,
          itemBuilder: (context, index) {
            final med = meds[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.medication, color: AppTheme.primaryColor),
                ),
                title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      _ChipInfo(icon: Icons.access_time, label: med.frequency),
                      const SizedBox(width: 8),
                      _ChipInfo(icon: Icons.local_pharmacy, label: med.dosage),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _HistoryListTab extends StatelessWidget {
  final String patientId;
  const _HistoryListTab({required this.patientId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<HistoryModel>>(
      stream: Provider.of<MedicationProvider>(context, listen: false)
          .getHistoryByUserId(patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final logs = snapshot.data ?? [];

        if (logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text("Belum ada riwayat minum", style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            final dateStr = DateFormat('EEEE, d MMM, HH:mm', 'id_ID').format(log.takenAt);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border(left: BorderSide(color: AppTheme.secondaryColor, width: 4)),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
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
                      Text(dateStr, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                  const Icon(Icons.check_circle, color: AppTheme.secondaryColor),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Widget Kecil Helper
class _ChipInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ChipInfo({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
        ],
      ),
    );
  }
}