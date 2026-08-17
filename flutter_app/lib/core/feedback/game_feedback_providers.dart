import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/core/feedback/audioplayers_game_audio_backend.dart';
import 'package:pixel_harmony/core/feedback/game_audio_service.dart';
import 'package:pixel_harmony/core/feedback/haptic_service.dart';

final gameAudioServiceProvider = Provider<GameAudioService>((ref) {
  final service = ProductionGameAudioService(
    backend: AudioplayersGameAudioBackend(),
  );
  unawaited(service.preload());
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});

final hapticServiceProvider = Provider<HapticService>((ref) {
  return FlutterHapticService();
});
