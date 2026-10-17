import 'dart:math' as math;

import 'package:pixel_harmony/game/levels/level_definition.dart';

abstract final class JourneyGradient {
  static double relativeLuminance(int colorValue) {
    double linearChannel(int shift) {
      final channel = ((colorValue >> shift) & 0xff) / 255;
      return channel <= 0.04045
          ? channel / 12.92
          : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
    }

    return 0.2126 * linearChannel(16) +
        0.7152 * linearChannel(8) +
        0.0722 * linearChannel(0);
  }

  static LevelDefinition enforceDarkToLight(LevelDefinition authored) {
    final authoredSolution = authored.solutionTileOrder;
    final initialPermutation = [
      for (final tileId in authored.initialTileOrder)
        authoredSolution.indexOf(tileId),
    ];
    final orderedTiles = List<LevelTileDefinition>.of(authored.tiles)
      ..sort((first, second) {
        final luminanceComparison = relativeLuminance(
          first.colorValue,
        ).compareTo(relativeLuminance(second.colorValue));
        return luminanceComparison != 0
            ? luminanceComparison
            : first.id.compareTo(second.id);
      });
    final solution = orderedTiles
        .map((tile) => tile.id)
        .toList(growable: false);

    _validateStrictLuminance(orderedTiles, authored.id);
    return LevelDefinition(
      id: authored.id,
      number: authored.number,
      nameKey: authored.nameKey,
      boardSize: authored.boardSize,
      rowCount: authored.rowCount,
      columnCount: authored.columnCount,
      difficulty: authored.difficulty,
      difficultyScore: authored.difficultyScore,
      tiles: authored.tiles,
      initialTileOrder: [
        for (final index in initialPermutation) solution[index],
      ],
      solutionTileOrder: solution,
    );
  }

  static void _validateStrictLuminance(
    List<LevelTileDefinition> orderedTiles,
    String levelId,
  ) {
    for (var index = 1; index < orderedTiles.length; index++) {
      if (relativeLuminance(orderedTiles[index - 1].colorValue) >=
          relativeLuminance(orderedTiles[index].colorValue)) {
        throw StateError('$levelId contains equal-lightness Journey colors.');
      }
    }
  }
}
