import 'package:flutter/material.dart';

abstract final class AppTheme {
  static final light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C7A89),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );
}
