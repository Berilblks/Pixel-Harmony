import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/features/endless/domain/endless_difficulty_curve.dart';
import 'package:pixel_harmony/features/endless/domain/endless_progress.dart';
import 'package:pixel_harmony/game/generation/procedural_level_generator.dart';
import 'package:pixel_harmony/game/generation/procedural_level_request.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';

void main() {
  test('difficulty curve follows every documented boundary', () {
    for (final (completed, boardSize, difficulty) in const [
      (0, 3, LevelDifficulty.easy),
      (4, 3, LevelDifficulty.easy),
      (5, 3, LevelDifficulty.medium),
      (9, 3, LevelDifficulty.medium),
      (10, 4, LevelDifficulty.medium),
      (19, 4, LevelDifficulty.medium),
      (20, 4, LevelDifficulty.hard),
      (34, 4, LevelDifficulty.hard),
      (35, 5, LevelDifficulty.hard),
      (49, 5, LevelDifficulty.hard),
      (50, 5, LevelDifficulty.expert),
      (1000, 5, LevelDifficulty.expert),
    ]) {
      final parameters = EndlessDifficultyCurve.forCompletedCount(completed);
      expect(parameters.boardSize, boardSize);
      expect(parameters.targetDifficulty, difficulty);
    }
  });

  test('seed progression is deterministic and advances one puzzle', () {
    final first = EndlessProgress.initial();
    final next = first.advance();
    expect(next, first.advance());
    expect(next.completedPuzzleCount, 1);
    expect(next.puzzleNumber, 2);
    expect(next.currentSeed, isNot(first.currentSeed));
    expect(next.generationVersion, first.generationVersion);
  });

  test('same progress recreates the exact same generated puzzle', () {
    const generator = ProceduralLevelGenerator();
    final progress = EndlessProgress.initial().advance().advance();
    ProceduralLevelRequest request() => ProceduralLevelRequest(
      seed: progress.currentSeed,
      boardSize: progress.currentBoardSize,
      targetDifficulty: progress.currentTargetDifficulty,
    );

    final first = generator.generate(request());
    final second = generator.generate(request());
    expect(first.initialTileOrder, second.initialTileOrder);
    expect(first.solutionTileOrder, second.solutionTileOrder);
    expect(
      first.tiles.map((tile) => tile.colorValue),
      second.tiles.map((tile) => tile.colorValue),
    );
  });

  test(
    'first 100 puzzle identities are valid, supported, and collision-free',
    () {
      const generator = ProceduralLevelGenerator();
      var progress = EndlessProgress.initial();
      final seeds = <int>{};
      for (var index = 0; index < 100; index++) {
        expect(seeds.add(progress.currentSeed), isTrue);
        final level = generator.generate(
          ProceduralLevelRequest(
            seed: progress.currentSeed,
            boardSize: progress.currentBoardSize,
            targetDifficulty: progress.currentTargetDifficulty,
          ),
        );
        expect(level.boardSize, inInclusiveRange(3, 5));
        expect(level.tiles, hasLength(level.boardSize * level.boardSize));
        expect(level.initialTileOrder, isNot(level.solutionTileOrder));
        expect(() => level.toLevelDefinition(), returnsNormally);
        progress = progress.advance();
      }
      expect(seeds, hasLength(100));
    },
  );
}
