import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/features/gameplay/presentation/gameplay_screen.dart';
import 'package:pixel_harmony/features/gameplay/presentation/pixel_coloring_viewport.dart';
import 'package:pixel_harmony/game/coloring/pixel_coloring_board_component.dart';
import 'package:pixel_harmony/game/coloring/pixel_coloring_cell_component.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_catalog.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_template.dart';
import 'package:pixel_harmony/game/pixel_harmony_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_daily_progress_repository.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'Daily Pixel Coloring exposes every template color and supports painting',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final template = _templateWithMostColors();
      final level = _pictureLevel(template, id: 'daily_picture_test');
      final daily = FakeDailyProgressRepository();
      await tester.pumpWidget(
        _testApp(
          GameplayScreen.daily(
            level: level,
            dailyDateKey: '2026-10-17',
            onDailyCompleted: (state) async {
              if (state.completed) await daily.complete('2026-10-17');
            },
            onBackHome: () {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final palette = find.byKey(const Key('pixelColorPalette'));
      expect(palette, findsOneWidget);
      expect(
        tester.getBottomLeft(palette).dy,
        lessThanOrEqualTo(tester.view.physicalSize.height),
      );
      for (final paletteIndex in template.requiredPaletteIndices) {
        final identifier = template.identifierForPalette(paletteIndex);
        final swatch = find.byKey(Key('pixelColorSwatch_$identifier'));
        expect(swatch, findsOneWidget);
        final colorContainer = tester.widget<Container>(
          find.descendant(of: swatch, matching: find.byType(Container)),
        );
        final decoration = colorContainer.decoration! as BoxDecoration;
        expect(decoration.color, Color(template.palette[paletteIndex]));
      }

      final game = _currentGame(tester);
      final board =
          game.children.whereType<PixelColoringBoardComponent>().single;
      final initialSelection = game.coloringSession!.state.selectedPaletteIndex;
      final wrongCell = board.children
          .whereType<PixelColoringCellComponent>()
          .firstWhere(
            (cell) =>
                cell.paintable &&
                template.pixels[cell.cellIndex] != initialSelection,
          );
      wrongCell.onTapped(wrongCell.cellIndex);
      expect(
        game.coloringSession!.state.paintedCells[wrongCell.cellIndex],
        isFalse,
      );

      final selectedCell = board.children
          .whereType<PixelColoringCellComponent>()
          .firstWhere(
            (cell) =>
                cell.paintable &&
                template.pixels[cell.cellIndex] == initialSelection,
          );
      selectedCell.onTapped(selectedCell.cellIndex);
      await tester.pump();
      expect(
        game.coloringSession!.state.paintedCells[selectedCell.cellIndex],
        isTrue,
      );

      final anotherPaletteIndex = template.requiredPaletteIndices.firstWhere(
        (index) => index != game.coloringSession!.state.selectedPaletteIndex,
      );
      final anotherIdentifier = template.identifierForPalette(
        anotherPaletteIndex,
      );
      final anotherSwatch = find.byKey(
        Key('pixelColorSwatch_$anotherIdentifier'),
      );
      await tester.ensureVisible(anotherSwatch);
      await tester.pump();
      await tester.tap(anotherSwatch);
      await tester.pump();
      expect(
        game.coloringSession!.state.selectedPaletteIndex,
        anotherPaletteIndex,
      );

      while (!game.coloringSession!.state.completed) {
        expect(game.requestHint(), isTrue);
      }
      await tester.pump(const Duration(milliseconds: 3100));
      expect(daily.completeCallCount, 1);
      expect(daily.progress.isCompleted('2026-10-17'), isTrue);
      expect(
        find.byKey(const Key('completedPixelArtPresentation')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('pixelColorPalette')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Free Play Pixel Coloring uses the shared palette', (
    tester,
  ) async {
    final template = _templateWithMostColors();
    await tester.pumpWidget(
      _testApp(
        GameplayScreen.endless(
          level: _pictureLevel(template, id: 'free_play_picture_test'),
          puzzleNumber: 1,
          onEndlessCompleted: (_) async {},
          onNextPuzzle: () {},
          onBackHome: () {},
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('pixelColorPalette')), findsOneWidget);
    final firstPaletteIndex = template.requiredPaletteIndices.first;
    final firstIdentifier = template.identifierForPalette(firstPaletteIndex);
    await tester.tap(find.byKey(Key('pixelColorSwatch_$firstIdentifier')));
    await tester.pump();
    expect(
      _currentGame(tester).coloringSession!.state.selectedPaletteIndex,
      firstPaletteIndex,
    );
  });

  testWidgets(
    '16x16 zoom keeps palette fixed, blocks multi-touch paint, and maps taps',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 720);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final template = PixelPictureCatalog.byId('northern_lights');
      await tester.pumpWidget(
        _testApp(
          GameplayScreen.endless(
            level: _pictureLevel(template, id: 'zoom_picture_test'),
            puzzleNumber: 1,
            onEndlessCompleted: (_) async {},
            onNextPuzzle: () {},
            onBackHome: () {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final palette = find.byKey(const Key('pixelColorPalette'));
      final palettePosition = tester.getTopLeft(palette);
      final game = _currentGame(tester);
      final board =
          game.children.whereType<PixelColoringBoardComponent>().single;
      final selected = board.children
          .whereType<PixelColoringCellComponent>()
          .firstWhere(
            (cell) =>
                cell.paintable &&
                template.pixels[cell.cellIndex] ==
                    game.coloringSession!.state.selectedPaletteIndex,
          );

      await _pinchGameplay(tester);
      expect(game.coloringSession!.state.paintedCount, 0);
      expect(tester.getTopLeft(palette), palettePosition);

      final viewport = tester.state<PixelColoringViewportState>(
        find.byType(PixelColoringViewport),
      );
      expect(
        viewport.transformationController.value.getMaxScaleOnAxis(),
        greaterThan(1),
      );
      final canvasPoint = Offset(
        board.position.x + selected.position.x + selected.size.x / 2,
        board.position.y + selected.position.y + selected.size.y / 2,
      );
      final transformedPoint = MatrixUtils.transformPoint(
        viewport.transformationController.value,
        canvasPoint,
      );
      final viewerOrigin = tester.getTopLeft(
        find.byKey(const Key('pixelColoringInteractiveViewer')),
      );
      await tester.tapAt(viewerOrigin + transformedPoint);
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        game.coloringSession!.state.paintedCells[selected.cellIndex],
        isTrue,
      );
    },
  );
}

Future<void> _pinchGameplay(WidgetTester tester) async {
  final center = tester.getCenter(
    find.byKey(const Key('pixelColoringInteractiveViewer')),
  );
  final first = await tester.createGesture(pointer: 11);
  final second = await tester.createGesture(pointer: 12);
  await first.down(center - const Offset(30, 0));
  await second.down(center + const Offset(30, 0));
  await first.moveTo(center - const Offset(100, 0));
  await second.moveTo(center + const Offset(100, 0));
  await tester.pump();
  await first.up();
  await second.up();
  await tester.pump();
}

Widget _testApp(Widget home) {
  return ProviderScope(
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

PixelHarmonyGame _currentGame(WidgetTester tester) {
  return tester
      .widget<GameWidget<PixelHarmonyGame>>(
        find.byType(GameWidget<PixelHarmonyGame>),
      )
      .game!;
}

PixelPictureTemplate _templateWithMostColors() {
  return PixelPictureCatalog.templates.reduce(
    (current, candidate) =>
        candidate.requiredPaletteIndices.length >
                current.requiredPaletteIndices.length
            ? candidate
            : current,
  );
}

LevelDefinition _pictureLevel(
  PixelPictureTemplate template, {
  required String id,
}) {
  final solution = List.generate(
    template.pixels.length,
    (index) => '${id}_tile_$index',
    growable: false,
  );
  return LevelDefinition(
    id: id,
    number: 1,
    nameKey: 'dailyPuzzle',
    boardSize: template.size,
    difficulty: LevelDifficulty.medium,
    difficultyScore: 43,
    puzzleType: JourneyPuzzleType.pixelPicture,
    pictureTemplateId: template.id,
    tiles: [
      for (var index = 0; index < template.pixels.length; index++)
        LevelTileDefinition(
          id: solution[index],
          colorValue: template.palette[template.pixels[index]],
        ),
    ],
    initialTileOrder: solution,
    solutionTileOrder: solution,
  );
}
