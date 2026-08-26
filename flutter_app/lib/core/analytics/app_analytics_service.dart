import 'package:flutter/foundation.dart';

abstract interface class AppAnalyticsService {
  Future<void> logEvent(String name, {Map<String, Object>? parameters});
}

class NoOpAppAnalyticsService implements AppAnalyticsService {
  const NoOpAppAnalyticsService();

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {}
}

class DelegatingAppAnalyticsService implements AppAnalyticsService {
  AppAnalyticsService _delegate = const NoOpAppAnalyticsService();

  void attach(AppAnalyticsService service) => _delegate = service;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    try {
      await _delegate.logEvent(name, parameters: parameters);
    } catch (error) {
      debugPrint('Pixel Harmony analytics event failed: $name ($error)');
    }
  }
}
