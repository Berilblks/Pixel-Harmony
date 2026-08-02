import 'package:pixel_harmony/game/models/tile_model.dart';

class BoardState {
  BoardState({
    required this.boardSize,
    required List<TileModel> tiles,
    this.moveCount = 0,
    this.elapsedTime = Duration.zero,
    this.completed = false,
  }) : assert(boardSize > 0),
       assert(tiles.length == boardSize * boardSize),
       tiles = List.unmodifiable(tiles);

  final int boardSize;
  final List<TileModel> tiles;
  final int moveCount;
  final Duration elapsedTime;
  final bool completed;
}
