import 'dart:ui';

import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/models/tile_model.dart';
import 'package:pixel_harmony/game/state/board_state.dart';
import 'package:pixel_harmony/game/state/puzzle_solution.dart';

class GameSession {
  GameSession({required this.level})
    : solution = PuzzleSolution(tileIds: level.solutionTileOrder),
      _boardState = _buildInitialState(level) {
    _boardState = _boardState.withCompleted(
      solution.matches(_boardState.tiles.map((tile) => tile.id)),
    );
  }

  final LevelDefinition level;
  final PuzzleSolution solution;
  BoardState _boardState;

  BoardState get boardState => _boardState;

  static BoardState _buildInitialState(LevelDefinition level) {
    final tilesById = {
      for (final tile in level.tiles)
        tile.id: TileModel(id: tile.id, color: Color(tile.colorValue)),
    };
    return BoardState(
      boardSize: level.boardSize,
      tiles: [for (final id in level.initialTileOrder) tilesById[id]!],
    );
  }

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
