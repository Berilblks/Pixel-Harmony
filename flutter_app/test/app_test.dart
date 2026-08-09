import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/app/app.dart';
import 'package:pixel_harmony/features/gameplay/presentation/gameplay_screen.dart';
import 'package:pixel_harmony/features/home/presentation/home_screen.dart';
import 'package:pixel_harmony/game/pixel_harmony_game.dart';

void main() {
  Widget buildApp() => const ProviderScope(child: PixelHarmonyApp());

  testWidgets('application starts on Home with three level buttons', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    expect(find.byType(PixelHarmonyApp), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Pixel Harmony'), findsOneWidget);
    expect(find.text('Find calm through color.'), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('Level 2'), findsOneWidget);
    expect(find.text('Level 3'), findsOneWidget);
  });

  for (final (label, levelId) in const [
    ('Level 1', 'level_001'),
    ('Level 2', 'level_002'),
    ('Level 3', 'level_003'),
  ]) {
    testWidgets('$label opens gameplay for $levelId', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      await tester.tap(find.text(label));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final screen = tester.widget<GameplayScreen>(find.byType(GameplayScreen));
      expect(screen.level.id, levelId);
      expect(find.byType(GameWidget<PixelHarmonyGame>), findsOneWidget);
      expect(find.byKey(const Key('gameplayGameWidget')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
