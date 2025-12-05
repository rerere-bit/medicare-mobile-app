class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'Pasien' atau 'Keluarga'

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
  });

  // Konversi dari Map (Firebase) ke Object Dart
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      role: map['role'] ?? 'Pasien', // Default Pasien jika kosong
    );
  }

  // Konversi dari Object Dart ke Map (untuk simpan ke Firebase)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}