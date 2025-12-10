import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme_app.dart';
import '../../providers/family_provider.dart';

class PatientCaregiverScreen extends StatelessWidget {
  const PatientCaregiverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final familyProvider = Provider.of<FamilyProvider>(context, listen: false);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Keluarga & Pengamat", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: const TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
            tabs: [
              Tab(text: "Terhubung"),
              Tab(text: "Permintaan"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: DAFTAR KELUARGA AKTIF
            _ActiveCaregiversList(provider: familyProvider),
            
            // TAB 2: PERMINTAAN MASUK (Pending)
            _PendingRequestsList(provider: familyProvider),
          ],
        ),
      ),
    );
  }
}

class _ActiveCaregiversList extends StatelessWidget {
  final FamilyProvider provider;
  const _ActiveCaregiversList({required this.provider});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectionModel>>(
      stream: provider.getIncomingRequests(), // Stream semua request ke pasien
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter hanya yang ACTIVE
        final activeList = (snapshot.data ?? [])
            .where((c) => c.status == 'active')
            .toList();

        if (activeList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.family_restroom, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text("Belum ada keluarga yang terhubung", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activeList.length,
          itemBuilder: (context, index) {
            final item = activeList[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(item.familyName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.blue)),
                ),
                title: Text(item.familyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(item.familyEmail),
                trailing: IconButton(
                  icon: const Icon(Icons.link_off, color: Colors.red),
                  onPressed: () {
                    // Konfirmasi Hapus
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Hapus Akses?"),
                        content: Text("${item.familyName} tidak akan bisa memantau Anda lagi."),
                        actions: [
                          TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text("Batal")),
                          TextButton(
                            onPressed: () {
                              provider.removeCaregiver(item.id);
                              Navigator.pop(ctx);
                            },
                            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PendingRequestsList extends StatelessWidget {
  final FamilyProvider provider;
  const _PendingRequestsList({required this.provider});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectionModel>>(
      stream: provider.getIncomingRequests(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        // Filter hanya yang PENDING
        final pendingList = (snapshot.data ?? [])
            .where((c) => c.status == 'pending')
            .toList();

        if (pendingList.isEmpty) {
          return const Center(child: Text("Tidak ada permintaan baru", style: TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pendingList.length,
          itemBuilder: (context, index) {
            final item = pendingList[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notification_important, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${item.familyName} ingin memantau obat Anda.",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item.familyEmail, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => provider.respondToRequest(item.id, false),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text("Tolak"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => provider.respondToRequest(item.id, true),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                        child: const Text("Terima", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}