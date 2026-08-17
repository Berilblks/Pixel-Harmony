import 'dart:ui';

import 'package:flame/game.dart';
import 'package:pixel_harmony/core/theme/app_design_tokens.dart';
import 'package:pixel_harmony/game/board/board_component.dart';
import 'package:pixel_harmony/game/board/board_config.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/state/board_state.dart';
import 'package:pixel_harmony/game/state/game_session.dart';

class PixelHarmonyGame extends FlameGame {
  PixelHarmonyGame({
    required LevelDefinition level,
    this.onCompleted,
    this.onTilePickedUp,
    this.onSwapCompleted,
  }) : session = GameSession(level: level);

  final GameSession session;
  final void Function(BoardState state)? onCompleted;
  final void Function()? onTilePickedUp;
  final void Function()? onSwapCompleted;
  BoardComponent? _board;

  bool get hasActiveHint => _board?.hasActiveHint ?? false;

  bool requestHint() {
    final board = _board;
    final hint = session.evaluateHint();
    if (board == null || hint == null) {
      return false;
    }
    return board.showHint(hint);
  }

  static const _backgroundColor = AppPalette.background;
  static const _boardConfig = BoardConfig(spacing: 14, screenPadding: 32);

  @override
  Color backgroundColor() => _backgroundColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final board = BoardComponent(
      state: session.boardState,
      config: _boardConfig,
      onCompleted: onCompleted,
      onTilePickedUp: onTilePickedUp,
      onSwapCompleted: onSwapCompleted,
      onDropRequested: (request) {
        return session.swapTiles(request.sourceIndex, request.targetIndex);
      },
    );
    _board = board;
    await add(board);
  }
}
