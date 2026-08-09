import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/board/board_component.dart';
import 'package:pixel_harmony/game/board/board_config.dart';
import 'package:pixel_harmony/game/models/tile_model.dart';
import 'package:pixel_harmony/game/state/board_state.dart';

void main() {
  test('completed board rejects further drag input', () {
    final board = BoardComponent(
      state: BoardState(
        boardSize: 1,
        tiles: const [TileModel(id: 'tile', color: Color(0xFF5BC0EB))],
        completed: true,
      ),
      config: const BoardConfig(spacing: 0),
      onDropRequested: (_) => throw StateError('No drop is expected.'),
    );

    expect(board.acceptsDragInput, isFalse);
  });
}
