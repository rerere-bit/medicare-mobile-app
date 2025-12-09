import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationModel {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String notes;
  final DateTime? createdAt; // Tambahkan field ini

  MedicationModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.notes,
    this.createdAt, // Tambahkan ke constructor
  });

  // Mengubah data dari Firebase (Map) ke Object Dart
  factory MedicationModel.fromMap(Map<String, dynamic> map, String id) {
    return MedicationModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? '',
      duration: map['duration'] ?? '',
      notes: map['notes'] ?? '',
      // Baca timestamp dari firestore
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // Mengubah Object Dart ke format Firebase (Map)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'notes': notes,
      // Hapus 'createdAt' dari sini untuk mencegah penimpaan
    };
  }
}