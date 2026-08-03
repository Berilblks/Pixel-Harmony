import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/board/board_target_detector.dart';

void main() {
  const detector = BoardTargetDetector();

  test('detects the cell containing the dragged tile center', () {
    final target = detector.detect(
      draggedCenter: const Point(155, 45),
      sourceIndex: 0,
      boardSize: 2,
      tileSize: 90,
      spacing: 20,
    );

    expect(target, 1);
  });

  test('rejects the source cell', () {
    final target = detector.detect(
      draggedCenter: const Point(45, 45),
      sourceIndex: 0,
      boardSize: 2,
      tileSize: 90,
      spacing: 20,
    );

    expect(target, isNull);
  });

  test('returns no target outside the board', () {
    final target = detector.detect(
      draggedCenter: const Point(205, 45),
      sourceIndex: 0,
      boardSize: 2,
      tileSize: 90,
      spacing: 20,
    );

    expect(target, isNull);
  });

  test('returns no target in spacing gaps', () {
    final target = detector.detect(
      draggedCenter: const Point(100, 100),
      sourceIndex: 0,
      boardSize: 2,
      tileSize: 90,
      spacing: 20,
    );

    expect(target, isNull);
  });
}
