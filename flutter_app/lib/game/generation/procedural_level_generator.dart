import 'package:pixel_harmony/game/generation/difficulty_evaluator.dart';
import 'package:pixel_harmony/game/generation/generated_level.dart';
import 'package:pixel_harmony/game/generation/palette_generator.dart';
import 'package:pixel_harmony/game/generation/permutation_generator.dart';
import 'package:pixel_harmony/game/generation/procedural_level_request.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';

class ProceduralLevelGenerator {
  const ProceduralLevelGenerator({
    this.maximumAttempts = 32,
    PaletteGenerator paletteGenerator = const PaletteGenerator(),
    PermutationGenerator permutationGenerator = const PermutationGenerator(),
    DifficultyEvaluator difficultyEvaluator = const DifficultyEvaluator(),
  }) : _paletteGenerator = paletteGenerator,
       _permutationGenerator = permutationGenerator,
       _difficultyEvaluator = difficultyEvaluator;

  static const generationVersion = 1;

  final int maximumAttempts;
  final PaletteGenerator _paletteGenerator;
  final PermutationGenerator _permutationGenerator;
  final DifficultyEvaluator _difficultyEvaluator;

  GeneratedLevel generate(ProceduralLevelRequest request) {
    if (maximumAttempts < 20 || maximumAttempts > 50) {
      throw StateError('maximumAttempts must remain between 20 and 50.');
    }
    final tileCount = request.boardSize * request.boardSize;
    final tileIds = List.generate(
      tileCount,
      (index) => 'generated_${request.seed}_$index',
      growable: false,
    );
    final target = _targetMidpoint(request.targetDifficulty);
    _Candidate? best;

    for (var attempt = 0; attempt < maximumAttempts; attempt++) {
      final colors = _paletteGenerator.generate(
        seed: request.paletteSeed ?? request.seed,
        boardSize: request.boardSize,
        difficulty: request.targetDifficulty,
        attempt: attempt,
      );
      if (!_paletteIsUsable(colors, request.boardSize)) continue;
      final initialOrder = _permutationGenerator.generate(
        solutionOrder: tileIds,
        seed: request.seed,
        boardSize: request.boardSize,
        difficulty: request.targetDifficulty,
        attempt: attempt,
      );
      final evaluation = _difficultyEvaluator.evaluate(
        boardSize: request.boardSize,
        solutionColors: colors,
        initialOrder: initialOrder,
        solutionOrder: tileIds,
      );
      final candidate = _Candidate(
        colors: colors,
        initialOrder: initialOrder,
        evaluation: evaluation,
        distanceFromTarget: (evaluation.score - target).abs(),
      );
      if (best == null || candidate.isBetterThan(best)) best = candidate;
    }
    if (best == null) {
      throw StateError('Unable to produce a visually valid palette.');
    }

    final tiles = List.generate(
      tileCount,
      (index) => LevelTileDefinition(
        id: tileIds[index],
        colorValue: best!.colors[index],
      ),
      growable: false,
    );
    return GeneratedLevel(
      id:
          request.generatedLevelId ??
          'generated_${request.seed}_${request.boardSize}_${request.targetDifficulty.name}',
      seed: request.seed,
      boardSize: request.boardSize,
      tiles: tiles,
      initialTileOrder: best.initialOrder,
      solutionTileOrder: tileIds,
      difficulty: best.evaluation.difficulty,
      difficultyScore: best.evaluation.score,
      generationVersion: generationVersion,
      candidateAttempts: maximumAttempts,
    );
  }

  static bool _paletteIsUsable(List<int> colors, int boardSize) {
    if (colors.toSet().length != colors.length) return false;
    var minimumNeighborDistance = double.infinity;
    for (var row = 0; row < boardSize; row++) {
      for (var column = 0; column < boardSize; column++) {
        final index = row * boardSize + column;
        if (column + 1 < boardSize) {
          final distance = DifficultyEvaluator.colorDistance(
            colors[index],
            colors[index + 1],
          );
          if (distance < minimumNeighborDistance) {
            minimumNeighborDistance = distance;
          }
        }
        if (row + 1 < boardSize) {
          final distance = DifficultyEvaluator.colorDistance(
            colors[index],
            colors[index + boardSize],
          );
          if (distance < minimumNeighborDistance) {
            minimumNeighborDistance = distance;
          }
        }
      }
    }
    return minimumNeighborDistance >= 3.5;
  }

  static double _targetMidpoint(LevelDifficulty difficulty) {
    return switch (difficulty) {
      LevelDifficulty.tutorial =>
        throw ArgumentError('Tutorial levels are not generated.'),
      LevelDifficulty.easy => 20.5,
      LevelDifficulty.medium => 43,
      LevelDifficulty.hard => 68,
      LevelDifficulty.expert => 90.5,
    };
  }
}

class _Candidate {
  const _Candidate({
    required this.colors,
    required this.initialOrder,
    required this.evaluation,
    required this.distanceFromTarget,
  });

  final List<int> colors;
  final List<String> initialOrder;
  final DifficultyEvaluation evaluation;
  final double distanceFromTarget;

  bool isBetterThan(_Candidate other) {
    if (distanceFromTarget != other.distanceFromTarget) {
      return distanceFromTarget < other.distanceFromTarget;
    }
    return initialOrder.join().compareTo(other.initialOrder.join()) < 0;
  }
}
