import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/features/endless/domain/free_play_configuration.dart';
import 'package:pixel_harmony/features/endless/domain/free_play_level_factory.dart';
import 'package:pixel_harmony/features/endless/domain/free_play_pixel_template_selector.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_catalog.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_template.dart';

void main() {
  late FreePlayLevelFactory factory;

  setUp(() {
    factory = FreePlayLevelFactory(
      pixelTemplateSelector: PixelPictureShuffleBag(random: Random(7)),
    );
  });

  test('Gradient difficulties change real generation parameters', () {
    final levels = {
      for (final difficulty in FreePlayDifficulty.values)
        difficulty: factory.create(
          configuration: FreePlayConfiguration(
            puzzleType: FreePlayPuzzleType.gradient,
            difficulty: difficulty,
          ),
          seed: 42,
        ),
    };

    expect(levels[FreePlayDifficulty.relaxed]!.boardSize, 3);
    expect(
      levels[FreePlayDifficulty.relaxed]!.difficulty,
      LevelDifficulty.easy,
    );
    expect(levels[FreePlayDifficulty.normal]!.boardSize, 4);
    expect(
      levels[FreePlayDifficulty.normal]!.difficulty,
      LevelDifficulty.medium,
    );
    expect(levels[FreePlayDifficulty.hard]!.boardSize, 5);
    expect(levels[FreePlayDifficulty.hard]!.difficulty, LevelDifficulty.hard);
    expect(levels[FreePlayDifficulty.expert]!.boardSize, 5);
    expect(
      levels[FreePlayDifficulty.expert]!.difficulty,
      LevelDifficulty.expert,
    );
  });

  test('Pixel Coloring difficulties use approved catalog tiers', () {
    const expected = {
      FreePlayDifficulty.relaxed: PixelPictureDifficulty.beginner,
      FreePlayDifficulty.normal: PixelPictureDifficulty.early,
      FreePlayDifficulty.hard: PixelPictureDifficulty.medium,
      FreePlayDifficulty.expert: PixelPictureDifficulty.advanced,
    };
    for (final difficulty in FreePlayDifficulty.values) {
      final level = factory.create(
        configuration: FreePlayConfiguration(
          puzzleType: FreePlayPuzzleType.pixelColoring,
          difficulty: difficulty,
        ),
        seed: 81,
      );
      expect(level.puzzleType, JourneyPuzzleType.pixelPicture);
      expect(
        PixelPictureCatalog.templates.map((template) => template.id),
        contains(level.pictureTemplateId),
      );
      expect(
        PixelPictureCatalog.byId(level.pictureTemplateId!).difficulty,
        expected[difficulty],
      );
    }
  });

  test('difficulty pools contain broad approved template sets', () {
    final selector = PixelPictureShuffleBag(random: Random(11));
    expect(selector.poolSize(FreePlayDifficulty.relaxed), 20);
    expect(selector.poolSize(FreePlayDifficulty.normal), 20);
    expect(selector.poolSize(FreePlayDifficulty.hard), 20);
    expect(selector.poolSize(FreePlayDifficulty.expert), 40);
  });

  test(
    'shuffle bag does not repeat before its difficulty pool is exhausted',
    () {
      final selector = PixelPictureShuffleBag(random: Random(19));
      for (final difficulty in FreePlayDifficulty.values) {
        final poolSize = selector.poolSize(difficulty);
        final firstRound = [
          for (var index = 0; index < poolSize; index++)
            selector.next(difficulty).id,
        ];
        expect(firstRound.toSet(), hasLength(poolSize));
        final nextRoundFirst = selector.next(difficulty).id;
        expect(nextRoundFirst, isNot(firstRound.last));
      }
    },
  );

  test('consecutive Pixel Coloring levels choose different figures', () {
    const configuration = FreePlayConfiguration(
      puzzleType: FreePlayPuzzleType.pixelColoring,
      difficulty: FreePlayDifficulty.relaxed,
    );
    final first = factory.create(configuration: configuration, seed: 1);
    final second = factory.create(
      configuration: configuration,
      seed: 2,
      sequence: 1,
    );
    expect(second.pictureTemplateId, isNot(first.pictureTemplateId));
  });

  test('Mixed alternates Gradient and Pixel Coloring deterministically', () {
    const configuration = FreePlayConfiguration(
      puzzleType: FreePlayPuzzleType.mixed,
      difficulty: FreePlayDifficulty.normal,
    );
    expect(
      factory.create(configuration: configuration, seed: 5).puzzleType,
      JourneyPuzzleType.gradient,
    );
    expect(
      factory
          .create(configuration: configuration, seed: 5, sequence: 1)
          .puzzleType,
      JourneyPuzzleType.pixelPicture,
    );
    expect(
      factory
          .create(configuration: configuration, seed: 5, sequence: 2)
          .puzzleType,
      JourneyPuzzleType.gradient,
    );
  });
}
