import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/board/board_component.dart';
import 'package:pixel_harmony/game/board/board_config.dart';
import 'package:pixel_harmony/game/components/tile_component.dart';
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

  test('invalid drop emits neither swap nor completion feedback', () {
    final state = _twoTileState();
    var swapCount = 0;
    var completionCount = 0;
    final board = BoardComponent(
      state: state,
      config: const BoardConfig(spacing: 8, screenPadding: 0),
      onSwapCompleted: () => swapCount++,
      onCompleted: (_) => completionCount++,
      onDropRequested: (_) => throw StateError('No swap is expected.'),
    )..onGameResize(Vector2(208, 208));
    final source = board.children.whereType<TileComponent>().first;

    expect(source.onDragStarted(source), isTrue);
    source.onDragFinished(source);

    expect(swapCount, 0);
    expect(completionCount, 0);
  });
}

BoardState _twoTileState() {
  return BoardState(
    boardSize: 2,
    tiles: const [
      TileModel(id: 'tile_0', color: Color(0xFF5BC0EB)),
      TileModel(id: 'tile_1', color: Color(0xFF9BC53D)),
      TileModel(id: 'tile_2', color: Color(0xFFFDE74C)),
      TileModel(id: 'tile_3', color: Color(0xFFE55934)),
    ],
  );
}
