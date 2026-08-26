import 'package:flutter/foundation.dart';

abstract interface class AppCrashReporter {
  Future<void> recordFlutterError(FlutterErrorDetails details);

  Future<void> recordError(Object error, StackTrace stack, {bool fatal});
}

class NoOpAppCrashReporter implements AppCrashReporter {
  const NoOpAppCrashReporter();

  @override
  Future<void> recordError(
    Object error,
    StackTrace stack, {
    bool fatal = false,
  }) async {}

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async {}
}

class DelegatingAppCrashReporter implements AppCrashReporter {
  AppCrashReporter _delegate = const NoOpAppCrashReporter();

  void attach(AppCrashReporter reporter) => _delegate = reporter;

  @override
  Future<void> recordError(
    Object error,
    StackTrace stack, {
    bool fatal = false,
  }) async {
    try {
      await _delegate.recordError(error, stack, fatal: fatal);
    } catch (reportingError) {
      debugPrint('Pixel Harmony crash reporting failed: $reportingError');
    }
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    try {
      await _delegate.recordFlutterError(details);
    } catch (reportingError) {
      debugPrint('Pixel Harmony crash reporting failed: $reportingError');
    }
  }
}
