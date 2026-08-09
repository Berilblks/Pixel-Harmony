import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/board/board_drag_controller.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/state/game_session.dart';

void main() {
  late BoardDragController controller;

  setUp(() {
    controller =
        BoardDragController()..updateLayout(
          boardSize: Vector2.all(200),
          originalPositions: {
            'first': Vector2.zero(),
            'second': Vector2(110, 0),
            'third': Vector2(0, 110),
            'fourth': Vector2(110, 110),
          },
          boardDimension: 2,
          tileExtent: 90,
          spacing: 20,
        );
  });

  test('clamps a dragged tile inside board bounds', () {
    expect(controller.tryStartDrag('first'), isTrue);

    final position = controller.updateDrag(
      tileId: 'first',
      currentPosition: Vector2(20, 30),
      delta: Vector2(300, -100),
      tileSize: Vector2.all(90),
    );

    expect(position, Vector2(110, 0));
  });

  test('returns the registered original position', () {
    expect(controller.tryStartDrag('second'), isTrue);

    final result = controller.endDrag('second');

    expect(result.originalPosition, Vector2(110, 0));
    expect(result.targetTileId, isNull);
    expect(controller.activeTileId, isNull);
  });

  test('allows only one active drag', () {
    expect(controller.tryStartDrag('first'), isTrue);
    expect(controller.tryStartDrag('second'), isFalse);
    expect(controller.activeTileId, 'first');

    controller.endDrag('first');

    expect(controller.tryStartDrag('second'), isTrue);
  });

  test('changes and clears the active target while dragging', () {
    expect(controller.tryStartDrag('first'), isTrue);

    var position = controller.updateDrag(
      tileId: 'first',
      currentPosition: Vector2.zero(),
      delta: Vector2(110, 0),
      tileSize: Vector2.all(90),
    );
    expect(controller.activeTargetTileId, 'second');

    position = controller.updateDrag(
      tileId: 'first',
      currentPosition: position,
      delta: Vector2(-110, 110),
      tileSize: Vector2.all(90),
    );
    expect(controller.activeTargetTileId, 'third');

    controller.updateDrag(
      tileId: 'first',
      currentPosition: position,
      delta: Vector2(55, -55),
      tileSize: Vector2.all(90),
    );
    expect(controller.activeTargetTileId, isNull);
  });

  test('clears the active target when drag ends', () {
    expect(controller.tryStartDrag('first'), isTrue);
    controller.updateDrag(
      tileId: 'first',
      currentPosition: Vector2.zero(),
      delta: Vector2(110, 0),
      tileSize: Vector2.all(90),
    );
    expect(controller.activeTargetTileId, 'second');

    final result = controller.endDrag('first');

    expect(result.targetTileId, 'second');
    expect(controller.activeTargetTileId, isNull);
  });

  test('visual dragging leaves BoardState unchanged', () {
    final session = GameSession(level: LevelCatalog.levels.first);
    final originalTiles = List.of(session.boardState.tiles);

    expect(controller.tryStartDrag('first'), isTrue);
    controller.updateDrag(
      tileId: 'first',
      currentPosition: Vector2.zero(),
      delta: Vector2(40, 50),
      tileSize: Vector2.all(90),
    );
    final result = controller.endDrag('first');

    expect(result.targetTileId, isNull);
    expect(session.boardState.tiles, orderedEquals(originalTiles));
    expect(session.boardState.moveCount, 0);
    expect(session.boardState.completed, isFalse);
  });
}
