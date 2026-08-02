import 'dart:ui';

import 'package:flame/components.dart';
import 'package:pixel_harmony/game/models/tile_model.dart';

class TileComponent extends PositionComponent {
  TileComponent({required this.model});

  final TileModel model;

  static const _cornerRadiusRatio = 0.12;
  static const _shadowColor = Color(0x33000000);
  static const _shadowElevation = 5.0;

  @override
  void render(Canvas canvas) {
    final cornerRadius = size.x * _cornerRadiusRatio;
    final tile = RRect.fromRectAndRadius(
      size.toRect(),
      Radius.circular(cornerRadius),
    );
    final tilePath = Path()..addRRect(tile);

    canvas.drawShadow(tilePath, _shadowColor, _shadowElevation, false);
    canvas.drawRRect(tile, Paint()..color = model.color);
  }
}
