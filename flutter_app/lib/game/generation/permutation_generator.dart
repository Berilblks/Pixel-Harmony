import 'package:pixel_harmony/game/generation/seeded_random.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';

class PermutationGenerator {
  const PermutationGenerator();

  List<String> generate({
    required List<String> solutionOrder,
    required int seed,
    required int boardSize,
    required LevelDifficulty difficulty,
    required int attempt,
  }) {
    final random = SeededRandom(seed ^ ((attempt + 1) * 0x27d4eb2d));
    final positions = List.generate(solutionOrder.length, (index) => index);
    for (var index = positions.length - 1; index > 0; index--) {
      final other = random.nextInt(index + 1);
      final value = positions[index];
      positions[index] = positions[other];
      positions[other] = value;
    }

    final baseSwapCount = switch (difficulty) {
      LevelDifficulty.tutorial =>
        throw ArgumentError('Tutorial permutations are not procedural.'),
      LevelDifficulty.easy => boardSize - 2,
      LevelDifficulty.medium => (solutionOrder.length * 0.40).round(),
      LevelDifficulty.hard => (solutionOrder.length * 0.62).round(),
      LevelDifficulty.expert => (solutionOrder.length * 0.82).round(),
    };
    final jitter = attempt % 3 - 1;
    final swapCount = (baseSwapCount + jitter).clamp(
      difficulty == LevelDifficulty.easy ? 1 : 2,
      solutionOrder.length - 1,
    );
    final result = List<String>.of(solutionOrder);
    final anchor = positions.first;
    for (var index = 1; index <= swapCount; index++) {
      final target = positions[index];
      final value = result[anchor];
      result[anchor] = result[target];
      result[target] = value;
    }
    return List.unmodifiable(result);
  }
}
