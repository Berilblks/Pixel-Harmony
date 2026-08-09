import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/features/gameplay/presentation/gameplay_completion_controller.dart';
import 'package:pixel_harmony/features/gameplay/presentation/gameplay_screen.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/models/tile_model.dart';
import 'package:pixel_harmony/game/state/board_state.dart';

void main() {
  BoardState completedState({int moveCount = 1}) {
    return BoardState(
      boardSize: 1,
      tiles: const [TileModel(id: 'tile', color: Color(0xFF5BC0EB))],
      moveCount: moveCount,
      completed: true,
    );
  }

  Widget buildApp(
    GameplayCompletionController controller, {
    Locale locale = const Locale('en'),
  }) {
    final router = GoRouter(
      initialLocation: '/gameplay/level_001',
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

  testWidgets('completion overlay is hidden while puzzle is incomplete', (
    tester,
  ) async {
    final controller = GameplayCompletionController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(buildApp(controller));
    await tester.pump();

    expect(find.byKey(const Key('levelCompleteOverlay')), findsNothing);
  });

  testWidgets('English completion overlay shows the move count', (
    tester,
  ) async {
    final controller = GameplayCompletionController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(buildApp(controller));
    await tester.pump();

    controller.showCompletion(completedState(moveCount: 3));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Harmony Restored'), findsOneWidget);
    expect(find.text('Beautifully done.'), findsOneWidget);
    expect(find.text('Moves: 3'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('completion overlay shows Turkish localization', (tester) async {
    final controller = GameplayCompletionController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(buildApp(controller, locale: const Locale('tr')));
    await tester.pump();

    controller.showCompletion(completedState(moveCount: 2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Uyum Tamamlandı'), findsOneWidget);
    expect(find.text('Harika tamamladın.'), findsOneWidget);
    expect(find.text('Hamle: 2'), findsOneWidget);
    expect(find.text('Devam Et'), findsOneWidget);
  });

  testWidgets('Continue returns to Level Select', (tester) async {
    final controller = GameplayCompletionController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(buildApp(controller));
    await tester.pump();
    controller.showCompletion(completedState());
    await tester.pump(const Duration(milliseconds: 350));

    await tester.tap(find.byKey(const Key('completionContinueButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('levels-marker'), findsOneWidget);
    expect(find.byType(GameplayScreen), findsNothing);
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
