import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme_app.dart';
import '../../widgets/custom_textfield.dart';
import '../../providers/medication_provider.dart';
import '../../models/medication_model.dart';
import '../../services/drug_service.dart';

class AddMedicationScreen extends StatefulWidget {
  final MedicationModel? medication;

  const AddMedicationScreen({super.key, this.medication});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  // Controller untuk Autocomplete sedikit berbeda
  // Kita simpan string nama obat di variabel terpisah jika pakai Autocomplete
  String _selectedDrugName = "";
  
  final _dosageController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  final DrugService _drugService = DrugService();

  final List<String> _frequencyOptions = [
    '1x Sehari (Pagi)',
    '2x Sehari (Pagi, Malam)',
    '3x Sehari (Pagi, Siang, Malam)',
    '4x Sehari (Setiap 6 jam)',
  ];

  late String _selectedFrequency; 

  bool get isEditMode => widget.medication != null;

  @override
  void initState() {
    super.initState();
    _selectedFrequency = _frequencyOptions[0];

    if (isEditMode) {
      final med = widget.medication!;
      _selectedDrugName = med.name; // Pre-fill nama
      _dosageController.text = med.dosage;
      
      if (_frequencyOptions.contains(med.frequency)) {
        _selectedFrequency = med.frequency;
      }
      
      _durationController.text = med.duration;
      _notesController.text = med.notes;
    }
  }

  @override
  void dispose() {
    _dosageController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveMedication() async {
    if (_selectedDrugName.isEmpty || _dosageController.text.isEmpty) {
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
          name: _selectedDrugName,
          dosage: _dosageController.text,
          frequency: _selectedFrequency, 
          duration: _durationController.text,
          notes: _notesController.text,
        );
      } else {
        await provider.addMedication(
          name: _selectedDrugName,
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
            // --- AUTOCOMPLETE NAMA OBAT (FITUR API) ---
            const Text("Nama Obat", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Autocomplete<DrugModel>(
              initialValue: TextEditingValue(text: _selectedDrugName),
              displayStringForOption: (DrugModel option) => option.name,
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text == '') {
                  return const Iterable<DrugModel>.empty();
                }
                return await _drugService.searchDrugs(textEditingValue.text);
              },
              onSelected: (DrugModel selection) {
                setState(() {
                  _selectedDrugName = selection.name;
                  // Auto-fill deskripsi jika notes masih kosong
                  if (_notesController.text.isEmpty) {
                    _notesController.text = selection.description;
                  }
                });
              },
              // Kustomisasi Tampilan Input agar mirip CustomTextField
              fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                // Sinkronisasi controller internal Autocomplete dengan variabel kita
                if (textController.text != _selectedDrugName) {
                    // Hanya set jika berbeda untuk menghindari infinite loop
                     textController.text = _selectedDrugName;
                }
                // Listener manual untuk menyimpan perubahan jika user mengetik manual (bukan pilih opsi)
                textController.addListener(() {
                  _selectedDrugName = textController.text;
                });

                return TextField(
                  controller: textController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: "Cari nama obat...",
                    fillColor: const Color(0xFFF9FAFB),
                    filled: true,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            
            CustomTextField(label: "Dosis", hint: "500mg", controller: _dosageController),
            const SizedBox(height: 16),
            
            const Text("Frekuensi", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
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
            
            const SizedBox(height: 16),
            CustomTextField(label: "Durasi", hint: "7 hari", controller: _durationController),
            const SizedBox(height: 16),
            
            const Text("Catatan / Deskripsi", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Otomatis terisi jika obat ditemukan...",
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                    : Text(isEditMode ? "Simpan Perubahan" : "Simpan Obat", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}