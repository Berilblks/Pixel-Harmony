import 'package:flame/components.dart';
import 'package:pixel_harmony/game/board/board_config.dart';
import 'package:pixel_harmony/game/board/board_drag_controller.dart';
import 'package:pixel_harmony/game/board/board_layout.dart';
import 'package:pixel_harmony/game/components/tile_component.dart';
import 'package:pixel_harmony/game/state/board_state.dart';

class BoardComponent extends PositionComponent {
  BoardComponent({
    required this.state,
    required this.config,
    BoardDragController? dragController,
  }) : _layout = BoardLayout(config),
       _dragController = dragController ?? BoardDragController() {
    addAll(
      state.tiles.map(
        (model) => TileComponent(
          model: model,
          onDragStarted: _onTileDragStarted,
          onDragUpdated: _onTileDragUpdated,
          onDragFinished: _onTileDragFinished,
          onReturnCompleted: _onTileReturnCompleted,
        ),
      ),
    );
  }

  final BoardState state;
  final BoardConfig config;
  final BoardLayout _layout;
  final BoardDragController _dragController;

  static const _restingPriority = 0;
  static const _draggedPriority = 100;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    final result = _layout.calculate(
      availableSize: size,
      boardSize: state.boardSize,
    );
    position = result.boardPosition;
    size = result.boardSize;

    final tiles = children.whereType<TileComponent>().toList();
    final originalPositions = <String, Vector2>{};
    for (var index = 0; index < tiles.length; index++) {
      final tile = tiles[index];
      final originalPosition = _layout.tilePosition(
        row: index ~/ state.boardSize,
        column: index % state.boardSize,
        tileSize: result.tileSize,
      );
      originalPositions[tile.model.id] = originalPosition;
      tile
        ..position = originalPosition
        ..size = Vector2.all(result.tileSize);
    }

    _dragController.updateLayout(
      boardSize: result.boardSize,
      originalPositions: originalPositions,
      boardDimension: state.boardSize,
      tileExtent: result.tileSize,
      spacing: config.spacing,
    );
    _syncTargetHighlight();
  }

  bool _onTileDragStarted(TileComponent tile) {
    final accepted = _dragController.tryStartDrag(tile.model.id);
    if (accepted) {
      tile.priority = _draggedPriority;
    }
    return accepted;
  }

  Vector2 _onTileDragUpdated(TileComponent tile, Vector2 delta) {
    final position = _dragController.updateDrag(
      tileId: tile.model.id,
      currentPosition: tile.position,
      delta: delta,
      tileSize: tile.size,
    );
    _syncTargetHighlight();
    return position;
  }

  Vector2 _onTileDragFinished(TileComponent tile) {
    tile.priority = _restingPriority;
    final originalPosition = _dragController.endDrag(tile.model.id);
    _syncTargetHighlight();
    return originalPosition;
  }

  void _onTileReturnCompleted(TileComponent tile) {
    tile.priority = _restingPriority;
  }

  void _syncTargetHighlight() {
    final activeTargetId = _dragController.activeTargetTileId;
    for (final tile in children.whereType<TileComponent>()) {
      tile.isDropTarget = tile.model.id == activeTargetId;
    }
  }
}
