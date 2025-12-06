import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryModel {
  final String id;
  final String userId;
  final String medicationId;
  final String medicationName;
  final String dosage;
  final DateTime takenAt;

  HistoryModel({
    required this.id,
    required this.userId,
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.takenAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'dosage': dosage,
      // Store as ISO string for portability when writing from client-side objects
      'takenAt': takenAt.toIso8601String(),
    };
  }

  factory HistoryModel.fromMap(Map<String, dynamic> map, String id) {
    // takenAt in Firestore could be a Timestamp (serverTimestamp) or an ISO String.
    final rawTaken = map['takenAt'];
    DateTime parsedTaken;

    if (rawTaken is Timestamp) {
      parsedTaken = rawTaken.toDate();
    } else if (rawTaken is String) {
      parsedTaken = DateTime.tryParse(rawTaken) ?? DateTime.now();
    } else {
      parsedTaken = DateTime.now();
    }

    return HistoryModel(
      id: id,
      userId: map['userId'] ?? '',
      medicationId: map['medicationId'] ?? '',
      medicationName: map['medicationName'] ?? '',
      dosage: map['dosage'] ?? '',
      takenAt: parsedTaken,
    );
  }
}
