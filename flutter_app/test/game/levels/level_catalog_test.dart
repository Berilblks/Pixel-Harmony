import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/board/board_config.dart';
import 'package:pixel_harmony/game/board/board_layout.dart';
import 'package:pixel_harmony/game/generation/difficulty_evaluator.dart';
import 'package:pixel_harmony/game/generation/procedural_level_generator.dart';
import 'package:pixel_harmony/game/generation/procedural_level_request.dart';
import 'package:pixel_harmony/game/levels/frozen_generated_journey_levels.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/state/game_session.dart';

void main() {
  test('catalog contains exactly 100 stable IDs in global order', () {
    final stopwatch = Stopwatch()..start();
    final levels = LevelCatalog.levels;
    LevelCatalog.validate();
    stopwatch.stop();

    expect(levels, hasLength(100));
    expect(levels.map((level) => level.id).toSet(), hasLength(100));
    expect(
      levels.map((level) => level.id),
      List.generate(
        100,
        (index) => 'level_${(index + 1).toString().padLeft(3, '0')}',
      ),
    );
    // Informational only; catalog startup timings vary by test host.
    // ignore: avoid_print
    print(
      '100-level catalog initialized in ${stopwatch.elapsedMicroseconds} us',
    );
  });

  test('original 36 puzzle layouts retain their frozen fingerprint', () {
    var fingerprint = 2166136261;
    void addInt(int value) {
      fingerprint ^= value;
      fingerprint = (fingerprint * 16777619) & 0xffffffff;
    }

    for (final level in LevelCatalog.levels.take(36)) {
      for (final codeUnit in level.id.codeUnits) {
        addInt(codeUnit);
      }
      addInt(level.boardSize);
      for (final tile in level.tiles) {
        addInt(tile.colorValue);
      }
      for (final tileId in level.initialTileOrder) {
        for (final codeUnit in tileId.codeUnits) {
          addInt(codeUnit);
        }
      }
    }
    expect(fingerprint, 1496476806);
  });

  test('ten chapters contain ten levels and partition the catalog', () {
    final chapters = LevelCatalog.chapters;
    expect(chapters, hasLength(10));
    expect(chapters.map((chapter) => chapter.id), [
      'calm_start',
      'ocean',
      'forest',
      'sunset',
      'lavender',
      'aurora',
      'midnight',
      'blossom',
      'desert',
      'northern_lights',
    ]);
    expect(
      chapters.map((chapter) => chapter.order),
      List.generate(10, (i) => i),
    );
    expect(chapters.every((chapter) => chapter.levelIds.length == 10), isTrue);
    expect(
      chapters.expand((chapter) => chapter.levelIds),
      LevelCatalog.levels.map((level) => level.id),
    );
    for (final chapter in chapters) {
      for (final levelId in chapter.levelIds) {
        expect(LevelCatalog.chapterForLevel(levelId), same(chapter));
      }
    }
  });

  test('every level is valid, supported, complete, and initially unsolved', () {
    const layout = BoardLayout(BoardConfig(spacing: 14, screenPadding: 32));
    LevelCatalog.validate();

    for (final level in LevelCatalog.levels) {
      final expectedCount = level.boardSize * level.boardSize;
      final tileIds = level.tiles.map((tile) => tile.id).toSet();
      final session = GameSession(level: level);
      final layoutResult = layout.calculate(
        availableSize: Vector2(320, 480),
        boardSize: level.boardSize,
      );

      expect(level.tiles, hasLength(expectedCount), reason: level.id);
      expect(tileIds, hasLength(expectedCount), reason: level.id);
      expect(level.initialTileOrder.toSet(), tileIds, reason: level.id);
      expect(level.solutionTileOrder.toSet(), tileIds, reason: level.id);
      expect(
        level.initialTileOrder,
        isNot(orderedEquals(level.solutionTileOrder)),
        reason: level.id,
      );
      expect(level.difficultyScore, inInclusiveRange(1, 100));
      expect(session.boardState.completed, isFalse, reason: level.id);
      expect(layoutResult.tileSize, greaterThan(0), reason: level.id);
    }
  });

  test('board-size curve preserves Levels 1-36 and expands gradually', () {
    expect(LevelCatalog.levels.map((level) => level.boardSize), [
      ...List.filled(4, 2),
      ...List.filled(8, 3),
      ...List.filled(12, 4),
      ...List.filled(12, 5),
      ...List.filled(34, 4),
      ...List.filled(30, 5),
    ]);
    expect(
      LevelCatalog.levels.every(
        (level) => level.boardSize >= 2 && level.boardSize <= 5,
      ),
      isTrue,
    );
  });

  test('campaign content follows the intended difficulty bands', () {
    void expectDifficulties(int first, int last, Set<LevelDifficulty> allowed) {
      for (var number = first; number <= last; number++) {
        expect(
          allowed,
          contains(LevelCatalog.levels[number - 1].difficulty),
          reason: 'level_$number',
        );
      }
    }

    expectDifficulties(1, 10, {LevelDifficulty.tutorial, LevelDifficulty.easy});
    expectDifficulties(11, 25, {LevelDifficulty.easy, LevelDifficulty.medium});
    expectDifficulties(26, 50, {LevelDifficulty.medium});
    expectDifficulties(51, 70, {LevelDifficulty.medium, LevelDifficulty.hard});
    expectDifficulties(71, 94, {LevelDifficulty.hard});
    expectDifficulties(95, 100, {LevelDifficulty.expert});
  });

  test('Levels 37-100 have complete frozen provenance metadata', () {
    expect(journeyGeneratedSources, hasLength(64));
    for (var index = 0; index < journeyGeneratedSources.length; index++) {
      final source = journeyGeneratedSources[index];
      final number = index + 37;
      final level = LevelCatalog.levels[number - 1];
      expect(source.journeyLevelNumber, number);
      expect(source.generationVersion, 1);
      expect(source.seed, greaterThan(0));
      expect(source.paletteSeed, greaterThan(0));
      expect(source.boardSize, level.boardSize);
      expect(source.chapterId, LevelCatalog.chapterForLevel(level.id).id);
    }
  });

  test('frozen definitions match their authoring provenance', () {
    const generator = ProceduralLevelGenerator();
    for (final source in journeyGeneratedSources) {
      final frozen = LevelCatalog.levels[source.journeyLevelNumber - 1];
      final generated = generator.generate(
        ProceduralLevelRequest(
          seed: source.seed,
          paletteSeed: source.paletteSeed,
          boardSize: source.boardSize,
          targetDifficulty: source.targetDifficulty,
        ),
      );
      final generatedSolutionIndices = {
        for (var index = 0; index < generated.solutionTileOrder.length; index++)
          generated.solutionTileOrder[index]: index,
      };
      final frozenSolutionIndices = {
        for (var index = 0; index < frozen.solutionTileOrder.length; index++)
          frozen.solutionTileOrder[index]: index,
      };
      expect(
        frozen.tiles.map((tile) => tile.colorValue),
        generated.tiles.map((tile) => tile.colorValue),
        reason: frozen.id,
      );
      expect(
        frozen.initialTileOrder.map((id) => frozenSolutionIndices[id]),
        generated.initialTileOrder.map((id) => generatedSolutionIndices[id]),
        reason: frozen.id,
      );
      expect(frozen.difficulty, generated.difficulty, reason: frozen.id);
      expect(
        frozen.difficultyScore,
        generated.difficultyScore,
        reason: frozen.id,
      );
      for (var index = 1; index < frozen.tiles.length; index++) {
        expect(
          DifficultyEvaluator.colorDistance(
            frozen.tiles[index - 1].colorValue,
            frozen.tiles[index].colorValue,
          ),
          greaterThan(3.5),
          reason: '${frozen.id} tile $index',
        );
      }
    }
  });

  test('catalog looks up stable IDs through the final level', () {
    expect(LevelCatalog.byId('level_036').boardSize, 5);
    expect(LevelCatalog.byId('level_100').boardSize, 5);
    expect(() => LevelCatalog.byId('unknown'), throwsArgumentError);
  });
}
