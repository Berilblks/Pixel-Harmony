import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pixel_harmony/game/state/board_state.dart';

class GameplayCompletionController extends ChangeNotifier {
  GameplayCompletionController({this.onCompletion});

  final Future<void> Function(BoardState state)? onCompletion;
  BoardState? _completion;

  BoardState? get completion => _completion;

  void showCompletion(BoardState state) {
    if (!state.completed || _completion != null) {
      return;
    }

    _completion = state;
    final completionCallback = onCompletion;
    if (completionCallback != null) {
      unawaited(completionCallback(state));
    }
    notifyListeners();
  }
}
