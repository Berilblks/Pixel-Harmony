import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/features/achievements/application/achievement_providers.dart';
import 'package:pixel_harmony/core/analytics/analytics_providers.dart';
import 'package:pixel_harmony/core/analytics/analytics_taxonomy.dart';
import 'package:pixel_harmony/features/level_progress/application/level_progress_providers.dart';
import 'package:pixel_harmony/features/statistics/application/player_statistics_providers.dart';
import 'package:pixel_harmony/features/statistics/domain/player_statistics.dart';

import '../../../support/fake_achievement_repository.dart';
import '../../../support/fake_app_analytics_service.dart';
import '../../../support/fake_level_progress_repository.dart';
import '../../../support/fake_player_statistics_repository.dart';

void main() {
  test(
    'multiple unlocks return one deterministic batch and do not repeat',
    () async {
      final repository = FakeAchievementRepository();
      final analytics = FakeAppAnalyticsService();
      final container = ProviderContainer(
        overrides: [
          achievementRepositoryProvider.overrideWithValue(repository),
          appAnalyticsServiceProvider.overrideWithValue(analytics),
          playerStatisticsRepositoryProvider.overrideWithValue(
            FakePlayerStatisticsRepository(
              statistics: const PlayerStatistics(
                totalPuzzlesCompleted: 9,
                totalMoves: 999,
              ),
            ),
          ),
          levelProgressRepositoryProvider.overrideWithValue(
            FakeLevelProgressRepository(),
          ),
          achievementNowProvider.overrideWithValue(() => DateTime(2026, 8, 21)),
        ],
      );
      addTearDown(container.dispose);
      await container.read(achievementControllerProvider.future);

      final first = await container
          .read(achievementControllerProvider.notifier)
          .evaluateAfterCompletion(
            const PlayerStatistics(totalPuzzlesCompleted: 10, totalMoves: 1000),
          );
      final duplicate = await container
          .read(achievementControllerProvider.notifier)
          .evaluateAfterCompletion(
            const PlayerStatistics(totalPuzzlesCompleted: 10, totalMoves: 1000),
          );

      expect(first.map((item) => item.id), ['ten_harmonies', 'thousand_moves']);
      expect(duplicate, isEmpty);
      expect(analytics.count(AnalyticsEvents.achievementUnlocked), 3);
    },
  );

  test('achievement persistence failure returns no false unlock', () async {
    final container = ProviderContainer(
      overrides: [
        achievementRepositoryProvider.overrideWithValue(
          FakeAchievementRepository(failWrites: true),
        ),
        playerStatisticsRepositoryProvider.overrideWithValue(
          FakePlayerStatisticsRepository(),
        ),
        levelProgressRepositoryProvider.overrideWithValue(
          FakeLevelProgressRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(achievementControllerProvider.future);

    final result = await container
        .read(achievementControllerProvider.notifier)
        .evaluateAfterCompletion(
          const PlayerStatistics(totalPuzzlesCompleted: 1),
        );
    expect(result, isEmpty);
    expect(container.read(achievementControllerProvider).hasError, isTrue);
  });
}
