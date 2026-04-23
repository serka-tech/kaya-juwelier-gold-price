import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // ── Light palette ──────────────────────────────────────────────────────────
  static const Color background    = Color(0xFFF5F6FA);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color surfaceAlt    = Color(0xFFF0F2F8);

  // Gold accent (warm, readable on white)
  static const Color gold          = Color(0xFFC9A227);
  static const Color goldLight     = Color(0xFFF5E6B0);
  static const Color goldGlow      = Color(0xFFFFF8E1);

  // Text
  static const Color textPrimary   = Color(0xFF1A1D2E);
  static const Color textSecondary = Color(0xFF8B8FA8);
  static const Color textHint      = Color(0xFFBBBECC);

  // Semantic
  static const Color priceUp       = Color(0xFF22C55E);
  static const Color priceDown     = Color(0xFFEF4444);
  static const Color priceUpBg     = Color(0xFFECFDF5);
  static const Color priceDownBg   = Color(0xFFFEF2F2);

  // Borders / dividers
  static const Color divider       = Color(0xFFEEF0F6);
  static const Color cardBorder    = Color(0xFFE8EBF4);

  // ── Card shadow ────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF1A1D2E).withAlpha(13),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF1A1D2E).withAlpha(6),
      blurRadius: 6,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: const Color(0xFF1A1D2E).withAlpha(10),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  // ── Theme ──────────────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.light(
      primary:   gold,
      secondary: goldLight,
      surface:   surface,
    ),
    fontFamily: 'Roboto',
    useMaterial3: true,
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        color: textPrimary, fontSize: 32,
        fontWeight: FontWeight.w700, letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: textSecondary, fontSize: 14, fontWeight: FontWeight.w500,
      ),
      bodySmall: TextStyle(color: textSecondary, fontSize: 12),
      labelSmall: TextStyle(color: textHint, fontSize: 10),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: TextStyle(
        color: textPrimary, fontSize: 20,
        fontWeight: FontWeight.w700, letterSpacing: -0.3,
      ),
    ),
    dividerTheme: const DividerThemeData(color: divider, space: 1),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceAlt,
      selectedColor: gold,
      labelStyle: const TextStyle(fontSize: 12),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
