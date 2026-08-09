import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:pixel_harmony/game/board/board_target_detector.dart';

class BoardDragController {
  BoardDragController({BoardTargetDetector? targetDetector})
    : _targetDetector = targetDetector ?? const BoardTargetDetector();

  final BoardTargetDetector _targetDetector;

  Vector2 _boardSize = Vector2.zero();
  Map<String, Vector2> _originalPositions = const {};
  List<String> _tileIds = const [];
  int _boardDimension = 0;
  double _tileExtent = 0;
  double _spacing = 0;
  String? _activeTileId;
  String? _activeTargetTileId;

  String? get activeTileId => _activeTileId;
  String? get activeTargetTileId => _activeTargetTileId;

  void updateLayout({
    required Vector2 boardSize,
    required Map<String, Vector2> originalPositions,
    required int boardDimension,
    required double tileExtent,
    required double spacing,
  }) {
    _boardSize = boardSize.clone();
    _originalPositions = {
      for (final entry in originalPositions.entries)
        entry.key: entry.value.clone(),
    };
    _tileIds = List.unmodifiable(originalPositions.keys);
    _boardDimension = boardDimension;
    _tileExtent = tileExtent;
    _spacing = spacing;
  }

  bool tryStartDrag(String tileId) {
    if (_activeTileId != null || !_originalPositions.containsKey(tileId)) {
      return false;
    }

    _activeTileId = tileId;
    _activeTargetTileId = null;
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

    final nextPosition = clampToBoard(
      position: currentPosition + delta,
      tileSize: tileSize,
      boardSize: _boardSize,
    );
    _updateTarget(tileId: tileId, tilePosition: nextPosition);
    return nextPosition;
  }

  BoardDragEndResult endDrag(String tileId) {
    final originalPosition = originalPositionFor(tileId);
    final targetTileId = _activeTileId == tileId ? _activeTargetTileId : null;
    if (_activeTileId == tileId) {
      _activeTileId = null;
      _activeTargetTileId = null;
    }
    return BoardDragEndResult(
      sourceTileId: tileId,
      targetTileId: targetTileId,
      originalPosition: originalPosition,
    );
  }

  void _updateTarget({required String tileId, required Vector2 tilePosition}) {
    final sourceIndex = _tileIds.indexOf(tileId);
    if (sourceIndex == -1 || _boardDimension == 0) {
      _activeTargetTileId = null;
      return;
    }

    final center = tilePosition + Vector2.all(_tileExtent / 2);
    final targetIndex = _targetDetector.detect(
      draggedCenter: math.Point(center.x, center.y),
      sourceIndex: sourceIndex,
      boardSize: _boardDimension,
      tileSize: _tileExtent,
      spacing: _spacing,
    );
    _activeTargetTileId = targetIndex == null ? null : _tileIds[targetIndex];
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

class BoardDragEndResult {
  const BoardDragEndResult({
    required this.sourceTileId,
    required this.targetTileId,
    required this.originalPosition,
  });

  final String sourceTileId;
  final String? targetTileId;
  final Vector2 originalPosition;
}
