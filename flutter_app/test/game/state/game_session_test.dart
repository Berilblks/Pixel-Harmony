import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/models/tile_model.dart';
import 'package:pixel_harmony/game/state/board_state.dart';
import 'package:pixel_harmony/game/state/game_session.dart';

void main() {
  test('GameSession owns the complete initial board state', () {
    final session = GameSession.initial();
    final state = session.boardState;

    expect(state.boardSize, 2);
    expect(state.tiles, hasLength(4));
    expect(state.moveCount, 0);
    expect(state.elapsedTime, Duration.zero);
    expect(state.completed, isFalse);
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
}
