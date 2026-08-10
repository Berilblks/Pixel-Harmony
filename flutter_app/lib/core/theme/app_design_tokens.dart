import 'package:flutter/material.dart';

abstract final class AppPalette {
  static const background = Color(0xFFF3F6F3);
  static const surface = Color(0xFFFBFCFA);
  static const surfaceMuted = Color(0xFFE9EFEB);
  static const ink = Color(0xFF263330);
  static const mutedInk = Color(0xFF64716D);
  static const primary = Color(0xFF527A75);
  static const completed = Color(0xFF4F7C67);

  static const sky = Color(0xFF5BC0EB);
  static const leaf = Color(0xFF9BC53D);
  static const sun = Color(0xFFFDE74C);
  static const coral = Color(0xFFE55934);
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract final class AppRadii {
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const pill = 999.0;
}

abstract final class AppMotion {
  static const quick = Duration(milliseconds: 160);
  static const standard = Duration(milliseconds: 220);
  static const gentle = Duration(milliseconds: 350);
}
