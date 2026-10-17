import 'dart:ui';

import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/hints/puzzle_hint.dart';
import 'package:pixel_harmony/game/hints/puzzle_hint_evaluator.dart';
import 'package:pixel_harmony/game/models/tile_model.dart';
import 'package:pixel_harmony/game/state/board_state.dart';
import 'package:pixel_harmony/game/state/puzzle_solution.dart';

class GameSession {
  GameSession({
    required this.level,
    PuzzleHintEvaluator hintEvaluator = const PuzzleHintEvaluator(),
  }) : _hintEvaluator = hintEvaluator,
       solution = PuzzleSolution(tileIds: level.solutionTileOrder),
       _boardState = _buildInitialState(level) {
    if (level.puzzleType == JourneyPuzzleType.gradient) {
      _boardState = _boardState.withCompleted(_isComplete(_boardState));
    }
  }

  final LevelDefinition level;
  final PuzzleSolution solution;
  final PuzzleHintEvaluator _hintEvaluator;
  BoardState _boardState;

  BoardState get boardState => _boardState;

  PuzzleHint? evaluateHint() {
    if (_boardState.completed) {
      return null;
    }

    if (level.puzzleType == JourneyPuzzleType.pixelPicture) {
      return null;
    }
    return _hintEvaluator.evaluate(
      currentTileIds: _boardState.tiles.map((tile) => tile.id).toList(),
      solutionTileIds: solution.tileIds,
    );
  }

  bool _isComplete(BoardState state) {
    return solution.matches(state.tiles.map((tile) => tile.id));
  }

  static BoardState _buildInitialState(LevelDefinition level) {
    final tilesById = {
      for (final tile in level.tiles)
        tile.id: TileModel(id: tile.id, color: Color(tile.colorValue)),
    };
    return BoardState(
      boardSize: level.boardSize,
      rowCount: level.rowCount,
      columnCount: level.columnCount,
      tiles: [for (final id in level.initialTileOrder) tilesById[id]!],
    );
  }

  BoardState swapTiles(int sourceIndex, int targetIndex) {
    if (level.puzzleType == JourneyPuzzleType.pixelPicture) {
      throw StateError('Pixel Coloring does not support tile swapping.');
    }
    if (_boardState.completed) {
      throw StateError('A completed game session cannot accept another swap.');
    }

    final swapped = _boardState.swapTiles(sourceIndex, targetIndex);
    return _boardState = swapped.withCompleted(_isComplete(swapped));
  }
}
