import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme_app.dart';
import '../../widgets/custom_textfield.dart';
import '../../providers/medication_provider.dart';
import '../../models/medication_model.dart'; 

class AddMedicationScreen extends StatefulWidget {
  final MedicationModel? medication; 
  const AddMedicationScreen({super.key, this.medication});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  bool get isEditMode => widget.medication != null; 

  @override
  void initState() {
    super.initState();
    // Jika Mode Edit, isi form dengan data lama
    if (isEditMode) {
      final med = widget.medication!;
      _nameController.text = med.name;
      _dosageController.text = med.dosage;
      _frequencyController.text = med.frequency;
      _durationController.text = med.duration;
      _notesController.text = med.notes;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveMedication() async {
    if (_nameController.text.isEmpty || _dosageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama obat dan dosis wajib diisi!")),
      );
      return;
    }

    try {
      final provider = Provider.of<MedicationProvider>(context, listen: false);

      if (isEditMode) {
        // --- LOGIKA UPDATE ---
        await provider.updateMedication(
          id: widget.medication!.id, 
          name: _nameController.text,
          dosage: _dosageController.text,
          frequency: _frequencyController.text,
          duration: _durationController.text,
          notes: _notesController.text,
        );
      } else {
        // --- LOGIKA TAMBAH BARU ---
        await provider.addMedication(
          name: _nameController.text,
          dosage: _dosageController.text,
          frequency: _frequencyController.text,
          duration: _durationController.text,
          notes: _notesController.text,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditMode ? "Data diperbarui!" : "Obat berhasil disimpan!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<MedicationProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Judul berubah dinamis
        title: Text(isEditMode ? "Edit Obat" : "Tambah Obat Baru", style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(label: "Nama Obat", hint: "Contoh: Paracetamol", controller: _nameController),
            const SizedBox(height: 16),
            CustomTextField(label: "Dosis", hint: "500mg", controller: _dosageController),
            const SizedBox(height: 16),
            CustomTextField(label: "Frekuensi", hint: "3x sehari", controller: _frequencyController),
            const SizedBox(height: 16),
            CustomTextField(label: "Durasi", hint: "7 hari", controller: _durationController),
            const SizedBox(height: 16),
            
            const Text("Catatan Dokter", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Catatan khusus...",
                fillColor: const Color(0xFFF9FAFB),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveMedication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                    : Text(isEditMode ? "Simpan Perubahan" : "Simpan Obat"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}