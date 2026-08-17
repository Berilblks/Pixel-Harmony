import 'dart:ui';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/animation.dart';
import 'package:pixel_harmony/core/theme/app_design_tokens.dart';
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
  static const _shadowElevation = 3.0;
  static const _dragShadowElevation = 7.0;
  static const _dragScale = 1.045;
  static const defaultMovementDuration = 0.2;

  bool _participatesInDrag = false;
  bool _isCancellingDrag = false;
  bool isDropTarget = false;
  bool isCompleted = false;
  bool isHintSource = false;
  bool isHintDestination = false;
  MoveEffect? _returnEffect;
  bool _isDragFeedbackActive = false;
  double _visualScale = 1;
  double _scaleAnimationStart = 1;
  double _scaleAnimationTarget = 1;
  double _scaleAnimationElapsed = 0;
  double _hintPulseElapsed = 0;

  bool get isDragFeedbackActive => _isDragFeedbackActive;
  double get visualScale => _visualScale;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _participatesInDrag = onDragStarted(this);

    if (_participatesInDrag) {
      _returnEffect?.removeFromParent();
      _returnEffect = null;
      startDragFeedback();
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
    endDragFeedback();
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

  void startDragFeedback() {
    _isDragFeedbackActive = true;
    _animateVisualScaleTo(_dragScale);
  }

  void endDragFeedback() {
    _isDragFeedbackActive = false;
    _animateVisualScaleTo(1);
  }

  void _animateVisualScaleTo(double target) {
    _scaleAnimationStart = _visualScale;
    _scaleAnimationTarget = target;
    _scaleAnimationElapsed = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isHintDestination) {
      _hintPulseElapsed = (_hintPulseElapsed + dt) % 1.2;
    } else {
      _hintPulseElapsed = 0;
    }

    if (_visualScale != _scaleAnimationTarget) {
      final durationSeconds = AppMotion.quick.inMilliseconds / 1000;
      _scaleAnimationElapsed = (_scaleAnimationElapsed + dt).clamp(
        0,
        durationSeconds,
      );
      final progress =
          (_scaleAnimationElapsed / durationSeconds).clamp(0, 1).toDouble();
      final easedProgress = Curves.easeOut.transform(progress);
      _visualScale =
          lerpDouble(
            _scaleAnimationStart,
            _scaleAnimationTarget,
            easedProgress,
          )!;
      if (progress == 1) {
        _visualScale = _scaleAnimationTarget;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    final center = Offset(size.x / 2, size.y / 2);
    canvas.translate(center.dx, center.dy);
    canvas.scale(_visualScale);
    canvas.translate(-center.dx, -center.dy);

    final cornerRadius = size.x * _cornerRadiusRatio;
    final tile = RRect.fromRectAndRadius(
      size.toRect(),
      Radius.circular(cornerRadius),
    );
    final tilePath = Path()..addRRect(tile);

    canvas.drawShadow(
      tilePath,
      _isDragFeedbackActive ? AppPalette.tileDragShadow : AppPalette.tileShadow,
      _isDragFeedbackActive ? _dragShadowElevation : _shadowElevation,
      false,
    );
    canvas.drawRRect(tile, Paint()..color = model.color);
    if (isCompleted) {
      canvas.drawRRect(tile, Paint()..color = const Color(0x1FFFFFFF));
      canvas.drawRRect(
        tile,
        Paint()
          ..color = const Color(0x66FFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.x * 0.018,
      );
    }
    if (isDropTarget) {
      canvas.drawRRect(tile, Paint()..color = AppPalette.tileDropOverlay);
      canvas.drawRRect(
        tile,
        Paint()
          ..color = AppPalette.tileDropTarget
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.x * 0.028,
      );
    }
    if (isHintSource) {
      canvas.drawRRect(
        tile,
        Paint()
          ..color = AppPalette.tileHintSource
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.x * 0.024,
      );
    }
    if (isHintDestination) {
      final pulse = (math.sin((_hintPulseElapsed / 1.2) * math.pi * 2) + 1) / 2;
      canvas.drawRRect(
        tile,
        Paint()
          ..color = AppPalette.tileHintDestination.withValues(
            alpha: 0.55 + pulse * 0.3,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.x * (0.022 + pulse * 0.009),
      );
    }
    canvas.restore();
  }
}
