import 'dart:ui';

import 'package:flame/components.dart';
import 'package:pixel_harmony/game/board/board_config.dart';
import 'package:pixel_harmony/game/board/board_layout.dart';
import 'package:pixel_harmony/game/coloring/pixel_coloring_cell_component.dart';
import 'package:pixel_harmony/game/coloring/pixel_coloring_session.dart';
import 'package:pixel_harmony/game/coloring/pixel_coloring_state.dart';

class PixelColoringBoardComponent extends PositionComponent {
  PixelColoringBoardComponent({
    required this.session,
    required this.config,
    required this.onStateChanged,
    required this.onCellPainted,
    required this.onCompleted,
  }) : _layout = BoardLayout(config) {
    final template = session.state.template;
    addAll([
      for (var index = 0; index < template.pixels.length; index++)
        PixelColoringCellComponent(
          cellIndex: index,
          targetColor: Color(template.palette[template.pixels[index]]),
          identifier: template.identifierForPalette(template.pixels[index]),
          paintable: template.isPaintable(index),
          onTapped: _paintCell,
        ),
    ]);
  }

  final PixelColoringSession session;
  final BoardConfig config;
  final void Function(PixelColoringState state) onStateChanged;
  final void Function() onCellPainted;
  final void Function() onCompleted;
  final BoardLayout _layout;
  double _tileExtent = 0;
  bool _completionNotified = false;
  bool inputBlocked = false;

  bool get acceptsInput => !session.state.completed && !inputBlocked;

  void selectPalette(int paletteIndex) {
    session.selectPalette(paletteIndex);
    _syncCells();
    onStateChanged(session.state);
  }

  bool applyHint() {
    if (!session.applyHint()) {
      return false;
    }
    onCellPainted();
    _syncCells();
    onStateChanged(session.state);
    _notifyCompletionIfNeeded();
    return true;
  }

  void _paintCell(int cellIndex) {
    _paintCellWithFeedback(cellIndex, feedback: true);
  }

  void _paintCellWithFeedback(int cellIndex, {required bool feedback}) {
    if (!acceptsInput) {
      return;
    }
    final result = session.paint(cellIndex);
    if (result == PixelPaintResult.wrongColor) {
      if (feedback) _cell(cellIndex).showWrongFeedback();
      return;
    }
    if (result != PixelPaintResult.painted) {
      return;
    }
    if (feedback) {
      onCellPainted();
    }
    _syncCells();
    onStateChanged(session.state);
    _notifyCompletionIfNeeded();
  }

  void _notifyCompletionIfNeeded() {
    if (!session.state.completed || _completionNotified) {
      return;
    }
    _completionNotified = true;
    onCompleted();
  }

  PixelColoringCellComponent _cell(int index) => children
      .whereType<PixelColoringCellComponent>()
      .firstWhere((cell) => cell.cellIndex == index);

  void _syncCells() {
    final state = session.state;
    for (final cell in children.whereType<PixelColoringCellComponent>()) {
      cell.painted = state.paintedCells[cell.cellIndex];
      cell.matchesSelection =
          !cell.painted &&
          cell.paintable &&
          state.template.pixels[cell.cellIndex] == state.selectedPaletteIndex;
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final template = session.state.template;
    final result = _layout.calculate(
      availableSize: size,
      rowCount: template.rows,
      columnCount: template.columns,
    );
    position = result.boardPosition;
    size = result.boardSize;
    _tileExtent = result.tileSize;
    for (final cell in children.whereType<PixelColoringCellComponent>()) {
      cell
        ..size = Vector2.all(_tileExtent)
        ..position = _layout.tilePosition(
          row: cell.cellIndex ~/ template.columns,
          column: cell.cellIndex % template.columns,
          tileSize: _tileExtent,
        );
    }
    _syncCells();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        size.toRect().inflate(5),
        const Radius.circular(8),
      ),
      Paint()
        ..color = const Color(0x22514B45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    super.render(canvas);
  }
}
