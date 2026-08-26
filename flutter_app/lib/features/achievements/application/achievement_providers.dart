import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/core/analytics/analytics_providers.dart';
import 'package:pixel_harmony/core/analytics/analytics_taxonomy.dart';
import 'package:pixel_harmony/features/achievements/data/achievement_local_data_source.dart';
import 'package:pixel_harmony/features/achievements/data/local_achievement_repository.dart';
import 'package:pixel_harmony/features/achievements/data/shared_preferences_achievement_data_source.dart';
import 'package:pixel_harmony/features/achievements/domain/achievement_definition.dart';
import 'package:pixel_harmony/features/achievements/domain/achievement_evaluator.dart';
import 'package:pixel_harmony/features/achievements/domain/achievement_repository.dart';
import 'package:pixel_harmony/features/achievements/domain/achievement_state.dart';
import 'package:pixel_harmony/features/level_progress/domain/level_progress_repository.dart';
import 'package:pixel_harmony/features/level_progress/application/level_progress_providers.dart';
import 'package:pixel_harmony/features/statistics/domain/player_statistics.dart';
import 'package:pixel_harmony/features/statistics/application/player_statistics_providers.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';

final achievementLocalDataSourceProvider = Provider<AchievementLocalDataSource>(
  (ref) {
    return SharedPreferencesAchievementDataSource();
  },
);

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return LocalAchievementRepository(
    dataSource: ref.watch(achievementLocalDataSourceProvider),
  );
});

final achievementEvaluatorProvider = Provider<AchievementEvaluator>((ref) {
  return const AchievementEvaluator();
});

final achievementNowProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
});

final achievementControllerProvider =
    AsyncNotifierProvider<AchievementController, AchievementCollection>(
      AchievementController.new,
    );

class AchievementController extends AsyncNotifier<AchievementCollection> {
  Future<List<AchievementDefinition>>? _evaluationOperation;

  @override
  Future<AchievementCollection> build() async {
    final result = await _evaluateAndPersist();
    return result.$1;
  }

  Future<List<AchievementDefinition>> evaluateAfterCompletion(
    PlayerStatistics statistics,
  ) {
    final active = _evaluationOperation;
    if (active != null) return active;
    final operation = _evaluateAfterCompletion(statistics);
    _evaluationOperation = operation;
    return operation.whenComplete(() => _evaluationOperation = null);
  }

  Future<List<AchievementDefinition>> _evaluateAfterCompletion(
    PlayerStatistics statistics,
  ) async {
    try {
      final result = await _evaluateAndPersist(statistics: statistics);
      state = AsyncData(result.$1);
      return result.$2;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return const [];
    }
  }

  Future<(AchievementCollection, List<AchievementDefinition>)>
  _evaluateAndPersist({PlayerStatistics? statistics}) async {
    final repository = ref.read(achievementRepositoryProvider);
    final previouslyUnlocked = await repository.readUnlocked();
    final resolvedStatistics =
        statistics ?? await ref.read(playerStatisticsRepositoryProvider).read();
    final completedJourneyIds = await _completedJourneyIds(
      ref.read(levelProgressRepositoryProvider),
    );
    final evaluated = ref
        .read(achievementEvaluatorProvider)
        .evaluate(
          statistics: resolvedStatistics,
          completedJourneyLevelIds: completedJourneyIds,
          chapters: LevelCatalog.chapters,
          unlockedAchievements: previouslyUnlocked,
        );
    final newlyUnlocked = evaluated.states
        .where(
          (item) =>
              item.unlocked &&
              !previouslyUnlocked.containsKey(item.definition.id),
        )
        .map((item) => item.definition)
        .toList(growable: false);
    final persisted = await repository.unlock(
      newlyUnlocked.map((item) => item.id).toSet(),
      ref.read(achievementNowProvider)(),
    );
    for (final achievement in newlyUnlocked) {
      unawaited(
        ref
            .read(appAnalyticsServiceProvider)
            .logEvent(
              AnalyticsEvents.achievementUnlocked,
              parameters: {AnalyticsParameters.achievementId: achievement.id},
            ),
      );
    }
    final finalState = ref
        .read(achievementEvaluatorProvider)
        .evaluate(
          statistics: resolvedStatistics,
          completedJourneyLevelIds: completedJourneyIds,
          chapters: LevelCatalog.chapters,
          unlockedAchievements: persisted,
        );
    return (finalState, newlyUnlocked);
  }

  Future<Set<String>> _completedJourneyIds(
    LevelProgressRepository repository,
  ) async {
    final progress = await repository.readAll();
    return progress
        .where((item) => item.completed)
        .map((item) => item.levelId)
        .toSet();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => (await _evaluateAndPersist()).$1,
    );
  }
}
