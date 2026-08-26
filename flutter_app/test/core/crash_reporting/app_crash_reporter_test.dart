import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/core/crash_reporting/app_crash_reporter.dart';

void main() {
  test('no-op crash reporter never interferes with expected errors', () async {
    const reporter = NoOpAppCrashReporter();
    await expectLater(
      reporter.recordError(StateError('expected'), StackTrace.current),
      completes,
    );
  });

  test('delegating crash reporter swallows reporting failures', () async {
    final reporter = DelegatingAppCrashReporter()..attach(_FailingReporter());
    await expectLater(
      reporter.recordError(StateError('source'), StackTrace.current),
      completes,
    );
  });
}

class _FailingReporter implements AppCrashReporter {
  @override
  Future<void> recordError(
    Object error,
    StackTrace stack, {
    bool fatal = false,
  }) {
    throw StateError('reporting failed');
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) {
    throw StateError('reporting failed');
  }
}
