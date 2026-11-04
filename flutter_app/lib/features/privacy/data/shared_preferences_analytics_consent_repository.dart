import 'package:pixel_harmony/features/privacy/domain/analytics_consent.dart';
import 'package:pixel_harmony/features/privacy/domain/analytics_consent_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesAnalyticsConsentRepository
    implements AnalyticsConsentRepository {
  static const preferenceKey = 'privacy.analytics_consent';

  @override
  Future<AnalyticsConsent> read() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getBool(preferenceKey);
    if (stored == null) {
      return AnalyticsConsent.undecided;
    }
    return stored ? AnalyticsConsent.enabled : AnalyticsConsent.disabled;
  }

  @override
  Future<void> write(AnalyticsConsent consent) async {
    if (consent == AnalyticsConsent.undecided) {
      throw ArgumentError.value(consent, 'consent', 'A decision is required.');
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(
      preferenceKey,
      consent == AnalyticsConsent.enabled,
    );
  }
}
