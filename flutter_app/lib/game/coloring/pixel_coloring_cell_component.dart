import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';

typedef PixelCellTapCallback = void Function(int cellIndex);

class PixelColoringCellComponent extends PositionComponent with TapCallbacks {
  PixelColoringCellComponent({
    required this.cellIndex,
    required this.targetColor,
    required this.identifier,
    required this.paintable,
    required this.onTapped,
  });

  final int cellIndex;
  final Color targetColor;
  final int identifier;
  final bool paintable;
  final PixelCellTapCallback onTapped;

  bool painted = false;
  bool matchesSelection = false;
  double _fillProgress = 0;
  double _wrongFeedback = 0;

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    onTapped(cellIndex);
  }

  void showWrongFeedback() => _wrongFeedback = 0.3;

  @override
  void update(double dt) {
    super.update(dt);
    _wrongFeedback = math.max(0, _wrongFeedback - dt);
    final target = painted ? 1.0 : 0.0;
    if (_fillProgress < target) {
      _fillProgress = math.min(target, _fillProgress + dt / 0.18);
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    final background =
        paintable
            ? const Color(0xFFF8F4ED)
            : targetColor.withValues(alpha: 0.3);
    canvas.drawRect(rect, Paint()..color = background);

    if (painted) {
      final inset = (1 - _fillProgress) * size.x * 0.28;
      canvas.drawRect(rect.deflate(inset), Paint()..color = targetColor);
    } else if (paintable) {
      if (matchesSelection) {
        canvas.drawRect(
          rect.deflate(1),
          Paint()..color = targetColor.withValues(alpha: 0.12),
        );
      }
      TextPaint(
        style: TextStyle(
          color: const Color(0xFF514B45).withValues(alpha: 0.82),
          fontSize: (size.x * 0.34).clamp(8.0, 15.0),
          fontWeight: FontWeight.w600,
        ),
      ).render(
        canvas,
        '$identifier',
        Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
      );
    }

    canvas.drawRect(
      rect,
      Paint()
        ..color =
            _wrongFeedback > 0
                ? const Color(
                  0xFFB86C62,
                ).withValues(alpha: (_wrongFeedback / 0.3) * 0.8)
                : const Color(0x24514B45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = matchesSelection && !painted ? 1.5 : 0.7,
    );
  }
}
