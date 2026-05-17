// lib/theme/theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette - Dark Neon Fantasy
  static const Color primaryGradientStart = Color(0xFF1a0033); // Deep Purple
  static const Color primaryGradientEnd = Color(0xFF330066); // Medium Purple
  static const Color accentNeon = Color(0xFF00D9FF); // Cyan Neon
  static const Color secondaryNeon = Color(0xFFFF006E); // Hot Pink Neon
  static const Color tertiaryNeon = Color(0xFF9D4EDD); // Purple Neon
  
  static const Color darkBg = Color(0xFF0F0017); // Very Dark Purple-Black
  static const Color cardDark = Color(0xFF1a0033); // Dark Card Background
  static const Color surfaceDark = Color(0xFF18001F); // Surface Dark
  
  static const Color textPrimary = Color(0xFFFFFFFF); // White
  static const Color textSecondary = Color(0xFFB0B0B0); // Light Gray
  static const Color textTertiary = Color(0xFF757575); // Medium Gray
  
  static const Color borderColor = Color(0xFF9D4EDD); // Purple Border
  static const Color successColor = Color(0xFF00D9FF); // Cyan Success
  static const Color errorColor = Color(0xFFFF006E); // Pink Error
  static const Color warningColor = Color(0xFFFFC300); // Amber Warning

  // Gradients
  static const LinearGradient neonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00D9FF), // Cyan
      Color(0xFFFF006E), // Hot Pink
    ],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      darkBg,
      Color(0xFF1a0033),
    ],
  );

  static const LinearGradient phantomGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF9D4EDD),
      Color(0xFF00D9FF),
    ],
  );

  // Theme Data
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: accentNeon,
    scaffoldBackgroundColor: darkBg,
    cardColor: cardDark,
    appBarTheme: AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.headlineSmall,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: secondaryNeon,
      foregroundColor: textPrimary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2a0052),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: tertiaryNeon, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: tertiaryNeon, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accentNeon, width: 2),
      ),
      hintStyle: const TextStyle(color: textTertiary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryNeon,
        foregroundColor: textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textTheme: textTheme,
  );

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: textPrimary,
      fontFamily: 'Poppins',
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: textPrimary,
      fontFamily: 'Poppins',
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      fontFamily: 'Poppins',
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      fontFamily: 'Poppins',
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: textPrimary,
      fontFamily: 'Poppins',
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: textPrimary,
      fontFamily: 'Poppins',
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: textSecondary,
      fontFamily: 'Poppins',
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: textTertiary,
      fontFamily: 'Poppins',
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: accentNeon,
      fontFamily: 'Poppins',
    ),
  );

  // Spacing & Sizing
  static const double paddingXs = 4;
  static const double paddingSm = 8;
  static const double paddingMd = 16;
  static const double paddingLg = 24;
  static const double paddingXl = 32;

  // Border Radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  // Shadow - Glassmorphism Effect
  static List<BoxShadow> glassBoxShadow = [
    BoxShadow(
      color: accentNeon.withOpacity(0.1),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> neonShadow = [
    BoxShadow(
      color: secondaryNeon.withOpacity(0.3),
      blurRadius: 15,
      spreadRadius: 2,
    ),
  ];
}
