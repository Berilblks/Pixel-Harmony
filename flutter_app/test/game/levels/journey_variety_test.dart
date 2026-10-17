import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/levels/journey_color_family.dart';
import 'package:pixel_harmony/game/levels/journey_level_generator.dart';
import 'package:pixel_harmony/game/levels/journey_variety.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_catalog.dart';

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

  test('Gradient families are balanced and avoid recent visual repeats', () {
    final families = [
      for (var ordinal = 0; ordinal < 196; ordinal++)
        JourneyColorFamily.forGradientOrdinal(ordinal),
    ];
    final counts = {
      for (final family in JourneyColorFamilyId.values)
        family: families.where((item) => item == family).length,
    };
    expect(counts.values.reduce(_maximum) - counts.values.reduce(_minimum), 0);
    for (var index = 0; index < families.length; index++) {
      expect(
        families.skip((index - 5).clamp(0, index)).take(index < 5 ? index : 5),
        isNot(contains(families[index])),
        reason: 'Gradient ordinal $index repeats a recent family',
      );
      if (index > 0) {
        expect(
          JourneyColorFamily.areVisuallyClose(
            families[index - 1],
            families[index],
          ),
          isFalse,
          reason: 'Gradient ordinal $index uses adjacent near-hue families',
        );
      }
    }
  });

  test('first 100 levels use all named Gradient families', () {
    const generator = JourneyLevelGenerator();
    final families = <JourneyColorFamilyId>{};
    for (var number = 1; number <= 100; number++) {
      final level = generator.generate(number);
      if (level.puzzleType != JourneyPuzzleType.gradient) continue;
      final colors = {for (final tile in level.tiles) tile.id: tile.colorValue};
      final middle =
          level.solutionTileOrder[level.solutionTileOrder.length ~/ 2];
      families.add(JourneyColorFamily.nearestToColor(colors[middle]!));
    }
    expect(families, containsAll(JourneyColorFamilyId.values));
  });

  test('Pixel Coloring balances category without breaking difficulty', () {
    final assessments = PixelPictureCatalog.journeyAssessments;
    var adjacentCategoryRepeats = 0;
    for (var index = 1; index < assessments.length; index++) {
      if (assessments[index - 1].template.category ==
          assessments[index].template.category) {
        adjacentCategoryRepeats++;
      }
      expect(
        assessments[index].score - assessments[index - 1].score,
        inInclusiveRange(-3, 8),
      );
    }
    expect(adjacentCategoryRepeats, lessThanOrEqualTo(12));
    expect(assessments.map((item) => item.template.id).toSet(), hasLength(100));
  });
}

int _minimum(int first, int second) => first < second ? first : second;
int _maximum(int first, int second) => first > second ? first : second;
