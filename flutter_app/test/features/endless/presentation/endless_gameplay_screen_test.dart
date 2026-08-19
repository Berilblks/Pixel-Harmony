import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/app/app.dart';
import 'package:pixel_harmony/features/daily/application/daily_progress_providers.dart';
import 'package:pixel_harmony/features/endless/application/endless_progress_providers.dart';
import 'package:pixel_harmony/features/endless/presentation/endless_gameplay_screen.dart';
import 'package:pixel_harmony/features/home/presentation/home_screen.dart';
import 'package:pixel_harmony/features/level_progress/application/level_progress_providers.dart';
import 'package:pixel_harmony/features/statistics/application/player_statistics_providers.dart';
import 'package:pixel_harmony/game/pixel_harmony_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_endless_progress_repository.dart';
import '../../../support/fake_daily_progress_repository.dart';
import '../../../support/fake_level_progress_repository.dart';
import '../../../support/fake_player_statistics_repository.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget buildApp({
    required FakeEndlessProgressRepository endlessRepository,
    FakeLevelProgressRepository? journeyRepository,
    FakeDailyProgressRepository? dailyRepository,
    FakePlayerStatisticsRepository? statisticsRepository,
  }) {
    return ProviderScope(
      overrides: [
        endlessProgressRepositoryProvider.overrideWithValue(endlessRepository),
        levelProgressRepositoryProvider.overrideWithValue(
          journeyRepository ?? FakeLevelProgressRepository(),
        ),
        dailyProgressRepositoryProvider.overrideWithValue(
          dailyRepository ?? FakeDailyProgressRepository(),
        ),
        playerStatisticsRepositoryProvider.overrideWithValue(
          statisticsRepository ?? FakePlayerStatisticsRepository(),
        ),
      ],
      child: const PixelHarmonyApp(),
    );
  }

  Future<void> openEndless(
    WidgetTester tester,
    FakeEndlessProgressRepository repository, {
    FakeLevelProgressRepository? journeyRepository,
    FakeDailyProgressRepository? dailyRepository,
    FakePlayerStatisticsRepository? statisticsRepository,
  }) async {
    await tester.pumpWidget(
      buildApp(
        endlessRepository: repository,
        journeyRepository: journeyRepository,
        dailyRepository: dailyRepository,
        statisticsRepository: statisticsRepository,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const Key('homeEndlessButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  PixelHarmonyGame currentGame(WidgetTester tester) {
    return tester
        .widget<GameWidget<PixelHarmonyGame>>(
          find.byType(GameWidget<PixelHarmonyGame>),
        )
        .game!;
  }

  Future<void> complete(WidgetTester tester) async {
    final game = currentGame(tester);
    game.onCompleted!(game.session.boardState.withCompleted(true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
  }

  testWidgets('Home exposes Journey and Endless mode choices', (tester) async {
    await tester.pumpWidget(
      buildApp(endlessRepository: FakeEndlessProgressRepository()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Journey'), findsOneWidget);
    expect(find.text('Endless'), findsOneWidget);
  });

  testWidgets('Endless opens and reuses GameSession, hint, and restart', (
    tester,
  ) async {
    final repository = FakeEndlessProgressRepository();
    final statistics = FakePlayerStatisticsRepository();
    await openEndless(tester, repository, statisticsRepository: statistics);

    expect(find.byType(EndlessGameplayScreen), findsOneWidget);
    expect(find.text('Puzzle 1'), findsOneWidget);
    final original = currentGame(tester);
    expect(original.session.level.id, contains('endless_v1_'));

    await tester.tap(find.byKey(const Key('hintButton')));
    await tester.pump();
    expect(original.hasActiveHint, isTrue);

    await tester.tap(find.byKey(const Key('restartLevelButton')));
    await tester.pump();
    expect(currentGame(tester), isNot(same(original)));
    expect(repository.advanceCallCount, 0);
    expect(repository.progress.completedPuzzleCount, 0);
    expect(statistics.recordCallCount, 0);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(statistics.recordCallCount, 0);
  });

  testWidgets('completion advances once and Next Puzzle displays puzzle 2', (
    tester,
  ) async {
    final repository = FakeEndlessProgressRepository();
    final statistics = FakePlayerStatisticsRepository();
    await openEndless(tester, repository, statisticsRepository: statistics);
    final firstSeed = repository.progress.currentSeed;

    await complete(tester);
    currentGame(tester).onCompleted!(
      currentGame(tester).session.boardState.withCompleted(true),
    );
    await tester.pump();

    expect(repository.advanceCallCount, 1);
    expect(statistics.statistics.endlessPuzzlesCompleted, 1);
    expect(statistics.statistics.totalPuzzlesCompleted, 1);
    expect(repository.progress.completedPuzzleCount, 1);
    expect(repository.progress.currentSeed, isNot(firstSeed));
    expect(find.byKey(const Key('nextPuzzleButton')), findsOneWidget);
    expect(find.text('Puzzle 1'), findsNWidgets(2));

    await tester.tap(find.byKey(const Key('nextPuzzleButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Puzzle 2'), findsOneWidget);
    expect(currentGame(tester).session.boardState.moveCount, 0);
    expect(repository.advanceCallCount, 1);
  });

  testWidgets('statistics failure does not block Endless advancement', (
    tester,
  ) async {
    final repository = FakeEndlessProgressRepository();
    await openEndless(
      tester,
      repository,
      statisticsRepository: FakePlayerStatisticsRepository(failWrites: true),
    );

    await complete(tester);

    expect(repository.progress.completedPuzzleCount, 1);
    expect(find.byKey(const Key('levelCompleteOverlay')), findsOneWidget);
  });

  testWidgets('Endless completion leaves Journey progress untouched', (
    tester,
  ) async {
    final endlessRepository = FakeEndlessProgressRepository();
    final journeyRepository = FakeLevelProgressRepository();
    final dailyRepository = FakeDailyProgressRepository();
    await openEndless(
      tester,
      endlessRepository,
      journeyRepository: journeyRepository,
      dailyRepository: dailyRepository,
    );
    await complete(tester);
    expect(journeyRepository.completedLevelIds, isEmpty);
    expect(journeyRepository.markCompletedCallCount, 0);
    expect(dailyRepository.completeCallCount, 0);
  });

  testWidgets('Back Home returns from Endless completion', (tester) async {
    final repository = FakeEndlessProgressRepository();
    await openEndless(tester, repository);
    await complete(tester);
    await tester.tap(find.byKey(const Key('endlessBackHomeButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Continue Endless'), findsOneWidget);
  });

  testWidgets('Turkish Endless puzzle label is localized', (tester) async {
    tester.binding.platformDispatcher.localesTestValue = const [Locale('tr')];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);
    final repository = FakeEndlessProgressRepository();
    await openEndless(tester, repository);
    expect(find.text('Bulmaca 1'), findsOneWidget);
  });
}
