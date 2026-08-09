import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/app/app.dart';
import 'package:pixel_harmony/features/gameplay/presentation/gameplay_screen.dart';
import 'package:pixel_harmony/features/home/presentation/home_screen.dart';
import 'package:pixel_harmony/features/level_select/presentation/level_select_screen.dart';
import 'package:pixel_harmony/game/pixel_harmony_game.dart';

void main() {
  Widget buildApp() => const ProviderScope(child: PixelHarmonyApp());

  Future<void> openLevelSelect(WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.tap(find.byKey(const Key('homePlayButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
  }

  testWidgets('Home shows Play without temporary level buttons', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.byKey(const Key('levelButton_level_001')), findsNothing);
    expect(find.text('Level 1'), findsNothing);
    expect(find.text('Level 2'), findsNothing);
    expect(find.text('Level 3'), findsNothing);
  });

  testWidgets('Play opens Level Select with every catalog level', (
    tester,
  ) async {
    await openLevelSelect(tester);

    expect(find.byType(LevelSelectScreen), findsOneWidget);
    expect(find.text('Choose a Level'), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('Level 2'), findsOneWidget);
    expect(find.text('Level 3'), findsOneWidget);
    expect(find.text('Board Size: 2 × 2'), findsNWidgets(2));
    expect(find.text('Board Size: 3 × 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final (label, levelId) in const [
    ('Level 1', 'level_001'),
    ('Level 2', 'level_002'),
    ('Level 3', 'level_003'),
  ]) {
    testWidgets('$label card opens gameplay for $levelId', (tester) async {
      await openLevelSelect(tester);

      await tester.tap(find.byKey(Key('levelCard_$levelId')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final screen = tester.widget<GameplayScreen>(find.byType(GameplayScreen));
      expect(screen.level?.id, levelId);
      expect(find.byType(GameWidget<PixelHarmonyGame>), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('invalid level ID shows error and returns to Level Select', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
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
}
