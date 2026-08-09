import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';

void main() {
  const tiles = [
    LevelTileDefinition(id: 'a', colorValue: 0xFF000001),
    LevelTileDefinition(id: 'b', colorValue: 0xFF000002),
    LevelTileDefinition(id: 'c', colorValue: 0xFF000003),
    LevelTileDefinition(id: 'd', colorValue: 0xFF000004),
  ];

  LevelDefinition createLevel({
    int boardSize = 2,
    List<LevelTileDefinition> levelTiles = tiles,
    List<String> initialOrder = const ['b', 'a', 'c', 'd'],
    List<String> solutionOrder = const ['a', 'b', 'c', 'd'],
  }) {
    return LevelDefinition(
      id: 'test_level',
      nameKey: 'testLevel',
      boardSize: boardSize,
      tiles: levelTiles,
      initialTileOrder: initialOrder,
      solutionTileOrder: solutionOrder,
    );
  }

  test('valid level is accepted', () {
    expect(createLevel().boardSize, 2);
  });

  test('duplicate tile IDs are rejected', () {
    expect(
      () => createLevel(levelTiles: [tiles[0], tiles[0], tiles[2], tiles[3]]),
      throwsArgumentError,
    );
  });

  test('wrong tile count and invalid board size are rejected', () {
    expect(() => createLevel(levelTiles: [tiles[0]]), throwsArgumentError);
    expect(() => createLevel(boardSize: 0), throwsArgumentError);
  });

  test('invalid initial order is rejected', () {
    expect(
      () => createLevel(initialOrder: const ['unknown', 'a', 'c', 'd']),
      throwsArgumentError,
    );
    expect(
      () => createLevel(initialOrder: const ['a', 'b', 'c', 'd']),
      throwsArgumentError,
    );
  });

  test('invalid solution order is rejected', () {
    expect(
      () => createLevel(solutionOrder: const ['a', 'b', 'c']),
      throwsArgumentError,
    );
    expect(
      () => createLevel(solutionOrder: const ['a', 'b', 'c', 'unknown']),
      throwsArgumentError,
    );
  });
}
