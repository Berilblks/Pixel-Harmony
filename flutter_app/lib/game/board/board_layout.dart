import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:pixel_harmony/game/board/board_config.dart';

class BoardLayout {
  const BoardLayout(this.config);

  final BoardConfig config;

  BoardLayoutResult calculate({
    required Vector2 availableSize,
    required int boardSize,
  }) {
    assert(boardSize > 0);
    final totalSpacing = config.spacing * (boardSize - 1);
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
      (usableWidth - totalSpacing) / boardSize,
    );
    final heightBasedTileSize = math.max(
      0.0,
      (usableHeight - totalSpacing) / boardSize,
    );
    final tileSize = math.min(widthBasedTileSize, heightBasedTileSize);
    final boardExtent = (tileSize * boardSize) + totalSpacing;

    return BoardLayoutResult(
      tileSize: tileSize,
      boardSize: Vector2.all(boardExtent),
      boardPosition: Vector2(
        (availableSize.x - boardExtent) / 2,
        (availableSize.y - boardExtent) / 2,
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
