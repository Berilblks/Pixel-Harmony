import 'dart:math';

class BoardTargetDetector {
  const BoardTargetDetector();

  int? detect({
    required Point<double> draggedCenter,
    required int sourceIndex,
    required int boardSize,
    required double tileSize,
    required double spacing,
  }) {
    assert(boardSize > 0);
    assert(tileSize >= 0);
    assert(spacing >= 0);

    final boardExtent = (tileSize * boardSize) + (spacing * (boardSize - 1));
    if (draggedCenter.x < 0 ||
        draggedCenter.y < 0 ||
        draggedCenter.x >= boardExtent ||
        draggedCenter.y >= boardExtent) {
      return null;
    }

    final stride = tileSize + spacing;
    final column = draggedCenter.x ~/ stride;
    final row = draggedCenter.y ~/ stride;
    final localX = draggedCenter.x - (column * stride);
    final localY = draggedCenter.y - (row * stride);

    if (column >= boardSize ||
        row >= boardSize ||
        localX >= tileSize ||
        localY >= tileSize) {
      return null;
    }

    final targetIndex = (row * boardSize) + column;
    return targetIndex == sourceIndex ? null : targetIndex;
  }
}
