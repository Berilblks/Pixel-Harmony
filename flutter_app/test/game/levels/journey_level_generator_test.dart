import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/levels/journey_color_family.dart';
import 'package:pixel_harmony/game/levels/journey_gradient.dart';
import 'package:pixel_harmony/game/levels/journey_level_fingerprint.dart';
import 'package:pixel_harmony/game/levels/journey_level_generator.dart';
import 'package:pixel_harmony/game/levels/journey_perceptual_color.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_catalog.dart';

void main() {
  const generator = JourneyLevelGenerator();

  test('Journey generation is stable for representative level numbers', () {
    for (final number in [1, 5, 20, 100, 120, 500, 1000, 5000, 10000]) {
      expect(
        _signature(generator.generate(number)),
        _signature(generator.generate(number)),
        reason: 'Level $number',
      );
    }
    expect(JourneyLevelGenerator.generationVersion, 6);
  });

  test('levels 1-5000 preserve mixed-Journey invariants', () {
    final stopwatch = Stopwatch()..start();
    final recentGradients = <JourneyLevelFingerprint>[];
    final pictureNumbers = <int>[];
    final pictureTemplates = <String>[];
    final pictureFamilies = <String>[];
    final gridSizes = <int, int>{};
    final paletteSizes = <int, int>{};
    final categories = <String, int>{};
    var gradientCount = 0;
    var earlyDeltaTotal = 0.0;
    var earlyDeltaCount = 0;
    var advancedDeltaTotal = 0.0;
    var advancedDeltaCount = 0;
    var earlyDifficulty = 0;
    var lateDifficulty = 0;

    for (var number = 1; number <= 5000; number++) {
      late final LevelDefinition level;
      try {
        level = generator.generate(number);
      } on Object catch (error) {
        fail('Level $number failed generation: $error');
      }
      final colors = {for (final tile in level.tiles) tile.id: tile.colorValue};
      expect(level.number, number);
      expect(level.boardSize, inInclusiveRange(2, 16), reason: level.id);
      expect(level.initialTileOrder.toSet(), level.solutionTileOrder.toSet());
      if (level.puzzleType == JourneyPuzzleType.gradient) {
        expect(_visuallySolved(level), isFalse, reason: level.id);
      } else {
        expect(_visuallySolved(level), isTrue, reason: level.id);
      }

      if (level.puzzleType == JourneyPuzzleType.gradient) {
        gradientCount++;
        expect(
          colors.values.toSet(),
          hasLength(colors.length),
          reason: level.id,
        );
        final hues = [
          for (final id in level.solutionTileOrder)
            JourneyColorFamily.hueDegrees(colors[id]!),
        ];
        final referenceHue = hues[hues.length ~/ 2];
        expect(
          hues.every(
            (hue) =>
                JourneyColorFamily.circularHueDistance(hue, referenceHue) <=
                JourneyLevelGenerator.maximumHueVariationDegrees,
          ),
          isTrue,
          reason: '${level.id} crosses color families',
        );
        for (var index = 1; index < level.solutionTileOrder.length; index++) {
          final previous = colors[level.solutionTileOrder[index - 1]]!;
          final current = colors[level.solutionTileOrder[index]]!;
          expect(
            JourneyGradient.relativeLuminance(current),
            greaterThan(JourneyGradient.relativeLuminance(previous)),
            reason: '${level.id} reverses dark-to-light order',
          );
          final delta = JourneyPerceptualColor.deltaE(previous, current);
          expect(
            delta,
            greaterThanOrEqualTo(
              JourneyLevelGenerator.perceptualThresholdForLevel(number),
            ),
            reason: '${level.id} has indistinguishable adjacent shades',
          );
          if (number <= 10) {
            earlyDeltaTotal += delta;
            earlyDeltaCount++;
          } else if (number > 4900) {
            advancedDeltaTotal += delta;
            advancedDeltaCount++;
          }
        }

        final fingerprint = JourneyLevelFingerprint.fromLevel(level);
        expect(
          recentGradients.every((item) => !fingerprint.isObviousRepeatOf(item)),
          isTrue,
          reason: '${level.id} repeats a recent gradient',
        );
        recentGradients.add(fingerprint);
        if (recentGradients.length >
            JourneyLevelGenerator.recentComparisonWindow) {
          recentGradients.removeAt(0);
        }
      } else {
        expect(level.pictureTemplateId, isNotNull, reason: level.id);
        expect(colors.values.toSet().length, lessThan(colors.length));
        expect(
          pictureNumbers.isEmpty ? number : number - pictureNumbers.last,
          greaterThan(1),
          reason: 'Pixel Pictures must not be consecutive',
        );
        pictureNumbers.add(number);
        pictureTemplates.add(level.pictureTemplateId!);
        final template = PixelPictureCatalog.byId(level.pictureTemplateId!);
        pictureFamilies.add(template.familyId);
        gridSizes.update(
          template.size,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
        paletteSizes.update(
          template.requiredPaletteIndices.length,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
        categories.update(
          template.category.name,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }

      if (number <= 100) earlyDifficulty += level.difficultyScore;
      if (number > 4900) lateDifficulty += level.difficultyScore;
    }
    stopwatch.stop();

    expect(pictureNumbers.first, 5);
    expect(pictureNumbers.length / 5000, closeTo(0.20, 0.001));
    expect(
      pictureTemplates
          .asMap()
          .entries
          .skip(1)
          .every((entry) => entry.value != pictureTemplates[entry.key - 1]),
      isTrue,
    );
    expect(lateDifficulty, greaterThan(earlyDifficulty));
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 60)));
    final spacings = [
      for (var index = 1; index < pictureNumbers.length; index++)
        pictureNumbers[index] - pictureNumbers[index - 1],
    ];
    final templateDistances = <int>[];
    final familyDistances = <int>[];
    final lastTemplateIndex = <String, int>{};
    final lastFamilyIndex = <String, int>{};
    for (var index = 0; index < pictureTemplates.length; index++) {
      final previous = lastTemplateIndex[pictureTemplates[index]];
      if (previous != null) templateDistances.add(index - previous);
      lastTemplateIndex[pictureTemplates[index]] = index;
      final familyPrevious = lastFamilyIndex[pictureFamilies[index]];
      if (familyPrevious != null) familyDistances.add(index - familyPrevious);
      lastFamilyIndex[pictureFamilies[index]] = index;
    }
    // ignore: avoid_print
    print(
      'Journey 1-5000 audit: gradients=$gradientCount '
      '(${(gradientCount / 50).toStringAsFixed(1)}%), '
      'pictures=${pictureNumbers.length} '
      '(${(pictureNumbers.length / 50).toStringAsFixed(1)}%), '
      'picture spacing min=${spacings.reduce(math.min)} '
      'avg=${(spacings.reduce((a, b) => a + b) / spacings.length).toStringAsFixed(2)}, '
      'template repeat min=${templateDistances.reduce(math.min)}, '
      'family repeat min=${familyDistances.reduce(math.min)}, '
      'unique templates=${pictureTemplates.toSet().length}, '
      'unique families=${pictureFamilies.toSet().length}, '
      'grids=$gridSizes, palettes=$paletteSizes, categories=$categories, '
      'early avg DeltaE=${(earlyDeltaTotal / earlyDeltaCount).toStringAsFixed(2)}, '
      'advanced avg DeltaE='
      '${(advancedDeltaTotal / advancedDeltaCount).toStringAsFixed(2)}, '
      'time=${stopwatch.elapsedMilliseconds}ms',
    );
    final samples = <String>[];
    for (final start in [5, 55, 130, 280, 520, 1000]) {
      for (var number = start; number < start + 10; number++) {
        if (generator.puzzleTypeFor(number) != JourneyPuzzleType.pixelPicture) {
          continue;
        }
        final level = generator.generate(number);
        final template = PixelPictureCatalog.byId(level.pictureTemplateId!);
        samples.add(
          '$number:${template.familyId}:${template.size}x${template.size}:'
          '${template.requiredPaletteIndices.length}:${template.category.name}',
        );
        break;
      }
    }
    // ignore: avoid_print
    print('Pixel Coloring samples: ${samples.join(', ')}');
  });

  test('board sizes stay mobile-safe for both puzzle types', () {
    for (final number in [1, 3, 4, 5, 12, 13, 40, 41, 100, 101, 5000]) {
      final level = generator.generate(number);
      expect(level.boardSize, inInclusiveRange(2, 16));
      if (level.puzzleType == JourneyPuzzleType.gradient) {
        final expected =
            number <= 5
                ? 2
                : number <= 15
                ? 3
                : number <= 35
                ? 4
                : number <= 70
                ? 5
                : number <= 120
                ? 6
                : number <= 200
                ? 7
                : 8;
        expect(level.boardSize, expected, reason: level.id);
      } else {
        expect(level.boardSize, inInclusiveRange(5, 16), reason: level.id);
      }
    }
  });

  test('Gradient size progression follows the approved Journey curve', () {
    for (final (start, end, size) in const [
      (1, 5, 2),
      (6, 15, 3),
      (16, 35, 4),
      (36, 70, 5),
      (71, 120, 6),
      (121, 200, 7),
      (201, 230, 8),
    ]) {
      for (var number = start; number <= end; number++) {
        if (generator.puzzleTypeFor(number) == JourneyPuzzleType.gradient) {
          expect(generator.boardSizeFor(number), size, reason: 'Level $number');
        }
      }
    }
  });

  test(
    'advanced gradients use closer perceptual steps than early gradients',
    () {
      final early = _nextGradient(generator, 101);
      final advanced = _nextGradient(generator, 5000);
      expect(_averageDeltaE(advanced), lessThan(_averageDeltaE(early)));
      expect(
        _minimumDeltaE(advanced),
        greaterThanOrEqualTo(JourneyLevelGenerator.minimumPerceptualDeltaE),
      );
    },
  );
}

