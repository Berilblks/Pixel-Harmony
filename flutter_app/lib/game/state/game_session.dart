import 'dart:ui';

import 'package:pixel_harmony/game/models/tile_model.dart';
import 'package:pixel_harmony/game/state/board_state.dart';
import 'package:pixel_harmony/game/state/puzzle_solution.dart';

class GameSession {
  GameSession({required BoardState boardState, required this.solution})
    : _boardState = boardState.withCompleted(
        solution.matches(boardState.tiles.map((tile) => tile.id)),
      );

  factory GameSession.initial() {
    return GameSession(
      solution: PuzzleSolution(
        tileIds: const ['tile_0', 'tile_1', 'tile_2', 'tile_3'],
      ),
      boardState: BoardState(
        boardSize: 2,
        tiles: const [
          TileModel(id: 'tile_1', color: Color(0xFF9BC53D)),
          TileModel(id: 'tile_0', color: Color(0xFF5BC0EB)),
          TileModel(id: 'tile_2', color: Color(0xFFFDE74C)),
          TileModel(id: 'tile_3', color: Color(0xFFE55934)),
        ],
      ),
    );
  }

  final PuzzleSolution solution;
  BoardState _boardState;

  BoardState get boardState => _boardState;

  BoardState swapTiles(int sourceIndex, int targetIndex) {
    if (_boardState.completed) {
      throw StateError('A completed game session cannot accept another swap.');
    }

    final swapped = _boardState.swapTiles(sourceIndex, targetIndex);
    return _boardState = swapped.withCompleted(
      solution.matches(swapped.tiles.map((tile) => tile.id)),
    );
  }
}
