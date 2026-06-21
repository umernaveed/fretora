import 'package:flutter/material.dart';

import '../network/api_models.dart';

class AppTheme {
  static ThemeData fromCourier(CourierWorkspace? courier) {
    final primary = _parseColor(courier?.primaryColor) ?? const Color(0xff135fd2);
    final secondary = _parseColor(courier?.secondaryColor) ?? const Color(0xff073b70);
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xfff8fafc),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: const Color(0xff0f172a),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xffe2e8f0)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static Color? _parseColor(String? value) {
    if (value == null || value.isEmpty) return null;
    final hex = value.replaceAll('#', '');
    if (hex.length != 6) return null;
    return Color(int.parse('ff$hex', radix: 16));
  }
}
