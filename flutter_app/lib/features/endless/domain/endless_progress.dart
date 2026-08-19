import 'package:pixel_harmony/features/endless/domain/endless_difficulty_curve.dart';
import 'package:pixel_harmony/game/generation/procedural_level_generator.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';

class EndlessProgress {
  const EndlessProgress({
    required this.currentSeed,
    required this.completedPuzzleCount,
    required this.generationVersion,
  });

  factory EndlessProgress.initial() {
    return const EndlessProgress(
      currentSeed: endlessStartSeedV1,
      completedPuzzleCount: 0,
      generationVersion: ProceduralLevelGenerator.generationVersion,
    );
  }

  static const endlessStartSeedV1 = 0x50485831;

  final int currentSeed;
  final int completedPuzzleCount;
  final int generationVersion;

  int get puzzleNumber => completedPuzzleCount + 1;

  EndlessPuzzleParameters get parameters =>
      EndlessDifficultyCurve.forCompletedCount(completedPuzzleCount);

  int get currentBoardSize => parameters.boardSize;

  LevelDifficulty get currentTargetDifficulty => parameters.targetDifficulty;

  EndlessProgress advance() {
    return EndlessProgress(
      currentSeed: nextSeed(currentSeed, completedPuzzleCount),
      completedPuzzleCount: completedPuzzleCount + 1,
      generationVersion: generationVersion,
    );
  }

  static int nextSeed(int currentSeed, int completedPuzzleCount) {
    if (completedPuzzleCount < 0) {
      throw ArgumentError.value(completedPuzzleCount, 'completedPuzzleCount');
    }
    return (currentSeed * 1664525 + 1013904223 + completedPuzzleCount) &
        0x7fffffff;
  }

  @override
  bool operator ==(Object other) {
    return other is EndlessProgress &&
        other.currentSeed == currentSeed &&
        other.completedPuzzleCount == completedPuzzleCount &&
        other.generationVersion == generationVersion;
  }

  @override
  int get hashCode =>
      Object.hash(currentSeed, completedPuzzleCount, generationVersion);
}
