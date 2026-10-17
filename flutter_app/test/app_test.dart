import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/app/app.dart';
import 'package:pixel_harmony/features/gameplay/presentation/gameplay_screen.dart';
import 'package:pixel_harmony/features/daily/application/daily_progress_providers.dart';
import 'package:pixel_harmony/features/achievements/application/achievement_providers.dart';
import 'package:pixel_harmony/features/achievements/domain/achievement_repository.dart';
import 'package:pixel_harmony/features/daily/domain/daily_clock.dart';
import 'package:pixel_harmony/features/daily/domain/daily_progress_repository.dart';
import 'package:pixel_harmony/features/daily/presentation/daily_gameplay_screen.dart';
import 'package:pixel_harmony/features/home/presentation/home_screen.dart';
import 'package:pixel_harmony/features/level_select/presentation/level_select_screen.dart';
import 'package:pixel_harmony/features/level_progress/application/level_progress_providers.dart';
import 'package:pixel_harmony/features/level_progress/domain/level_progress_repository.dart';
import 'package:pixel_harmony/features/settings/presentation/settings_screen.dart';
import 'package:pixel_harmony/features/statistics/application/player_statistics_providers.dart';
import 'package:pixel_harmony/features/statistics/domain/player_statistics_repository.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/pixel_harmony_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_level_progress_repository.dart';
import 'support/fake_player_statistics_repository.dart';
import 'support/fake_daily_progress_repository.dart';
import 'support/fake_achievement_repository.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget buildApp({
    LevelProgressRepository? repository,
    DailyProgressRepository? dailyRepository,
    PlayerStatisticsRepository? statisticsRepository,
    AchievementRepository? achievementRepository,
  }) {
    return ProviderScope(
      overrides: [
        if (repository != null)
          levelProgressRepositoryProvider.overrideWithValue(repository),
        if (dailyRepository != null)
          dailyProgressRepositoryProvider.overrideWithValue(dailyRepository),
        if (statisticsRepository != null)
          playerStatisticsRepositoryProvider.overrideWithValue(
            statisticsRepository,
          ),
        achievementRepositoryProvider.overrideWithValue(
          achievementRepository ?? FakeAchievementRepository(),
        ),
        dailyClockProvider.overrideWithValue(
          _FixedDailyClock(DateTime(2026, 8, 19, 12)),
        ),
      ],
      child: const PixelHarmonyApp(),
    );
  }

  Future<void> openLevelSelect(
    WidgetTester tester, {
    LevelProgressRepository? repository,
  }) async {
    await tester.pumpWidget(buildApp(repository: repository));
    await tester.pump();
    await tester.tap(find.byKey(const Key('homePlayButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
  }

  Future<void> scrollToLevel(WidgetTester tester, String levelId) async {
    final cardFinder = find.byKey(Key('levelCard_$levelId'));
    final number = LevelCatalog.numberFromId(levelId)!;
    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byKey(const Key('levelSelectGrid')),
        matching: find.byType(Scrollable),
      ),
    );
    scrollable.position.jumpTo(
      ((number - 1) * 124.0).clamp(0, scrollable.position.maxScrollExtent),
    );
    await tester.pump();
    expect(cardFinder, findsOneWidget);
    await tester.ensureVisible(cardFinder);
    await tester.pump();
  }

  testWidgets('App hides the debug mode banner', (tester) async {
    await tester.pumpWidget(
      buildApp(repository: FakeLevelProgressRepository()),
    );
    await tester.pump();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.debugShowCheckedModeBanner, isFalse);
  });

  testWidgets('Home shows primary Journey, Daily, and Free Play experiences', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(repository: FakeLevelProgressRepository()),
    );
    await tester.pump();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Daily Puzzle'), findsOneWidget);
    expect(find.text('Free Play'), findsOneWidget);
    expect(find.byKey(const Key('homeJourneyContinueButton')), findsOneWidget);
    expect(find.byKey(const Key('homeBackground')), findsOneWidget);
    expect(find.byKey(const Key('homeLogo')), findsOneWidget);
    final logo = tester.widget<Image>(find.byKey(const Key('homeLogo')));
    expect(
      (logo.image as AssetImage).assetName,
      'assets/branding/app_icon/'
      'pixel_harmony_home.png',
    );
    expect(find.byKey(const Key('homeUtilityDock')), findsOneWidget);
    expect(find.byType(Card), findsNothing);
    expect(find.text('Play'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_rounded), findsNothing);
    expect(find.text('Pixel Art — 100 Template Review'), findsNothing);
    expect(find.byKey(const Key('pixelArtContactSheet')), findsNothing);
    expect(find.byKey(const Key('levelButton_level_001')), findsNothing);
    expect(find.text('Level 1'), findsNothing);
    expect(find.text('Level 2'), findsNothing);
    expect(find.text('Level 3'), findsNothing);
  });

  testWidgets('Daily opens today deterministic puzzle and returns Home', (
    tester,
  ) async {
    final dailyRepository = FakeDailyProgressRepository();
    await tester.pumpWidget(
      buildApp(
        repository: FakeLevelProgressRepository(),
        dailyRepository: dailyRepository,
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('homeDailyButton')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(DailyGameplayScreen), findsOneWidget);
    expect(find.text('Daily Puzzle'), findsOneWidget);
    final gameplay = tester.widget<GameplayScreen>(find.byType(GameplayScreen));
    expect(gameplay.level?.id, 'daily_v1_2026-08-19');
    final game =
        tester
            .widget<GameWidget<PixelHarmonyGame>>(
              find.byType(GameWidget<PixelHarmonyGame>),
            )
            .game!;
    game.onCompleted!(game.session.boardState.withCompleted(true));
    await tester.pump();
    expect(find.text('Daily Complete'), findsOneWidget);
    expect(dailyRepository.completeCallCount, 1);

    await tester.tap(find.byKey(const Key('dailyBackHomeButton')));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byKey(const Key('homeDailyCompleted')), findsOneWidget);
  });

  testWidgets(
    'Home utility actions are anchored in an equal-width bottom bar',
    (tester) async {
      await tester.pumpWidget(
        buildApp(repository: FakeLevelProgressRepository()),
      );
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.bottomNavigationBar, isNotNull);
      expect(scaffold.extendBody, isTrue);

      final dock = find.byKey(const Key('homeUtilityDock'));
      final background = find.byKey(const Key('homeBackground'));
      expect(find.descendant(of: background, matching: dock), findsNothing);
      expect(
        tester.getBottomLeft(dock).dy,
        tester.view.physicalSize.height / tester.view.devicePixelRatio,
      );

      final actionSizes = [
        tester.getSize(find.byKey(const Key('homeAchievementsButton'))),
        tester.getSize(find.byKey(const Key('homeStatisticsButton'))),
        tester.getSize(find.byKey(const Key('homeSettingsButton'))),
      ];
      expect(actionSizes.toSet(), hasLength(1));
      expect(actionSizes.first.height, 68);
    },
  );

  testWidgets('Home bottom bar handles narrow screens and enlarged text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      buildApp(repository: FakeLevelProgressRepository()),
    );
    await tester.pump();

    expect(find.byKey(const Key('homeUtilityDock')), findsOneWidget);
    expect(find.text('Achievements'), findsOneWidget);
    expect(find.text('Statistics'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home opens Settings', (tester) async {
    await tester.pumpWidget(
      buildApp(repository: FakeLevelProgressRepository()),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('homeSettingsButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Home Continue opens Journey map without starting gameplay', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        repository: FakeLevelProgressRepository(
          completedLevelIds: const {'level_001', 'level_002'},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Level 3'), findsNothing);
    await tester.tap(find.byKey(const Key('homeJourneyContinueButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(LevelSelectScreen), findsOneWidget);
    expect(find.byType(GameplayScreen), findsNothing);
    expect(find.byKey(const Key('currentLevel_level_003')), findsOneWidget);
  });

  testWidgets('Free Play opens setup with puzzle types and difficulties', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(repository: FakeLevelProgressRepository()),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('homeEndlessButton')));
    await tester.pumpAndSettle();

    expect(find.text('Free Play'), findsOneWidget);
    expect(find.text('Gradient'), findsOneWidget);
    expect(find.text('Pixel Coloring'), findsOneWidget);
    expect(find.text('Mixed'), findsOneWidget);
    for (final label in const ['Relaxed', 'Normal', 'Hard', 'Expert']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('Play opens a continuous Journey map without range headings', (
    tester,
  ) async {
    await openLevelSelect(tester, repository: FakeLevelProgressRepository());

    expect(find.byType(LevelSelectScreen), findsOneWidget);
    expect(find.text('Levels'), findsOneWidget);
    expect(find.textContaining('1–10'), findsNothing);
    expect(find.textContaining('Levels 1'), findsNothing);
    expect(
      find.byKey(const Key('chapterHeader_journey_segment_1')),
      findsNothing,
    );
    expect(find.byKey(const Key('levelCard_level_001')), findsOneWidget);
    expect(find.byKey(const Key('journeyPathSegment_1')), findsOneWidget);
    expect(find.byKey(const Key('journeyPathSegment_2')), findsOneWidget);
    expect(find.byKey(const Key('journeySelectBackground')), findsOneWidget);
    expect(find.byKey(const Key('currentLevel_level_001')), findsOneWidget);
    expect(find.byKey(const Key('gradientNode_level_001')), findsOneWidget);
    expect(find.byKey(const Key('levelSelectBackButton')), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNothing);
    expect(find.byIcon(Icons.star_rounded), findsNothing);
    await scrollToLevel(tester, 'level_100');
    expect(find.byKey(const Key('levelCard_level_100')), findsOneWidget);
    expect(find.byKey(const Key('milestoneLevel_level_100')), findsOneWidget);
    expect(find.byKey(const Key('journeySelectBackground')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final (label, levelId, completedLevelIds) in const [
    ('Level 1', 'level_001', <String>{}),
    ('Level 2', 'level_002', {'level_001'}),
    ('Level 3', 'level_003', {'level_001', 'level_002'}),
  ]) {
    testWidgets('$label card opens gameplay for $levelId', (tester) async {
      await openLevelSelect(
        tester,
        repository: FakeLevelProgressRepository(
          completedLevelIds: completedLevelIds,
        ),
      );

      await scrollToLevel(tester, levelId);
      await tester.tap(
        find.descendant(
          of: find.byKey(Key('levelCard_$levelId')),
          matching: find.byType(InkWell),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final screen = tester.widget<GameplayScreen>(find.byType(GameplayScreen));
      expect(screen.level?.id, levelId);
      expect(find.byKey(const Key('gameplayLevelTitle')), findsOneWidget);
      expect(find.text(label), findsOneWidget);
      expect(find.byType(GameWidget<PixelHarmonyGame>), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Level 12 opens when the preceding levels are completed', (
    tester,
  ) async {
    final completedLevelIds = {
      for (final level in LevelCatalog.levels.take(11)) level.id,
    };
    await openLevelSelect(
      tester,
      repository: FakeLevelProgressRepository(
        completedLevelIds: completedLevelIds,
      ),
    );
    await scrollToLevel(tester, 'level_012');

    await tester.tap(find.byKey(const Key('levelCard_level_012')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final screen = tester.widget<GameplayScreen>(find.byType(GameplayScreen));
    expect(screen.level?.id, 'level_012');
    expect(find.text('Level 12'), findsOneWidget);
    expect(find.byType(GameWidget<PixelHarmonyGame>), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('invalid level ID shows error and returns to Level Select', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(repository: FakeLevelProgressRepository()),
    );
    await tester.pump();
    final context = tester.element(find.byType(HomeScreen));

    GoRouter.of(context).go('/gameplay/unknown');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(GameplayScreen), findsOneWidget);
    expect(find.text('Level not found'), findsOneWidget);
    expect(find.byType(GameWidget<PixelHarmonyGame>), findsNothing);

    await tester.tap(find.byKey(const Key('backToLevelsButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(LevelSelectScreen), findsOneWidget);
    expect(find.text('Levels'), findsOneWidget);
  });

  testWidgets('primary navigation retains accessible tap semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      buildApp(repository: FakeLevelProgressRepository()),
    );
    await tester.pump();

    final journeySemantics = tester.widget<Semantics>(
      find.byKey(const Key('homeJourneySemantics')),
    );
    expect(journeySemantics.properties.label, 'Play');
    expect(find.bySemanticsLabel('Settings'), findsOneWidget);

    await tester.tap(find.byKey(const Key('homePlayButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    final lockedCardSemantics = tester.widget<Semantics>(
      find.byKey(const Key('levelCard_level_002')),
    );
    expect(lockedCardSemantics.properties.label, contains('Locked'));
    expect(lockedCardSemantics.properties.enabled, isFalse);
    expect(lockedCardSemantics.properties.button, isTrue);
    semantics.dispose();
  });

  testWidgets('Home and Level Select avoid overflow at narrow and wide sizes', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    for (final size in const [
      Size(320, 640),
      Size(360, 800),
      Size(412, 915),
      Size(600, 960),
      Size(800, 1280),
      Size(1200, 800),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await openLevelSelect(tester, repository: FakeLevelProgressRepository());
      expect(find.byType(LevelSelectScreen), findsOneWidget);
      await scrollToLevel(tester, 'level_100');
      expect(find.byKey(const Key('levelCard_level_100')), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('gameplay renders every supported board size', (tester) async {
    final completedLevelIds = {
      for (final level in LevelCatalog.levels) level.id,
    };
    final repository = FakeLevelProgressRepository(
      completedLevelIds: completedLevelIds,
    );

    for (final (levelId, rows, columns) in const [
      ('level_001', 2, 2),
      ('level_002', 2, 2),
      ('level_003', 2, 2),
      ('level_004', 2, 2),
      ('level_005', 5, 5),
      ('level_013', 3, 3),
      ('level_071', 6, 6),
    ]) {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.pumpWidget(buildApp(repository: repository));
      await tester.pump();
      final context = tester.element(find.byType(HomeScreen));

      GoRouter.of(context).go('/gameplay/$levelId');
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final game =
          tester
              .widget<GameWidget<PixelHarmonyGame>>(
                find.byType(GameWidget<PixelHarmonyGame>),
              )
              .game!;
      expect(game.session.boardState.rowCount, rows);
      expect(game.session.boardState.columnCount, columns);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Level Select marks only completed levels', (tester) async {
    await openLevelSelect(
      tester,
      repository: FakeLevelProgressRepository(
        completedLevelIds: const {'level_001'},
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('levelCompleted_level_001')), findsOneWidget);
    expect(find.byKey(const Key('levelCompleted_level_002')), findsNothing);
    expect(find.byKey(const Key('levelCompleted_level_003')), findsNothing);
    expect(find.byKey(const Key('levelLocked_level_002')), findsNothing);
    expect(find.byKey(const Key('levelLocked_level_003')), findsOneWidget);
  });

  testWidgets(
    'Level Select labels Pixel Pictures without revealing templates',
    (tester) async {
      await openLevelSelect(
        tester,
        repository: FakeLevelProgressRepository(
          completedLevelIds:
              LevelCatalog.levels.take(4).map((level) => level.id).toSet(),
        ),
      );
      await scrollToLevel(tester, 'level_005');

      expect(
        find.byKey(const Key('pixelPictureBadge_level_005')),
        findsOneWidget,
      );
      expect(find.text('heart'), findsNothing);
      expect(
        find.byKey(const Key('pixelPictureBadge_level_004')),
        findsNothing,
      );
    },
  );

  testWidgets('Level Select focuses the next stop after completed progress', (
    tester,
  ) async {
    await openLevelSelect(
      tester,
      repository: FakeLevelProgressRepository(
        completedLevelIds: LevelCatalog.chapters.first.levelIds.toSet(),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('currentLevel_level_011')), findsOneWidget);
    expect(find.byKey(const Key('levelCompleted_level_010')), findsOneWidget);
    expect(find.byKey(const Key('levelLocked_level_012')), findsOneWidget);
  });

  testWidgets('Journey map supports lazy high-level focus', (tester) async {
    for (final currentLevel in const [101, 500, 1000]) {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      final completed = {
        for (var number = 1; number < currentLevel; number++)
          'level_${number.toString().padLeft(3, '0')}',
      };
      await openLevelSelect(
        tester,
        repository: FakeLevelProgressRepository(completedLevelIds: completed),
      );
      await tester.pump();

      final id = 'level_${currentLevel.toString().padLeft(3, '0')}';
      expect(find.byKey(Key('currentLevel_$id')), findsOneWidget);
      expect(find.byKey(Key('levelCard_$id')), findsOneWidget);
      expect(find.byType(Semantics).evaluate().length, lessThan(80));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('tapping a locked level does not open Gameplay', (tester) async {
    await openLevelSelect(tester, repository: FakeLevelProgressRepository());

    await scrollToLevel(tester, 'level_007');
    expect(find.byKey(const Key('levelLocked_level_007')), findsOneWidget);
    await tester.tap(find.byKey(const Key('levelCard_level_007')));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(LevelSelectScreen), findsOneWidget);
    expect(find.byType(GameplayScreen), findsNothing);
  });

  testWidgets('direct navigation to a locked level is rejected safely', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(repository: FakeLevelProgressRepository()),
    );
    await tester.pump();
    final context = tester.element(find.byType(HomeScreen));

    GoRouter.of(context).go('/gameplay/level_003');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(GameplayScreen), findsOneWidget);
    expect(find.text('Locked'), findsOneWidget);
    expect(
      find.text('Complete the previous level to unlock this one.'),
      findsOneWidget,
    );
    expect(find.byType(GameWidget<PixelHarmonyGame>), findsNothing);

    await tester.tap(find.byKey(const Key('lockedBackToLevelsButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(LevelSelectScreen), findsOneWidget);
  });

  testWidgets('progress failure keeps Level Select usable', (tester) async {
    await openLevelSelect(
      tester,
      repository: FakeLevelProgressRepository(failReads: true),
    );
    await tester.pump();

    expect(find.byKey(const Key('levelProgressError')), findsOneWidget);
    expect(find.byKey(const Key('levelCard_level_001')), findsOneWidget);
    expect(find.byKey(const Key('levelCard_level_002')), findsOneWidget);
    expect(find.byKey(const Key('levelCard_level_003')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('game completion callback stores level completion', (
    tester,
  ) async {
    final repository = FakeLevelProgressRepository();
    final dailyRepository = FakeDailyProgressRepository();
    final statisticsRepository = FakePlayerStatisticsRepository();
    final achievementRepository = FakeAchievementRepository();
    await tester.pumpWidget(
      buildApp(
        repository: repository,
        dailyRepository: dailyRepository,
        statisticsRepository: statisticsRepository,
        achievementRepository: achievementRepository,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const Key('homePlayButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.byKey(const Key('levelCard_level_001')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final gameWidget = tester.widget<GameWidget<PixelHarmonyGame>>(
      find.byType(GameWidget<PixelHarmonyGame>),
    );
    final game = gameWidget.game!;
    game.onCompleted!(game.session.boardState.withCompleted(true));
    game.onCompleted!(game.session.boardState.withCompleted(true));
    await tester.pump(const Duration(milliseconds: 100));

    expect(repository.completedLevelIds, contains('level_001'));
    expect(dailyRepository.completeCallCount, 0);
    expect(statisticsRepository.statistics.journeyPuzzlesCompleted, 1);
    expect(statisticsRepository.statistics.totalPuzzlesCompleted, 1);
    expect(achievementRepository.unlocked, contains('first_harmony'));
    expect(find.byKey(const Key('achievementUnlockFeedback')), findsOneWidget);
    expect(find.byKey(const Key('levelCompleteOverlay')), findsOneWidget);

    await tester.tap(find.byKey(const Key('completionBackToLevelsButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(LevelSelectScreen), findsOneWidget);
    expect(find.byKey(const Key('levelCompleted_level_001')), findsOneWidget);
    expect(find.byKey(const Key('levelLocked_level_002')), findsNothing);
  });

  testWidgets('statistics failure does not block Journey progression', (
    tester,
  ) async {
    final journey = FakeLevelProgressRepository();
    final achievements = FakeAchievementRepository();
    await tester.pumpWidget(
      buildApp(
        repository: journey,
        statisticsRepository: FakePlayerStatisticsRepository(failWrites: true),
        achievementRepository: achievements,
      ),
    );
    await tester.pump();
    final context = tester.element(find.byType(HomeScreen));
    GoRouter.of(context).go('/gameplay/level_001');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final game =
        tester
            .widget<GameWidget<PixelHarmonyGame>>(
              find.byType(GameWidget<PixelHarmonyGame>),
            )
            .game!;

    game.onCompleted!(game.session.boardState.withCompleted(true));
    await tester.pump();

    expect(journey.completedLevelIds, contains('level_001'));
    expect(achievements.unlocked, isEmpty);
    expect(find.byKey(const Key('levelCompleteOverlay')), findsOneWidget);
  });

  testWidgets('achievement failure does not block Journey progression', (
    tester,
  ) async {
    final journey = FakeLevelProgressRepository();
    await tester.pumpWidget(
      buildApp(
        repository: journey,
        statisticsRepository: FakePlayerStatisticsRepository(),
        achievementRepository: FakeAchievementRepository(failWrites: true),
      ),
    );
    await tester.pump();
    final context = tester.element(find.byType(HomeScreen));
    GoRouter.of(context).go('/gameplay/level_001');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final game =
        tester
            .widget<GameWidget<PixelHarmonyGame>>(
              find.byType(GameWidget<PixelHarmonyGame>),
            )
            .game!;

    game.onCompleted!(game.session.boardState.withCompleted(true));
    await tester.pump(const Duration(milliseconds: 100));

    expect(journey.completedLevelIds, contains('level_001'));
    expect(find.byKey(const Key('levelCompleteOverlay')), findsOneWidget);
  });
}

class _FixedDailyClock implements DailyClock {
  const _FixedDailyClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}
