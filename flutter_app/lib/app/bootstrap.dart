import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/app/app.dart';
import 'package:pixel_harmony/app/firebase_support.dart';
import 'package:pixel_harmony/core/analytics/analytics_providers.dart';
import 'package:pixel_harmony/core/analytics/app_analytics_service.dart';
import 'package:pixel_harmony/core/crash_reporting/app_crash_reporter.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  final analytics = DelegatingAppAnalyticsService();
  final crashReporter = DelegatingAppCrashReporter();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    unawaited(crashReporter.recordFlutterError(details));
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(crashReporter.recordError(error, stack, fatal: true));
    return true;
  };

  runApp(
    ProviderScope(
      overrides: [appAnalyticsServiceProvider.overrideWithValue(analytics)],
      child: const PixelHarmonyApp(),
    ),
  );
  unawaited(
    initializeOptionalFirebase(
      analytics: analytics,
      crashReporter: crashReporter,
    ),
  );
}
