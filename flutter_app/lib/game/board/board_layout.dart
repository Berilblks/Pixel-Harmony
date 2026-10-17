import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:pixel_harmony/game/board/board_config.dart';

class BoardLayout {
  const BoardLayout(this.config);

  final BoardConfig config;

  BoardLayoutResult calculate({
    required Vector2 availableSize,
    int? boardSize,
    int? rowCount,
    int? columnCount,
  }) {
    final rows = rowCount ?? boardSize ?? 0;
    final columns = columnCount ?? boardSize ?? 0;
    assert(rows > 0);
    assert(columns > 0);
    final horizontalSpacing = config.spacing * (columns - 1);
    final verticalSpacing = config.spacing * (rows - 1);
    final usableWidth = math.max(
      0.0,
      availableSize.x - (config.screenPadding * 2),
    );
    final usableHeight = math.max(
      0.0,
      availableSize.y - (config.screenPadding * 2),
    );
    final widthBasedTileSize = math.max(
      0.0,
      (usableWidth - horizontalSpacing) / columns,
    );
    final heightBasedTileSize = math.max(
      0.0,
      (usableHeight - verticalSpacing) / rows,
    );
    final tileSize = math.min(widthBasedTileSize, heightBasedTileSize);
    final boardWidth = (tileSize * columns) + horizontalSpacing;
    final boardHeight = (tileSize * rows) + verticalSpacing;

    return BoardLayoutResult(
      tileSize: tileSize,
      boardSize: Vector2(boardWidth, boardHeight),
      boardPosition: Vector2(
        (availableSize.x - boardWidth) / 2,
        (availableSize.y - boardHeight) / 2,
      ),
    );
  }

  Vector2 tilePosition({
    required int row,
    required int column,
    required double tileSize,
  }) {
    final step = tileSize + config.spacing;
    return Vector2(column * step, row * step);
  }
}

class BoardLayoutResult {
  const BoardLayoutResult({
    required this.tileSize,
    required this.boardSize,
    required this.boardPosition,
  });

  final double tileSize;
  final Vector2 boardSize;
  final Vector2 boardPosition;
}
