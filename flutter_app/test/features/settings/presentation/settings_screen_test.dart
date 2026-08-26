import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/core/analytics/analytics_providers.dart';
import 'package:pixel_harmony/core/analytics/analytics_taxonomy.dart';
import 'package:pixel_harmony/features/settings/application/game_feedback_settings_providers.dart';
import 'package:pixel_harmony/features/settings/domain/game_feedback_settings.dart';
import 'package:pixel_harmony/features/settings/domain/game_feedback_settings_repository.dart';
import 'package:pixel_harmony/features/settings/presentation/settings_screen.dart';

import '../../../support/fake_app_analytics_service.dart';

void main() {
  testWidgets('Settings screen updates persisted provider state', (
    tester,
  ) async {
    final repository = _FakeSettingsRepository();
    final analytics = FakeAppAnalyticsService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameFeedbackSettingsRepositoryProvider.overrideWithValue(repository),
          appAnalyticsServiceProvider.overrideWithValue(analytics),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Sound Effects'), findsOneWidget);
    expect(find.text('Haptics'), findsOneWidget);

    await tester.tap(find.byKey(const Key('soundEffectsSwitch')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hapticsSwitch')));
    await tester.pumpAndSettle();

    expect(repository.settings.soundEffectsEnabled, isFalse);
    expect(repository.settings.hapticsEnabled, isFalse);
    expect(repository.writeCount, 2);
    expect(analytics.count(AnalyticsEvents.settingsChanged), 2);
    expect(analytics.events.map((event) => event.parameters['setting']), [
      'sound_effects',
      'haptics',
    ]);
  });
}

class _FakeSettingsRepository implements GameFeedbackSettingsRepository {
  GameFeedbackSettings settings = const GameFeedbackSettings();
  int writeCount = 0;

  @override
  Future<GameFeedbackSettings> read() async => settings;

  @override
  Future<void> write(GameFeedbackSettings settings) async {
    writeCount++;
    this.settings = settings;
  }
}
