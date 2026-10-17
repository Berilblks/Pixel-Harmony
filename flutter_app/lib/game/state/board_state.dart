import 'package:pixel_harmony/game/models/tile_model.dart';

class BoardState {
  BoardState({
    required this.boardSize,
    int? rowCount,
    int? columnCount,
    required List<TileModel> tiles,
    this.moveCount = 0,
    this.elapsedTime = Duration.zero,
    this.completed = false,
  }) : rowCount = rowCount ?? boardSize,
       columnCount = columnCount ?? boardSize,
       assert(boardSize > 0),
       assert((rowCount ?? boardSize) > 0),
       assert((columnCount ?? boardSize) > 0),
       assert(
         tiles.length == (rowCount ?? boardSize) * (columnCount ?? boardSize),
       ),
       tiles = List.unmodifiable(tiles);

  final int boardSize;
  final int rowCount;
  final int columnCount;
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
      rowCount: rowCount,
      columnCount: columnCount,
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
      rowCount: rowCount,
      columnCount: columnCount,
      tiles: swappedTiles,
      moveCount: moveCount + 1,
      elapsedTime: elapsedTime,
      completed: completed,
    );
  }
}
