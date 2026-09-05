import 'package:flutter/material.dart';

class AppTheme {
  // Warm Monochrome & Muted Pastels Palette
  static const Color canvasColor = Color(0xFFFBFBFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF111111);
  static const Color secondaryText = Color(0xFF787774);
  static const Color dividerColor = Color(0xFFEAEAEA);
  
  // Status/Tags Colors
  static const Color successBg = Color(0xFFEDF3EC);
  static const Color successText = Color(0xFF346538);
  static const Color activeBg = Color(0xFFE1F3FE);
  static const Color activeText = Color(0xFF1F6C9F);
  static const Color warningBg = Color(0xFFFBF3DB);
  static const Color warningText = Color(0xFF956400);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: canvasColor,
      primaryColor: primaryText,
      colorScheme: const ColorScheme.light(
        primary: primaryText,
        secondary: secondaryText,
        surface: surfaceColor,
        error: warningText,
      ),
      dividerColor: dividerColor,
      fontFamily: '.SF Pro Display', // Fallback to system font on iOS
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: primaryText, fontWeight: FontWeight.bold, letterSpacing: -0.03),
        displayMedium: TextStyle(color: primaryText, fontWeight: FontWeight.bold, letterSpacing: -0.03),
        titleLarge: TextStyle(color: primaryText, fontWeight: FontWeight.w600, letterSpacing: -0.03),
        bodyLarge: TextStyle(color: primaryText, fontWeight: FontWeight.normal, height: 1.5),
        bodyMedium: TextStyle(color: primaryText, fontWeight: FontWeight.normal, height: 1.5),
        bodySmall: TextStyle(color: secondaryText, fontWeight: FontWeight.normal, height: 1.5),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: canvasColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: primaryText),
        titleTextStyle: TextStyle(
          color: primaryText, 
          fontSize: 20, 
          fontWeight: FontWeight.w600,
          letterSpacing: -0.03,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryText,
          foregroundColor: surfaceColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6), // Sharp radius per guidelines
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ).copyWith(
          // Subtle scale down effect on press is handled by custom widget or default flutter behavior (splash factory)
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: dividerColor, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(), // Use slide for android too
        },
      ),
    );
  }
}
