import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/features/achievements/domain/achievement_catalog.dart';
import 'package:pixel_harmony/features/achievements/presentation/achievement_unlock_feedback.dart';

void main() {
  testWidgets('multiple unlock feedback uses one non-stacking snackbar', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          GlobalMaterialLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder:
                (context) => FilledButton(
                  onPressed: () {
                    showAchievementUnlockFeedback(context, [
                      AchievementCatalog.byId('ten_harmonies'),
                      AchievementCatalog.byId('thousand_moves'),
                    ]);
                  },
                  child: const Text('Show'),
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    await tester.tap(find.text('Show'));
    await tester.pump();

    expect(find.byKey(const Key('achievementUnlockFeedback')), findsOneWidget);
    expect(
      find.text('Achievement Unlocked: Ten Harmonies (+1 more)'),
      findsOneWidget,
    );
  });
}
