import 'package:flutter/material.dart';

/// Visual language: soft, rounded, warm. Everything is generous with radius
/// and shadow so the UI feels like felt and paper rather than glass.
class AppTheme {
  const AppTheme._();

  static const Color brand = Color(0xFF5FBF6E);
  static const Color heart = Color(0xFFF2607A);
  static const Color gem = Color(0xFF5BC8F5);
  static const Color ink = Color(0xFF3B3547);
  static const Color parchment = Color(0xFFFDF8F0);

  static const double radius = 22;
  static const double tileRadius = 16;

  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: brand,
      surface: parchment,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: parchment,
      splashFactory: InkSparkle.splashFactory,
      textTheme: const TextTheme().apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: .2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: .2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: brand.withValues(alpha: .18),
        elevation: 0,
        height: 66,
        labelTextStyle: const WidgetStatePropertyAll<TextStyle>(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  /// Rarity colours used by collection cards and discovery fanfare.
  static const List<Color> rarityColors = <Color>[
    Color(0xFF9AA6B2),
    Color(0xFF5FBF6E),
    Color(0xFF4E9BE8),
    Color(0xFFB06FE0),
    Color(0xFFF0A32E),
  ];
}
