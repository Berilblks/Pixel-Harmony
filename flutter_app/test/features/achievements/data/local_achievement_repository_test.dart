import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/features/achievements/data/achievement_local_data_source.dart';
import 'package:pixel_harmony/features/achievements/data/local_achievement_repository.dart';

void main() {
  final unlockedAt = DateTime(2026, 8, 21, 12);

  test('unlock survives repository recreation', () async {
    final source = _MemoryAchievementDataSource();
    await LocalAchievementRepository(
      dataSource: source,
    ).unlock({'first_harmony'}, unlockedAt);

    final recreated = LocalAchievementRepository(dataSource: source);
    expect(await recreated.readUnlocked(), {'first_harmony': unlockedAt});
  });

  test('duplicate unlock is idempotent and keeps original timestamp', () async {
    final source = _MemoryAchievementDataSource();
    final repository = LocalAchievementRepository(dataSource: source);
    await repository.unlock({'first_harmony'}, unlockedAt);
    final result = await repository.unlock({
      'first_harmony',
    }, unlockedAt.add(const Duration(days: 1)));

    expect(result['first_harmony'], unlockedAt);
    expect(source.writeCount, 1);
  });

  test('unknown achievement ID is rejected without a write', () async {
    final source = _MemoryAchievementDataSource();
    final repository = LocalAchievementRepository(dataSource: source);

    await expectLater(
      repository.unlock({'unknown'}, unlockedAt),
      throwsArgumentError,
    );
    expect(source.writeCount, 0);
  });
}

class _MemoryAchievementDataSource implements AchievementLocalDataSource {
  Map<String, DateTime>? unlocked;
  int writeCount = 0;

  @override
  Future<void> clear() async => unlocked = null;

  @override
  Future<Map<String, DateTime>?> readUnlocked() async =>
      unlocked == null ? null : Map.of(unlocked!);

  @override
  Future<void> writeUnlocked(Map<String, DateTime> unlocked) async {
    writeCount++;
    this.unlocked = Map.of(unlocked);
  }
}
