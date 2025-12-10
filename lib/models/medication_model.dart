import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationModel {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String notes;
  
  final int color;
  final String type;
  final int stock;
  final String instruction;
  final List<String> timeSlots;
  
  // FIELD PENTING UNTUK DURASI
  final DateTime createdAt; 

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
    this.timeSlots = const [],
    required this.createdAt, // Wajib diisi sekarang
  });

  factory MedicationModel.fromMap(Map<String, dynamic> map, String id) {
    // Parsing tanggal aman
    DateTime parseDate(dynamic val) {
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is Timestamp) return val.toDate(); // Jika dari Firestore Timestamp
      return DateTime.now();
    }

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
      timeSlots: List<String>.from(map['timeSlots'] ?? []),
      createdAt: parseDate(map['createdAt']), // Load Tanggal Buat
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
      'timeSlots': timeSlots,
      'createdAt': createdAt.toIso8601String(), // Simpan sebagai String ISO
    };
  }
}