import 'dart:ui';

import 'package:pixel_harmony/game/models/tile_model.dart';
import 'package:pixel_harmony/game/state/board_state.dart';

class GameSession {
  const GameSession({required this.boardState});

  factory GameSession.initial() {
    return GameSession(
      boardState: BoardState(
        boardSize: 2,
        tiles: const [
          TileModel(id: 'top-left', color: Color(0xFF5BC0EB)),
          TileModel(id: 'top-right', color: Color(0xFF9BC53D)),
          TileModel(id: 'bottom-left', color: Color(0xFFFDE74C)),
          TileModel(id: 'bottom-right', color: Color(0xFFE55934)),
        ],
      ),
    );
  }

  final BoardState boardState;
}
