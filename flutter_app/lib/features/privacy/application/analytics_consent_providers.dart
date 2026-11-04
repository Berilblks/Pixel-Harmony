import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/core/analytics/analytics_privacy_runtime.dart';
import 'package:pixel_harmony/features/privacy/data/shared_preferences_analytics_consent_repository.dart';
import 'package:pixel_harmony/features/privacy/domain/analytics_consent.dart';
import 'package:pixel_harmony/features/privacy/domain/analytics_consent_repository.dart';

final analyticsConsentRepositoryProvider = Provider<AnalyticsConsentRepository>(
  (ref) {
    return SharedPreferencesAnalyticsConsentRepository();
  },
);

final analyticsPrivacyRuntimeProvider = Provider<AnalyticsPrivacyRuntime>((
  ref,
) {
  return const NoOpAnalyticsPrivacyRuntime();
});

final analyticsConsentControllerProvider =
    AsyncNotifierProvider<AnalyticsConsentController, AnalyticsConsent>(
      AnalyticsConsentController.new,
    );

class AnalyticsConsentController extends AsyncNotifier<AnalyticsConsent> {
  @override
  Future<AnalyticsConsent> build() {
    return ref.watch(analyticsConsentRepositoryProvider).read();
  }

  Future<void> setEnabled(bool enabled) async {
    final previous = state.value ?? AnalyticsConsent.undecided;
    final updated =
        enabled ? AnalyticsConsent.enabled : AnalyticsConsent.disabled;
    if (previous == updated) {
      return;
    }

    state = AsyncData(updated);
    try {
      await ref.read(analyticsConsentRepositoryProvider).write(updated);
      await ref.read(analyticsPrivacyRuntimeProvider).setEnabled(enabled);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
