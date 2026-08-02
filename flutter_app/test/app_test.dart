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

  testWidgets('application starts on the Home screen', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    expect(find.byType(PixelHarmonyApp), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Home screen renders localized content', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    expect(find.text('Pixel Harmony'), findsOneWidget);
    expect(find.text('Find calm through color.'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
  });

  testWidgets('navigates from Home to Gameplay', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    await tester.tap(find.text('Play'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(GameplayScreen), findsOneWidget);
    expect(find.text('Gameplay'), findsOneWidget);
  });

  testWidgets('Gameplay contains a Flame GameWidget', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    await tester.tap(find.text('Play'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(GameWidget<PixelHarmonyGame>), findsOneWidget);
    expect(find.byKey(const Key('gameplayGameWidget')), findsOneWidget);
  });
}
