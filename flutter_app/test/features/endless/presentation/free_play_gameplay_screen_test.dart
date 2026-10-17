import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/features/endless/application/free_play_providers.dart';
import 'package:pixel_harmony/features/endless/domain/free_play_configuration.dart';
import 'package:pixel_harmony/features/endless/domain/free_play_pixel_template_selector.dart';
import 'package:pixel_harmony/features/endless/presentation/free_play_gameplay_screen.dart';
import 'package:pixel_harmony/features/gameplay/presentation/gameplay_screen.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_catalog.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('rebuild is stable and New Puzzle consumes the next figure', (
    tester,
  ) async {
    final selector = _OrderedSelector([
      PixelPictureCatalog.byId('heart'),
      PixelPictureCatalog.byId('star'),
    ]);
    await tester.pumpWidget(_app(selector));
    await tester.pump();

    final first = _gameplay(tester);
    expect(first.level!.pictureTemplateId, contains('heart'));
    expect(selector.selectionCount, 1);

    await tester.pump();
    expect(
      _gameplay(tester).level!.pictureTemplateId,
      first.level!.pictureTemplateId,
    );
    expect(selector.selectionCount, 1);

    _gameplay(tester).onNextPuzzle!.call();
    await tester.pump();
    expect(_gameplay(tester).level!.pictureTemplateId, contains('star'));
    expect(selector.selectionCount, 2);
  });

  testWidgets('color selection and zoom do not consume another figure', (
    tester,
  ) async {
    final selector = _OrderedSelector([
      PixelPictureCatalog.byId('star'),
      PixelPictureCatalog.byId('cloud'),
    ]);
    await tester.pumpWidget(_app(selector));
    await tester.pump();
    final initialId = _gameplay(tester).level!.pictureTemplateId;

    await tester.tap(find.byKey(const Key('pixelColorSwatch_1')));
    await tester.pump();
    expect(_gameplay(tester).level!.pictureTemplateId, initialId);
    expect(selector.selectionCount, 1);
  });
}

Widget _app(FreePlayPixelTemplateSelector selector) {
  return ProviderScope(
    overrides: [
      freePlayPixelTemplateSelectorProvider.overrideWithValue(selector),
    ],
    child: const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: FreePlayGameplayScreen(
        configuration: FreePlayConfiguration(
          puzzleType: FreePlayPuzzleType.pixelColoring,
          difficulty: FreePlayDifficulty.relaxed,
        ),
      ),
    ),
  );
}

GameplayScreen _gameplay(WidgetTester tester) =>
    tester.widget<GameplayScreen>(find.byType(GameplayScreen));

class _OrderedSelector implements FreePlayPixelTemplateSelector {
  _OrderedSelector(this.templates);

  final List<PixelPictureTemplate> templates;
  int selectionCount = 0;

  @override
  PixelPictureTemplate next(FreePlayDifficulty difficulty) =>
      templates[selectionCount++ % templates.length];

  @override
  int poolSize(FreePlayDifficulty difficulty) => templates.length;
}
