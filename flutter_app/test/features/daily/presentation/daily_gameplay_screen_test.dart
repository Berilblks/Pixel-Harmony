import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/app/app.dart';
import 'package:pixel_harmony/features/achievements/application/achievement_providers.dart';
import 'package:pixel_harmony/features/daily/application/daily_progress_providers.dart';
import 'package:pixel_harmony/features/daily/domain/daily_clock.dart';
import 'package:pixel_harmony/features/daily/domain/daily_progress.dart';
import 'package:pixel_harmony/features/endless/application/endless_progress_providers.dart';
import 'package:pixel_harmony/features/level_progress/application/level_progress_providers.dart';
import 'package:pixel_harmony/features/statistics/application/player_statistics_providers.dart';
import 'package:pixel_harmony/game/pixel_harmony_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_daily_progress_repository.dart';
import '../../../support/fake_achievement_repository.dart';
import '../../../support/fake_endless_progress_repository.dart';
import '../../../support/fake_level_progress_repository.dart';
import '../../../support/fake_player_statistics_repository.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget buildApp({
    required FakeDailyProgressRepository daily,
    FakeLevelProgressRepository? journey,
    FakeEndlessProgressRepository? endless,
    FakePlayerStatisticsRepository? statistics,
    FakeAchievementRepository? achievements,
  }) {
    return ProviderScope(
      overrides: [
        dailyClockProvider.overrideWithValue(
          _FakeClock(DateTime(2026, 8, 19, 12)),
        ),
        dailyProgressRepositoryProvider.overrideWithValue(daily),
        levelProgressRepositoryProvider.overrideWithValue(
          journey ?? FakeLevelProgressRepository(),
        ),
        endlessProgressRepositoryProvider.overrideWithValue(
          endless ?? FakeEndlessProgressRepository(),
        ),
        playerStatisticsRepositoryProvider.overrideWithValue(
          statistics ?? FakePlayerStatisticsRepository(),
        ),
        achievementRepositoryProvider.overrideWithValue(
          achievements ?? FakeAchievementRepository(),
        ),
      ],
      child: const PixelHarmonyApp(),
    );
  }

  Future<PixelHarmonyGame> openDaily(
    WidgetTester tester, {
    required FakeDailyProgressRepository daily,
    FakeLevelProgressRepository? journey,
    FakeEndlessProgressRepository? endless,
    FakePlayerStatisticsRepository? statistics,
    FakeAchievementRepository? achievements,
  }) async {
    await tester.pumpWidget(
      buildApp(
        daily: daily,
        journey: journey,
        endless: endless,
        statistics: statistics,
        achievements: achievements,
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('homeDailyButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    return tester
        .widget<GameWidget<PixelHarmonyGame>>(
          find.byType(GameWidget<PixelHarmonyGame>),
        )
        .game!;
  }

  testWidgets('Daily completion is idempotent and isolated from other modes', (
    tester,
  ) async {
    final daily = FakeDailyProgressRepository();
    final journey = FakeLevelProgressRepository();
    final endless = FakeEndlessProgressRepository();
    final statistics = FakePlayerStatisticsRepository();
    final achievements = FakeAchievementRepository();
    final game = await openDaily(
      tester,
      daily: daily,
      journey: journey,
      endless: endless,
      statistics: statistics,
      achievements: achievements,
    );

    final completed = game.session.boardState.withCompleted(true);
    game.onCompleted!(completed);
    game.onCompleted!(completed);
    await tester.pump(const Duration(milliseconds: 100));

    expect(daily.completeCallCount, 1);
    expect(daily.progress.currentStreak, 1);
    expect(journey.markCompletedCallCount, 0);
    expect(journey.completedLevelIds, isEmpty);
    expect(endless.advanceCallCount, 0);
    expect(endless.progress.completedPuzzleCount, 0);
    expect(statistics.statistics.dailyPuzzlesCompleted, 1);
    expect(statistics.statistics.currentDailyStreak, 1);
    expect(achievements.unlocked, contains('first_harmony'));
    expect(find.byKey(const Key('achievementUnlockFeedback')), findsOneWidget);
  });

  testWidgets('persistence failure keeps completion overlay usable', (
    tester,
  ) async {
    final daily = FakeDailyProgressRepository(failWrites: true);
    final game = await openDaily(tester, daily: daily);

    game.onCompleted!(game.session.boardState.withCompleted(true));
    await tester.pump();

    expect(find.byKey(const Key('levelCompleteOverlay')), findsOneWidget);
    expect(find.text('Daily Complete'), findsOneWidget);
    expect(daily.progress.totalDailyCompleted, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('statistics failure does not block Daily completion', (
    tester,
  ) async {
    final daily = FakeDailyProgressRepository();
    final statistics = FakePlayerStatisticsRepository(failWrites: true);
    final game = await openDaily(tester, daily: daily, statistics: statistics);

    game.onCompleted!(game.session.boardState.withCompleted(true));
    await tester.pump();

    expect(daily.progress.totalDailyCompleted, 1);
    expect(find.byKey(const Key('levelCompleteOverlay')), findsOneWidget);
  });

  testWidgets('backwards-clock Daily rejection does not record statistics', (
    tester,
  ) async {
    final daily = FakeDailyProgressRepository(
      progress: const DailyProgress(
        lastCompletedDateKey: '2026-08-20',
        currentStreak: 2,
        longestStreak: 2,
        totalDailyCompleted: 2,
      ),
    );
    final statistics = FakePlayerStatisticsRepository();
    final game = await openDaily(tester, daily: daily, statistics: statistics);

    game.onCompleted!(game.session.boardState.withCompleted(true));
    await tester.pump();

    expect(daily.progress.lastCompletedDateKey, '2026-08-20');
    expect(statistics.recordCallCount, 0);
  });

  testWidgets('Daily Home and completion copy is localized in Turkish', (
    tester,
  ) async {
    tester.binding.platformDispatcher.localesTestValue = const [Locale('tr')];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);
    final daily = FakeDailyProgressRepository();
    final game = await openDaily(tester, daily: daily);

    expect(find.text('Günün Bulmacası'), findsOneWidget);
    game.onCompleted!(game.session.boardState.withCompleted(true));
    await tester.pump();
    expect(find.text('Günün Bulmacası Tamamlandı'), findsOneWidget);
    expect(find.text('Bugünün uyumu tamamlandı.'), findsOneWidget);
  });
}

class _FakeClock implements DailyClock {
  const _FakeClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}
