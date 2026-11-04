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
        DelegatingAppAnalyticsService()
          ..attach(_FailingAnalyticsService())
          ..setEnabled(true);

    await expectLater(service.logEvent('hint_used'), completes);
  });

  test(
    'delegating analytics suppresses events until consent is enabled',
    () async {
      final backend = _RecordingAnalyticsService();
      final service = DelegatingAppAnalyticsService()..attach(backend);

      await service.logEvent('before_consent');
      expect(backend.events, isEmpty);

      service.setEnabled(true);
      await service.logEvent('after_consent');
      expect(backend.events, ['after_consent']);

      service.setEnabled(false);
      await service.logEvent('after_withdrawal');
      expect(backend.events, ['after_consent']);
    },
  );
}

class _RecordingAnalyticsService implements AppAnalyticsService {
  final events = <String>[];

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    events.add(name);
  }
}

class _FailingAnalyticsService implements AppAnalyticsService {
  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) {
    throw StateError('unavailable');
  }
}
