import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/levels/journey_variety.dart';

void main() {
  test('Levels 7, 8, and 9 use distinct palettes and permutations', () {
    final levels = [
      LevelCatalog.byId('level_007'),
      LevelCatalog.byId('level_008'),
      LevelCatalog.byId('level_009'),
    ];

    expect(levels.map(JourneyVariety.paletteSignature).toSet(), hasLength(3));
    expect(
      levels.map(JourneyVariety.permutationSignature).toSet(),
      hasLength(3),
    );
    expect(
      levels.map(JourneyVariety.effectiveShuffleSignature).toSet(),
      hasLength(3),
    );
  });

  test('adjacent Journey levels never repeat gameplay signatures', () {
    for (var index = 1; index < LevelCatalog.levels.length; index++) {
      final previous = LevelCatalog.levels[index - 1];
      final current = LevelCatalog.levels[index];
      if (previous.boardSize != current.boardSize) continue;

      expect(
        JourneyVariety.paletteSignature(current),
        isNot(JourneyVariety.paletteSignature(previous)),
        reason: '${previous.id} -> ${current.id} palette',
      );
      expect(
        JourneyVariety.permutationSignature(current),
        isNot(JourneyVariety.permutationSignature(previous)),
        reason: '${previous.id} -> ${current.id} permutation',
      );
      expect(
        JourneyVariety.effectiveShuffleSignature(current),
        isNot(JourneyVariety.effectiveShuffleSignature(previous)),
        reason: '${previous.id} -> ${current.id} shuffle structure',
      );
    }
  });

  test('difficulty rises over broad windows while allowing breathers', () {
    final early = LevelCatalog.levels
        .take(20)
        .map((level) => level.difficultyScore);
    final late = LevelCatalog.levels
        .skip(80)
        .map((level) => level.difficultyScore);
    expect(
      late.reduce((a, b) => a + b) / late.length,
      greaterThan(early.reduce((a, b) => a + b) / early.length),
    );
  });
}
