import 'dart:math';

class BoardTargetDetector {
  const BoardTargetDetector();

  int? detect({
    required Point<double> draggedCenter,
    required int sourceIndex,
    int? boardSize,
    int? rowCount,
    int? columnCount,
    required double tileSize,
    required double spacing,
  }) {
    final rows = rowCount ?? boardSize ?? 0;
    final columns = columnCount ?? boardSize ?? 0;
    assert(rows > 0);
    assert(columns > 0);
    assert(tileSize >= 0);
    assert(spacing >= 0);

    final boardWidth = (tileSize * columns) + (spacing * (columns - 1));
    final boardHeight = (tileSize * rows) + (spacing * (rows - 1));
    if (draggedCenter.x < 0 ||
        draggedCenter.y < 0 ||
        draggedCenter.x >= boardWidth ||
        draggedCenter.y >= boardHeight) {
      return null;
    }

    final stride = tileSize + spacing;
    final column = draggedCenter.x ~/ stride;
    final row = draggedCenter.y ~/ stride;
    final localX = draggedCenter.x - (column * stride);
    final localY = draggedCenter.y - (row * stride);

    if (column >= columns ||
        row >= rows ||
        localX >= tileSize ||
        localY >= tileSize) {
      return null;
    }

    final targetIndex = (row * columns) + column;
    return targetIndex == sourceIndex ? null : targetIndex;
  }
}
