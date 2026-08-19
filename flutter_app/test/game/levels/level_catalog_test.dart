import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/board/board_config.dart';
import 'package:pixel_harmony/game/board/board_layout.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/state/game_session.dart';

void main() {
  test('catalog contains exactly 36 uniquely identified levels in order', () {
    final levels = LevelCatalog.levels;
    expect(levels, hasLength(36));
    expect(levels.map((level) => level.id).toSet(), hasLength(36));
    expect(
      levels.map((level) => level.id),
      List.generate(
        36,
        (index) => 'level_${(index + 1).toString().padLeft(3, '0')}',
      ),
    );
  });

  test('six chapters are unique, ordered, and partition the catalog', () {
    final chapters = LevelCatalog.chapters;
    expect(chapters, hasLength(6));
    expect(chapters.map((chapter) => chapter.id), [
      'calm_start',
      'ocean',
      'forest',
      'sunset',
      'lavender',
      'aurora',
    ]);
    expect(chapters.map((chapter) => chapter.order), [0, 1, 2, 3, 4, 5]);
    expect(chapters.every((chapter) => chapter.levelIds.length == 6), isTrue);
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

  test('catalog follows the required board-size and difficulty curves', () {
    expect(LevelCatalog.levels.map((level) => level.boardSize), [
      ...List.filled(4, 2),
      ...List.filled(8, 3),
      ...List.filled(12, 4),
      ...List.filled(12, 5),
    ]);

    final scores =
        LevelCatalog.levels.map((level) => level.difficultyScore).toList();
    for (var index = 1; index < scores.length; index++) {
      expect(scores[index], greaterThanOrEqualTo(scores[index - 1] - 2));
    }
  });

  test('catalog looks up stable IDs through the final level', () {
    expect(LevelCatalog.byId('level_036').boardSize, 5);
    expect(() => LevelCatalog.byId('unknown'), throwsArgumentError);
  });
}
