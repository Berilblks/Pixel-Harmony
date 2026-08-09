import 'package:flame/components.dart';
import 'package:pixel_harmony/game/board/board_config.dart';
import 'package:pixel_harmony/game/board/board_drag_controller.dart';
import 'package:pixel_harmony/game/board/board_drop_request.dart';
import 'package:pixel_harmony/game/board/board_layout.dart';
import 'package:pixel_harmony/game/components/tile_component.dart';
import 'package:pixel_harmony/game/state/board_state.dart';

typedef BoardDropRequestCallback =
    BoardState Function(BoardDropRequest request);

class BoardComponent extends PositionComponent {
  BoardComponent({
    required BoardState state,
    required this.config,
    required this.onDropRequested,
    BoardDragController? dragController,
  }) : _state = state,
       _layout = BoardLayout(config),
       _dragController = dragController ?? BoardDragController() {
    addAll(
      _state.tiles.map(
        (model) => TileComponent(
          model: model,
          onDragStarted: _onTileDragStarted,
          onDragUpdated: _onTileDragUpdated,
          onDragFinished: _onTileDragFinished,
          onDragCancelled: _onTileDragCancelled,
        ),
      ),
    );
  }

  BoardState _state;
  final BoardConfig config;
  final BoardDropRequestCallback onDropRequested;
  final BoardLayout _layout;
  final BoardDragController _dragController;

  bool _isSwapAnimating = false;
  double _tileExtent = 0;

  bool get acceptsDragInput => !_isSwapAnimating && !_state.completed;

  static const _restingPriority = 0;
  static const _draggedPriority = 100;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    final result = _layout.calculate(
      availableSize: size,
      boardSize: _state.boardSize,
    );
    position = result.boardPosition;
    this.size = result.boardSize;
    _tileExtent = result.tileSize;

    _synchronizeLayout(animateTileIds: const {});
    _syncTargetHighlight();
  }

  bool _onTileDragStarted(TileComponent tile) {
    if (!acceptsDragInput) {
      return false;
    }

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

  void _onTileDragFinished(TileComponent tile) {
    tile.priority = _restingPriority;
    final result = _dragController.endDrag(tile.model.id);
    _syncTargetHighlight();

    final targetTileId = result.targetTileId;
    if (targetTileId == null) {
      tile.moveTo(result.originalPosition);
      return;
    }

    final sourceIndex = _indexOfTile(result.sourceTileId);
    final targetIndex = _indexOfTile(targetTileId);
    _state = onDropRequested(
      BoardDropRequest(sourceIndex: sourceIndex, targetIndex: targetIndex),
    );
    _isSwapAnimating = true;
    _synchronizeLayout(animateTileIds: {result.sourceTileId, targetTileId});
  }

  void _syncTargetHighlight() {
    final activeTargetId = _dragController.activeTargetTileId;
    for (final tile in children.whereType<TileComponent>()) {
      tile.isDropTarget = tile.model.id == activeTargetId;
    }
  }

  int _indexOfTile(String tileId) {
    final index = _state.tiles.indexWhere((tile) => tile.id == tileId);
    if (index == -1) {
      throw StateError('Tile $tileId is not present in BoardState.');
    }
    return index;
  }

  void _synchronizeLayout({required Set<String> animateTileIds}) {
    final tileComponents = {
      for (final tile in children.whereType<TileComponent>())
        tile.model.id: tile,
    };
    final originalPositions = <String, Vector2>{};
    var remainingAnimations = animateTileIds.length;

    for (var index = 0; index < _state.tiles.length; index++) {
      final model = _state.tiles[index];
      final tile = tileComponents[model.id];
      if (tile == null) {
        throw StateError('Missing TileComponent for ${model.id}.');
      }

      final destination = _layout.tilePosition(
        row: index ~/ _state.boardSize,
        column: index % _state.boardSize,
        tileSize: _tileExtent,
      );
      originalPositions[model.id] = destination;
      tile.size = Vector2.all(_tileExtent);

      if (animateTileIds.contains(model.id)) {
        tile.moveTo(
          destination,
          onComplete: () {
            remainingAnimations--;
            if (remainingAnimations == 0) {
              _isSwapAnimating = false;
            }
          },
        );
      } else {
        tile.position = destination;
      }
    }

    _dragController.updateLayout(
      boardSize: size,
      originalPositions: originalPositions,
      boardDimension: _state.boardSize,
      tileExtent: _tileExtent,
      spacing: config.spacing,
    );
  }

  void _onTileDragCancelled(TileComponent tile) {
    tile.priority = _restingPriority;
    final result = _dragController.endDrag(tile.model.id);
    _syncTargetHighlight();
    tile.moveTo(result.originalPosition);
  }
}
