import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/board/board_component.dart';
import 'package:pixel_harmony/game/board/board_config.dart';
import 'package:pixel_harmony/game/components/tile_component.dart';
import 'package:pixel_harmony/game/hints/puzzle_hint.dart';
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

  test('hint clears after its presentation duration', () {
    final board = _board()..showHint(_hint);

    board.update(BoardComponent.hintPresentationDuration - 0.01);
    expect(board.hasActiveHint, isTrue);

    board.update(0.01);
    expect(board.hasActiveHint, isFalse);
  });

  test('hint marks the source tile and current destination cell occupant', () {
    final board = _board();

    expect(board.showHint(_hint), isTrue);

    final tiles = board.children.whereType<TileComponent>().toList();
    expect(tiles[0].isHintSource, isTrue);
    expect(tiles[0].isHintDestination, isFalse);
    expect(tiles[1].isHintSource, isFalse);
    expect(tiles[1].isHintDestination, isTrue);
  });

  test('beginning a drag clears the active hint', () {
    final board = _board()..showHint(_hint);
    final source = board.children.whereType<TileComponent>().first;

    expect(source.onDragStarted(source), isTrue);
    expect(board.hasActiveHint, isFalse);
  });

  test('completed board rejects hint requests', () {
    final board = BoardComponent(
      state: BoardState(
        boardSize: 1,
        tiles: const [TileModel(id: 'tile', color: Color(0xFF5BC0EB))],
        completed: true,
      ),
      config: const BoardConfig(spacing: 0),
      onDropRequested: (_) => throw StateError('No drop is expected.'),
    );

    expect(board.showHint(_hint), isFalse);
    expect(board.hasActiveHint, isFalse);
  });

  test('repeated hint requests restart one presentation', () {
    final board = _board()..showHint(_hint);
    board.update(1.2);

    expect(board.showHint(_hint), isTrue);
    board.update(1.2);

    expect(board.hasActiveHint, isTrue);
    board.update(0.61);
    expect(board.hasActiveHint, isFalse);
  });

  test('swap animation rejects hint requests', () {
    final initialState = _twoTileState();
    final board = BoardComponent(
      state: initialState,
      config: const BoardConfig(spacing: 8, screenPadding: 0),
      onDropRequested:
          (request) =>
              initialState.swapTiles(request.sourceIndex, request.targetIndex),
    )..onGameResize(Vector2(208, 208));
    final source = board.children.whereType<TileComponent>().first;

    expect(source.onDragStarted(source), isTrue);
    source.position = source.onDragUpdated(source, Vector2(108, 0));
    source.onDragFinished(source);

    expect(board.acceptsDragInput, isFalse);
    expect(board.showHint(_hint), isFalse);
  });
}

const _hint = PuzzleHint(tileId: 'tile_0', currentIndex: 0, targetIndex: 1);

BoardComponent _board() {
  return BoardComponent(
    state: _twoTileState(),
    config: const BoardConfig(spacing: 8, screenPadding: 0),
    onDropRequested: (_) => throw StateError('No drop is expected.'),
  )..onGameResize(Vector2(208, 208));
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
