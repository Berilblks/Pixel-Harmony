import 'package:audioplayers/audioplayers.dart';
import 'package:pixel_harmony/core/feedback/game_audio_service.dart';

class AudioplayersGameAudioBackend implements GameAudioBackend {
  final Map<GameSoundEffect, AudioPool> _pools = {};
  final Map<GameSoundEffect, StopFunction> _activeSounds = {};
  final Map<GameSoundEffect, Future<void>> _playQueues = {};

  @override
  Future<void> preload(GameSoundEffect effect, String assetPath) async {
    final existingPool = _pools.remove(effect);
    await existingPool?.dispose();
    _pools[effect] = await AudioPool.createFromAsset(
      path: assetPath,
      minPlayers: 1,
      maxPlayers: effect == GameSoundEffect.levelComplete ? 1 : 2,
    );
  }

  @override
  Future<void> play(GameSoundEffect effect) {
    final previous = _playQueues[effect] ?? Future<void>.value();
    final operation = previous.then((_) => _playNow(effect));
    _playQueues[effect] = operation.then<void>((_) {}, onError: (_, _) {});
    return operation;
  }

  Future<void> _playNow(GameSoundEffect effect) async {
    final pool = _pools[effect];
    if (pool == null) return;

    await _activeSounds.remove(effect)?.call();
    _activeSounds[effect] = await pool.start();
  }

  @override
  Future<void> stopAll() async {
    await Future.wait(_playQueues.values);
    final activeSounds = _activeSounds.values.toList(growable: false);
    _activeSounds.clear();
    _playQueues.clear();
    await Future.wait(activeSounds.map((stop) => stop()));
  }

  @override
  Future<void> dispose() async {
    await stopAll();
    final pools = _pools.values.toList(growable: false);
    _pools.clear();
    await Future.wait(pools.map((pool) => pool.dispose()));
  }
}
