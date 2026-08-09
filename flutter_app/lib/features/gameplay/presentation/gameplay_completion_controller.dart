import 'package:flutter/foundation.dart';
import 'package:pixel_harmony/game/state/board_state.dart';

class GameplayCompletionController extends ChangeNotifier {
  BoardState? _completion;

  BoardState? get completion => _completion;

  void showCompletion(BoardState state) {
    if (!state.completed || _completion != null) {
      return;
    }

    _completion = state;
    notifyListeners();
  }
}
