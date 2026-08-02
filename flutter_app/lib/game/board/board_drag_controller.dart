import 'dart:math' as math;

import 'package:flame/components.dart';

class BoardDragController {
  Vector2 _boardSize = Vector2.zero();
  Map<String, Vector2> _originalPositions = const {};
  String? _activeTileId;

  String? get activeTileId => _activeTileId;

  void updateLayout({
    required Vector2 boardSize,
    required Map<String, Vector2> originalPositions,
  }) {
    _boardSize = boardSize.clone();
    _originalPositions = {
      for (final entry in originalPositions.entries)
        entry.key: entry.value.clone(),
    };
  }

  bool tryStartDrag(String tileId) {
    if (_activeTileId != null || !_originalPositions.containsKey(tileId)) {
      return false;
    }

    _activeTileId = tileId;
    return true;
  }

  Vector2 updateDrag({
    required String tileId,
    required Vector2 currentPosition,
    required Vector2 delta,
    required Vector2 tileSize,
  }) {
    if (_activeTileId != tileId) {
      return currentPosition.clone();
    }

    return clampToBoard(
      position: currentPosition + delta,
      tileSize: tileSize,
      boardSize: _boardSize,
    );
  }

  Vector2 endDrag(String tileId) {
    final originalPosition = originalPositionFor(tileId);
    if (_activeTileId == tileId) {
      _activeTileId = null;
    }
    return originalPosition;
  }

  Vector2 originalPositionFor(String tileId) {
    final position = _originalPositions[tileId];
    if (position == null) {
      throw StateError('No board position registered for tile $tileId.');
    }
    return position.clone();
  }

  static Vector2 clampToBoard({
    required Vector2 position,
    required Vector2 tileSize,
    required Vector2 boardSize,
  }) {
    final maxX = math.max(0.0, boardSize.x - tileSize.x);
    final maxY = math.max(0.0, boardSize.y - tileSize.y);

    return Vector2(
      position.x.clamp(0.0, maxX).toDouble(),
      position.y.clamp(0.0, maxY).toDouble(),
    );
  }
}
