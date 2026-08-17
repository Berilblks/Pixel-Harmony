import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/core/feedback/game_audio_service.dart';
import 'package:pixel_harmony/core/feedback/game_feedback_providers.dart';
import 'package:pixel_harmony/core/feedback/haptic_service.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/features/gameplay/presentation/gameplay_completion_controller.dart';
import 'package:pixel_harmony/features/gameplay/presentation/gameplay_screen.dart';
import 'package:pixel_harmony/features/level_progress/application/level_progress_providers.dart';
import 'package:pixel_harmony/features/level_progress/domain/level_progress.dart';
import 'package:pixel_harmony/features/level_progress/domain/level_progress_repository.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/models/tile_model.dart';
import 'package:pixel_harmony/game/pixel_harmony_game.dart';
import 'package:pixel_harmony/game/state/board_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_level_progress_repository.dart';

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
    await tester.pump(const Duration(milliseconds: 350));
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

  testWidgets('Level 12 shows final copy and returns to Levels', (
    tester,
  ) async {
    final repository = FakeLevelProgressRepository(
      completedLevelIds: {
        for (final level in LevelCatalog.levels.take(11)) level.id,
      },
    );
    await tester.pumpWidget(
      buildApp(repository: repository, initialLevelId: 'level_012'),
    );
    await tester.pump(const Duration(seconds: 1));
    await completeCurrentGame(tester);

    expect(find.byKey(const Key('nextLevelButton')), findsNothing);
    expect(find.text('All Levels Complete'), findsOneWidget);
    expect(find.text('You restored every harmony.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('finalBackToLevelsButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('levels-marker'), findsOneWidget);
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
