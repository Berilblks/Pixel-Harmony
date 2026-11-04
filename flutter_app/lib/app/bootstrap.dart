import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/app/app.dart';
import 'package:pixel_harmony/app/firebase_support.dart';
import 'package:pixel_harmony/app/startup_splash.dart';
import 'package:pixel_harmony/core/analytics/analytics_providers.dart';
import 'package:pixel_harmony/core/analytics/analytics_privacy_runtime.dart';
import 'package:pixel_harmony/core/analytics/app_analytics_service.dart';
import 'package:pixel_harmony/core/crash_reporting/app_crash_reporter.dart';
import 'package:pixel_harmony/features/privacy/application/analytics_consent_providers.dart';
import 'package:pixel_harmony/features/privacy/data/shared_preferences_analytics_consent_repository.dart';
import 'package:pixel_harmony/features/privacy/domain/analytics_consent.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(_bootstrap());
}

Future<void> _bootstrap() async {
  final analytics = DelegatingAppAnalyticsService();
  final crashReporter = DelegatingAppCrashReporter();
  final consentRepository = SharedPreferencesAnalyticsConsentRepository();
  final consent = await consentRepository.read().catchError(
    (_) => AnalyticsConsent.undecided,
  );
  final analyticsPrivacyRuntime = DelegatingAnalyticsPrivacyRuntime(
    analytics: analytics,
    enabled: consent == AnalyticsConsent.enabled,
  );

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
      overrides: [
        appAnalyticsServiceProvider.overrideWithValue(analytics),
        analyticsConsentRepositoryProvider.overrideWithValue(consentRepository),
        analyticsPrivacyRuntimeProvider.overrideWithValue(
          analyticsPrivacyRuntime,
        ),
      ],
      child: const StartupSplash(child: PixelHarmonyApp()),
    ),
  );
  unawaited(
    initializeOptionalFirebase(
      analytics: analytics,
      crashReporter: crashReporter,
      analyticsPrivacyRuntime: analyticsPrivacyRuntime,
      analyticsEnabled: consent == AnalyticsConsent.enabled,
    ),
  );
}
