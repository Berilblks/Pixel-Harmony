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
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          color: AppPalette.ink,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
        titleMedium: TextStyle(
          color: AppPalette.ink,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        bodyLarge: TextStyle(color: AppPalette.mutedInk, height: 1.45),
        bodyMedium: TextStyle(color: AppPalette.mutedInk, height: 1.4),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppPalette.ink,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppPalette.surface,
        elevation: 1,
        shadowColor: AppPalette.shadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: AppPalette.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 54),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(48),
          foregroundColor: AppPalette.mutedInk,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppPalette.border,
        space: 1,
        thickness: 1,
      ),
    );
  }
}
