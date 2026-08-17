import 'package:flutter/material.dart';

abstract final class AppPalette {
  static const background = Color(0xFFF3F6F3);
  static const surface = Color(0xFFFBFCFA);
  static const surfaceMuted = Color(0xFFE9EFEB);
  static const surfaceCompleted = Color(0xFFF0F5F1);
  static const surfaceLocked = Color(0xFFEDF1EE);
  static const ink = Color(0xFF263330);
  static const mutedInk = Color(0xFF64716D);
  static const primary = Color(0xFF527A75);
  static const completed = Color(0xFF4F7C67);
  static const border = Color(0x1F263330);
  static const borderStrong = Color(0x38263330);
  static const shadow = Color(0x140D1F1A);
  static const tileShadow = Color(0x1F000000);
  static const tileDragShadow = Color(0x38000000);
  static const tileDropTarget = Color(0xE6FFFFFF);
  static const tileDropOverlay = Color(0x14FFFFFF);
  static const tileHintSource = Color(0xCCFFF2B2);
  static const tileHintDestination = Color(0xCC536F67);

  static const sky = Color(0xFF5BC0EB);
  static const leaf = Color(0xFF9BC53D);
  static const sun = Color(0xFFFDE74C);
  static const coral = Color(0xFFE55934);
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const compact = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract final class AppRadii {
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const pill = 999.0;
}

abstract final class AppMotion {
  static const press = Duration(milliseconds: 120);
  static const quick = Duration(milliseconds: 150);
  static const standard = Duration(milliseconds: 220);
  static const gentle = Duration(milliseconds: 320);
}

abstract final class AppShadows {
  static const card = [
    BoxShadow(color: AppPalette.shadow, blurRadius: 16, offset: Offset(0, 6)),
  ];

  static const floating = [
    BoxShadow(color: Color(0x1A0D1F1A), blurRadius: 24, offset: Offset(0, 10)),
  ];
}
