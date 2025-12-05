import 'package:flutter/material.dart';
import '../../core/theme_app.dart';
import '../../widgets/medication_card.dart';
import '../../widgets/summary_chart.dart';
import '../medication/add_medication_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final String name;
  const PatientDetailScreen({super.key, required this.name});

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
          // 1. HEADER CUSTOM (Gradient & Profil Besar)
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF34D399)], // Hijau Keluarga
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
                // Tombol Back & Judul
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
                
                // Foto Profil & Nama
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
                            "Status: Perlu Perhatian",
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
                color: const Color(0xFFECFDF5), // Hijau muda sekali
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFF059669).withOpacity(0.3)),
              ),
              tabs: const [
                Tab(text: "Statistik"),
                Tab(text: "Daftar Obat"),
              ],
            ),
          ),

          // 3. Isi Konten (TabBarView)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // --- TAB 1: STATISTIK LENGKAP ---
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Grafik Kepatuhan Mingguan", 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            
                            // Legenda / Keterangan Warna
                            Row(
                              children: [
                                _buildLegendItem(AppTheme.secondaryColor, "Diminum"),
                                const SizedBox(width: 16),
                                _buildLegendItem(Colors.grey[200]!, "Target Harian"),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Grafik
                            const SizedBox(height: 200, child: SummaryChart()), 
                            
                            const SizedBox(height: 24),
                            const Divider(height: 32, color: Color(0xFFF3F4F6)),
                            const SizedBox(height: 16),
                            
                            // Ringkasan Angka
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem("Total Jadwal", "28", Colors.black),
                                _buildStatItem("Diminum", "24", AppTheme.secondaryColor),
                                _buildStatItem("Terlewat", "4", AppTheme.errorColor),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tips Kesehatan
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.tips_and_updates, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Tips: ${widget.name} sering melewatkan obat di sore hari. Coba telepon beliau sekitar jam 17:00.",
                                style: const TextStyle(color: Colors.blue, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                // --- TAB 2: KELOLA OBAT ---
                Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        MedicationCard(
                          name: "Amlodipine",
                          dosage: "5mg",
                          frequency: "1x Sehari",
                          duration: "Rutin",
                          onEdit: () {},
                          onDelete: () => _showDeleteConfirm(context),
                        ),
                        MedicationCard(
                          name: "Metformin",
                          dosage: "500mg",
                          frequency: "2x Sehari",
                          duration: "Rutin",
                          onEdit: () {},
                          onDelete: () => _showDeleteConfirm(context),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                    Positioned(
                      bottom: 24,
                      right: 24,
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddMedicationScreen()),
                          );
                        },
                        backgroundColor: const Color(0xFF059669),
                        icon: const Icon(Icons.add),
                        label: const Text("Tambah Obat"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Kecil untuk Legenda Warna
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  // Widget Kecil untuk Statistik Angka
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Obat?"),
        content: const Text("Obat ini akan dihapus dari daftar orang tua Anda."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("Hapus", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}