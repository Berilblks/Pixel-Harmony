import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/debug/large_pixel_art_test_catalog.dart';
import 'package:pixel_harmony/game/coloring/pixel_coloring_session.dart';
import 'package:pixel_harmony/game/coloring/pixel_coloring_state.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_catalog.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_difficulty.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_template.dart';
import 'package:pixel_harmony/game/pixel_harmony_game.dart';

void main() {
  test('24x24 and 32x32 review templates validate with stable identities', () {
    const expected = <(String, String, int)>[
      ('debug_large_red_potion_24', 'Kırmızı İksir', 24),
      ('debug_large_strawberry_24', 'Çilek', 24),
      ('debug_large_golden_key_24', 'Altın Anahtar', 24),
      ('debug_large_castle_32', 'Şato', 32),
      ('debug_large_sailing_ship_32', 'Yelkenli Gemi', 32),
    ];

    expect(LargePixelArtTestCatalog.templates, hasLength(5));
    for (var index = 0; index < expected.length; index++) {
      final template = LargePixelArtTestCatalog.templates[index];
      template.validate();
      expect((
        template.id,
        template.turkishName,
        template.size,
      ), expected[index]);
      expect(template.pixels, hasLength(template.size * template.size));
      expect(template.paintablePixelCount, greaterThan(0));
      expect(template.difficulty, PixelPictureDifficulty.medium);
      expect(
        LargePixelArtTestCatalog.levelFor(template).difficulty,
        LevelDifficulty.hard,
      );
    }
  });

  test('grids above the reviewed 32x32 ceiling remain rejected', () {
    final unsupported = PixelPictureTemplate(
      id: 'unsupported_33',
      familyId: 'unsupported_33',
      englishName: 'Unsupported',
      turkishName: 'Desteklenmeyen',
      category: PixelPictureCategory.object,
      minimumJourneyLevel: 1,
      difficulty: PixelPictureDifficulty.advanced,
      rows: 33,
      columns: 33,
      palette: const [0x00000000, 0xffffffff],
      pixels: List.filled(33 * 33, 1),
    );

    expect(unsupported.validate, throwsStateError);
  });

  test('existing catalog validation remains unchanged', () {
    expect(PixelPictureCatalog.validate, returnsNormally);
  });

  test('large-grid difficulty remains bounded and distinguishes grid load', () {
    final scores = {
      for (final template in LargePixelArtTestCatalog.templates)
        template.id: PixelPictureDifficultyEvaluator.evaluate(template).score,
    };
    expect(scores.values.every((score) => score >= 1 && score <= 100), isTrue);
    final average24 =
        LargePixelArtTestCatalog.templates
            .where((template) => template.size == 24)
            .map(PixelPictureDifficultyEvaluator.evaluate)
            .map((assessment) => assessment.score)
            .reduce((first, second) => first + second) /
        3;
    final average32 =
        LargePixelArtTestCatalog.templates
            .where((template) => template.size == 32)
            .map(PixelPictureDifficultyEvaluator.evaluate)
            .map((assessment) => assessment.score)
            .reduce((first, second) => first + second) /
        2;
    expect(average32, greaterThan(average24));
  });

  test('large-grid coloring preserves wrong-tap and completion rules', () {
    for (final template in LargePixelArtTestCatalog.templates) {
      final session = PixelColoringSession(template: template);
      final selected = session.state.selectedPaletteIndex;
      final wrongIndex = template.pixels.indexWhere(
        (value) => value != 0 && value != selected,
      );
      if (wrongIndex >= 0) {
        expect(session.paint(wrongIndex), PixelPaintResult.wrongColor);
        expect(session.state.paintedCells[wrongIndex], isFalse);
      }

      var hints = 0;
      while (!session.state.completed) {
        expect(session.applyHint(), isTrue, reason: template.id);
        hints++;
      }
      expect(hints, template.paintablePixelCount, reason: template.id);
      expect(session.state.completed, isTrue, reason: template.id);
    }
  });

  test('PixelHarmonyGame accepts an isolated template override', () {
    final template = LargePixelArtTestCatalog.castle;
    final level = LargePixelArtTestCatalog.levelFor(template);
    final game = PixelHarmonyGame(level: level, pixelPictureTemplate: template);

    expect(game.coloringSession?.state.template, same(template));
    expect(level.pictureTemplateId, template.id);
  });
}
