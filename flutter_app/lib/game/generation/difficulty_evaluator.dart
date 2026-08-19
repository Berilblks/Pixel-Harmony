import 'dart:math' as math;

import 'package:pixel_harmony/game/levels/level_definition.dart';

class DifficultyEvaluation {
  const DifficultyEvaluation({
    required this.score,
    required this.difficulty,
    required this.minimumSwaps,
    required this.misplacedTiles,
    required this.averageDisplacement,
    required this.paletteSimilarity,
    required this.closeNeighborRatio,
  });

  final int score;
  final LevelDifficulty difficulty;
  final int minimumSwaps;
  final int misplacedTiles;
  final double averageDisplacement;
  final double paletteSimilarity;
  final double closeNeighborRatio;
}

class DifficultyEvaluator {
  const DifficultyEvaluator();

  DifficultyEvaluation evaluate({
    required int boardSize,
    required List<int> solutionColors,
    required List<String> initialOrder,
    required List<String> solutionOrder,
  }) {
    if (boardSize < 2 || solutionColors.length != boardSize * boardSize) {
      throw ArgumentError('Board size and color count do not match.');
    }
    if (initialOrder.length != solutionOrder.length ||
        initialOrder.toSet().length != initialOrder.length ||
        initialOrder.toSet().difference(solutionOrder.toSet()).isNotEmpty ||
        solutionOrder.toSet().difference(initialOrder.toSet()).isNotEmpty) {
      throw ArgumentError('Orders must contain the same unique tile IDs.');
    }

    final solutionIndices = <String, int>{
      for (var index = 0; index < solutionOrder.length; index++)
        solutionOrder[index]: index,
    };
    var misplaced = 0;
    var displacement = 0.0;
    final permutation = <int>[];
    for (var index = 0; index < initialOrder.length; index++) {
      final destination = solutionIndices[initialOrder[index]]!;
      permutation.add(destination);
      if (destination != index) {
        misplaced++;
      }
      final rowDistance = (index ~/ boardSize - destination ~/ boardSize).abs();
      final columnDistance =
          (index % boardSize - destination % boardSize).abs();
      displacement += rowDistance + columnDistance;
    }

    final minimumSwaps = _minimumSwaps(permutation);
    final averageDisplacement =
        displacement / (initialOrder.length * math.max(1, 2 * (boardSize - 1)));
    final palette = _evaluatePalette(solutionColors, boardSize);
    final boardFactor = (boardSize - 3) / 2;
    final swapFactor = minimumSwaps / (initialOrder.length - 1);
    final misplacedFactor = misplaced / initialOrder.length;
    final rawScore =
        1 +
        boardFactor * 8 +
        swapFactor * 34 +
        misplacedFactor * 20 +
        averageDisplacement * 15 +
        palette.$1 * 17 +
        palette.$2 * 5;
    final score = rawScore.round().clamp(1, 100);

    return DifficultyEvaluation(
      score: score,
      difficulty: difficultyForScore(score),
      minimumSwaps: minimumSwaps,
      misplacedTiles: misplaced,
      averageDisplacement: averageDisplacement,
      paletteSimilarity: palette.$1,
      closeNeighborRatio: palette.$2,
    );
  }

  static LevelDifficulty difficultyForScore(int score) {
    if (score < 1 || score > 100) {
      throw ArgumentError.value(score, 'score', 'Must be between 1 and 100.');
    }
    if (score <= 10) return LevelDifficulty.tutorial;
    if (score <= 30) return LevelDifficulty.easy;
    if (score <= 55) return LevelDifficulty.medium;
    if (score <= 80) return LevelDifficulty.hard;
    return LevelDifficulty.expert;
  }

  static int _minimumSwaps(List<int> permutation) {
    final visited = List.filled(permutation.length, false);
    var cycles = 0;
    for (var index = 0; index < permutation.length; index++) {
      if (visited[index]) continue;
      cycles++;
      var cursor = index;
      while (!visited[cursor]) {
        visited[cursor] = true;
        cursor = permutation[cursor];
      }
    }
    return permutation.length - cycles;
  }

  static (double, double) _evaluatePalette(List<int> colors, int boardSize) {
    var totalDistance = 0.0;
    var closeNeighbors = 0;
    var comparisons = 0;
    for (var row = 0; row < boardSize; row++) {
      for (var column = 0; column < boardSize; column++) {
        final index = row * boardSize + column;
        if (column + 1 < boardSize) {
          final distance = colorDistance(colors[index], colors[index + 1]);
          totalDistance += distance;
          closeNeighbors += distance < 32 ? 1 : 0;
          comparisons++;
        }
        if (row + 1 < boardSize) {
          final distance = colorDistance(
            colors[index],
            colors[index + boardSize],
          );
          totalDistance += distance;
          closeNeighbors += distance < 32 ? 1 : 0;
          comparisons++;
        }
      }
    }
    final averageDistance = totalDistance / comparisons;
    final similarity = (1 - averageDistance / 120).clamp(0.0, 1.0);
    return (similarity, closeNeighbors / comparisons);
  }

  static double colorDistance(int first, int second) {
    final red = ((first >> 16) & 0xff) - ((second >> 16) & 0xff);
    final green = ((first >> 8) & 0xff) - ((second >> 8) & 0xff);
    final blue = (first & 0xff) - (second & 0xff);
    return math.sqrt(red * red + green * green + blue * blue);
  }
}
