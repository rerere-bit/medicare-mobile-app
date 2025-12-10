import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medicare_mobile/core/theme_app.dart';
import 'package:medicare_mobile/widgets/custom_textfield.dart';
import 'package:medicare_mobile/providers/medication_provider.dart';
import 'package:medicare_mobile/models/medication_model.dart';
import 'package:medicare_mobile/services/drug_service.dart';

class AddMedicationScreen extends StatefulWidget {
  final MedicationModel? medication;

  const AddMedicationScreen({super.key, this.medication});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  // Controller Text
  String _selectedDrugName = "";
  final _dosageController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  final _stockController = TextEditingController(); // NEW: Controller Stock

  final DrugService _drugService = DrugService();

  // --- DATA PILIHAN BARU ---
  
  // 1. Frekuensi
  final List<String> _frequencyOptions = [
    '1x Sehari (Pagi)',
    '2x Sehari (Pagi, Malam)',
    '3x Sehari (Pagi, Siang, Malam)',
    '4x Sehari (Setiap 6 jam)',
  ];
  late String _selectedFrequency; 

  // 2. Instruksi Minum
  final List<String> _instructionOptions = [
    'Sesudah makan',
    'Sebelum makan',
    'Saat makan',
    'Waktu bebas',
  ];
  String _selectedInstruction = 'Sesudah makan';

  // 3. Jenis Obat (Icon)
  final Map<String, IconData> _typeOptions = {
    'pill': Icons.medication,
    'syrup': Icons.local_drink,
    'injection': Icons.vaccines,
    'powder': Icons.grain,
  };
  String _selectedType = 'pill';

  // 4. Warna Identitas
  final List<int> _colorOptions = [
    0xFF2196F3, // Biru (Default)
    0xFF4CAF50, // Hijau
    0xFFF44336, // Merah
    0xFFFFC107, // Kuning
    0xFF9C27B0, // Ungu
    0xFFFF9800, // Orange
    0xFF795548, // Coklat
    0xFF607D8B, // Abu-abu
  ];
  int _selectedColor = 0xFF2196F3;

  bool get isEditMode => widget.medication != null;

  @override
  void initState() {
    super.initState();
    _selectedFrequency = _frequencyOptions[0];

    if (isEditMode) {
      final med = widget.medication!;
      _selectedDrugName = med.name;
      _dosageController.text = med.dosage;
      
      if (_frequencyOptions.contains(med.frequency)) {
        _selectedFrequency = med.frequency;
      }
      
      _durationController.text = med.duration;
      _notesController.text = med.notes;
      
      // Load New Fields
      _stockController.text = med.stock.toString();
      _selectedColor = med.color;
      _selectedType = med.type;
      
      if (_instructionOptions.contains(med.instruction)) {
        _selectedInstruction = med.instruction;
      }
    }
  }

  @override
  void dispose() {
    _dosageController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    _stockController.dispose();
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
      // Parse stock (default 0 jika kosong)
      int stockVal = int.tryParse(_stockController.text) ?? 0;

      if (isEditMode) {
        await provider.updateMedication(
          id: widget.medication!.id,
          name: _selectedDrugName,
          dosage: _dosageController.text,
          frequency: _selectedFrequency, 
          duration: _durationController.text,
          notes: _notesController.text,
          // New Fields
          color: _selectedColor,
          type: _selectedType,
          stock: stockVal,
          instruction: _selectedInstruction,
        );
      } else {
        await provider.addMedication(
          name: _selectedDrugName,
          dosage: _dosageController.text,
          frequency: _selectedFrequency, 
          duration: _durationController.text,
          notes: _notesController.text,
          // New Fields
          color: _selectedColor,
          type: _selectedType,
          stock: stockVal,
          instruction: _selectedInstruction,
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
            // 1. NAMA OBAT (API)
            const Text("Nama Obat", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Autocomplete<DrugModel>(
              initialValue: TextEditingValue(text: _selectedDrugName),
              displayStringForOption: (DrugModel option) => option.name,
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text == '') return const Iterable<DrugModel>.empty();
                return await _drugService.searchDrugs(textEditingValue.text);
              },
              onSelected: (DrugModel selection) {
                setState(() {
                  _selectedDrugName = selection.name;
                  if (_notesController.text.isEmpty) {
                    _notesController.text = selection.description;
                  }
                });
              },
              fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                 if (textController.text != _selectedDrugName && _selectedDrugName.isNotEmpty) {
                    if(textController.text.isEmpty) textController.text = _selectedDrugName;
                }
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    suffixIcon: _selectedDrugName.isNotEmpty 
                      ? IconButton(icon: const Icon(Icons.clear), onPressed: (){textController.clear(); setState(() => _selectedDrugName = "");}) 
                      : null,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // 2. DOSIS & STOK (Row)
            Row(
              children: [
                Expanded(child: CustomTextField(label: "Dosis", hint: "500mg", controller: _dosageController)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Stok Awal", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Jml Butir/Botol",
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                          fillColor: const Color(0xFFF9FAFB),
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3. FREKUENSI & INSTRUKSI
            const Text("Jadwal & Aturan", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFrequency,
                  isExpanded: true,
                  items: _frequencyOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: (v) => setState(() => _selectedFrequency = v!),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _instructionOptions.map((option) {
                  final isSelected = _selectedInstruction == option;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(option),
                      selected: isSelected,
                      onSelected: (selected) => setState(() => _selectedInstruction = option),
                      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                      labelStyle: TextStyle(color: isSelected ? AppTheme.primaryColor : Colors.grey),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // 4. VISUALISASI (Bentuk & Warna)
            const Text("Visualisasi (Agar mudah dikenali)", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                // PILIH BENTUK
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedType,
                        isExpanded: true,
                        items: _typeOptions.keys.map((key) {
                          return DropdownMenuItem(
                            value: key,
                            child: Row(
                              children: [
                                Icon(_typeOptions[key], color: Colors.grey, size: 20),
                                const SizedBox(width: 8),
                                Text(key[0].toUpperCase() + key.substring(1)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedType = v!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // PILIH WARNA
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _colorOptions.map((colorVal) {
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = colorVal),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Color(colorVal),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedColor == colorVal ? Colors.black : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [
                                if (_selectedColor == colorVal)
                                  BoxShadow(color: Color(colorVal).withOpacity(0.4), blurRadius: 6, spreadRadius: 2)
                              ]
                            ),
                            child: _selectedColor == colorVal 
                                ? const Icon(Icons.check, size: 16, color: Colors.white) 
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 5. DURASI & CATATAN
            CustomTextField(label: "Durasi Pengobatan", hint: "Contoh: 7 hari / Selamanya", controller: _durationController),
            const SizedBox(height: 16),
            const Text("Catatan / Deskripsi", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Catatan dari dokter...",
                fillColor: const Color(0xFFF9FAFB),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),

            // BUTTON SAVE
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}