import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        surface: AppColors.surfaceLight,
        background: AppColors.backgroundLight,
        error: AppColors.errorLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
        onBackground: AppColors.textPrimaryLight,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: const TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w700, fontSize: 32, letterSpacing: -0.5),
        headlineMedium: const TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w600, fontSize: 24, letterSpacing: 0),
        titleMedium: const TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w500, fontSize: 16, letterSpacing: 0.15),
        bodyLarge: const TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w400, fontSize: 16, letterSpacing: 0.5),
        bodyMedium: const TextStyle(color: AppColors.textSecondaryLight, fontWeight: FontWeight.w400, fontSize: 14, letterSpacing: 0.25),
        labelLarge: const TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.1),
        labelSmall: const TextStyle(color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500, fontSize: 11, letterSpacing: 0.5),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
        titleTextStyle: TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w600, fontSize: 20),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.errorLight),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.secondaryDark,
        surface: AppColors.surfaceDark,
        background: AppColors.backgroundDark,
        error: AppColors.errorDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryDark,
        onBackground: AppColors.textPrimaryDark,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: const TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w700, fontSize: 32, letterSpacing: -0.5),
        headlineMedium: const TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600, fontSize: 24, letterSpacing: 0),
        titleMedium: const TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w500, fontSize: 16, letterSpacing: 0.15),
        bodyLarge: const TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w400, fontSize: 16, letterSpacing: 0.5),
        bodyMedium: const TextStyle(color: AppColors.textSecondaryDark, fontWeight: FontWeight.w400, fontSize: 14, letterSpacing: 0.25),
        labelLarge: const TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.1),
        labelSmall: const TextStyle(color: AppColors.textSecondaryDark, fontWeight: FontWeight.w500, fontSize: 11, letterSpacing: 0.5),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
        titleTextStyle: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600, fontSize: 20),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.errorDark),
        ),
      ),
    );
  }
}
