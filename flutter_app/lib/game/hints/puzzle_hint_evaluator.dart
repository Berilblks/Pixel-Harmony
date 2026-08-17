import 'package:pixel_harmony/game/hints/puzzle_hint.dart';

class PuzzleHintEvaluator {
  const PuzzleHintEvaluator();

  PuzzleHint? evaluate({
    required List<String> currentTileIds,
    required List<String> solutionTileIds,
  }) {
    if (currentTileIds.length != solutionTileIds.length) {
      throw ArgumentError(
        'Current and solution orders must have equal length.',
      );
    }

    for (var index = 0; index < currentTileIds.length; index++) {
      final tileId = currentTileIds[index];
      if (tileId == solutionTileIds[index]) {
        continue;
      }

      final targetIndex = solutionTileIds.indexOf(tileId);
      if (targetIndex == -1) {
        throw ArgumentError.value(
          tileId,
          'currentTileIds',
          'Every current tile ID must exist in the solution.',
        );
      }
      return PuzzleHint(
        tileId: tileId,
        currentIndex: index,
        targetIndex: targetIndex,
      );
    }

    return null;
  }
}
