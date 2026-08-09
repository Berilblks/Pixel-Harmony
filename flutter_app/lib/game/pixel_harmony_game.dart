import 'dart:ui';

import 'package:flame/game.dart';
import 'package:pixel_harmony/game/board/board_component.dart';
import 'package:pixel_harmony/game/board/board_config.dart';
import 'package:pixel_harmony/game/state/game_session.dart';

class PixelHarmonyGame extends FlameGame {
  PixelHarmonyGame({GameSession? session})
    : session = session ?? GameSession.initial();

  final GameSession session;

  static const _backgroundColor = Color(0xFFF1F4F2);
  static const _boardConfig = BoardConfig(spacing: 14);

  @override
  Color backgroundColor() => _backgroundColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(
      BoardComponent(
        state: session.boardState,
        config: _boardConfig,
        onDropRequested: (request) {
          return session.swapTiles(request.sourceIndex, request.targetIndex);
        },
      ),
    );
  }
}
