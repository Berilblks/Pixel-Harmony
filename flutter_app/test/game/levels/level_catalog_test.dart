import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/state/game_session.dart';

void main() {
  test('catalog contains exactly three uniquely identified valid levels', () {
    final levels = LevelCatalog.levels;

    expect(levels, hasLength(3));
    expect(levels.map((level) => level.id).toSet(), hasLength(3));
    expect(levels.map((level) => level.id), [
      'level_001',
      'level_002',
      'level_003',
    ]);
  });

  test('every catalog level starts unsolved with the expected tile count', () {
    for (final level in LevelCatalog.levels) {
      final session = GameSession(level: level);

      expect(level.initialTileOrder, isNot(level.solutionTileOrder));
      expect(level.tiles, hasLength(level.boardSize * level.boardSize));
      expect(session.boardState.completed, isFalse, reason: level.id);
    }
  });

  test('catalog looks up levels by stable ID', () {
    expect(LevelCatalog.byId('level_003').boardSize, 3);
    expect(() => LevelCatalog.byId('unknown'), throwsArgumentError);
  });
}
