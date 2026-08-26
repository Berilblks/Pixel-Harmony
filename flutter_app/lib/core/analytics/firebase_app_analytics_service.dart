import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:pixel_harmony/core/analytics/app_analytics_service.dart';

class FirebaseAppAnalyticsService implements AppAnalyticsService {
  FirebaseAppAnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) {
    return _analytics.logEvent(name: name, parameters: parameters);
  }
}
