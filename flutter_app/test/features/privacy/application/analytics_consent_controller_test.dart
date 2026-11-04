import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/core/analytics/analytics_privacy_runtime.dart';
import 'package:pixel_harmony/features/privacy/application/analytics_consent_providers.dart';
import 'package:pixel_harmony/features/privacy/domain/analytics_consent.dart';
import 'package:pixel_harmony/features/privacy/domain/analytics_consent_repository.dart';

void main() {
  test('controller persists and applies analytics choice', () async {
    final repository = _FakeConsentRepository();
    final runtime = _FakePrivacyRuntime();
    final container = ProviderContainer(
      overrides: [
        analyticsConsentRepositoryProvider.overrideWithValue(repository),
        analyticsPrivacyRuntimeProvider.overrideWithValue(runtime),
      ],
    );
    addTearDown(container.dispose);

    await container.read(analyticsConsentControllerProvider.future);
    await container
        .read(analyticsConsentControllerProvider.notifier)
        .setEnabled(true);

    expect(repository.consent, AnalyticsConsent.enabled);
    expect(runtime.values, [true]);

    await container
        .read(analyticsConsentControllerProvider.notifier)
        .setEnabled(false);
    expect(repository.consent, AnalyticsConsent.disabled);
    expect(runtime.values, [true, false]);
  });
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
