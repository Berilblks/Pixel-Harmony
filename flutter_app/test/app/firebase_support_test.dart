import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/app/firebase_support.dart';
import 'package:pixel_harmony/core/analytics/app_analytics_service.dart';
import 'package:pixel_harmony/core/crash_reporting/app_crash_reporter.dart';

void main() {
  test(
    'unavailable Firebase safely retains no-op supporting services',
    () async {
      final analytics = DelegatingAppAnalyticsService();
      final crashReporter = DelegatingAppCrashReporter();

      final available = await initializeOptionalFirebase(
        analytics: analytics,
        crashReporter: crashReporter,
        initializeFirebase: () async => throw StateError('missing config'),
      );

      expect(available, isFalse);
      await expectLater(analytics.logEvent('app_open'), completes);
      await expectLater(
        crashReporter.recordError(StateError('expected'), StackTrace.current),
        completes,
      );
    },
  );
}
