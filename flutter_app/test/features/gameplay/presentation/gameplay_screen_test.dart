import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/core/analytics/analytics_providers.dart';
import 'package:pixel_harmony/core/analytics/analytics_taxonomy.dart';
import 'package:pixel_harmony/core/analytics/app_analytics_service.dart';
import 'package:pixel_harmony/core/feedback/game_audio_service.dart';
import 'package:pixel_harmony/core/feedback/game_feedback_providers.dart';
import 'package:pixel_harmony/core/feedback/haptic_service.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/features/gameplay/presentation/gameplay_completion_controller.dart';
import 'package:pixel_harmony/features/gameplay/presentation/gameplay_screen.dart';
import 'package:pixel_harmony/features/gameplay/application/pixel_picture_onboarding_provider.dart';
import 'package:pixel_harmony/features/gameplay/domain/pixel_picture_onboarding_repository.dart';
import 'package:pixel_harmony/features/level_progress/application/level_progress_providers.dart';
import 'package:pixel_harmony/features/level_progress/domain/level_progress.dart';
import 'package:pixel_harmony/features/level_progress/domain/level_progress_repository.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/models/tile_model.dart';
import 'package:pixel_harmony/game/pixel_harmony_game.dart';
import 'package:pixel_harmony/game/state/board_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_level_progress_repository.dart';
import '../../../support/fake_app_analytics_service.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  BoardState completedState({int moveCount = 1}) {
    return BoardState(
      boardSize: 1,
      tiles: const [TileModel(id: 'tile', color: Color(0xFF5BC0EB))],
      moveCount: moveCount,
      completed: true,
    );
  }

  Widget buildApp({
    GameplayCompletionController? controller,
    LevelProgressRepository? repository,
    String initialLevelId = 'level_001',
    Locale locale = const Locale('en'),
    GameAudioService? audioService,
    HapticService? hapticService,
    AppAnalyticsService? analyticsService,
    PixelPictureOnboardingRepository? onboardingRepository,
  }) {
    final router = GoRouter(
      initialLocation: '/gameplay/$initialLevelId',
      routes: [
        GoRoute(
          path: '/levels',
          name: 'level-select',
          builder:
              (context, state) => const Scaffold(body: Text('levels-marker')),
        ),
        GoRoute(
          path: '/gameplay/:levelId',
          name: 'gameplay',
          builder:
              (context, state) => GameplayScreen(
                level: LevelCatalog.byId(state.pathParameters['levelId']!),
                completionController: controller,
              ),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        if (audioService != null)
          gameAudioServiceProvider.overrideWithValue(audioService),
        if (hapticService != null)
          hapticServiceProvider.overrideWithValue(hapticService),
        if (analyticsService != null)
          appAnalyticsServiceProvider.overrideWithValue(analyticsService),
        pixelPictureOnboardingRepositoryProvider.overrideWithValue(
          onboardingRepository ?? _FakePixelPictureOnboardingRepository(),
        ),
        levelProgressRepositoryProvider.overrideWithValue(
          repository ?? FakeLevelProgressRepository(),
        ),
      ],
      child: MaterialApp.router(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  PixelHarmonyGame currentGame(WidgetTester tester) {
    return tester
        .widget<GameWidget<PixelHarmonyGame>>(
          find.byType(GameWidget<PixelHarmonyGame>),
        )
        .game!;
  }

  Future<void> completeCurrentGame(WidgetTester tester) async {
    final game = currentGame(tester);
    game.onCompleted!(game.session.boardState.withCompleted(true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 3100));
  }

  testWidgets('completion overlay is hidden while puzzle is incomplete', (
    tester,
  ) async {
    final controller = GameplayCompletionController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(buildApp(controller: controller));
    await tester.pump();

    expect(find.byKey(const Key('levelCompleteOverlay')), findsNothing);
  });

  testWidgets('first Pixel Coloring level is immediately understandable', (
    tester,
  ) async {
    final progress = FakeLevelProgressRepository(
      completedLevelIds:
          LevelCatalog.levels.take(4).map((level) => level.id).toSet(),
    );
    await tester.pumpWidget(
      buildApp(initialLevelId: 'level_005', repository: progress),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('pixelColorPalette')), findsOneWidget);
    expect(find.byKey(const Key('pixelColorSwatch_1')), findsOneWidget);
    expect(find.byKey(const Key('pixelColorSwatch_2')), findsOneWidget);
    expect(find.byKey(const Key('pixelColorSwatch_3')), findsNothing);
    await tester.tap(find.byKey(const Key('pixelColorSwatch_2')));
    await tester.pump();
    expect(currentGame(tester).coloringSession!.state.selectedPaletteIndex, 2);
    expect(find.byKey(const Key('pixelPictureFirstTutorial')), findsNothing);
    expect(find.text('COLOR THE HEART'), findsOneWidget);
    expect(
      find.text('Choose a color, then paint the matching numbers.'),
      findsOneWidget,
    );
  });

  testWidgets('later Pixel Coloring opens directly without a transition', (
    tester,
  ) async {
    final pictureLevel = LevelCatalog.levels.firstWhere(
      (level) => level.number > 5 && level.puzzleType.name == 'pixelPicture',
    );
    final progress = FakeLevelProgressRepository(
      completedLevelIds:
          LevelCatalog.levels
              .take(pictureLevel.number - 1)
              .map((level) => level.id)
              .toSet(),
    );
    await tester.pumpWidget(
      buildApp(
        initialLevelId: pictureLevel.id,
        repository: progress,
        onboardingRepository: _FakePixelPictureOnboardingRepository(seen: true),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('pixelColorPalette')), findsOneWidget);
    expect(find.byKey(const Key('pixelPictureTransition')), findsNothing);
  });

  testWidgets('Pixel Coloring restart clears painted cells', (tester) async {
    final progress = FakeLevelProgressRepository(
      completedLevelIds:
          LevelCatalog.levels.take(4).map((level) => level.id).toSet(),
    );
    await tester.pumpWidget(
      buildApp(
        initialLevelId: 'level_005',
        repository: progress,
        onboardingRepository: _FakePixelPictureOnboardingRepository(seen: true),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final original = currentGame(tester);
    expect(original.requestHint(), isTrue);
    expect(original.coloringSession!.state.paintedCount, 1);
    expect(
      tester.widget<IconButton>(find.byKey(const Key('hintButton'))).tooltip,
      'Color one pixel',
    );
    await tester.tap(find.byKey(const Key('restartLevelButton')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(currentGame(tester), isNot(same(original)));
    expect(currentGame(tester).coloringSession!.state.paintedCount, 0);
    expect(find.byKey(const Key('pixelColorPalette')), findsOneWidget);
  });

  testWidgets('Pixel Picture remains visible before completion overlay', (
    tester,
  ) async {
    final controller = GameplayCompletionController();
    addTearDown(controller.dispose);
    final progress = FakeLevelProgressRepository(
      completedLevelIds:
          LevelCatalog.levels.take(4).map((level) => level.id).toSet(),
    );
    await tester.pumpWidget(
      buildApp(
        controller: controller,
        initialLevelId: 'level_005',
        repository: progress,
        onboardingRepository: _FakePixelPictureOnboardingRepository(seen: true),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final game = currentGame(tester);
    game.onCompleted!(game.session.boardState.withCompleted(true));
    await tester.pump(const Duration(milliseconds: 450));
    expect(find.byKey(const Key('levelCompleteOverlay')), findsNothing);
    expect(
      find.byKey(const Key('completedPixelArtPresentation')),
      findsNothing,
    );
    expect(find.byType(GameWidget<PixelHarmonyGame>), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.byKey(const Key('completedPixelArtPresentation')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('levelCompleteOverlay')), findsNothing);
    await tester.pump(const Duration(milliseconds: 2500));
    expect(find.byKey(const Key('levelCompleteOverlay')), findsOneWidget);
  });

  testWidgets('Pixel Picture names the target without hidden-picture copy', (
    tester,
  ) async {
    final progress = FakeLevelProgressRepository(
      completedLevelIds:
          LevelCatalog.levels.take(4).map((level) => level.id).toSet(),
    );
    await tester.pumpWidget(
      buildApp(
        initialLevelId: 'level_005',
        repository: progress,
        onboardingRepository: _FakePixelPictureOnboardingRepository(seen: true),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('COLOR THE HEART'), findsOneWidget);
    expect(
      find.text('Choose a color, then paint the matching numbers.'),
      findsOneWidget,
    );
    expect(find.textContaining('hidden', findRichText: true), findsNothing);
    expect(find.textContaining('dark to light'), findsNothing);
    expect(
      find.byKey(const Key('completedPixelArtPresentation')),
      findsNothing,
    );
  });

  testWidgets('Journey tutorial explains the rule without showing the answer', (
    tester,
  ) async {
    final level = LevelCatalog.byId('level_001');
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(const Key('journeyRuleCue')), findsOneWidget);
    expect(find.byKey(const Key('gradientInstruction')), findsOneWidget);
    expect(
      find.text('Arrange shades of the same color from dark to light.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.south_east_rounded), findsOneWidget);
    expect(find.byKey(const Key('gradientStartIndicator')), findsOneWidget);
    expect(find.byKey(const Key('gradientEndIndicator')), findsOneWidget);
    for (final tileId in level.solutionTileOrder) {
      expect(find.byKey(ValueKey('target_$tileId')), findsNothing);
    }
    expect(find.byType(GridView), findsNothing);
  });

  testWidgets('Journey dark-to-light rule is localized in Turkish', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(locale: const Locale('tr')));
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.text('Aynı rengin tonlarını koyudan açığa doğru sırala.'),
      findsOneWidget,
    );
  });

  testWidgets('later tutorial cue remains minimal on a narrow phone', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 780);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = FakeLevelProgressRepository(
      completedLevelIds: const {'level_001', 'level_002'},
    );

    await tester.pumpWidget(
      buildApp(repository: repository, initialLevelId: 'level_003'),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(const Key('journeyRuleCue')), findsNothing);
    expect(find.byKey(const Key('gradientInstruction')), findsNothing);
    expect(find.byIcon(Icons.south_east_rounded), findsNothing);
    expect(find.byType(GridView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('later Gradient levels do not repeat the instruction', (
    tester,
  ) async {
    final repository = FakeLevelProgressRepository(
      completedLevelIds: const {'level_001', 'level_002', 'level_003'},
    );

    await tester.pumpWidget(
      buildApp(repository: repository, initialLevelId: 'level_004'),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(const Key('journeyRuleCue')), findsNothing);
    expect(find.byKey(const Key('gradientInstruction')), findsNothing);
    expect(find.text('Arrange dark to light'), findsNothing);
  });

  testWidgets('Gradient tutorial acknowledgement persists', (tester) async {
    final onboarding = _FakePixelPictureOnboardingRepository();
    await tester.pumpWidget(buildApp(onboardingRepository: onboarding));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byKey(const Key('gradientTutorialAcknowledge')));
    await tester.pump();
    expect(onboarding.gradientSeen, isTrue);
    expect(find.byKey(const Key('journeyRuleCue')), findsNothing);
  });

  testWidgets('Journey analytics emit start and completion exactly once', (
    tester,
  ) async {
    final analytics = FakeAppAnalyticsService();
    await tester.pumpWidget(buildApp(analyticsService: analytics));
    await tester.pump(const Duration(seconds: 1));

    expect(analytics.count(AnalyticsEvents.journeyLevelStart), 1);
    final game = currentGame(tester);
    final completed = game.session.boardState.withCompleted(true);
    game.onCompleted!(completed);
    game.onCompleted!(completed);
    await tester.pump(const Duration(seconds: 1));

    expect(analytics.count(AnalyticsEvents.journeyLevelComplete), 1);
  });

  testWidgets('accepted hint and restart emit analytics', (tester) async {
    final analytics = FakeAppAnalyticsService();
    await tester.pumpWidget(buildApp(analyticsService: analytics));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byKey(const Key('hintButton')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('hintButton')));
    await tester.pump();
    expect(analytics.count(AnalyticsEvents.hintUsed), 2);

    await tester.tap(find.byKey(const Key('restartLevelButton')));
    await tester.pump();
    expect(analytics.count(AnalyticsEvents.levelRestart), 1);
  });

  testWidgets('rejected hint does not emit analytics', (tester) async {
    final analytics = FakeAppAnalyticsService();
    await tester.pumpWidget(buildApp(analyticsService: analytics));
    await tester.pump(const Duration(seconds: 1));
    currentGame(tester).session.swapTiles(0, 1);

    await tester.tap(find.byKey(const Key('hintButton')));
    await tester.pump();

    expect(analytics.count(AnalyticsEvents.hintUsed), 0);
  });

  testWidgets('analytics backend failure does not break gameplay', (
    tester,
  ) async {
    final analytics =
        DelegatingAppAnalyticsService()
          ..attach(FakeAppAnalyticsService(fail: true));
    await tester.pumpWidget(buildApp(analyticsService: analytics));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(GameWidget<PixelHarmonyGame>), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('restart creates a fresh session from the same level', (
    tester,
  ) async {
    final audio = _FakeAudioService();
    final haptics = _FakeHapticService();
    await tester.pumpWidget(
      buildApp(audioService: audio, hapticService: haptics),
    );
    await tester.pump(const Duration(seconds: 1));
    final originalGame = currentGame(tester);
    originalGame.session.swapTiles(0, 1);
    expect(originalGame.session.boardState.moveCount, 1);
    expect(originalGame.session.boardState.completed, isTrue);

    await tester.tap(find.byKey(const Key('restartLevelButton')));
    await tester.pump();

    final restartedGame = currentGame(tester);
    expect(restartedGame, isNot(same(originalGame)));
    expect(
      restartedGame.session.boardState.tiles.map((tile) => tile.id),
      LevelCatalog.byId('level_001').initialTileOrder,
    );
    expect(restartedGame.session.boardState.moveCount, 0);
    expect(restartedGame.session.boardState.completed, isFalse);
    expect(find.byKey(const Key('levelCompleteOverlay')), findsNothing);
    expect(audio.completionCalls, 0);
    expect(haptics.completionCalls, 0);
  });

  testWidgets('restart clears an active hint', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(seconds: 1));
    final originalGame = currentGame(tester);

    await tester.tap(find.byKey(const Key('hintButton')));
    await tester.pump();
    expect(originalGame.hasActiveHint, isTrue);

    await tester.tap(find.byKey(const Key('restartLevelButton')));
    await tester.pump();

    expect(currentGame(tester), isNot(same(originalGame)));
    expect(currentGame(tester).hasActiveHint, isFalse);
  });

  testWidgets('Hint action has a localized Turkish tooltip', (tester) async {
    await tester.pumpWidget(buildApp(locale: const Locale('tr')));
    await tester.pump(const Duration(seconds: 1));

    final button = tester.widget<IconButton>(
      find.byKey(const Key('hintButton')),
    );
    expect(button.tooltip, 'İpucu');
  });

  testWidgets('Hint and Restart remain accessible secondary controls', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(seconds: 1));

    final hint = find.byKey(const Key('hintButton'));
    final restart = find.byKey(const Key('restartLevelButton'));
    expect(tester.widget<IconButton>(hint).tooltip, 'Hint');
    expect(tester.widget<IconButton>(restart).tooltip, 'Restart Level');
    expect(tester.getSize(hint).width, greaterThanOrEqualTo(48));
    expect(tester.getSize(hint).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(restart).width, greaterThanOrEqualTo(48));
    expect(find.bySemanticsLabel('Hint'), findsOneWidget);
    expect(find.bySemanticsLabel('Restart Level'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('completion overlay remains usable on a narrow phone', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final controller = GameplayCompletionController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(buildApp(controller: controller));
    await tester.pump();
    controller.showCompletion(completedState(moveCount: 3));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byKey(const Key('levelCompleteOverlay')), findsOneWidget);
    expect(find.byKey(const Key('nextLevelButton')), findsOneWidget);
    expect(
      find.byKey(const Key('completionBackToLevelsButton')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('restart preserves persisted completion', (tester) async {
    final repository = FakeLevelProgressRepository(
      completedLevelIds: const {'level_001'},
    );
    await tester.pumpWidget(buildApp(repository: repository));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byKey(const Key('restartLevelButton')));
    await tester.pump();

    expect(repository.completedLevelIds, contains('level_001'));
    expect(repository.markCompletedCallCount, 0);
  });

  testWidgets('English completion overlay offers next and back actions', (
    tester,
  ) async {
    final controller = GameplayCompletionController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(buildApp(controller: controller));
    await tester.pump();

    controller.showCompletion(completedState(moveCount: 3));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Harmony Restored'), findsOneWidget);
    expect(find.text('Beautifully done.'), findsOneWidget);
    expect(find.text('Moves: 3'), findsOneWidget);
    expect(find.text('Next Level'), findsOneWidget);
    expect(find.text('Back to Levels'), findsOneWidget);
  });

  testWidgets('completion overlay shows Turkish actions', (tester) async {
    final controller = GameplayCompletionController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      buildApp(controller: controller, locale: const Locale('tr')),
    );
    await tester.pump();

    controller.showCompletion(completedState(moveCount: 2));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Uyum Tamamlandı'), findsOneWidget);
    expect(find.text('Hamle: 2'), findsOneWidget);
    expect(find.text('Sonraki Seviye'), findsOneWidget);
    expect(find.text('Seviyelere Dön'), findsOneWidget);
  });

  testWidgets('Back to Levels returns from completion overlay', (tester) async {
    final controller = GameplayCompletionController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(buildApp(controller: controller));
    await tester.pump();
    controller.showCompletion(completedState());
    await tester.pump(const Duration(milliseconds: 350));

    await tester.tap(find.byKey(const Key('completionBackToLevelsButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('levels-marker'), findsOneWidget);
    expect(find.byType(GameplayScreen), findsNothing);
  });

  testWidgets('Next Level from Level 1 opens Level 2 after persistence', (
    tester,
  ) async {
    final repository = FakeLevelProgressRepository();
    await tester.pumpWidget(buildApp(repository: repository));
    await tester.pump(const Duration(seconds: 1));
    await completeCurrentGame(tester);

    await tester.tap(find.byKey(const Key('nextLevelButton')));
    await tester.pump(const Duration(seconds: 1));

    final screen = tester.widget<GameplayScreen>(find.byType(GameplayScreen));
    expect(repository.completedLevelIds, contains('level_001'));
    expect(screen.level?.id, 'level_002');
    expect(currentGame(tester).session.boardState.moveCount, 0);
  });

  testWidgets('Next Level follows catalog order for an intermediate level', (
    tester,
  ) async {
    final repository = FakeLevelProgressRepository(
      completedLevelIds: {
        for (final level in LevelCatalog.levels.take(4)) level.id,
      },
    );
    await tester.pumpWidget(
      buildApp(repository: repository, initialLevelId: 'level_005'),
    );
    await tester.pump(const Duration(seconds: 1));
    await completeCurrentGame(tester);

    await tester.tap(find.byKey(const Key('nextLevelButton')));
    await tester.pump(const Duration(seconds: 1));

    final screen = tester.widget<GameplayScreen>(find.byType(GameplayScreen));
    expect(screen.level?.id, 'level_006');
  });

  testWidgets('completing Level 10 uses standard Journey feedback', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = FakeLevelProgressRepository(
      completedLevelIds: {
        for (final level in LevelCatalog.levels.take(9)) level.id,
      },
    );
    await tester.pumpWidget(
      buildApp(repository: repository, initialLevelId: 'level_010'),
    );
    await tester.pump(const Duration(seconds: 1));
    await completeCurrentGame(tester);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Harmony Restored'), findsOneWidget);
    expect(find.text('Chapter Complete'), findsNothing);
    expect(find.byKey(const Key('chapterPaletteAccent')), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('nextLevelButton')));
    await tester.pump(const Duration(seconds: 1));
    expect(
      tester.widget<GameplayScreen>(find.byType(GameplayScreen)).level?.id,
      'level_011',
    );
  });

  testWidgets('a non-final chapter level keeps normal completion feedback', (
    tester,
  ) async {
    final repository = FakeLevelProgressRepository(
      completedLevelIds: {
        for (final level in LevelCatalog.levels.take(8)) level.id,
      },
    );
    await tester.pumpWidget(
      buildApp(repository: repository, initialLevelId: 'level_009'),
    );
    await tester.pump(const Duration(seconds: 1));
    await completeCurrentGame(tester);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Harmony Restored'), findsOneWidget);
    expect(find.text('Chapter Complete'), findsNothing);
  });

  testWidgets('replaying Level 10 does not repeat chapter feedback', (
    tester,
  ) async {
    final repository = FakeLevelProgressRepository(
      completedLevelIds: LevelCatalog.chapters.first.levelIds.toSet(),
    );
    await tester.pumpWidget(
      buildApp(repository: repository, initialLevelId: 'level_010'),
    );
    await tester.pump(const Duration(seconds: 1));
    await completeCurrentGame(tester);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Harmony Restored'), findsOneWidget);
    expect(find.text('Chapter Complete'), findsNothing);
  });

  testWidgets('Level 10 standard completion feedback is localized in Turkish', (
    tester,
  ) async {
    final repository = FakeLevelProgressRepository(
      completedLevelIds: {
        for (final level in LevelCatalog.levels.take(9)) level.id,
      },
    );
    await tester.pumpWidget(
      buildApp(
        repository: repository,
        initialLevelId: 'level_010',
        locale: const Locale('tr'),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await completeCurrentGame(tester);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Uyum Tamamlandı'), findsOneWidget);
    expect(find.text('Bölüm Tamamlandı'), findsNothing);
  });

  testWidgets('Next Level waits for completion persistence', (tester) async {
    final repository = _DelayedProgressRepository();
    await tester.pumpWidget(buildApp(repository: repository));
    await tester.pump(const Duration(seconds: 1));
    await completeCurrentGame(tester);

    await tester.tap(find.byKey(const Key('nextLevelButton')));
    await tester.pump();
    expect(
      tester.widget<GameplayScreen>(find.byType(GameplayScreen)).level?.id,
      'level_001',
    );

    repository.completeWrite();
    await tester.pump(const Duration(seconds: 1));
    expect(
      tester.widget<GameplayScreen>(find.byType(GameplayScreen)).level?.id,
      'level_002',
    );
  });

  testWidgets('Level 36 is an intermediate level with Next Level', (
    tester,
  ) async {
    final repository = FakeLevelProgressRepository(
      completedLevelIds: {
        for (final level in LevelCatalog.levels.take(35)) level.id,
      },
    );
    await tester.pumpWidget(
      buildApp(repository: repository, initialLevelId: 'level_036'),
    );
    await tester.pump(const Duration(seconds: 1));
    await completeCurrentGame(tester);

    expect(find.byKey(const Key('nextLevelButton')), findsOneWidget);
    expect(find.text('All Levels Complete'), findsNothing);
  });

  testWidgets('Level 100 continues to procedurally generated Level 101', (
    tester,
  ) async {
    final repository = FakeLevelProgressRepository(
      completedLevelIds: {
        for (final level in LevelCatalog.levels.take(99)) level.id,
      },
    );
    await tester.pumpWidget(
      buildApp(repository: repository, initialLevelId: 'level_100'),
    );
    await tester.pump(const Duration(seconds: 1));
    await completeCurrentGame(tester);

    expect(find.byKey(const Key('nextLevelButton')), findsOneWidget);
    expect(find.text('All Levels Complete'), findsNothing);
  });

  test('completion is emitted only once per controller', () {
    final controller = GameplayCompletionController();
    addTearDown(controller.dispose);
    var notificationCount = 0;
    controller.addListener(() => notificationCount++);

    controller.showCompletion(completedState(moveCount: 1));
    controller.showCompletion(completedState(moveCount: 2));

    expect(notificationCount, 1);
    expect(controller.completion?.moveCount, 1);
  });
}

class _FakePixelPictureOnboardingRepository
    implements PixelPictureOnboardingRepository {
  _FakePixelPictureOnboardingRepository({this.seen = false});

  bool seen;
  bool gradientSeen = false;

  @override
  Future<bool> hasSeenTutorial() async => seen;

  @override
  Future<void> markTutorialSeen() async => seen = true;

  @override
  Future<bool> hasSeenGradientTutorial() async => gradientSeen;

  @override
  Future<void> markGradientTutorialSeen() async => gradientSeen = true;
}

class _DelayedProgressRepository implements LevelProgressRepository {
  final completedLevelIds = <String>{};
  final _writeCompleter = Completer<void>();

  void completeWrite() => _writeCompleter.complete();

  @override
  Future<void> markCompleted(String levelId) async {
    await _writeCompleter.future;
    completedLevelIds.add(levelId);
  }

  @override
  Future<List<LevelProgress>> readAll() async => [
    for (final levelId in completedLevelIds)
      LevelProgress(levelId: levelId, completed: true),
  ];

  @override
  Future<LevelProgress?> read(String levelId) async =>
      completedLevelIds.contains(levelId)
          ? LevelProgress(levelId: levelId, completed: true)
          : null;

  @override
  Future<void> clearAll() async => completedLevelIds.clear();
}

class _FakeAudioService implements GameAudioService {
  int completionCalls = 0;

  @override
  Future<void> playAcceptedSwap() async {}

  @override
  Future<void> playLevelComplete() async => completionCalls++;

  @override
  Future<void> playTilePickup() async {}
}

class _FakeHapticService implements HapticService {
  int completionCalls = 0;

  @override
  Future<void> acceptedSwap() async {}

  @override
  Future<void> levelComplete() async => completionCalls++;

  @override
  Future<void> tilePickup() async {}
}
