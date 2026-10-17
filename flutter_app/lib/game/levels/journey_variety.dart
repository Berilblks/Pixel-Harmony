import 'package:pixel_harmony/game/levels/level_definition.dart';

abstract final class JourneyVariety {
  static void validateAdjacent(List<LevelDefinition> levels) {
    for (var index = 1; index < levels.length; index++) {
      final previous = levels[index - 1];
      final current = levels[index];
      if (previous.boardSize != current.boardSize) continue;

      if (paletteSignature(previous) == paletteSignature(current)) {
        throw StateError(
          '${previous.id} and ${current.id} use identical solution palettes.',
        );
      }
      if (permutationSignature(previous) == permutationSignature(current)) {
        throw StateError(
          '${previous.id} and ${current.id} use identical permutations.',
        );
      }
      if (effectiveShuffleSignature(previous) ==
          effectiveShuffleSignature(current)) {
        throw StateError(
          '${previous.id} and ${current.id} use effectively identical shuffles.',
        );
      }
    }
  }

  static String paletteSignature(LevelDefinition level) {
    final colorsById = {
      for (final tile in level.tiles) tile.id: tile.colorValue,
    };
    return level.solutionTileOrder.map((id) => colorsById[id]).join(',');
  }

  static String permutationSignature(LevelDefinition level) =>
      permutation(level).join(',');

  static String effectiveShuffleSignature(LevelDefinition level) {
    final normalizedPermutation = permutation(level);
    final displacements = [
      for (var index = 0; index < normalizedPermutation.length; index++)
        (normalizedPermutation[index] - index).abs(),
    ]..sort();
    return '${_cycleSignature(normalizedPermutation)}:${displacements.join(',')}';
  }

  static List<int> permutation(LevelDefinition level) {
    final solutionIndices = {
      for (var index = 0; index < level.solutionTileOrder.length; index++)
        level.solutionTileOrder[index]: index,
    };
    return [
      for (final tileId in level.initialTileOrder) solutionIndices[tileId]!,
    ];
  }

  static String _cycleSignature(List<int> permutation) {
    final visited = List.filled(permutation.length, false);
    final cycles = <int>[];
    for (var start = 0; start < permutation.length; start++) {
      if (visited[start] || permutation[start] == start) continue;
      var length = 0;
      var cursor = start;
      while (!visited[cursor]) {
        visited[cursor] = true;
        length++;
        cursor = permutation[cursor];
      }
      cycles.add(length);
    }
    cycles.sort();
    return cycles.join(',');
  }
}
