import 'package:flutter/material.dart';

class AppTheme {
  // Warna Utama dari Screenshot
  static const Color primaryColor = Color(0xFF3B82F6); // Biru cerah
  static const Color secondaryColor = Color(0xFF10B981); // Hijau soft
  static const Color backgroundColor = Color(0xFFF3F4F6); // Abu-abu sangat muda
  static const Color errorColor = Color(0xFFEF4444); // Merah alert
  
  static const Color textDark = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF6B7280);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      // Konfigurasi Text agar besar dan jelas (Ramah Lansia)
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 24, 
          fontWeight: FontWeight.bold, 
          color: textDark
        ),
        titleLarge: TextStyle(
          fontSize: 20, 
          fontWeight: FontWeight.w600, 
          color: textDark
        ),
        bodyLarge: TextStyle( // Untuk teks utama
          fontSize: 16, 
          color: textDark,
          height: 1.5,
        ),
        bodyMedium: TextStyle( // Untuk teks sekunder
          fontSize: 14, 
          color: textLight,
        ),
      ),
      // Style Input Form Standar
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      // Style Tombol Standar
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }
}