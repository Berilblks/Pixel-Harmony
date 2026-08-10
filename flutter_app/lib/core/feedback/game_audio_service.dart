abstract interface class GameAudioService {
  Future<void> playTilePickup();

  Future<void> playAcceptedSwap();

  Future<void> playLevelComplete();
}

/// Keeps the feedback contract active until approved production assets exist.
class SilentGameAudioService implements GameAudioService {
  @override
  Future<void> playAcceptedSwap() async {}

  @override
  Future<void> playLevelComplete() async {}

  @override
  Future<void> playTilePickup() async {}
}
