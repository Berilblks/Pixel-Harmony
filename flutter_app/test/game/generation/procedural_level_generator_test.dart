import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/generation/difficulty_evaluator.dart';
import 'package:pixel_harmony/game/generation/generated_level.dart';
import 'package:pixel_harmony/game/generation/palette_generator.dart';
import 'package:pixel_harmony/game/generation/permutation_generator.dart';
import 'package:pixel_harmony/game/generation/procedural_level_generator.dart';
import 'package:pixel_harmony/game/generation/procedural_level_request.dart';
import 'package:pixel_harmony/game/generation/seeded_random.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/state/puzzle_solution.dart';

void main() {
  const generator = ProceduralLevelGenerator();
  const difficulties = [
    LevelDifficulty.easy,
    LevelDifficulty.medium,
    LevelDifficulty.hard,
    LevelDifficulty.expert,
  ];

  group('ProceduralLevelRequest', () {
    test('accepts only supported non-tutorial requests', () {
      for (final boardSize in [3, 4, 5]) {
        for (final difficulty in difficulties) {
          expect(
            () => ProceduralLevelRequest(
              seed: 1,
              boardSize: boardSize,
              targetDifficulty: difficulty,
            ),
            returnsNormally,
          );
        }
      }
      expect(
        () => ProceduralLevelRequest(
          seed: 1,
          boardSize: 2,
          targetDifficulty: LevelDifficulty.easy,
        ),
        throwsArgumentError,
      );
      expect(
        () => ProceduralLevelRequest(
          seed: 1,
          boardSize: 3,
          targetDifficulty: LevelDifficulty.tutorial,
        ),
        throwsArgumentError,
      );
    });
  });

  group('deterministic components', () {
    test('seeded random produces a stable sequence', () {
      final first = SeededRandom(12345);
      final second = SeededRandom(12345);
      expect(
        List.generate(20, (_) => first.nextUint32()),
        List.generate(20, (_) => second.nextUint32()),
      );
    });

    test('palette generation is deterministic', () {
      const paletteGenerator = PaletteGenerator();
      final first = paletteGenerator.generate(
        seed: 44,
        boardSize: 5,
        difficulty: LevelDifficulty.hard,
        attempt: 3,
      );
      final second = paletteGenerator.generate(
        seed: 44,
        boardSize: 5,
        difficulty: LevelDifficulty.hard,
        attempt: 3,
      );
      expect(first, second);
      expect(first.toSet(), hasLength(25));
    });

    test('controlled permutation is deterministic and nontrivial', () {
      const permutationGenerator = PermutationGenerator();
      final solution = List.generate(16, (index) => 'tile_$index');
      final first = permutationGenerator.generate(
        solutionOrder: solution,
        seed: 99,
        boardSize: 4,
        difficulty: LevelDifficulty.medium,
        attempt: 2,
      );
      final second = permutationGenerator.generate(
        solutionOrder: solution,
        seed: 99,
        boardSize: 4,
        difficulty: LevelDifficulty.medium,
        attempt: 2,
      );
      expect(first, second);
      expect(first, isNot(solution));
      expect(first.toSet(), solution.toSet());
      expect(_misplacedCount(first, solution), greaterThanOrEqualTo(3));
    });
  });

  group('ProceduralLevelGenerator', () {
    test('same complete request always produces the same level', () {
      final request = ProceduralLevelRequest(
        seed: 12345,
        paletteSeed: 678,
        boardSize: 4,
        targetDifficulty: LevelDifficulty.medium,
        generatedLevelId: 'daily_12345',
      );
      final first = generator.generate(request);
      final second = generator.generate(request);

      expect(first.id, second.id);
      expect(
        first.tiles.map((tile) => tile.id),
        second.tiles.map((tile) => tile.id),
      );
      expect(
        first.tiles.map((tile) => tile.colorValue),
        second.tiles.map((tile) => tile.colorValue),
      );
      expect(first.initialTileOrder, second.initialTileOrder);
      expect(first.solutionTileOrder, second.solutionTileOrder);
      expect(first.difficulty, second.difficulty);
      expect(first.difficultyScore, second.difficultyScore);
      expect(first.generationVersion, second.generationVersion);
    });

    test('different seeds produce meaningfully different output', () {
      final first = generator.generate(
        ProceduralLevelRequest(
          seed: 10,
          boardSize: 4,
          targetDifficulty: LevelDifficulty.hard,
        ),
      );
      final second = generator.generate(
        ProceduralLevelRequest(
          seed: 11,
          boardSize: 4,
          targetDifficulty: LevelDifficulty.hard,
        ),
      );
      expect(first.id, isNot(second.id));
      expect(first.solutionTileOrder, isNot(second.solutionTileOrder));
      expect(
        first.tiles.map((tile) => tile.colorValue),
        isNot(second.tiles.map((tile) => tile.colorValue)),
      );
      expect(first.initialTileOrder, isNot(second.initialTileOrder));
    });

    test('supports every board size and requested difficulty', () {
      for (final boardSize in [3, 4, 5]) {
        for (final difficulty in difficulties) {
          final level = generator.generate(
            ProceduralLevelRequest(
              seed: boardSize * 100 + difficulty.index,
              boardSize: boardSize,
              targetDifficulty: difficulty,
            ),
          );
          _expectValid(level);
        }
      }
    });

    test('solution order is compatible with PuzzleSolution', () {
      final level = generator.generate(
        ProceduralLevelRequest(
          seed: 91,
          boardSize: 3,
          targetDifficulty: LevelDifficulty.easy,
        ),
      );
      final solution = PuzzleSolution(tileIds: level.solutionTileOrder);
      expect(solution.matches(level.solutionTileOrder), isTrue);
      expect(solution.matches(level.initialTileOrder), isFalse);
    });

    test('generated model can create a validated LevelDefinition', () {
      final generated = generator.generate(
        ProceduralLevelRequest(
          seed: 72,
          boardSize: 5,
          targetDifficulty: LevelDifficulty.expert,
        ),
      );
      final definition = generated.toLevelDefinition(
        number: 1001,
        nameKey: 'generatedLevel',
      );
      expect(definition.id, generated.id);
      expect(definition.boardSize, 5);
    });

    test('attempt count is deterministic and bounded', () {
      final level = generator.generate(
        ProceduralLevelRequest(
          seed: 17,
          boardSize: 4,
          targetDifficulty: LevelDifficulty.hard,
        ),
      );
      expect(level.candidateAttempts, 32);
      expect(level.candidateAttempts, inInclusiveRange(20, 50));
      expect(level.generationVersion, 1);
    });

    test('difficulty bands rise across representative seeds', () {
      final totals = <LevelDifficulty, int>{
        for (final difficulty in difficulties) difficulty: 0,
      };
      for (var seed = 1; seed <= 24; seed++) {
        for (final difficulty in difficulties) {
          totals[difficulty] =
              totals[difficulty]! +
              generator
                  .generate(
                    ProceduralLevelRequest(
                      seed: seed,
                      boardSize: 4,
                      targetDifficulty: difficulty,
                    ),
                  )
                  .difficultyScore;
        }
      }
      expect(
        totals[LevelDifficulty.easy]!,
        lessThan(totals[LevelDifficulty.hard]!),
      );
      expect(
        totals[LevelDifficulty.medium]!,
        lessThan(totals[LevelDifficulty.expert]!),
      );
    });

    test('250-seed stress sample preserves all invariants', () {
      final stopwatch = Stopwatch()..start();
      var generatedCount = 0;
      for (var seed = 1; seed <= 250; seed++) {
        final boardSize = 3 + seed % 3;
        for (final difficulty in difficulties) {
          final level = generator.generate(
            ProceduralLevelRequest(
              seed: seed,
              paletteSeed: seed * 31,
              boardSize: boardSize,
              targetDifficulty: difficulty,
            ),
          );
          _expectValid(level);
          generatedCount++;
        }
      }
      stopwatch.stop();
      // Informational only: CI hardware differs, so this is not a timing gate.
      // ignore: avoid_print
      print(
        'Generated $generatedCount procedural levels in '
        '${stopwatch.elapsedMilliseconds} ms.',
      );
      expect(generatedCount, 1000);
    });

    test('reports benchmark-style timings by board size', () {
      for (final boardSize in [3, 4, 5]) {
        final stopwatch = Stopwatch()..start();
        for (var seed = 1; seed <= 40; seed++) {
          generator.generate(
            ProceduralLevelRequest(
              seed: seed,
              boardSize: boardSize,
              targetDifficulty: LevelDifficulty.hard,
            ),
          );
        }
        stopwatch.stop();
        final averageMicroseconds = stopwatch.elapsedMicroseconds / 40;
        // ignore: avoid_print
        print(
          '${boardSize}x$boardSize average: ${averageMicroseconds.round()} us',
        );
      }
    });
  });

  group('DifficultyEvaluator', () {
    test('maps all score boundaries to existing difficulty metadata', () {
      expect(
        DifficultyEvaluator.difficultyForScore(1),
        LevelDifficulty.tutorial,
      );
      expect(
        DifficultyEvaluator.difficultyForScore(10),
        LevelDifficulty.tutorial,
      );
      expect(DifficultyEvaluator.difficultyForScore(11), LevelDifficulty.easy);
      expect(DifficultyEvaluator.difficultyForScore(30), LevelDifficulty.easy);
      expect(
        DifficultyEvaluator.difficultyForScore(31),
        LevelDifficulty.medium,
      );
      expect(
        DifficultyEvaluator.difficultyForScore(55),
        LevelDifficulty.medium,
      );
      expect(DifficultyEvaluator.difficultyForScore(56), LevelDifficulty.hard);
      expect(DifficultyEvaluator.difficultyForScore(80), LevelDifficulty.hard);
      expect(
        DifficultyEvaluator.difficultyForScore(81),
        LevelDifficulty.expert,
      );
      expect(
        DifficultyEvaluator.difficultyForScore(100),
        LevelDifficulty.expert,
      );
    });

    test('uses permutation complexity in addition to board size', () {
      const evaluator = DifficultyEvaluator();
      final solution = List.generate(9, (index) => 'tile_$index');
      const colors = [
        0xff275d8c,
        0xff3170a0,
        0xff3d83b4,
        0xff39739a,
        0xff4386ae,
        0xff4f99c2,
        0xff4b89a8,
        0xff559cbc,
        0xff61afd0,
      ];
      final easier = evaluator.evaluate(
        boardSize: 3,
        solutionColors: colors,
        initialOrder: [solution[1], solution[0], ...solution.skip(2)],
        solutionOrder: solution,
      );
      final harder = evaluator.evaluate(
        boardSize: 3,
        solutionColors: colors,
        initialOrder: [...solution.skip(1), solution.first],
        solutionOrder: solution,
      );
      expect(harder.minimumSwaps, greaterThan(easier.minimumSwaps));
      expect(harder.misplacedTiles, greaterThan(easier.misplacedTiles));
      expect(harder.score, greaterThan(easier.score));
    });

    test('closer neighboring colors increase evaluated difficulty', () {
      const evaluator = DifficultyEvaluator();
      final solution = List.generate(9, (index) => 'tile_$index');
      final initial = [...solution.skip(1), solution.first];
      final distinct = List.generate(
        9,
        (index) => 0xff203040 + index * 0x080402,
      );
      final close = List.generate(9, (index) => 0xff506070 + index * 0x010101);
      final distinctResult = evaluator.evaluate(
        boardSize: 3,
        solutionColors: distinct,
        initialOrder: initial,
        solutionOrder: solution,
      );
      final closeResult = evaluator.evaluate(
        boardSize: 3,
        solutionColors: close,
        initialOrder: initial,
        solutionOrder: solution,
      );
      expect(
        closeResult.paletteSimilarity,
        greaterThan(distinctResult.paletteSimilarity),
      );
      expect(closeResult.score, greaterThan(distinctResult.score));
    });
  });
}

void _expectValid(GeneratedLevel level) {
  final expectedCount = level.boardSize * level.boardSize;
  final tileIds = level.tiles.map((tile) => tile.id).toList();
  expect(level.tiles, hasLength(expectedCount));
  expect(tileIds.toSet(), hasLength(expectedCount));
  expect(level.solutionTileOrder.toSet(), tileIds.toSet());
  expect(level.initialTileOrder.toSet(), tileIds.toSet());
  expect(level.initialTileOrder, isNot(level.solutionTileOrder));
  expect(level.difficultyScore, inInclusiveRange(1, 100));
  expect(
    level.difficulty,
    DifficultyEvaluator.difficultyForScore(level.difficultyScore),
  );
  expect(level.generationVersion, greaterThan(0));
  expect(() => level.toLevelDefinition(), returnsNormally);
}

int _misplacedCount(List<String> first, List<String> second) {
  var count = 0;
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) count++;
  }
  return count;
}
