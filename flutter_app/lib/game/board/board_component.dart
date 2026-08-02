import 'package:flame/components.dart';
import 'package:pixel_harmony/game/board/board_config.dart';
import 'package:pixel_harmony/game/board/board_layout.dart';
import 'package:pixel_harmony/game/components/tile_component.dart';
import 'package:pixel_harmony/game/state/board_state.dart';

class BoardComponent extends PositionComponent {
  BoardComponent({required this.state, required this.config})
    : _layout = BoardLayout(config) {
    addAll(state.tiles.map((model) => TileComponent(model: model)));
  }

  final BoardState state;
  final BoardConfig config;
  final BoardLayout _layout;

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
    for (var index = 0; index < tiles.length; index++) {
      final tile = tiles[index];
      tile
        ..position = _layout.tilePosition(
          row: index ~/ state.boardSize,
          column: index % state.boardSize,
          tileSize: result.tileSize,
        )
        ..size = Vector2.all(result.tileSize);
    }
  }
}
