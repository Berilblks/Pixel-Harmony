import 'package:pixel_harmony/features/privacy/domain/analytics_consent.dart';

abstract interface class AnalyticsConsentRepository {
  Future<AnalyticsConsent> read();

  Future<void> write(AnalyticsConsent consent);
}
