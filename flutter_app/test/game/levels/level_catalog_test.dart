import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/board/board_config.dart';
import 'package:pixel_harmony/game/board/board_layout.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/state/game_session.dart';

void main() {
  test('catalog contains exactly 12 uniquely identified levels in order', () {
    final levels = LevelCatalog.levels;

    expect(levels, hasLength(12));
    expect(levels.map((level) => level.id).toSet(), hasLength(12));
    expect(
      levels.map((level) => level.id),
      List.generate(
        12,
        (index) => 'level_${(index + 1).toString().padLeft(3, '0')}',
      ),
    );
  });

  test('every catalog level is valid, complete, supported, and unsolved', () {
    const layout = BoardLayout(BoardConfig(spacing: 14, screenPadding: 32));

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
      expect(session.boardState.completed, isFalse, reason: level.id);
      expect(layoutResult.tileSize, greaterThan(0), reason: level.id);
    }
  });

  test('catalog uses the intended board-size difficulty curve', () {
    expect(LevelCatalog.levels.map((level) => level.boardSize), [
      2,
      2,
      3,
      3,
      3,
      3,
      4,
      4,
      4,
      4,
      4,
      5,
    ]);
  });

  test('catalog looks up levels by stable ID', () {
    expect(LevelCatalog.byId('level_012').boardSize, 5);
    expect(() => LevelCatalog.byId('unknown'), throwsArgumentError);
  });
}
