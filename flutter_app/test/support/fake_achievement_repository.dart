import 'package:pixel_harmony/features/achievements/domain/achievement_catalog.dart';
import 'package:pixel_harmony/features/achievements/domain/achievement_repository.dart';

class FakeAchievementRepository implements AchievementRepository {
  FakeAchievementRepository({
    Map<String, DateTime>? unlocked,
    this.failReads = false,
    this.failWrites = false,
  }) : unlocked = Map.of(unlocked ?? const {});

  Map<String, DateTime> unlocked;
  final bool failReads;
  final bool failWrites;
  int writeCount = 0;

  @override
  Future<void> clear() async => unlocked = {};

  @override
  Future<Map<String, DateTime>> readUnlocked() async {
    if (failReads) throw StateError('achievement read failed');
    return Map.unmodifiable(unlocked);
  }

  @override
  Future<Map<String, DateTime>> unlock(
    Set<String> achievementIds,
    DateTime unlockedAt,
  ) async {
    if (achievementIds.isEmpty) return Map.unmodifiable(unlocked);
    if (failWrites) throw StateError('achievement write failed');
    for (final id in achievementIds) {
      if (!AchievementCatalog.contains(id)) throw ArgumentError(id);
    }
    if (achievementIds.any((id) => !unlocked.containsKey(id))) writeCount++;
    for (final id in achievementIds) {
      unlocked.putIfAbsent(id, () => unlockedAt);
    }
    return Map.unmodifiable(unlocked);
  }
}
