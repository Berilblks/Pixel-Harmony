import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:pixel_harmony/core/analytics/analytics_taxonomy.dart';
import 'package:pixel_harmony/core/analytics/app_analytics_service.dart';
import 'package:pixel_harmony/core/analytics/firebase_app_analytics_service.dart';
import 'package:pixel_harmony/core/crash_reporting/app_crash_reporter.dart';
import 'package:pixel_harmony/core/crash_reporting/firebase_app_crash_reporter.dart';

Future<bool> initializeOptionalFirebase({
  required DelegatingAppAnalyticsService analytics,
  required DelegatingAppCrashReporter crashReporter,
  Future<void> Function()? initializeFirebase,
}) async {
  try {
    await (initializeFirebase?.call() ?? Firebase.initializeApp());
    final firebaseAnalytics = FirebaseAnalytics.instance;
    final firebaseCrashlytics = FirebaseCrashlytics.instance;
    await firebaseCrashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
    analytics.attach(FirebaseAppAnalyticsService(firebaseAnalytics));
    crashReporter.attach(FirebaseAppCrashReporter(firebaseCrashlytics));
    await analytics.logEvent(AnalyticsEvents.appOpen);
    return true;
  } catch (error) {
    debugPrint(
      'Pixel Harmony Firebase unavailable; continuing offline: $error',
    );
    return false;
  }
}
