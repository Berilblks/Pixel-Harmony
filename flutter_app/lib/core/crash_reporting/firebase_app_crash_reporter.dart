import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:pixel_harmony/core/crash_reporting/app_crash_reporter.dart';

class FirebaseAppCrashReporter implements AppCrashReporter {
  FirebaseAppCrashReporter(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> recordError(
    Object error,
    StackTrace stack, {
    bool fatal = false,
  }) {
    return _crashlytics.recordError(error, stack, fatal: fatal);
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) {
    return _crashlytics.recordFlutterFatalError(details);
  }
}
