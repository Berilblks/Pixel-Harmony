import 'package:pixel_harmony/game/levels/level_definition.dart';

class EndlessPuzzleParameters {
  const EndlessPuzzleParameters({
    required this.boardSize,
    required this.targetDifficulty,
  });

  final int boardSize;
  final LevelDifficulty targetDifficulty;
}

abstract final class EndlessDifficultyCurve {
  static EndlessPuzzleParameters forCompletedCount(int completedPuzzleCount) {
    if (completedPuzzleCount < 0) {
      throw ArgumentError.value(
        completedPuzzleCount,
        'completedPuzzleCount',
        'Must not be negative.',
      );
    }
    if (completedPuzzleCount < 5) {
      return const EndlessPuzzleParameters(
        boardSize: 3,
        targetDifficulty: LevelDifficulty.easy,
      );
    }
    if (completedPuzzleCount < 10) {
      return const EndlessPuzzleParameters(
        boardSize: 3,
        targetDifficulty: LevelDifficulty.medium,
      );
    }
    if (completedPuzzleCount < 20) {
      return const EndlessPuzzleParameters(
        boardSize: 4,
        targetDifficulty: LevelDifficulty.medium,
      );
    }
    if (completedPuzzleCount < 35) {
      return const EndlessPuzzleParameters(
        boardSize: 4,
        targetDifficulty: LevelDifficulty.hard,
      );
    }
    if (completedPuzzleCount < 50) {
      return const EndlessPuzzleParameters(
        boardSize: 5,
        targetDifficulty: LevelDifficulty.hard,
      );
    }
    return const EndlessPuzzleParameters(
      boardSize: 5,
      targetDifficulty: LevelDifficulty.expert,
    );
  }
}
