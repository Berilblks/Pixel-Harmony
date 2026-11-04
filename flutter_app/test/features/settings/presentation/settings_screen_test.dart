import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/core/links/external_link_providers.dart';
import 'package:pixel_harmony/core/links/external_link_service.dart';
import 'package:pixel_harmony/core/analytics/analytics_providers.dart';
import 'package:pixel_harmony/core/analytics/analytics_taxonomy.dart';
import 'package:pixel_harmony/features/settings/application/game_feedback_settings_providers.dart';
import 'package:pixel_harmony/features/settings/domain/game_feedback_settings.dart';
import 'package:pixel_harmony/features/settings/domain/game_feedback_settings_repository.dart';
import 'package:pixel_harmony/features/settings/presentation/settings_screen.dart';
import 'package:pixel_harmony/core/analytics/analytics_privacy_runtime.dart';
import 'package:pixel_harmony/features/privacy/application/analytics_consent_providers.dart';
import 'package:pixel_harmony/features/privacy/domain/analytics_consent.dart';
import 'package:pixel_harmony/features/privacy/domain/analytics_consent_repository.dart';

import '../../../support/fake_app_analytics_service.dart';

void main() {
  testWidgets('Settings screen updates persisted provider state', (
    tester,
  ) async {
    final repository = _FakeSettingsRepository();
    final analytics = FakeAppAnalyticsService();
    final consentRepository = _FakeConsentRepository(AnalyticsConsent.disabled);
    final privacyRuntime = _FakePrivacyRuntime();
    final links = _FakeExternalLinkService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameFeedbackSettingsRepositoryProvider.overrideWithValue(repository),
          appAnalyticsServiceProvider.overrideWithValue(analytics),
          analyticsConsentRepositoryProvider.overrideWithValue(
            consentRepository,
          ),
          analyticsPrivacyRuntimeProvider.overrideWithValue(privacyRuntime),
          externalLinkServiceProvider.overrideWithValue(links),
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
    expect(find.text('Sound Effects'), findsNothing);
    expect(find.text('Haptics'), findsOneWidget);
    expect(find.text('Usage Analytics'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);

    await tester.tap(find.byKey(const Key('hapticsSwitch')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('analyticsConsentSwitch')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('privacyPolicyLink')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('supportLink')));
    await tester.pumpAndSettle();

    expect(repository.settings.hapticsEnabled, isFalse);
    expect(repository.writeCount, 1);
    expect(consentRepository.consent, AnalyticsConsent.enabled);
    expect(privacyRuntime.values, [true]);
    expect(analytics.count(AnalyticsEvents.settingsChanged), 1);
    expect(analytics.events.map((event) => event.parameters['setting']), [
      'haptics',
    ]);
    expect(links.opened.map((uri) => uri.toString()), [
      'https://berilblks.github.io/Pixel-Harmony/privacy.html',
      'https://berilblks.github.io/Pixel-Harmony/support.html',
    ]);
  });

  testWidgets('Settings reports a link that cannot be opened', (tester) async {
    final links = _FakeExternalLinkService(result: false);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameFeedbackSettingsRepositoryProvider.overrideWithValue(
            _FakeSettingsRepository(),
          ),
          analyticsConsentRepositoryProvider.overrideWithValue(
            _FakeConsentRepository(AnalyticsConsent.disabled),
          ),
          externalLinkServiceProvider.overrideWithValue(links),
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

    await tester.tap(find.byKey(const Key('privacyPolicyLink')));
    await tester.pumpAndSettle();

    expect(
      find.text('The link could not be opened. Please try again later.'),
      findsOneWidget,
    );
  });
}

class _FakeConsentRepository implements AnalyticsConsentRepository {
  _FakeConsentRepository(this.consent);

  AnalyticsConsent consent;

  @override
  Future<AnalyticsConsent> read() async => consent;

  @override
  Future<void> write(AnalyticsConsent consent) async {
    this.consent = consent;
  }
}

class _FakePrivacyRuntime implements AnalyticsPrivacyRuntime {
  final values = <bool>[];

  @override
  Future<void> setEnabled(bool enabled) async => values.add(enabled);
}

class _FakeExternalLinkService implements ExternalLinkService {
  _FakeExternalLinkService({this.result = true});

  final bool result;
  final opened = <Uri>[];

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return result;
  }
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
