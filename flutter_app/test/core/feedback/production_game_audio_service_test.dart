import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/core/feedback/game_audio_service.dart';

void main() {
  const assets = {
    'assets/audio/sfx/tile_pickup.wav',
    'assets/audio/sfx/tile_swap.mp3',
    'assets/audio/sfx/level_complete.m4a',
  };

  test('preloads and plays each available production sound role', () async {
    final backend = _FakeGameAudioBackend();
    final service = ProductionGameAudioService(
      backend: backend,
      assetKeysLoader: () async => assets,
    );

    await service.preload();
    await service.playTilePickup();
    await service.playAcceptedSwap();
    await service.playLevelComplete();

    expect(backend.preloadedPaths, {
      GameSoundEffect.tilePickup: 'audio/sfx/tile_pickup.wav',
      GameSoundEffect.acceptedSwap: 'audio/sfx/tile_swap.mp3',
      GameSoundEffect.levelComplete: 'audio/sfx/level_complete.m4a',
    });
    expect(backend.playedEffects, [
      GameSoundEffect.tilePickup,
      GameSoundEffect.acceptedSwap,
      GameSoundEffect.levelComplete,
    ]);
  });

  test('missing production assets are skipped safely', () async {
    final backend = _FakeGameAudioBackend();
    final service = ProductionGameAudioService(
      backend: backend,
      assetKeysLoader: () async => const {},
    );

    await service.preload();
    await service.playTilePickup();
    await service.playAcceptedSwap();
    await service.playLevelComplete();

    expect(backend.preloadedPaths, isEmpty);
    expect(backend.playedEffects, isEmpty);
  });

  test('playback and manifest errors never escape the service', () async {
    final playbackBackend = _FakeGameAudioBackend(throwOnPlay: true);
    final playbackService = ProductionGameAudioService(
      backend: playbackBackend,
      assetKeysLoader: () async => assets,
    );
    final manifestService = ProductionGameAudioService(
      backend: _FakeGameAudioBackend(),
      assetKeysLoader: () => Future.error(StateError('manifest unavailable')),
    );

    await expectLater(playbackService.playTilePickup(), completes);
    await expectLater(manifestService.playTilePickup(), completes);
  });

  test('background stops active sounds and resume does not autoplay', () async {
    final backend = _FakeGameAudioBackend();
    final service = ProductionGameAudioService(
      backend: backend,
      assetKeysLoader: () async => assets,
    );
    await service.playTilePickup();

    await service.setAudioActive(false);
    await service.playAcceptedSwap();
    expect(backend.stopAllCalls, 1);
    expect(backend.playedEffects, [GameSoundEffect.tilePickup]);

    await service.setAudioActive(true);
    expect(backend.playedEffects, [GameSoundEffect.tilePickup]);
    await service.playAcceptedSwap();
    expect(backend.playedEffects, [
      GameSoundEffect.tilePickup,
      GameSoundEffect.acceptedSwap,
    ]);
  });

  test('dispose releases the backend once', () async {
    final backend = _FakeGameAudioBackend();
    final service = ProductionGameAudioService(
      backend: backend,
      assetKeysLoader: () async => assets,
    );

    await service.dispose();
    await service.dispose();

    expect(backend.disposeCalls, 1);
  });
}

class _FakeGameAudioBackend implements GameAudioBackend {
  _FakeGameAudioBackend({this.throwOnPlay = false});

  final bool throwOnPlay;
  final Map<GameSoundEffect, String> preloadedPaths = {};
  final List<GameSoundEffect> playedEffects = [];
  int stopAllCalls = 0;
  int disposeCalls = 0;

  @override
  Future<void> preload(GameSoundEffect effect, String assetPath) async {
    preloadedPaths[effect] = assetPath;
  }

  @override
  Future<void> play(GameSoundEffect effect) async {
    if (throwOnPlay) throw StateError('playback failed');
    playedEffects.add(effect);
  }

  @override
  Future<void> stopAll() async => stopAllCalls++;

  @override
  Future<void> dispose() async => disposeCalls++;
}
