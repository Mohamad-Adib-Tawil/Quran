import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: false);
    final text = GoogleFonts.balooBhaijaan2TextTheme(base.textTheme).apply(
      bodyColor: AppColors.textDark,
      displayColor: AppColors.textDark,
    );
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.scaffoldLight,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: text,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: false);
    final text = GoogleFonts.balooBhaijaan2TextTheme(base.textTheme).apply(
      bodyColor: AppColors.textLight,
      displayColor: AppColors.textLight,
    );
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.scaffoldDark,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: text,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
