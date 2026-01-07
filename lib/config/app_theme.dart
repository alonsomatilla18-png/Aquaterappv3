import 'package:flutter/material.dart';

class AppTheme {
  // Colores Corporativos
  static const Color primary = Color(0xFF0D47A1);
  static const Color secondary = Color(0xFFEF6C00); // Naranja para edición
  static const Color background = Color(0xFFF5F5F5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: background,
      
      // Estilo de Barra Superior
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
      ),

      // Estilo de Inputs (Cajas de texto) - IDÉNTICO AL ORIGINAL
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2.5),
        ),
      ),
    );
  }
}