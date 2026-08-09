import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/models/tile_model.dart';
import 'package:pixel_harmony/game/state/board_state.dart';
import 'package:pixel_harmony/game/state/game_session.dart';
import 'package:pixel_harmony/game/state/puzzle_solution.dart';

void main() {
  const tiles = [
    TileModel(id: 'a', color: Color(0xFF000001)),
    TileModel(id: 'b', color: Color(0xFF000002)),
    TileModel(id: 'c', color: Color(0xFF000003)),
    TileModel(id: 'd', color: Color(0xFF000004)),
  ];

  GameSession createSession({
    List<TileModel> initialTiles = tiles,
    List<String> solutionIds = const ['a', 'b', 'c', 'd'],
    Duration elapsedTime = Duration.zero,
  }) {
    return GameSession(
      boardState: BoardState(
        boardSize: 2,
        tiles: initialTiles,
        elapsedTime: elapsedTime,
      ),
      solution: PuzzleSolution(tileIds: solutionIds),
    );
  }

  test('GameSession owns the complete initial board state', () {
    final session = GameSession.initial();
    final state = session.boardState;

    expect(state.boardSize, 2);
    expect(state.tiles, hasLength(4));
    expect(state.moveCount, 0);
    expect(state.elapsedTime, Duration.zero);
    expect(state.completed, isFalse);
    expect(state.tiles.map((tile) => tile.id), [
      'tile_1',
      'tile_0',
      'tile_2',
      'tile_3',
    ]);
    expect(session.solution.tileIds, ['tile_0', 'tile_1', 'tile_2', 'tile_3']);
  });

  test('BoardState keeps its tile collection immutable', () {
    final state = BoardState(
      boardSize: 1,
      tiles: const [TileModel(id: 'tile', color: Color(0xFF5BC0EB))],
    );

    expect(
      () => state.tiles.add(
        const TileModel(id: 'other', color: Color(0xFF9BC53D)),
      ),
      throwsUnsupportedError,
    );
  });

  test('an accepted swap can solve the puzzle', () {
    final session = GameSession.initial();

    final solved = session.swapTiles(0, 1);

    expect(solved.completed, isTrue);
    expect(solved.moveCount, 1);
    expect(solved.elapsedTime, Duration.zero);
  });

  test('a non-solving accepted swap remains incomplete', () {
    final session = GameSession.initial();

    final state = session.swapTiles(2, 3);

    expect(state.completed, isFalse);
    expect(state.moveCount, 1);
  });

  test('invalid swaps do not affect completion or move count', () {
    final session = GameSession.initial();
    final initial = session.boardState;

    expect(() => session.swapTiles(0, 0), throwsArgumentError);
    expect(() => session.swapTiles(-1, 2), throwsRangeError);
    expect(session.boardState, same(initial));
    expect(session.boardState.completed, isFalse);
    expect(session.boardState.moveCount, 0);
  });

  test('completion compares IDs rather than colors', () {
    const sameColor = Color(0xFF123456);
    final session = createSession(
      initialTiles: const [
        TileModel(id: 'b', color: sameColor),
        TileModel(id: 'a', color: sameColor),
        TileModel(id: 'c', color: sameColor),
        TileModel(id: 'd', color: sameColor),
      ],
    );

    expect(session.boardState.completed, isFalse);
    expect(session.swapTiles(0, 1).completed, isTrue);
  });

  test('completion preserves elapsed time, tile IDs, and colors', () {
    const elapsed = Duration(seconds: 37);
    final session = createSession(
      initialTiles: const [
        TileModel(id: 'b', color: Color(0xFF000002)),
        TileModel(id: 'a', color: Color(0xFF000001)),
        TileModel(id: 'c', color: Color(0xFF000003)),
        TileModel(id: 'd', color: Color(0xFF000004)),
      ],
      elapsedTime: elapsed,
    );
    final originalTiles = session.boardState.tiles.toSet();

    final solved = session.swapTiles(0, 1);

    expect(solved.elapsedTime, elapsed);
    expect(solved.tiles.toSet(), originalTiles);
    expect(
      {for (final tile in solved.tiles) tile.id: tile.color},
      {for (final tile in tiles) tile.id: tile.color},
    );
  });

  test('completed session rejects further swaps', () {
    final session = GameSession.initial();
    final solved = session.swapTiles(0, 1);

    expect(() => session.swapTiles(1, 2), throwsStateError);
    expect(session.boardState, same(solved));
    expect(session.boardState.moveCount, 1);
  });

  test('GameSession applies two consecutive non-solving valid swaps', () {
    final session = createSession(solutionIds: const ['d', 'c', 'b', 'a']);

    final firstSwap = session.swapTiles(0, 1);
    final secondSwap = session.swapTiles(2, 3);

    expect(firstSwap.tiles.map((tile) => tile.id), ['b', 'a', 'c', 'd']);
    expect(secondSwap.tiles.map((tile) => tile.id), ['b', 'a', 'd', 'c']);
    expect(session.boardState, same(secondSwap));
    expect(session.boardState.moveCount, 2);
    expect(session.boardState.completed, isFalse);
  });
}
