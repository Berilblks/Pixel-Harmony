abstract interface class AchievementRepository {
  Future<Map<String, DateTime>> readUnlocked();

  Future<Map<String, DateTime>> unlock(
    Set<String> achievementIds,
    DateTime unlockedAt,
  );

  Future<void> clear();
}
