import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/animation.dart';
import 'package:pixel_harmony/game/models/tile_model.dart';

typedef TileDragStartCallback = bool Function(TileComponent tile);
typedef TileDragUpdateCallback =
    Vector2 Function(TileComponent tile, Vector2 delta);
typedef TileDragEndCallback = void Function(TileComponent tile);
typedef TileDragCancelCallback = void Function(TileComponent tile);

class TileComponent extends PositionComponent with DragCallbacks {
  TileComponent({
    required this.model,
    required this.onDragStarted,
    required this.onDragUpdated,
    required this.onDragFinished,
    required this.onDragCancelled,
  });

  final TileModel model;
  final TileDragStartCallback onDragStarted;
  final TileDragUpdateCallback onDragUpdated;
  final TileDragEndCallback onDragFinished;
  final TileDragCancelCallback onDragCancelled;

  static const _cornerRadiusRatio = 0.12;
  static const _shadowColor = Color(0x33000000);
  static const _shadowElevation = 5.0;
  static const _targetOutlineColor = Color(0xB3FFFFFF);
  static const defaultMovementDuration = 0.2;

  bool _participatesInDrag = false;
  bool _isCancellingDrag = false;
  bool isDropTarget = false;
  bool isCompleted = false;
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
    if (_isCancellingDrag) {
      _isCancellingDrag = false;
      onDragCancelled(this);
    } else {
      onDragFinished(this);
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    _isCancellingDrag = true;
    super.onDragCancel(event);
  }

  void moveTo(
    Vector2 destination, {
    double duration = defaultMovementDuration,
    void Function()? onComplete,
  }) {
    _returnEffect?.removeFromParent();
    final effect = MoveEffect.to(
      destination,
      EffectController(duration: duration, curve: Curves.easeOutCubic),
      onComplete: () {
        _returnEffect = null;
        onComplete?.call();
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
    if (isCompleted) {
      canvas.drawRRect(tile, Paint()..color = const Color(0x0DFFFFFF));
    }
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