LevelDefinition _nextGradient(JourneyLevelGenerator generator, int start) {
  for (var number = start; number < start + 10; number++) {
    final level = generator.generate(number);
    if (level.puzzleType == JourneyPuzzleType.gradient) return level;
  }
  throw StateError('No gradient level near $start.');
}

bool _visuallySolved(LevelDefinition level) {
  final colors = {for (final tile in level.tiles) tile.id: tile.colorValue};
  for (var index = 0; index < level.initialTileOrder.length; index++) {
    if (colors[level.initialTileOrder[index]] !=
        colors[level.solutionTileOrder[index]]) {
      return false;
    }
  }
  return true;
}

String _signature(LevelDefinition level) => [
  level.id,
  level.boardSize,
  level.puzzleType.name,
  level.pictureTemplateId,
  level.difficultyScore,
  ...level.tiles.map((tile) => tile.colorValue),
  ...level.initialTileOrder,
  ...level.solutionTileOrder,
].join(':');

double _averageDeltaE(LevelDefinition level) {
  final gaps = _deltaEs(level);
  return gaps.reduce((a, b) => a + b) / gaps.length;
}

double _minimumDeltaE(LevelDefinition level) =>
    _deltaEs(level).reduce(math.min);

List<double> _deltaEs(LevelDefinition level) {
  final colors = {for (final tile in level.tiles) tile.id: tile.colorValue};
  return [
    for (var index = 1; index < level.solutionTileOrder.length; index++)
      JourneyPerceptualColor.deltaE(
        colors[level.solutionTileOrder[index - 1]]!,
        colors[level.solutionTileOrder[index]]!,
      ),
  ];
}
