import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';

class AppTheme {
  // Minimalist Everforest & Swiss Palette
  static const Color canvasColor = Color(0xFFFAF9F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color primaryAccent = Color(0xFF2D4B3E); // Deep Everforest Evergreen
  static const Color primaryText = Color(0xFF232A2E); // Deep Everforest Charcoal
  static const Color secondaryText = Color(0xFF7A8478); // Soft Sage Gray
  static const Color dividerColor = Color(0xFFE8EAE4); // Hairline Organic Border
  static const Color subtleFill = Color(0xFFF2F4EE); // Soft Neutral Sage Squircle Fill
  
  // Everforest Organic Accents
  static const Color accentSage = Color(0xFFA7C080);
  static const Color accentAqua = Color(0xFF7FBBB3);
  
  // Clean Status Colors
  static const Color successBg = Color(0xFFF2F4EE);
  static const Color successText = Color(0xFF2D4B3E);
  static const Color activeBg = Color(0xFFF2F4EE);
  static const Color activeText = Color(0xFF232A2E);
  static const Color warningBg = Color(0xFFFDF6E3);
  static const Color warningText = Color(0xFF7A8478);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: canvasColor,
      primaryColor: primaryAccent,
      colorScheme: const ColorScheme.light(
        primary: primaryAccent,
        secondary: Color(0xFF3D5A4C),
        surface: surfaceColor,
        error: Color(0xFFE67E80),
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
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: primaryText),
        titleTextStyle: TextStyle(
          color: primaryText, 
          fontSize: 18, 
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: surfaceColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: -0.2,
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
