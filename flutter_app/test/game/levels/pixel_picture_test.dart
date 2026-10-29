import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/coloring/pixel_coloring_session.dart';
import 'package:pixel_harmony/game/coloring/pixel_coloring_state.dart';
import 'package:pixel_harmony/game/levels/journey_level_generator.dart';
import 'package:pixel_harmony/game/levels/journey_pixel_picture_selector.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_catalog.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_difficulty.dart';
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

  test('all 100 approved template assets retain their stable content', () {
    expect(_catalogDigest(PixelPictureCatalog.templates), -6611065927770145330);
  });

  test('Level 5 introduces a deterministic beginner Heart coloring puzzle', () {
    const generator = JourneyLevelGenerator();
    final first = generator.generate(5);
    final second = generator.generate(5);
    final template = PixelPictureCatalog.byId(first.pictureTemplateId!);

    expect(first.puzzleType, JourneyPuzzleType.pixelPicture);
    expect(template, PixelPictureCatalog.journeyTemplates.first);
    expect(first.difficulty, LevelDifficulty.tutorial);
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

      final samples = [early, level55, level130, level280, level520];
      final scores = samples.map((level) => level.difficultyScore).toList();
      expect(scores, orderedEquals([...scores]..sort()));
      expect(level1000.difficulty, LevelDifficulty.expert);
      expect(level1000.difficultyScore, greaterThanOrEqualTo(81));
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
    expect(pictures, orderedEquals(PixelPictureCatalog.journeyTemplates));
  });

  test('all templates receive a multi-factor Journey difficulty score', () {
    final assessments = PixelPictureCatalog.journeyAssessments;
    expect(assessments, hasLength(100));
    expect(assessments.map((item) => item.template.id).toSet(), hasLength(100));
    for (var index = 1; index < assessments.length; index++) {
      expect(
        assessments[index].score - assessments[index - 1].score,
        inInclusiveRange(-3, 8),
        reason: 'Journey Pixel Coloring order $index',
      );
    }
  });

  test('matrix size is not the only Journey difficulty measure', () {
    final assessments =
        PixelPictureCatalog.templates
            .map(PixelPictureDifficultyEvaluator.evaluate)
            .toList();
    final hasComplexSmallerTemplate = assessments.any(
      (smaller) => assessments.any(
        (larger) =>
            smaller.template.size < larger.template.size &&
            smaller.score > larger.score,
      ),
    );
    expect(hasComplexSmallerTemplate, isTrue);
  });

  test('post-catalog Journey retains deterministic expert variety', () {
    const generator = JourneyLevelGenerator();
    final pictureLevels = <int>[];
    for (var number = 1; pictureLevels.length < 145; number++) {
      if (generator.puzzleTypeFor(number) == JourneyPuzzleType.pixelPicture) {
        pictureLevels.add(number);
      }
    }
    final firstCycle =
        pictureLevels
            .skip(100)
            .take(40)
            .map((number) => generator.generate(number).pictureTemplateId)
            .toList();
    expect(firstCycle.toSet(), hasLength(40));
    expect(
      firstCycle,
      everyElement(
        isIn(
          PixelPictureCatalog.journeyTemplates.skip(60).map((item) => item.id),
        ),
      ),
    );
  });

  test('post-legacy reuse separates IDs and improves category variety', () {
    final selections = [
      for (var ordinal = 85; ordinal < 250; ordinal++)
        PixelPictureCatalog.journeySelector.select(ordinal),
    ];
    final lastSeen = <String, int>{};
    final repeatDistances = <int>[];
    var adjacentCategoryRepeats = 0;
    for (var index = 0; index < selections.length; index++) {
      final template = selections[index];
      final previous = lastSeen[template.id];
      if (previous != null) repeatDistances.add(index - previous);
      lastSeen[template.id] = index;
      if (index > 0 && selections[index - 1].category == template.category) {
        adjacentCategoryRepeats++;
      }
    }
    expect(PixelPictureCatalog.journeySelector.reusePoolSize, 40);
    expect(repeatDistances, everyElement(greaterThanOrEqualTo(15)));
    expect(adjacentCategoryRepeats, lessThan(20));
    expect(
      selections.skip(15).take(40).map((template) => template.id).toSet(),
      hasLength(40),
    );
  });

  test('Journey selection stays deterministic at distant occurrences', () {
    for (final ordinal in [0, 99, 100, 129, 130, 169, 500, 1000]) {
      expect(
        PixelPictureCatalog.journeySelector.select(ordinal).id,
        PixelPictureCatalog.journeySelector.select(ordinal).id,
      );
    }
  });

  test('selector accepts catalog expansion without rewriting its logic', () {
    final added = PixelPictureTemplate(
      id: 'future_pixel_101',
      familyId: 'future_pixel_101',
      englishName: 'Future Template',
      turkishName: 'Gelecek Şablonu',
      category: PixelPictureCategory.object,
      minimumJourneyLevel: 501,
      difficulty: PixelPictureDifficulty.advanced,
      rows: 5,
      columns: 5,
      palette: const [0xffffffff, 0xff553388],
      pixels: const [
        0,
        0,
        1,
        0,
        0,
        0,
        1,
        1,
        1,
        0,
        1,
        1,
        1,
        1,
        1,
        0,
        1,
        1,
        1,
        0,
        0,
        0,
        1,
        0,
        0,
      ],
    );
    final metadata = [
      for (final assessment in PixelPictureCatalog.journeyAssessments)
        JourneyPixelTemplateMetadata(assessment: assessment, paletteFamily: 0),
      JourneyPixelTemplateMetadata(
        assessment: PixelPictureDifficultyEvaluator.evaluate(added),
        paletteFamily: 1,
      ),
    ];
    final expanded = JourneyPixelPictureSelector(metadata: metadata);

    for (var ordinal = 0; ordinal < 100; ordinal++) {
      expect(
        expanded.select(ordinal).id,
        PixelPictureCatalog.journeyTemplates[ordinal].id,
      );
    }
    expect(expanded.catalogSize, 101);
    expect(expanded.select(100).id, added.id);
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

int _catalogDigest(List<PixelPictureTemplate> templates) {
  var hash = 0xcbf29ce484222325;
  for (final template in templates) {
    final content = [
      template.id,
      template.familyId,
      template.englishName,
      template.turkishName,
      template.category.name,
      template.minimumJourneyLevel,
      template.difficulty.name,
      template.rows,
      template.columns,
      template.backgroundPaletteIndex,
      ...template.palette,
      ...template.pixels,
    ].join(':');
    for (final unit in content.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x100000001b3) & 0xffffffffffffffff;
    }
  }
  return hash;
}
