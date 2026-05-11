import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // ── Light professional palette ─────────────────────────────────────────────
  static const Color background      = Color(0xFFF4F6FB);
  static const Color surface         = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF0F3FA);
  static const Color surfaceHighlight = Color(0xFFE8EDF8);

  // Gold brand
  static const Color gold            = Color(0xFFC9A227);
  static const Color goldLight       = Color(0xFFE8C84A);
  static const Color goldDim         = Color(0xFFB8960E);

  // Text
  static const Color textPrimary     = Color(0xFF0D1117);
  static const Color textSecondary   = Color(0xFF4A5568);
  static const Color textHint        = Color(0xFF9AA5B4);

  // Semantic
  static const Color priceUp         = Color(0xFF16A34A);
  static const Color priceDown       = Color(0xFFDC2626);
  static const Color priceUpBg       = Color(0xFFDCFCE7);
  static const Color priceDownBg     = Color(0xFFFEE2E2);

  // Borders
  static const Color divider         = Color(0xFFE8ECF4);
  static const Color cardBorder      = Color(0xFFE2E8F0);

  // Compat aliases
  static const Color surfaceAlt      = Color(0xFFF0F3FA); // = surfaceElevated
  static const Color goldGlow        = Color(0xFFFFF8E8); // light gold tint

  // ── Shadows ────────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withAlpha(12),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: Colors.black.withAlpha(8),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // ── Theme ──────────────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
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
    ),
    dividerTheme: const DividerThemeData(color: divider, space: 1),
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: TextStyle(
        color: textPrimary, fontSize: 13,
        fontWeight: FontWeight.w800, letterSpacing: 1.8,
        fontFamily: 'Roboto',
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: gold,
      unselectedItemColor: textHint,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceElevated,
      selectedColor: gold,
      labelStyle: const TextStyle(fontSize: 12),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
