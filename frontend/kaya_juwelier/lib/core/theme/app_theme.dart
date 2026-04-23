import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color gold          = Color(0xFFD4AF37);
  static const Color goldLight     = Color(0xFFEDD98A);
  static const Color background    = Color(0xFF1A1A2E);
  static const Color surface       = Color(0xFF16213E);
  static const Color cardBorder    = Color(0xFF2A2A4A);
  static const Color priceUp       = Color(0xFF4CAF50);
  static const Color priceDown     = Color(0xFFE53935);
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C8);

  static ThemeData get dark => ThemeData(
    brightness:         Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary:   gold,
      secondary: goldLight,
      surface:   surface,
    ),
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        color:       textPrimary,
        fontSize:    32,
        fontWeight:  FontWeight.bold,
        letterSpacing: -0.5,
      ),
      titleMedium: TextStyle(
        color:      textSecondary,
        fontSize:   14,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: TextStyle(
        color:    textSecondary,
        fontSize: 12,
      ),
    ),
    cardTheme: CardThemeData(
      color:        surface,
      elevation:    4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: cardBorder),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor:    background,
      foregroundColor:    gold,
      elevation:          0,
      centerTitle:        true,
      titleTextStyle: TextStyle(
        color:      gold,
        fontSize:   20,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
  );
}
