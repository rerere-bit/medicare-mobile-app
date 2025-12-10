class MedicationModel {
  final String id;
  final String userId; 
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String notes;
  
  // --- FIELD BARU (PERSONALISASI) ---
  final int color; // Menyimpan value warna (0xFF...)
  final String type; // 'pill', 'syrup', 'injection', 'powder'
  final int stock; // Jumlah stok saat ini
  final String instruction; // 'Sesudah makan', 'Sebelum makan', dll.

  MedicationModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.notes,
    // Default value agar tidak error dengan data lama
    this.color = 0xFF2196F3, // Default Blue
    this.type = 'pill',
    this.stock = 0,
    this.instruction = 'Sesudah makan',
  });

  factory MedicationModel.fromMap(Map<String, dynamic> map, String id) {
    return MedicationModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? '',
      duration: map['duration'] ?? '',
      notes: map['notes'] ?? '',
      // Mapping field baru dengan safety check
      color: map['color'] ?? 0xFF2196F3,
      type: map['type'] ?? 'pill',
      stock: map['stock'] ?? 0,
      instruction: map['instruction'] ?? 'Sesudah makan',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'notes': notes,
      'color': color,
      'type': type,
      'stock': stock,
      'instruction': instruction,
      'createdAt': DateTime.now().toIso8601String(), 
    };
  }
}