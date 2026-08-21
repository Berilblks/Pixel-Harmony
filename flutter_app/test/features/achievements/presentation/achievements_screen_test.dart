import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/app/app.dart';
import 'package:pixel_harmony/features/achievements/application/achievement_providers.dart';
import 'package:pixel_harmony/features/achievements/presentation/achievements_screen.dart';
import 'package:pixel_harmony/features/level_progress/application/level_progress_providers.dart';
import 'package:pixel_harmony/features/statistics/application/player_statistics_providers.dart';
import 'package:pixel_harmony/features/statistics/domain/player_statistics.dart';
import 'package:pixel_harmony/features/statistics/presentation/statistics_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_achievement_repository.dart';
import '../../../support/fake_level_progress_repository.dart';
import '../../../support/fake_player_statistics_repository.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget buildApp({
    FakeAchievementRepository? achievements,
    PlayerStatistics statistics = const PlayerStatistics(),
  }) {
    return ProviderScope(
      overrides: [
        achievementRepositoryProvider.overrideWithValue(
          achievements ?? FakeAchievementRepository(),
        ),
        playerStatisticsRepositoryProvider.overrideWithValue(
          FakePlayerStatisticsRepository(statistics: statistics),
        ),
        levelProgressRepositoryProvider.overrideWithValue(
          FakeLevelProgressRepository(),
        ),
        achievementNowProvider.overrideWithValue(
          () => DateTime(2026, 8, 21, 12),
        ),
      ],
      child: const PixelHarmonyApp(),
    );
  }

  Future<void> openFromHome(WidgetTester tester, Widget app) async {
    await tester.pumpWidget(app);
    await tester.pump();
    await tester.tap(find.byKey(const Key('homeAchievementsButton')));
    await tester.pumpAndSettle();
  }

  testWidgets('Achievements screen shows all 14 locked and unlocked items', (
    tester,
  ) async {
    await openFromHome(
      tester,
      buildApp(
        achievements: FakeAchievementRepository(
          unlocked: {'first_harmony': DateTime(2026, 8, 21)},
        ),
        statistics: const PlayerStatistics(totalPuzzlesCompleted: 3),
      ),
    );

    expect(find.byType(AchievementsScreen), findsOneWidget);
    final list = tester.widget<ListView>(
      find.byKey(const Key('achievementsList')),
    );
    // ListView.separated builds 14 cards with 13 separator slots.
    expect(list.childrenDelegate.estimatedChildCount, 27);
    expect(find.text('First Harmony'), findsOneWidget);
    expect(find.text('Unlocked'), findsOneWidget);
    expect(find.text('Locked'), findsWidgets);
    expect(find.text('3 / 10'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('achievement_thousand_moves')),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('A Thousand Moves'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Achievements copy is localized in Turkish', (tester) async {
    tester.binding.platformDispatcher.localesTestValue = const [Locale('tr')];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);
    await openFromHome(tester, buildApp());

    expect(find.text('Başarımlar'), findsOneWidget);
    expect(find.text('İlk Uyum'), findsOneWidget);
    expect(find.text('İlk bulmacanı tamamla.'), findsOneWidget);
    expect(find.text('Kilitli'), findsWidgets);
  });

  testWidgets('Statistics also navigates to Achievements', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.tap(find.byKey(const Key('homeStatisticsButton')));
    await tester.pumpAndSettle();
    expect(find.byType(StatisticsScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('statisticsAchievementsButton')));
    await tester.pumpAndSettle();
    expect(find.byType(AchievementsScreen), findsOneWidget);
  });

  testWidgets('narrow phone achievement list scrolls without overflow', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await openFromHome(tester, buildApp());

    await tester.scrollUntilVisible(
      find.byKey(const Key('achievement_thousand_moves')),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(tester.takeException(), isNull);
  });
}
