import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/app/app.dart';
import 'package:pixel_harmony/features/gameplay/presentation/gameplay_screen.dart';
import 'package:pixel_harmony/features/home/presentation/home_screen.dart';
import 'package:pixel_harmony/features/level_select/presentation/level_select_screen.dart';
import 'package:pixel_harmony/features/level_progress/application/level_progress_providers.dart';
import 'package:pixel_harmony/features/level_progress/domain/level_progress_repository.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/pixel_harmony_game.dart';

import 'support/fake_level_progress_repository.dart';

void main() {
  Widget buildApp({LevelProgressRepository? repository}) {
    return ProviderScope(
      overrides: [
        if (repository != null)
          levelProgressRepositoryProvider.overrideWithValue(repository),
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
    await tester.scrollUntilVisible(
      cardFinder,
      260,
      scrollable:
          find
              .descendant(
                of: find.byKey(const Key('levelSelectGrid')),
                matching: find.byType(Scrollable),
              )
              .first,
    );
    await tester.ensureVisible(cardFinder);
    await tester.pump();
  }

  testWidgets('Home shows Play without temporary level buttons', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(repository: FakeLevelProgressRepository()),
    );
    await tester.pump();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Find calm in color.'), findsOneWidget);
    expect(find.byKey(const Key('levelButton_level_001')), findsNothing);
    expect(find.text('Level 1'), findsNothing);
    expect(find.text('Level 2'), findsNothing);
    expect(find.text('Level 3'), findsNothing);
  });

  testWidgets('Play opens Level Select with every catalog level', (
    tester,
  ) async {
    await openLevelSelect(tester, repository: FakeLevelProgressRepository());

    expect(find.byType(LevelSelectScreen), findsOneWidget);
    expect(find.text('Choose a Level'), findsOneWidget);
    for (var index = 0; index < LevelCatalog.levels.length; index++) {
      final level = LevelCatalog.levels[index];
      await scrollToLevel(tester, level.id);
      expect(find.text('Level ${index + 1}'), findsOneWidget);
      expect(find.byKey(Key('levelBoardSize_${level.id}')), findsOneWidget);
    }
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

      await tester.tap(find.byKey(Key('levelCard_$levelId')));
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
    expect(find.text('Choose a Level'), findsOneWidget);
  });

  testWidgets('primary navigation retains accessible tap semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      buildApp(repository: FakeLevelProgressRepository()),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('Play'), findsOneWidget);

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

    for (final size in const [Size(320, 640), Size(1200, 800)]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await openLevelSelect(tester, repository: FakeLevelProgressRepository());
      expect(find.byType(LevelSelectScreen), findsOneWidget);
      await scrollToLevel(tester, 'level_012');
      expect(find.byKey(const Key('levelCard_level_012')), findsOneWidget);
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
    expect(find.text('Completed'), findsOneWidget);
    expect(find.byKey(const Key('levelCompleted_level_002')), findsNothing);
    expect(find.byKey(const Key('levelCompleted_level_003')), findsNothing);
    expect(find.byKey(const Key('levelLocked_level_002')), findsNothing);
    expect(find.byKey(const Key('levelLocked_level_003')), findsOneWidget);
  });

  testWidgets('tapping a locked level does not open Gameplay', (tester) async {
    await openLevelSelect(tester, repository: FakeLevelProgressRepository());

    await tester.tap(find.byKey(const Key('levelCard_level_002')));
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
    await openLevelSelect(tester, repository: repository);
    await tester.tap(find.byKey(const Key('levelCard_level_001')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final gameWidget = tester.widget<GameWidget<PixelHarmonyGame>>(
      find.byType(GameWidget<PixelHarmonyGame>),
    );
    final game = gameWidget.game!;
    game.onCompleted!(game.session.boardState.withCompleted(true));
    await tester.pump();

    expect(repository.completedLevelIds, contains('level_001'));
    expect(find.byKey(const Key('levelCompleteOverlay')), findsOneWidget);

    await tester.tap(find.byKey(const Key('completionContinueButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(LevelSelectScreen), findsOneWidget);
    expect(find.byKey(const Key('levelCompleted_level_001')), findsOneWidget);
    expect(find.byKey(const Key('levelLocked_level_002')), findsNothing);
  });
}
