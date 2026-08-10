class GameFeedbackSettings {
  const GameFeedbackSettings({
    this.soundEffectsEnabled = true,
    this.hapticsEnabled = true,
  });

  final bool soundEffectsEnabled;
  final bool hapticsEnabled;

  GameFeedbackSettings copyWith({
    bool? soundEffectsEnabled,
    bool? hapticsEnabled,
  }) {
    return GameFeedbackSettings(
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is GameFeedbackSettings &&
      other.soundEffectsEnabled == soundEffectsEnabled &&
      other.hapticsEnabled == hapticsEnabled;

  @override
  int get hashCode => Object.hash(soundEffectsEnabled, hapticsEnabled);
}
