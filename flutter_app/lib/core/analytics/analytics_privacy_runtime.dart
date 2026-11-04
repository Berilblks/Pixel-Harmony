import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:pixel_harmony/core/analytics/app_analytics_service.dart';

abstract interface class AnalyticsPrivacyRuntime {
  Future<void> setEnabled(bool enabled);
}

class NoOpAnalyticsPrivacyRuntime implements AnalyticsPrivacyRuntime {
  const NoOpAnalyticsPrivacyRuntime();

  @override
  Future<void> setEnabled(bool enabled) async {}
}

class DelegatingAnalyticsPrivacyRuntime implements AnalyticsPrivacyRuntime {
  DelegatingAnalyticsPrivacyRuntime({
    required DelegatingAppAnalyticsService analytics,
    bool enabled = false,
  }) : _analytics = analytics,
       _enabled = enabled {
    _analytics.setEnabled(enabled);
  }

  final DelegatingAppAnalyticsService _analytics;
  FirebaseAnalytics? _firebaseAnalytics;
  bool _enabled;

  Future<void> attach(FirebaseAnalytics firebaseAnalytics) async {
    _firebaseAnalytics = firebaseAnalytics;
    await firebaseAnalytics.setAnalyticsCollectionEnabled(_enabled);
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    if (!enabled) {
      _analytics.setEnabled(false);
    }
    await _firebaseAnalytics?.setAnalyticsCollectionEnabled(enabled);
    if (enabled) {
      _analytics.setEnabled(true);
    }
  }
}
