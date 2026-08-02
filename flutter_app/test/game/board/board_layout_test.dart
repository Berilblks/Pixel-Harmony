import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/board/board_config.dart';
import 'package:pixel_harmony/game/board/board_layout.dart';

void main() {
  test('calculates a centered 2x2 board from the available width', () {
    const config = BoardConfig(spacing: 12, screenPadding: 24);
    const layout = BoardLayout(config);

    final result = layout.calculate(
      availableSize: Vector2(400, 700),
      boardSize: 2,
    );

    expect(result.tileSize, 170);
    expect(result.boardSize, Vector2.all(352));
    expect(result.boardPosition, Vector2(24, 174));
    expect(
      layout.tilePosition(row: 1, column: 1, tileSize: result.tileSize),
      Vector2(182, 182),
    );
  });

  test('the same configuration supports larger square boards', () {
    const config = BoardConfig(spacing: 8, screenPadding: 20);
    const layout = BoardLayout(config);

    final result = layout.calculate(
      availableSize: Vector2(390, 700),
      boardSize: 5,
    );

    expect(result.tileSize, closeTo(63.6, 0.001));
    expect(result.boardSize.x, closeTo(350, 0.001));
  });
}
