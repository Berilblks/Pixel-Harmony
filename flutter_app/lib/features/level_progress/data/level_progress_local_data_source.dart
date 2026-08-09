abstract interface class LevelProgressLocalDataSource {
  Future<Set<String>> readCompletedLevelIds();

  Future<void> writeCompletedLevelIds(Set<String> levelIds);

  Future<void> clear();
}
