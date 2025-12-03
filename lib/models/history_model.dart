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
      'takenAt': takenAt.toIso8601String(), // Simpan waktu sebagai String ISO
    };
  }

  factory HistoryModel.fromMap(Map<String, dynamic> map, String id) {
    return HistoryModel(
      id: id,
      userId: map['userId'] ?? '',
      medicationId: map['medicationId'] ?? '',
      medicationName: map['medicationName'] ?? '',
      dosage: map['dosage'] ?? '',
      takenAt: DateTime.parse(map['takenAt']),
    );
  }
}