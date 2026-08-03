import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/animation.dart';
import 'package:pixel_harmony/game/models/tile_model.dart';

typedef TileDragStartCallback = bool Function(TileComponent tile);
typedef TileDragUpdateCallback =
    Vector2 Function(TileComponent tile, Vector2 delta);
typedef TileDragEndCallback = Vector2 Function(TileComponent tile);
typedef TileReturnCompletedCallback = void Function(TileComponent tile);

class TileComponent extends PositionComponent with DragCallbacks {
  TileComponent({
    required this.model,
    required this.onDragStarted,
    required this.onDragUpdated,
    required this.onDragFinished,
    required this.onReturnCompleted,
  });

  final TileModel model;
  final TileDragStartCallback onDragStarted;
  final TileDragUpdateCallback onDragUpdated;
  final TileDragEndCallback onDragFinished;
  final TileReturnCompletedCallback onReturnCompleted;

  static const _cornerRadiusRatio = 0.12;
  static const _shadowColor = Color(0x33000000);
  static const _shadowElevation = 5.0;
  static const _targetOutlineColor = Color(0xB3FFFFFF);
  static const _returnDuration = 0.18;

  bool _participatesInDrag = false;
  bool isDropTarget = false;
  MoveEffect? _returnEffect;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _participatesInDrag = onDragStarted(this);

    if (_participatesInDrag) {
      _returnEffect?.removeFromParent();
      _returnEffect = null;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_participatesInDrag) {
      return;
    }

    position = onDragUpdated(this, event.localDelta);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!_participatesInDrag) {
      return;
    }

    _participatesInDrag = false;
    _returnTo(onDragFinished(this));
  }

  void _returnTo(Vector2 originalPosition) {
    final effect = MoveEffect.to(
      originalPosition,
      EffectController(duration: _returnDuration, curve: Curves.easeOutCubic),
      onComplete: () {
        _returnEffect = null;
        onReturnCompleted(this);
      },
    );
    _returnEffect = effect;
    add(effect);
  }

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
    if (isDropTarget) {
      canvas.drawRRect(
        tile,
        Paint()
          ..color = _targetOutlineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.x * 0.025,
      );
    }
  }
}
