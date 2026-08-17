import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/hints/puzzle_hint_evaluator.dart';

void main() {
  const evaluator = PuzzleHintEvaluator();

  test('solved puzzle returns no hint', () {
    final hint = evaluator.evaluate(
      currentTileIds: const ['a', 'b', 'c', 'd'],
      solutionTileIds: const ['a', 'b', 'c', 'd'],
    );

    expect(hint, isNull);
  });

  test('returns the first misplaced tile and its solution index', () {
    final hint = evaluator.evaluate(
      currentTileIds: const ['b', 'a', 'c', 'd'],
      solutionTileIds: const ['a', 'b', 'c', 'd'],
    );

    expect(hint, isNotNull);
    expect(hint!.tileId, 'b');
    expect(hint.currentIndex, 0);
    expect(hint.targetIndex, 1);
  });

  test('comparison is based on stable tile IDs', () {
    final hint = evaluator.evaluate(
      currentTileIds: const ['blue_tile', 'green_tile'],
      solutionTileIds: const ['green_tile', 'blue_tile'],
    );

    expect(hint?.tileId, 'blue_tile');
    expect(hint?.targetIndex, 1);
  });
}
