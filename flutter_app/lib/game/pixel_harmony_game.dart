import 'dart:ui';

import 'package:flame/game.dart';
import 'package:pixel_harmony/core/theme/app_design_tokens.dart';
import 'package:pixel_harmony/game/board/board_component.dart';
import 'package:pixel_harmony/game/board/board_config.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/state/board_state.dart';
import 'package:pixel_harmony/game/state/game_session.dart';

class PixelHarmonyGame extends FlameGame {
  PixelHarmonyGame({required LevelDefinition level, this.onCompleted})
    : session = GameSession(level: level);

  final GameSession session;
  final void Function(BoardState state)? onCompleted;

  static const _backgroundColor = AppPalette.background;
  static const _boardConfig = BoardConfig(spacing: 14, screenPadding: 32);

  @override
  Color backgroundColor() => _backgroundColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(
      BoardComponent(
        state: session.boardState,
        config: _boardConfig,
        onCompleted: onCompleted,
        onDropRequested: (request) {
          return session.swapTiles(request.sourceIndex, request.targetIndex);
        },
      ),
    );
  }
}
