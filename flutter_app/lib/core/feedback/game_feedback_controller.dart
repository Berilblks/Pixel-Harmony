import 'dart:async';

import 'package:pixel_harmony/core/feedback/game_audio_service.dart';
import 'package:pixel_harmony/core/feedback/haptic_service.dart';
import 'package:pixel_harmony/features/settings/domain/game_feedback_settings.dart';

class GameFeedbackController {
  GameFeedbackController({
    required GameAudioService audioService,
    required HapticService hapticService,
    GameFeedbackSettings settings = const GameFeedbackSettings(),
  }) : _audioService = audioService,
       _hapticService = hapticService,
       _settings = settings;

  final GameAudioService _audioService;
  final HapticService _hapticService;
  GameFeedbackSettings _settings;
  bool _isAppActive = true;
  bool _didComplete = false;

  void updateSettings(GameFeedbackSettings settings) {
    _settings = settings;
  }

  void setAppActive(bool active) {
    _isAppActive = active;
    final audioService = _audioService;
    if (audioService is LifecycleAwareGameAudioService) {
      unawaited(audioService.setAudioActive(active));
    }
  }

  void resetSession() {
    _didComplete = false;
  }

  void tilePickedUp() {
    if (!_isAppActive) return;
    if (_settings.soundEffectsEnabled) {
      unawaited(_audioService.playTilePickup());
    }
    if (_settings.hapticsEnabled) {
      unawaited(_hapticService.tilePickup());
    }
  }

  void acceptedSwap() {
    if (!_isAppActive) return;
    if (_settings.soundEffectsEnabled) {
      unawaited(_audioService.playAcceptedSwap());
    }
    if (_settings.hapticsEnabled) {
      unawaited(_hapticService.acceptedSwap());
    }
  }

  void levelCompleted() {
    if (!_isAppActive || _didComplete) return;
    _didComplete = true;
    if (_settings.soundEffectsEnabled) {
      unawaited(_audioService.playLevelComplete());
    }
    if (_settings.hapticsEnabled) {
      unawaited(_hapticService.levelComplete());
    }
  }
}
