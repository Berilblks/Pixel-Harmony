import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pixel_harmony/game/state/board_state.dart';

class GameplayCompletionController extends ChangeNotifier {
  GameplayCompletionController({this.onCompletion});

  final Future<void> Function(BoardState state)? onCompletion;
  BoardState? _completion;
  Future<void> _completionPersistence = Future.value();

  BoardState? get completion => _completion;
  Future<void> get completionPersistence => _completionPersistence;

  void showCompletion(BoardState state) {
    if (!state.completed || _completion != null) {
      return;
    }

    _completion = state;
    final completionCallback = onCompletion;
    if (completionCallback != null) {
      _completionPersistence = completionCallback(state);
      unawaited(_completionPersistence);
    }
    notifyListeners();
  }

  void reset() {
    _completion = null;
    _completionPersistence = Future.value();
    notifyListeners();
  }
}
