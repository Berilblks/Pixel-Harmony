import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/features/privacy/data/shared_preferences_analytics_consent_repository.dart';
import 'package:pixel_harmony/features/privacy/domain/analytics_consent.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('analytics consent is undecided on first use', () async {
    final repository = SharedPreferencesAnalyticsConsentRepository();

    expect(await repository.read(), AnalyticsConsent.undecided);
  });

  test('analytics consent persists enabled and disabled choices', () async {
    final repository = SharedPreferencesAnalyticsConsentRepository();
    await repository.write(AnalyticsConsent.enabled);

    expect(
      await SharedPreferencesAnalyticsConsentRepository().read(),
      AnalyticsConsent.enabled,
    );

    await repository.write(AnalyticsConsent.disabled);
    expect(
      await SharedPreferencesAnalyticsConsentRepository().read(),
      AnalyticsConsent.disabled,
    );
  });
}
