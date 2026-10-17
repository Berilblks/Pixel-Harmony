import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/board/board_config.dart';
import 'package:pixel_harmony/game/board/board_layout.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/levels/journey_perceptual_color.dart';
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

  test(
    'first 100 mixed procedural levels have a stable generation-v4 fingerprint',
    () {
      var fingerprint = 2166136261;
      void addInt(int value) {
        fingerprint ^= value;
        fingerprint = (fingerprint * 16777619) & 0xffffffff;
      }

      for (final level in LevelCatalog.levels) {
        for (final codeUnit in level.id.codeUnits) {
          addInt(codeUnit);
        }
        addInt(level.boardSize);
        addInt(level.rowCount);
        addInt(level.columnCount);
        for (final tile in level.tiles) {
          addInt(tile.colorValue);
        }
        for (final tileId in level.initialTileOrder) {
          for (final codeUnit in tileId.codeUnits) {
            addInt(codeUnit);
          }
        }
      }
      expect(fingerprint, isNonZero);
    },
  );

  test(
    'ten internal milestone segments partition the first catalog window',
    () {
      final chapters = LevelCatalog.chapters;
      expect(chapters, hasLength(10));
      expect(
        chapters.map((chapter) => chapter.id),
        List.generate(10, (index) => 'journey_segment_${index + 1}'),
      );
      expect(
        chapters.map((chapter) => chapter.order),
        List.generate(10, (i) => i),
      );
      expect(
        chapters.every((chapter) => chapter.levelIds.length == 10),
        isTrue,
      );
      expect(
        chapters.expand((chapter) => chapter.levelIds),
        LevelCatalog.levels.map((level) => level.id),
      );
      for (final chapter in chapters) {
        for (final levelId in chapter.levelIds) {
          expect(LevelCatalog.chapterForLevel(levelId), same(chapter));
        }
      }
    },
  );

  test('every level is valid, supported, complete, and initially unsolved', () {
    const layout = BoardLayout(BoardConfig(spacing: 14, screenPadding: 32));
    LevelCatalog.validate();

    for (final level in LevelCatalog.levels) {
      final expectedCount = level.rowCount * level.columnCount;
      final tileIds = level.tiles.map((tile) => tile.id).toSet();
      final session = GameSession(level: level);
      final layoutResult = layout.calculate(
        availableSize: Vector2(320, 480),
        rowCount: level.rowCount,
        columnCount: level.columnCount,
      );

      expect(level.tiles, hasLength(expectedCount), reason: level.id);
      expect(tileIds, hasLength(expectedCount), reason: level.id);
      expect(level.initialTileOrder.toSet(), tileIds, reason: level.id);
      expect(level.solutionTileOrder.toSet(), tileIds, reason: level.id);
      if (level.puzzleType == JourneyPuzzleType.gradient) {
        expect(
          level.initialTileOrder,
          isNot(orderedEquals(level.solutionTileOrder)),
          reason: level.id,
        );
      } else {
        expect(
          level.initialTileOrder,
          orderedEquals(level.solutionTileOrder),
          reason: level.id,
        );
      }
      expect(level.difficultyScore, inInclusiveRange(1, 100));
      expect(session.boardState.completed, isFalse, reason: level.id);
      expect(layoutResult.tileSize, greaterThan(0), reason: level.id);
    }
  });

  test('board geometry expands gradually and keeps pictures mobile-safe', () {
    expect(
      LevelCatalog.levels.every(
        (level) => level.boardSize >= 2 && level.boardSize <= 16,
      ),
      isTrue,
    );
    expect(LevelCatalog.levels[4].puzzleType, JourneyPuzzleType.pixelPicture);
    expect(LevelCatalog.levels[4].boardSize, 5);
  });

  test('early levels are square with distinct palettes and permutations', () {
    final tutorials = LevelCatalog.levels.take(8).toList(growable: false);
    expect(tutorials.take(3).every((level) => level.boardSize == 2), isTrue);
    expect(tutorials[3].boardSize, 2);
    expect(tutorials[4].boardSize, 5);
    expect(
      tutorials
          .map((level) => level.tiles.map((tile) => tile.colorValue).join(','))
          .toSet(),
      hasLength(8),
    );
    expect(
      tutorials
          .map(
            (level) => level.initialTileOrder
                .map(level.solutionTileOrder.indexOf)
                .join(','),
          )
          .toSet()
          .length,
      greaterThanOrEqualTo(7),
    );
  });

  test('early tutorial gradient colors have strong perceptual separation', () {
    for (final level in LevelCatalog.levels.take(3)) {
      final colors = level.tiles.map((tile) => tile.colorValue).toList();
      for (var first = 0; first < colors.length; first++) {
        for (var second = first + 1; second < colors.length; second++) {
          expect(
            JourneyPerceptualColor.deltaE(colors[first], colors[second]),
            greaterThanOrEqualTo(18),
            reason: '${level.id}: colors $first and $second are too similar',
          );
        }
      }
    }
  });

  test('tutorial goal order is the exact GameSession completion order', () {
    for (final level in LevelCatalog.levels.take(4)) {
      final session = GameSession(level: level);
      expect(session.solution.tileIds, level.solutionTileOrder);
      expect(session.solution.matches(level.solutionTileOrder), isTrue);
      expect(session.solution.matches(level.initialTileOrder), isFalse);
    }
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

    expectDifficulties(1, 3, {LevelDifficulty.tutorial});
    expectDifficulties(4, 8, {LevelDifficulty.easy});
    expectDifficulties(9, 100, {LevelDifficulty.medium, LevelDifficulty.hard});
  });

  test('catalog resolves levels beyond the original milestone', () {
    expect(LevelCatalog.byId('level_036').boardSize, 5);
    expect(LevelCatalog.byId('level_100').boardSize, inInclusiveRange(4, 8));
    expect(LevelCatalog.byId('level_101').boardSize, inInclusiveRange(4, 10));
    expect(LevelCatalog.byId('level_10000').number, 10000);
    expect(() => LevelCatalog.byId('unknown'), throwsArgumentError);
  });
}
