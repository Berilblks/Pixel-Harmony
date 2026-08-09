import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/models/tile_model.dart';
import 'package:pixel_harmony/game/state/board_state.dart';

void main() {
  const tiles = [
    TileModel(id: 'a', color: Color(0xFF000001)),
    TileModel(id: 'b', color: Color(0xFF000002)),
    TileModel(id: 'c', color: Color(0xFF000003)),
    TileModel(id: 'd', color: Color(0xFF000004)),
  ];

  BoardState createState({
    int moveCount = 0,
    Duration elapsedTime = Duration.zero,
    bool completed = false,
  }) {
    return BoardState(
      boardSize: 2,
      tiles: tiles,
      moveCount: moveCount,
      elapsedTime: elapsedTime,
      completed: completed,
    );
  }

  test('valid swap changes order and increments moveCount once', () {
    final state = createState(moveCount: 4);

    final swapped = state.swapTiles(0, 1);

    expect(swapped.tiles.map((tile) => tile.id), ['b', 'a', 'c', 'd']);
    expect(swapped.moveCount, 5);
    expect(state.moveCount, 4);
  });

  test('swaps first and last indices', () {
    final swapped = createState().swapTiles(0, 3);

    expect(swapped.tiles.map((tile) => tile.id), ['d', 'b', 'c', 'a']);
  });

  test('identical indices are rejected', () {
    final state = createState();

    expect(() => state.swapTiles(2, 2), throwsArgumentError);
    expect(state.moveCount, 0);
    expect(state.tiles, orderedEquals(tiles));
  });

  test('out-of-range indices are rejected', () {
    final state = createState();

    expect(() => state.swapTiles(-1, 1), throwsRangeError);
    expect(() => state.swapTiles(0, 4), throwsRangeError);
  });

  test('preserves tile IDs and colors', () {
    final swapped = createState().swapTiles(1, 2);

    expect(swapped.tiles.toSet(), equals(tiles.toSet()));
    expect(
      {for (final tile in swapped.tiles) tile.id: tile.color},
      {for (final tile in tiles) tile.id: tile.color},
    );
  });

  test('preserves elapsedTime and completed', () {
    const elapsedTime = Duration(seconds: 42);
    final swapped = createState(
      elapsedTime: elapsedTime,
      completed: true,
    ).swapTiles(0, 1);

    expect(swapped.elapsedTime, elapsedTime);
    expect(swapped.completed, isTrue);
  });
}
