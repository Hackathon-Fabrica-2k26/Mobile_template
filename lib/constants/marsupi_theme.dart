import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarsupiColors {
  // Paleta oficial extraída diretamente do Figma
  static const Color primary = Color(0xFF356B5B);
  static const Color darkForest = Color(0xFF263D35);
  static const Color background = Color(0xFFF7F7F1);
  static const Color surface = Colors.white;
  static const Color accentPeach = Color(0xFFE3B477);
  static const Color sage = Color(0xFFA9C7B4);
  static const Color mintContainer = Color(0xFFEBF2EC);
  static const Color mintBorder = Color(0xFFD2E4D9);
  static const Color textMuted = Color(0xFF526D65);
}

class MarsupiTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: MarsupiColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MarsupiColors.primary,
        primary: MarsupiColors.primary,
        onPrimary: Colors.white,
        surface: MarsupiColors.surface,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: MarsupiColors.darkForest,
        displayColor: MarsupiColors.darkForest,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: MarsupiColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: MarsupiColors.darkForest),
        titleTextStyle: TextStyle(
          color: MarsupiColors.darkForest,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MarsupiColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MarsupiColors.mintBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MarsupiColors.mintBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MarsupiColors.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MarsupiColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
