import 'dart:ui';

import 'package:flame/game.dart';
import 'package:pixel_harmony/core/theme/app_design_tokens.dart';
import 'package:pixel_harmony/game/board/board_component.dart';
import 'package:pixel_harmony/game/board/board_config.dart';
import 'package:pixel_harmony/game/coloring/pixel_coloring_board_component.dart';
import 'package:pixel_harmony/game/coloring/pixel_coloring_session.dart';
import 'package:pixel_harmony/game/coloring/pixel_coloring_state.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_catalog.dart';
import 'package:pixel_harmony/game/state/board_state.dart';
import 'package:pixel_harmony/game/state/game_session.dart';

class PixelHarmonyGame extends FlameGame {
  PixelHarmonyGame({
    required LevelDefinition level,
    this.onCompleted,
    this.onTilePickedUp,
    this.onSwapCompleted,
    this.onColoringStateChanged,
  }) : session = GameSession(level: level) {
    coloringSession =
        level.puzzleType == JourneyPuzzleType.pixelPicture
            ? PixelColoringSession(
              template: PixelPictureCatalog.byId(level.pictureTemplateId!),
            )
            : null;
  }

  final GameSession session;
  final void Function(BoardState state)? onCompleted;
  final void Function()? onTilePickedUp;
  final void Function()? onSwapCompleted;
  final void Function(PixelColoringState state)? onColoringStateChanged;
  late final PixelColoringSession? coloringSession;
  BoardComponent? _board;
  PixelColoringBoardComponent? _coloringBoard;

  bool get hasActiveHint => _board?.hasActiveHint ?? false;

  bool requestHint() {
    if (coloringSession != null) {
      return _coloringBoard?.applyHint() ?? false;
    }
    final board = _board;
    final hint = session.evaluateHint();
    if (board == null || hint == null) return false;
    return board.showHint(hint);
  }

  void selectColor(int paletteIndex) =>
      _coloringBoard?.selectPalette(paletteIndex);

  void setColoringInteractionBlocked(bool blocked) {
    _coloringBoard?.inputBlocked = blocked;
  }

  static const _backgroundColor = AppPalette.background;
  static const gradientBoardConfig = BoardConfig(
    spacing: 14,
    screenPadding: 32,
  );
  static const pixelPictureBoardConfig = BoardConfig(
    spacing: 1,
    screenPadding: 24,
  );

  @override
  Color backgroundColor() => _backgroundColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final coloring = coloringSession;
    if (coloring != null) {
      final board = PixelColoringBoardComponent(
        session: coloring,
        config: pixelPictureBoardConfig,
        onStateChanged: (state) => onColoringStateChanged?.call(state),
        onCellPainted: () => onTilePickedUp?.call(),
        onCompleted:
            () => onCompleted?.call(session.boardState.withCompleted(true)),
      );
      _coloringBoard = board;
      await add(board);
      onColoringStateChanged?.call(coloring.state);
      return;
    }

    final board = BoardComponent(
      state: session.boardState,
      config: gradientBoardConfig,
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
