import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/app/app.dart';
import 'package:pixel_harmony/features/statistics/application/player_statistics_providers.dart';
import 'package:pixel_harmony/features/statistics/domain/player_statistics.dart';
import 'package:pixel_harmony/features/statistics/presentation/statistics_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_player_statistics_repository.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget buildApp(FakePlayerStatisticsRepository repository) {
    return ProviderScope(
      overrides: [
        playerStatisticsRepositoryProvider.overrideWithValue(repository),
      ],
      child: const PixelHarmonyApp(),
    );
  }

  testWidgets('Home opens Statistics and persisted values render', (
    tester,
  ) async {
    final repository = FakePlayerStatisticsRepository(
      statistics: const PlayerStatistics(
        totalPuzzlesCompleted: 6,
        journeyPuzzlesCompleted: 3,
        endlessPuzzlesCompleted: 2,
        dailyPuzzlesCompleted: 1,
        totalMoves: 25,
        currentDailyStreak: 2,
        bestDailyStreak: 4,
      ),
    );
    await tester.pumpWidget(buildApp(repository));
    await tester.pump();
    await tester.tap(find.byKey(const Key('homeStatisticsButton')));
    await tester.pumpAndSettle();

    expect(find.byType(StatisticsScreen), findsOneWidget);
    for (final label in const [
      'Statistics',
      'Overview',
      'Total Puzzles',
      'Total Moves',
      'Modes',
      'Journey',
      'Endless',
      'Daily Puzzle',
      'Current Streak',
      'Best Streak',
    ]) {
      expect(find.text(label), findsWidgets);
    }
    expect(find.text('25'), findsOneWidget);
  });

  testWidgets('Statistics is localized in Turkish', (tester) async {
    tester.binding.platformDispatcher.localesTestValue = const [Locale('tr')];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(buildApp(FakePlayerStatisticsRepository()));
    await tester.pump();
    await tester.tap(find.byKey(const Key('homeStatisticsButton')));
    await tester.pumpAndSettle();

    expect(find.text('İstatistikler'), findsOneWidget);
    expect(find.text('Toplam Bulmaca'), findsOneWidget);
    expect(find.text('Mevcut Seri'), findsOneWidget);
    expect(find.text('En İyi Seri'), findsOneWidget);
  });

  testWidgets('Statistics has no overflow on a narrow phone', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(buildApp(FakePlayerStatisticsRepository()));
    await tester.pump();
    await tester.tap(find.byKey(const Key('homeStatisticsButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('statisticsScrollView')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
