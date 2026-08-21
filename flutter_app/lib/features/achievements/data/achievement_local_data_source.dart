abstract interface class AchievementLocalDataSource {
  Future<Map<String, DateTime>?> readUnlocked();

  Future<void> writeUnlocked(Map<String, DateTime> unlocked);

  Future<void> clear();
}
