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
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  // --- OPSI DROPDOWN ---
  final List<String> _frequencyOptions = [
    '1x Sehari (Pagi)',
    '2x Sehari (Pagi, Malam)',
    '3x Sehari (Pagi, Siang, Malam)',
    '4x Sehari (Setiap 6 jam)',
  ];

  // --- PERBAIKAN DI SINI: Default value harus sama persis dengan item pertama ---
  late String _selectedFrequency; 

  bool get isEditMode => widget.medication != null;

  @override
  void initState() {
    super.initState();
    
    // Set default value ke opsi pertama agar aman
    _selectedFrequency = _frequencyOptions[0];

    if (isEditMode) {
      final med = widget.medication!;
      _nameController.text = med.name;
      _dosageController.text = med.dosage;
      
      // --- PERBAIKAN SAFETY CHECK ---
      // Cek apakah frekuensi dari database ada di list opsi kita?
      // Jika ada, pakai itu. Jika tidak (misal data lama), tetap pakai default agar tidak crash.
      if (_frequencyOptions.contains(med.frequency)) {
        _selectedFrequency = med.frequency;
      }
      
      _durationController.text = med.duration;
      _notesController.text = med.notes;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
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
        await provider.updateMedication(
          id: widget.medication!.id,
          name: _nameController.text,
          dosage: _dosageController.text,
          frequency: _selectedFrequency, 
          duration: _durationController.text,
          notes: _notesController.text,
        );
      } else {
        await provider.addMedication(
          name: _nameController.text,
          dosage: _dosageController.text,
          frequency: _selectedFrequency, 
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
            
            // --- DROPDOWN FREKUENSI ---
            const Text("Frekuensi", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFrequency,
                  isExpanded: true,
                  items: _frequencyOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedFrequency = newValue!;
                    });
                  },
                ),
              ),
            ),
            // -------------------------------
            
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