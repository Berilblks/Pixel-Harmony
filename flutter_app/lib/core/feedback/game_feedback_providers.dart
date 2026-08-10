import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/core/feedback/game_audio_service.dart';
import 'package:pixel_harmony/core/feedback/haptic_service.dart';

final gameAudioServiceProvider = Provider<GameAudioService>((ref) {
  return SilentGameAudioService();
});

final hapticServiceProvider = Provider<HapticService>((ref) {
  return FlutterHapticService();
});
