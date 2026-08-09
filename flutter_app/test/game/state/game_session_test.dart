import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/state/game_session.dart';

void main() {
  LevelDefinition createLevel({
    List<String> initialOrder = const ['b', 'a', 'c', 'd'],
    List<String> solutionOrder = const ['a', 'b', 'c', 'd'],
  }) {
    return LevelDefinition(
      id: 'test_level',
      nameKey: 'testLevel',
      boardSize: 2,
      tiles: const [
        LevelTileDefinition(id: 'a', colorValue: 0xFF000001),
        LevelTileDefinition(id: 'b', colorValue: 0xFF000002),
        LevelTileDefinition(id: 'c', colorValue: 0xFF000003),
        LevelTileDefinition(id: 'd', colorValue: 0xFF000004),
      ],
      initialTileOrder: initialOrder,
      solutionTileOrder: solutionOrder,
    );
  }

  test('builds board and solution from the supplied level definition', () {
    final level = createLevel();
    final session = GameSession(level: level);

    expect(session.level, same(level));
    expect(session.boardState.boardSize, 2);
    expect(session.boardState.tiles.map((tile) => tile.id), [
      'b',
      'a',
      'c',
      'd',
    ]);
    expect(session.solution.tileIds, ['a', 'b', 'c', 'd']);
    expect(session.boardState.moveCount, 0);
    expect(session.boardState.elapsedTime, Duration.zero);
    expect(session.boardState.completed, isFalse);
  });

  test(
    'maps level colors to render tiles without using them for completion',
    () {
      final session = GameSession(level: createLevel());

      expect(session.boardState.tiles.first.color.toARGB32(), 0xFF000002);
      expect(session.swapTiles(0, 1).completed, isTrue);
    },
  );

  test('invalid swaps do not affect state', () {
    final session = GameSession(level: createLevel());
    final initial = session.boardState;

    expect(() => session.swapTiles(0, 0), throwsArgumentError);
    expect(() => session.swapTiles(-1, 2), throwsRangeError);
    expect(session.boardState, same(initial));
  });

  test('all catalog levels complete using their own solution', () {
    final swapsByLevel = {
      'level_001': const [(0, 1)],
      'level_002': const [(0, 1), (2, 3)],
      'level_003': const [(0, 1), (6, 7)],
    };

    for (final level in LevelCatalog.levels) {
      final session = GameSession(level: level);
      for (final (source, target) in swapsByLevel[level.id]!) {
        session.swapTiles(source, target);
      }

      expect(session.boardState.completed, isTrue, reason: level.id);
      expect(
        session.boardState.moveCount,
        swapsByLevel[level.id]!.length,
        reason: level.id,
      );
      expect(session.boardState.elapsedTime, Duration.zero);
    }
  });

  test('completed session rejects further swaps', () {
    final session = GameSession(level: createLevel());
    final solved = session.swapTiles(0, 1);

    expect(() => session.swapTiles(1, 2), throwsStateError);
    expect(session.boardState, same(solved));
  });

  test('two consecutive non-solving swaps remain supported', () {
    final session = GameSession(
      level: createLevel(solutionOrder: const ['d', 'c', 'b', 'a']),
    );

    session.swapTiles(0, 1);
    final second = session.swapTiles(2, 3);

    expect(second.tiles.map((tile) => tile.id), ['a', 'b', 'd', 'c']);
    expect(second.moveCount, 2);
    expect(second.completed, isFalse);
  });
}
