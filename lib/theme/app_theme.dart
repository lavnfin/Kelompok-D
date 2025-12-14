import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    final cs = ColorScheme.fromSeed(
      seedColor: AppColors.orangeMain,
      brightness: Brightness.light,
      primary: AppColors.orangeMain,
      secondary: AppColors.yellowSolid,
      surface: AppColors.yellowSolid,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,

      // Background global cream
      scaffoldBackgroundColor: AppColors.bgCream,

      // AppBar global kuning solid
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.yellowSolid,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),

      // FAB global orange
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.orangeMain,
        foregroundColor: Colors.white,
      ),

      // Tombol-tombol default
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.orangeMain,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orangeMain,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: const BorderSide(color: AppColors.orangeMain, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.orangeMain,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      // Input global (TextField)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(
          color: AppColors.orangeMain,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.orangeMain, width: 2),
        ),
      ),

      // SnackBar biar seragam
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black.withOpacity(0.9),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      // Icon default (kalau kamu nggak set color di icon)
      iconTheme: const IconThemeData(color: AppColors.orangeMain),
    );
  }
}
