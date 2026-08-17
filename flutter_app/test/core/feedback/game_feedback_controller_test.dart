import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/core/feedback/game_audio_service.dart';
import 'package:pixel_harmony/core/feedback/game_feedback_controller.dart';
import 'package:pixel_harmony/core/feedback/haptic_service.dart';
import 'package:pixel_harmony/features/settings/domain/game_feedback_settings.dart';

void main() {
  test('disabled sound and haptics prevent feedback calls', () {
    final audio = _FakeAudioService();
    final haptics = _FakeHapticService();
    final controller = GameFeedbackController(
      audioService: audio,
      hapticService: haptics,
      settings: const GameFeedbackSettings(
        soundEffectsEnabled: false,
        hapticsEnabled: false,
      ),
    );

    controller.tilePickedUp();
    controller.acceptedSwap();
    controller.levelCompleted();

    expect(audio.totalCalls, 0);
    expect(haptics.totalCalls, 0);
  });

  test('disabled sound still permits enabled haptics', () {
    final audio = _FakeAudioService();
    final haptics = _FakeHapticService();
    final controller = GameFeedbackController(
      audioService: audio,
      hapticService: haptics,
      settings: const GameFeedbackSettings(soundEffectsEnabled: false),
    );

    controller.tilePickedUp();

    expect(audio.totalCalls, 0);
    expect(haptics.pickupCalls, 1);
  });

  test('disabled haptics still permits enabled sound', () {
    final audio = _FakeAudioService();
    final haptics = _FakeHapticService();
    final controller = GameFeedbackController(
      audioService: audio,
      hapticService: haptics,
      settings: const GameFeedbackSettings(hapticsEnabled: false),
    );

    controller.tilePickedUp();

    expect(audio.pickupCalls, 1);
    expect(haptics.totalCalls, 0);
  });

  test('completion feedback fires once per session', () {
    final audio = _FakeAudioService();
    final haptics = _FakeHapticService();
    final controller = GameFeedbackController(
      audioService: audio,
      hapticService: haptics,
    );

    controller.levelCompleted();
    controller.levelCompleted();

    expect(audio.completionCalls, 1);
    expect(haptics.completionCalls, 1);
  });

  test('one accepted swap produces exactly one feedback request', () {
    final audio = _FakeAudioService();
    final haptics = _FakeHapticService();
    final controller = GameFeedbackController(
      audioService: audio,
      hapticService: haptics,
    );

    controller.acceptedSwap();

    expect(audio.swapCalls, 1);
    expect(haptics.swapCalls, 1);
    expect(audio.completionCalls, 0);
    expect(haptics.completionCalls, 0);
  });

  test('background state prevents all feedback', () {
    final audio = _FakeAudioService();
    final haptics = _FakeHapticService();
    final controller = GameFeedbackController(
      audioService: audio,
      hapticService: haptics,
    )..setAppActive(false);

    controller.tilePickedUp();
    controller.acceptedSwap();
    controller.levelCompleted();

    expect(audio.totalCalls, 0);
    expect(haptics.totalCalls, 0);
  });

  test('lifecycle state is forwarded only to lifecycle-aware audio', () async {
    final audio = _LifecycleAudioService();
    final haptics = _FakeHapticService();
    final controller = GameFeedbackController(
      audioService: audio,
      hapticService: haptics,
    );

    controller.setAppActive(false);
    await Future<void>.delayed(Duration.zero);
    controller.setAppActive(true);
    await Future<void>.delayed(Duration.zero);

    expect(audio.activeStates, [false, true]);
    expect(audio.totalCalls, 0);
    expect(haptics.totalCalls, 0);
  });
}

class _FakeAudioService implements GameAudioService {
  int pickupCalls = 0;
  int swapCalls = 0;
  int completionCalls = 0;

  int get totalCalls => pickupCalls + swapCalls + completionCalls;

  @override
  Future<void> playAcceptedSwap() async => swapCalls++;

  @override
  Future<void> playLevelComplete() async => completionCalls++;

  @override
  Future<void> playTilePickup() async => pickupCalls++;
}

class _FakeHapticService implements HapticService {
  int pickupCalls = 0;
  int swapCalls = 0;
  int completionCalls = 0;

  int get totalCalls => pickupCalls + swapCalls + completionCalls;

  @override
  Future<void> acceptedSwap() async => swapCalls++;

  @override
  Future<void> levelComplete() async => completionCalls++;

  @override
  Future<void> tilePickup() async => pickupCalls++;
}

class _LifecycleAudioService extends _FakeAudioService
    implements LifecycleAwareGameAudioService {
  final List<bool> activeStates = [];

  @override
  Future<void> setAudioActive(bool active) async => activeStates.add(active);

  @override
  Future<void> dispose() async {}
}
