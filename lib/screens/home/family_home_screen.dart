import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../providers/family_provider.dart';
import '../auth/login_screen.dart';
import 'patient_detail_screen.dart';

class FamilyHomeScreen extends StatefulWidget {
  const FamilyHomeScreen({super.key});

  @override
  State<FamilyHomeScreen> createState() => _FamilyHomeScreenState();
}

class _FamilyHomeScreenState extends State<FamilyHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // Fungsi Logout
  void _handleLogout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Keluar Mode Keluarga?"),
        content: const Text("Anda harus login kembali untuk memantau pasien."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService().signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Dialog Kirim Permintaan
  void _showAddPatientDialog() {
    final emailController = TextEditingController();
    bool isSubmitting = false;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Tambah Pasien"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Kirim permintaan pantauan ke email pasien. Pasien harus menyetujui permintaan ini.",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "email.pasien@contoh.com",
                    labelText: "Email Pasien",
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
              ElevatedButton(
                onPressed: isSubmitting ? null : () async {
                  if (emailController.text.trim().isEmpty) return;
                  
                  setState(() => isSubmitting = true);
                  try {
                    // MENGGUNAKAN LOGIC BARU: SEND REQUEST
                    await Provider.of<FamilyProvider>(context, listen: false)
                        .sendConnectionRequest(emailController.text.trim());
                    
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Permintaan dikirim! Menunggu persetujuan pasien."),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Pindah ke tab "Pending" agar user melihat request barunya
                      _tabController.animateTo(1);
                    }
                  } catch (e) {
                    setState(() => isSubmitting = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Gagal: ${e.toString().replaceAll('Exception: ', '')}")),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isSubmitting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Kirim Request"),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      body: Column(
        children: [
          // 1. HEADER CUSTOM
          Container(
            padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF10B981)], // Emerald Gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 8)),
              ],
            ),
            child: Column(
              children: [
                // Top Row (Title & Logout)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.family_restroom, color: Colors.white, size: 14),
                              SizedBox(width: 6),
                              Text("Mode Keluarga", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Monitor Pasien",
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: _handleLogout,
                      style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Tab Bar di dalam Header
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                    ),
                    labelColor: const Color(0xFF059669),
                    unselectedLabelColor: Colors.white.withOpacity(0.7),
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const [
                      Tab(text: "Pantauan Aktif"),
                      Tab(text: "Menunggu"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. CONTENT (StreamBuilder)
          Expanded(
            child: StreamBuilder<List<ConnectionModel>>(
              // Menggunakan stream dari FamilyProvider yang baru
              stream: Provider.of<FamilyProvider>(context, listen: false).getMyPatients(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allConnections = snapshot.data ?? [];
                
                // Pisahkan data berdasarkan status
                final activePatients = allConnections.where((c) => c.status == 'active').toList();
                final pendingPatients = allConnections.where((c) => c.status == 'pending').toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // TAB 1: LIST AKTIF
                    _buildActiveList(activePatients),
                    
                    // TAB 2: LIST PENDING
                    _buildPendingList(pendingPatients),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPatientDialog,
        backgroundColor: const Color(0xFF059669),
        elevation: 4,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text("Tambah Pasien", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- WIDGET HELPER: LIST AKTIF ---
  Widget _buildActiveList(List<ConnectionModel> list) {
    if (list.isEmpty) {
      return _buildEmptyState(
        icon: Icons.monitor_heart_outlined,
        title: "Belum ada pasien aktif",
        subtitle: "Kirim permintaan ke pasien untuk mulai memantau.",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // Navigasi ke Detail Pasien
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientDetailScreen(
                      patientId: item.patientId,
                      name: item.patientName,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color(0xFFECFDF5),
                      child: Text(
                        item.patientName.isNotEmpty ? item.patientName[0].toUpperCase() : "?",
                        style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(item.patientEmail, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET HELPER: LIST PENDING ---
  Widget _buildPendingList(List<ConnectionModel> list) {
    if (list.isEmpty) {
      return _buildEmptyState(
        icon: Icons.outbox,
        title: "Tidak ada permintaan tertunda",
        subtitle: "Semua permintaan Anda telah diproses.",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.hourglass_top, color: Colors.orange),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Menunggu Persetujuan", style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(item.patientEmail, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET HELPER: EMPTY STATE ---
  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }
}