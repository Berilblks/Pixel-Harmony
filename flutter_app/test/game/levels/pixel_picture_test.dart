import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/coloring/pixel_coloring_session.dart';
import 'package:pixel_harmony/game/coloring/pixel_coloring_state.dart';
import 'package:pixel_harmony/game/levels/journey_level_generator.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_catalog.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_template.dart';

void main() {
  test('the Pixel Coloring starter library is valid and complete', () {
    PixelPictureCatalog.validate();
    expect(PixelPictureCatalog.templates, hasLength(100));
    expect(
      PixelPictureCatalog.templates
          .map((template) => template.familyId)
          .toSet(),
      hasLength(100),
    );
    for (final template in PixelPictureCatalog.templates) {
      expect(template.englishName, isNotEmpty);
      expect(template.turkishName, isNotEmpty);
      expect(template.requiredPaletteIndices, isNotEmpty);
      expect(template.pixels.length, template.rows * template.columns);
      expect(template.paintablePixelCount, greaterThanOrEqualTo(5));
      for (final paletteIndex in template.requiredPaletteIndices) {
        expect(template.identifierForPalette(paletteIndex), greaterThan(0));
      }
    }
  });

  test('Level 5 introduces a deterministic beginner Heart coloring puzzle', () {
    const generator = JourneyLevelGenerator();
    final first = generator.generate(5);
    final second = generator.generate(5);
    final template = PixelPictureCatalog.byId(first.pictureTemplateId!);

    expect(first.puzzleType, JourneyPuzzleType.pixelPicture);
    expect(template.familyId, 'heart');
    expect(first.boardSize, 5);
    expect(first.initialTileOrder, first.solutionTileOrder);
    expect(second.pictureTemplateId, first.pictureTemplateId);
    expect(template.requiredPaletteIndices, isNotEmpty);
    expect(
      Iterable<int>.generate(
        template.pixels.length,
      ).where(template.isPaintable).length,
      greaterThanOrEqualTo(7),
    );
  });

  test('correct color paints a cell and removes its unfinished state', () {
    final template = PixelPictureCatalog.byId('heart');
    final session = PixelColoringSession(template: template);
    final cell = _firstCellFor(template, session.state.selectedPaletteIndex);

    expect(session.paint(cell), PixelPaintResult.painted);
    expect(session.state.paintedCells[cell], isTrue);
    expect(session.state.paintedCount, 1);
  });

  test('wrong color never paints the cell', () {
    final template = PixelPictureCatalog.byId('heart');
    final session = PixelColoringSession(template: template);
    final wrongCell = Iterable.generate(template.pixels.length).firstWhere(
      (index) =>
          template.isPaintable(index) &&
          template.pixels[index] != session.state.selectedPaletteIndex,
    );

    expect(session.paint(wrongCell), PixelPaintResult.wrongColor);
    expect(session.state.paintedCells[wrongCell], isFalse);
    expect(session.state.paintedCount, 0);
  });

  test('finishing a palette marks it complete and selects the next color', () {
    final template = PixelPictureCatalog.byId('heart');
    final session = PixelColoringSession(template: template);
    final firstPalette = session.state.selectedPaletteIndex;
    for (var index = 0; index < template.pixels.length; index++) {
      if (template.pixels[index] == firstPalette) session.paint(index);
    }

    expect(session.state.isPaletteComplete(firstPalette), isTrue);
    expect(session.state.selectedPaletteIndex, isNot(firstPalette));
  });

  test('painting every required cell completes the artwork', () {
    final template = PixelPictureCatalog.byId('heart');
    final session = PixelColoringSession(template: template);
    _complete(session);

    expect(session.state.completed, isTrue);
    expect(
      session.state.paintedCount,
      Iterable<int>.generate(
        template.pixels.length,
      ).where(template.isPaintable).length,
    );
  });

  test('hint paints exactly one unfinished cell', () {
    final session = PixelColoringSession(
      template: PixelPictureCatalog.byId('heart'),
    );

    expect(session.applyHint(), isTrue);
    expect(session.state.paintedCount, 1);
    expect(session.state.completed, isFalse);
  });

  test('restart creates the same empty deterministic coloring puzzle', () {
    const generator = JourneyLevelGenerator();
    final level = generator.generate(5);
    final template = PixelPictureCatalog.byId(level.pictureTemplateId!);
    final first = PixelColoringSession(template: template)..applyHint();
    final restarted = PixelColoringSession(template: template);

    expect(first.state.paintedCount, 1);
    expect(restarted.state.paintedCount, 0);
    expect(generator.generate(5).pictureTemplateId, level.pictureTemplateId);
  });

  test('Butterfly template preserves its authored symmetric silhouette', () {
    final template = PixelPictureCatalog.byId('butterfly');
    final session = PixelColoringSession(template: template);

    expect(template.size, 8);
    expect(template.familyId, 'butterfly');
    for (var row = 0; row < template.rows; row++) {
      final values = template.pixels.sublist(
        row * template.columns,
        (row + 1) * template.columns,
      );
      expect(values, orderedEquals(values.reversed));
    }
    _complete(session);
    expect(session.state.completed, isTrue);
  });

  test(
    'Journey picture complexity grows without resetting after level 100',
    () {
      const generator = JourneyLevelGenerator();
      final early = _nextPicture(generator, 5);
      final level55 = _nextPicture(generator, 51);
      final level130 = _nextPicture(generator, 101);
      final level280 = _nextPicture(generator, 201);
      final level520 = _nextPicture(generator, 401);
      final level1000 = _nextPicture(generator, 1000);

      expect(early.boardSize, 5);
      expect(level55.boardSize, inInclusiveRange(5, 7));
      expect(level130.boardSize, inInclusiveRange(7, 9));
      // Detailed authored subjects may use the catalog's mobile-safe 16x16
      // maximum when a smaller matrix would make the silhouette ambiguous.
      expect(level280.boardSize, inInclusiveRange(9, 16));
      expect(level520.boardSize, inInclusiveRange(13, 16));
      expect(level1000.boardSize, inInclusiveRange(5, 16));
    },
  );

  test('the first 100 occurrences expose 100 unique curated artworks', () {
    const generator = JourneyLevelGenerator();
    final pictures = <PixelPictureTemplate>[];
    for (var number = 1; pictures.length < 100; number++) {
      if (generator.puzzleTypeFor(number) != JourneyPuzzleType.pixelPicture) {
        continue;
      }
      pictures.add(
        PixelPictureCatalog.byId(generator.generate(number).pictureTemplateId!),
      );
    }
    expect(pictures.map((item) => item.id).toSet(), hasLength(100));
    expect(pictures.map((item) => item.familyId).toSet(), hasLength(100));
    expect(pictures.first.familyId, 'heart');
    expect(pictures.last.familyId, 'northern_lights');
  });

  test('paintable detail trends upward across all five curated tiers', () {
    final averages = <double>[];
    for (var group = 0; group < 5; group++) {
      final templates = PixelPictureCatalog.templates.skip(group * 20).take(20);
      averages.add(
        templates
                .map((item) => item.paintablePixelCount)
                .reduce((a, b) => a + b) /
            20,
      );
    }
    for (var index = 1; index < averages.length; index++) {
      expect(averages[index], greaterThan(averages[index - 1]));
    }
    expect(PixelPictureCatalog.templates.first.size, 5);
    expect(PixelPictureCatalog.templates.last.size, 16);
  });

  test('detailed artwork is not a nearest-neighbor upscale', () {
    final simple = PixelPictureCatalog.byId('butterfly');
    final detailed = PixelPictureCatalog.byId('detailed_butterfly');
    expect(detailed.size, greaterThan(simple.size));
    expect(
      detailed.paintablePixelCount,
      greaterThan(simple.paintablePixelCount),
    );
    expect(
      detailed.requiredPaletteIndices.length,
      greaterThan(simple.requiredPaletteIndices.length),
    );
  });

  test('approved recognizable redesigns preserve all 43 stable identities', () {
    const redesignedIds = {
      'star',
      'smiley_face',
      'cloud',
      'lightning_bolt',
      'diamond',
      'leaf',
      'balloon',
      'bee',
      'fish',
      'turtle',
      'penguin',
      'panda_face',
      'fox_face',
      'bear_face',
      'crown',
      'camera',
      'hot_air_balloon',
      'bicycle',
      'car',
      'train',
      'teapot',
      'donut',
      'book',
      'paint_palette',
      'peacock',
      'dolphin',
      'whale',
      'elephant',
      'giraffe',
      'lion',
      'tiger',
      'unicorn',
      'swan',
      'hummingbird',
      'koi_fish',
      'small_island',
      'flower_field',
      'mountains_at_sunrise',
      'sailboat_at_sea',
      'snowy_mountain',
      'waterfall_scene',
      'city_skyline_night',
      'northern_lights',
    };

    expect(redesignedIds, hasLength(43));
    for (final familyId in redesignedIds) {
      final template = PixelPictureCatalog.byId(familyId);
      expect(template.familyId, familyId);
      expect(template.size, inInclusiveRange(12, 16));
      expect(template.requiredPaletteIndices.length, greaterThanOrEqualTo(3));
      expect(template.paintablePixelCount, greaterThanOrEqualTo(12));
    }
    expect(PixelPictureCatalog.templates, hasLength(100));
  });
}

LevelDefinition _nextPicture(JourneyLevelGenerator generator, int start) {
  for (var number = start; number < start + 10; number++) {
    if (generator.puzzleTypeFor(number) == JourneyPuzzleType.pixelPicture) {
      return generator.generate(number);
    }
  }
  throw StateError('No picture level found after $start.');
}

int _firstCellFor(PixelPictureTemplate template, int paletteIndex) =>
    Iterable.generate(
      template.pixels.length,
    ).firstWhere((index) => template.pixels[index] == paletteIndex);

void _complete(PixelColoringSession session) {
  final template = session.state.template;
  for (final paletteIndex in template.requiredPaletteIndices) {
    session.selectPalette(paletteIndex);
    for (var index = 0; index < template.pixels.length; index++) {
      if (template.pixels[index] == paletteIndex) session.paint(index);
    }
  }
}
