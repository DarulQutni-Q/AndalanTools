import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';

class AppTheme {
  // Vibrant, High-Contrast Modern Palette
  static const Color canvasColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color primaryAccent = Color(0xFF4F46E5);
  static const Color primaryText = Color(0xFF0F172A);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color dividerColor = Color(0xFFE2E8F0);
  
  // Status/Tags Colors (Vibrant & Trustworthy)
  static const Color successBg = Color(0xFFECFDF5);
  static const Color successText = Color(0xFF059669);
  static const Color activeBg = Color(0xFFEEF2FF);
  static const Color activeText = Color(0xFF4F46E5);
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color warningText = Color(0xFFD97706);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: canvasColor,
      primaryColor: primaryAccent,
      colorScheme: const ColorScheme.light(
        primary: primaryAccent,
        secondary: Color(0xFF0EA5E9),
        surface: surfaceColor,
        error: warningText,
      ),
      dividerColor: dividerColor,
      fontFamily: '.SF Pro Display',
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: primaryText, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        displayMedium: TextStyle(color: primaryText, fontWeight: FontWeight.bold, letterSpacing: -0.4),
        titleLarge: TextStyle(color: primaryText, fontWeight: FontWeight.w700, letterSpacing: -0.3),
        titleMedium: TextStyle(color: primaryText, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        bodyLarge: TextStyle(color: primaryText, fontWeight: FontWeight.normal, height: 1.5),
        bodyMedium: TextStyle(color: primaryText, fontWeight: FontWeight.normal, height: 1.5),
        bodySmall: TextStyle(color: secondaryText, fontWeight: FontWeight.normal, height: 1.4),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: primaryText),
        titleTextStyle: TextStyle(
          color: primaryText, 
          fontSize: 20, 
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: surfaceColor,
          elevation: 1,
          shadowColor: primaryAccent.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryText,
          side: const BorderSide(color: dividerColor, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
