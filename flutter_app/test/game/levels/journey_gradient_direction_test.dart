import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/levels/journey_gradient.dart';

void main() {
  test('all 100 Journey levels start darkest and end lightest', () {
    for (final level in LevelCatalog.levels) {
      if (level.puzzleType != JourneyPuzzleType.gradient) continue;
      final luminances = _solutionLuminances(level);
      expect(luminances.first, luminances.reduce(_minimum), reason: level.id);
      expect(luminances.last, luminances.reduce(_maximum), reason: level.id);
    }
  });

  test('all Journey solution paths are strictly dark to light', () {
    for (final level in LevelCatalog.levels) {
      if (level.puzzleType != JourneyPuzzleType.gradient) continue;
      expect(
        _strictlyIncreasing(_solutionLuminances(level)),
        isTrue,
        reason: '${level.id} must never reverse luminance direction',
      );
    }
  });
}

List<double> _solutionLuminances(LevelDefinition level) {
  final colorById = {for (final tile in level.tiles) tile.id: tile.colorValue};
  return [
    for (final id in level.solutionTileOrder)
      JourneyGradient.relativeLuminance(colorById[id]!),
  ];
}

double _minimum(double first, double second) => first < second ? first : second;

double _maximum(double first, double second) => first > second ? first : second;

bool _strictlyIncreasing(List<double> values) {
  for (var index = 1; index < values.length; index++) {
    if (values[index - 1] >= values[index]) return false;
  }
  return true;
}
