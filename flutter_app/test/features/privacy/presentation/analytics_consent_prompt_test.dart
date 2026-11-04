import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/core/analytics/analytics_privacy_runtime.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/features/privacy/application/analytics_consent_providers.dart';
import 'package:pixel_harmony/features/privacy/domain/analytics_consent.dart';
import 'package:pixel_harmony/features/privacy/domain/analytics_consent_repository.dart';
import 'package:pixel_harmony/features/privacy/presentation/analytics_consent_prompt.dart';

void main() {
  testWidgets('first use asks before enabling analytics', (tester) async {
    final repository = _FakeConsentRepository();
    final runtime = _FakePrivacyRuntime();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsConsentRepositoryProvider.overrideWithValue(repository),
          analyticsPrivacyRuntimeProvider.overrideWithValue(runtime),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: AnalyticsConsentPrompt(child: Scaffold(body: Text('Home'))),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('analyticsConsentDialog')), findsOneWidget);
    expect(runtime.values, isEmpty);

    await tester.tap(find.byKey(const Key('analyticsConsentAccept')));
    await tester.pumpAndSettle();

    expect(repository.consent, AnalyticsConsent.enabled);
    expect(runtime.values, [true]);
    expect(find.byKey(const Key('analyticsConsentDialog')), findsNothing);
  });

  testWidgets(
    'consent actions remain accessible on a small iPhone with 200% text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final repository = _FakeConsentRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            analyticsConsentRepositoryProvider.overrideWithValue(repository),
            analyticsPrivacyRuntimeProvider.overrideWithValue(
              _FakePrivacyRuntime(),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: AnalyticsConsentPrompt(child: Scaffold(body: Text('Home'))),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('analyticsConsentDialog')), findsOneWidget);
      expect(
        find.byKey(const Key('analyticsConsentDecline')).hitTestable(),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('analyticsConsentAccept')).hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const Key('analyticsConsentDecline')));
      await tester.pumpAndSettle();
      expect(repository.consent, AnalyticsConsent.disabled);
    },
  );
}

class _FakeConsentRepository implements AnalyticsConsentRepository {
  AnalyticsConsent consent = AnalyticsConsent.undecided;

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
