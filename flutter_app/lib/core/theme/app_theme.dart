import 'package:flutter/material.dart';
import 'package:pixel_harmony/core/theme/app_design_tokens.dart';

abstract final class AppTheme {
  static final light = _buildLightTheme();

  static ThemeData _buildLightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppPalette.primary,
      brightness: Brightness.light,
      surface: AppPalette.surface,
    ).copyWith(
      primary: AppPalette.primary,
      onSurface: AppPalette.ink,
      surfaceContainerLow: AppPalette.surfaceMuted,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppPalette.background,
      useMaterial3: true,
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: AppPalette.ink,
          fontSize: 42,
          fontWeight: FontWeight.w600,
          letterSpacing: -1.2,
          height: 1.05,
        ),
        headlineSmall: TextStyle(
          color: AppPalette.ink,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: AppPalette.ink,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: AppPalette.mutedInk, height: 1.45),
        bodyMedium: TextStyle(color: AppPalette.mutedInk, height: 1.4),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppPalette.ink,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppPalette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: Color(0x1A263330)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 54),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
