import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/debug/large_pixel_art_test_catalog.dart';
import 'package:pixel_harmony/game/board/board_config.dart';
import 'package:pixel_harmony/game/coloring/pixel_coloring_board_component.dart';
import 'package:pixel_harmony/game/coloring/pixel_coloring_cell_component.dart';
import 'package:pixel_harmony/game/coloring/pixel_coloring_session.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_catalog.dart';

void main() {
  test('Pixel Coloring cells paint only through an intentional tap', () {
    final board = _board();
    final cells = board.children.whereType<PixelColoringCellComponent>();
    final state = board.session.state;
    final matching = cells.firstWhere(
      (cell) =>
          cell.paintable &&
          state.template.pixels[cell.cellIndex] == state.selectedPaletteIndex,
    );
    final wrong = cells.firstWhere(
      (cell) =>
          cell.paintable &&
          state.template.pixels[cell.cellIndex] != state.selectedPaletteIndex,
    );

    expect(cells, isNotEmpty);
    matching.onTapped(matching.cellIndex);
    wrong.onTapped(wrong.cellIndex);
    expect(board.session.state.paintedCells[matching.cellIndex], isTrue);
    expect(board.session.state.paintedCells[wrong.cellIndex], isFalse);
  });

  test('one hint paints one cell and full coloring completes once', () {
    final template = PixelPictureCatalog.byId('heart');
    final session = PixelColoringSession(template: template);
    var completionCount = 0;
    final board = PixelColoringBoardComponent(
      session: session,
      config: const BoardConfig(spacing: 1, screenPadding: 0),
      onStateChanged: (_) {},
      onCellPainted: () {},
      onCompleted: () => completionCount++,
    )..onGameResize(Vector2(250, 250));

    expect(board.applyHint(), isTrue);
    expect(session.state.paintedCount, 1);
    while (!session.state.completed) {
      expect(board.applyHint(), isTrue);
    }
    expect(completionCount, 1);
    expect(board.applyHint(), isFalse);
    expect(completionCount, 1);
    expect(board.acceptsInput, isFalse);
    expect(
      board.children
          .whereType<PixelColoringCellComponent>()
          .where((cell) => cell.paintable)
          .every((cell) => cell.completionPresentation),
      isTrue,
    );
  });

  test('16x16, 24x24, and 32x32 boards reveal their painted matrix', () {
    for (final template in [
      PixelPictureCatalog.byId('snowy_mountain'),
      LargePixelArtTestCatalog.redPotion,
      LargePixelArtTestCatalog.castle,
    ]) {
      final session = PixelColoringSession(template: template);
      final board = PixelColoringBoardComponent(
        session: session,
        config: const BoardConfig(spacing: 1, screenPadding: 0),
        onStateChanged: (_) {},
        onCellPainted: () {},
        onCompleted: () {},
      )..onGameResize(Vector2(320, 320));
      while (!session.state.completed) {
        expect(board.applyHint(), isTrue);
      }

      final cells = board.children.whereType<PixelColoringCellComponent>();
      expect(cells, hasLength(template.rows * template.columns));
      expect(
        cells
            .where((cell) => cell.paintable)
            .every(
              (cell) =>
                  cell.painted &&
                  cell.completionPresentation &&
                  cell.targetColor.toARGB32() ==
                      template.palette[template.pixels[cell.cellIndex]],
            ),
        isTrue,
      );
    }
  });

  test('32x32 board lays out every cell and keeps tap targeting exact', () {
    final template = LargePixelArtTestCatalog.castle;
    final session = PixelColoringSession(template: template);
    final board = PixelColoringBoardComponent(
      session: session,
      config: const BoardConfig(spacing: 1, screenPadding: 0),
      onStateChanged: (_) {},
      onCellPainted: () {},
      onCompleted: () {},
    )..onGameResize(Vector2(320, 320));
    final cells = board.children.whereType<PixelColoringCellComponent>();
    final matching = cells.firstWhere(
      (cell) =>
          cell.paintable &&
          template.pixels[cell.cellIndex] == session.state.selectedPaletteIndex,
    );
    final wrong = cells.firstWhere(
      (cell) =>
          cell.paintable &&
          template.pixels[cell.cellIndex] != session.state.selectedPaletteIndex,
    );

    expect(cells, hasLength(32 * 32));
    expect(matching.size.x, closeTo((320 - 31) / 32, 0.001));
    matching.onTapped(matching.cellIndex);
    wrong.onTapped(wrong.cellIndex);
    expect(session.state.paintedCells[matching.cellIndex], isTrue);
    expect(session.state.paintedCells[wrong.cellIndex], isFalse);
  });
}

PixelColoringBoardComponent _board() {
  return PixelColoringBoardComponent(
    session: PixelColoringSession(
      template: PixelPictureCatalog.byId('butterfly'),
    ),
    config: const BoardConfig(spacing: 1, screenPadding: 0),
    onStateChanged: (_) {},
    onCellPainted: () {},
    onCompleted: () {},
  )..onGameResize(Vector2(300, 300));
}
