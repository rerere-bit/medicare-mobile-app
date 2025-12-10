class MedicationModel {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String notes;
  
  // Personalisasi (Fitur sebelumnya)
  final int color;
  final String type;
  final int stock;
  final String instruction;

  // --- FIELD BARU (JADWAL DINAMIS) ---
  final List<String> timeSlots; // Format: ["HH:mm", "HH:mm"]

  MedicationModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.notes,
    this.color = 0xFF2196F3,
    this.type = 'pill',
    this.stock = 0,
    this.instruction = 'Sesudah makan',
    // Default kosong agar aman untuk data lama
    this.timeSlots = const [], 
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
      color: map['color'] ?? 0xFF2196F3,
      type: map['type'] ?? 'pill',
      stock: map['stock'] ?? 0,
      instruction: map['instruction'] ?? 'Sesudah makan',
      // Konversi List<dynamic> ke List<String>
      timeSlots: List<String>.from(map['timeSlots'] ?? []),
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
      'timeSlots': timeSlots, // Simpan ke Firestore
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}