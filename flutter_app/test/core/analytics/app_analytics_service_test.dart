import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/core/analytics/app_analytics_service.dart';

void main() {
  test('no-op analytics accepts events safely', () async {
    await expectLater(
      const NoOpAppAnalyticsService().logEvent('app_open'),
      completes,
    );
  });

  test('delegating analytics swallows backend failures', () async {
    final service =
        DelegatingAppAnalyticsService()..attach(_FailingAnalyticsService());

    await expectLater(service.logEvent('hint_used'), completes);
  });
}

class _FailingAnalyticsService implements AppAnalyticsService {
  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) {
    throw StateError('unavailable');
  }
}
