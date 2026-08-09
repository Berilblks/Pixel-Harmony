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

  BoardState withCompleted(bool value) {
    if (completed == value) {
      return this;
    }

    return BoardState(
      boardSize: boardSize,
      tiles: tiles,
      moveCount: moveCount,
      elapsedTime: elapsedTime,
      completed: value,
    );
  }

  BoardState swapTiles(int sourceIndex, int targetIndex) {
    RangeError.checkValidIndex(sourceIndex, tiles, 'sourceIndex');
    RangeError.checkValidIndex(targetIndex, tiles, 'targetIndex');
    if (sourceIndex == targetIndex) {
      throw ArgumentError.value(
        targetIndex,
        'targetIndex',
        'Source and target indices must be different.',
      );
    }

    final swappedTiles = List<TileModel>.of(tiles);
    final sourceTile = swappedTiles[sourceIndex];
    swappedTiles[sourceIndex] = swappedTiles[targetIndex];
    swappedTiles[targetIndex] = sourceTile;

    return BoardState(
      boardSize: boardSize,
      tiles: swappedTiles,
      moveCount: moveCount + 1,
      elapsedTime: elapsedTime,
      completed: completed,
    );
  }
}
