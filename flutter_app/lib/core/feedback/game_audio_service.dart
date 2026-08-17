import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum GameSoundEffect { tilePickup, acceptedSwap, levelComplete }

abstract interface class GameAudioService {
  Future<void> playTilePickup();

  Future<void> playAcceptedSwap();

  Future<void> playLevelComplete();
}

abstract interface class LifecycleAwareGameAudioService
    implements GameAudioService {
  Future<void> setAudioActive(bool active);

  Future<void> dispose();
}

abstract interface class GameAudioBackend {
  Future<void> preload(GameSoundEffect effect, String assetPath);

  Future<void> play(GameSoundEffect effect);

  Future<void> stopAll();

  Future<void> dispose();
}

typedef AudioAssetKeysLoader = Future<Set<String>> Function();

class ProductionGameAudioService implements LifecycleAwareGameAudioService {
  ProductionGameAudioService({
    required GameAudioBackend backend,
    AudioAssetKeysLoader assetKeysLoader = loadBundledAudioAssetKeys,
  }) : _backend = backend,
       _assetKeysLoader = assetKeysLoader;

  static const expectedAssetPaths = {
    GameSoundEffect.tilePickup: 'assets/audio/sfx/tile_pickup',
    GameSoundEffect.acceptedSwap: 'assets/audio/sfx/tile_swap',
    GameSoundEffect.levelComplete: 'assets/audio/sfx/level_complete',
  };
  static const _supportedExtensions = ['wav', 'mp3', 'm4a', 'aac'];

  final GameAudioBackend _backend;
  final AudioAssetKeysLoader _assetKeysLoader;
  final Set<GameSoundEffect> _availableEffects = {};
  Future<void>? _initialization;
  bool _isActive = true;
  bool _isDisposed = false;

  Future<void> preload() => _initialization ??= _initializeSafely();

  @override
  Future<void> playTilePickup() => _play(GameSoundEffect.tilePickup);

  @override
  Future<void> playAcceptedSwap() => _play(GameSoundEffect.acceptedSwap);

  @override
  Future<void> playLevelComplete() => _play(GameSoundEffect.levelComplete);

  Future<void> _initializeSafely() async {
    try {
      final assetKeys = await _assetKeysLoader();
      for (final entry in expectedAssetPaths.entries) {
        final assetPath = _findAsset(entry.value, assetKeys);
        if (assetPath == null) {
          debugPrint('Pixel Harmony audio asset unavailable: ${entry.value}.*');
          continue;
        }

        try {
          await _backend.preload(entry.key, _relativeAssetPath(assetPath));
          _availableEffects.add(entry.key);
        } catch (error) {
          debugPrint(
            'Pixel Harmony audio preload failed for $assetPath: $error',
          );
        }
      }
    } catch (error) {
      debugPrint('Pixel Harmony audio manifest could not be read: $error');
    }
  }

  static String? _findAsset(String stem, Set<String> assetKeys) {
    for (final extension in _supportedExtensions) {
      final candidate = '$stem.$extension';
      if (assetKeys.contains(candidate)) {
        return candidate;
      }
    }
    return null;
  }

  static String _relativeAssetPath(String fullPath) {
    const assetPrefix = 'assets/';
    return fullPath.startsWith(assetPrefix)
        ? fullPath.substring(assetPrefix.length)
        : fullPath;
  }

  Future<void> _play(GameSoundEffect effect) async {
    if (!_isActive || _isDisposed) return;
    await preload();
    if (!_isActive || _isDisposed || !_availableEffects.contains(effect)) {
      return;
    }

    try {
      await _backend.play(effect);
    } catch (error) {
      debugPrint('Pixel Harmony audio playback failed for $effect: $error');
    }
  }

  @override
  Future<void> setAudioActive(bool active) async {
    _isActive = active;
    if (!active && !_isDisposed) {
      try {
        await _backend.stopAll();
      } catch (error) {
        debugPrint('Pixel Harmony audio stop failed: $error');
      }
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    try {
      await _initialization;
      await _backend.dispose();
    } catch (error) {
      debugPrint('Pixel Harmony audio disposal failed: $error');
    }
  }
}

Future<Set<String>> loadBundledAudioAssetKeys() async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  return manifest.listAssets().toSet();
}
