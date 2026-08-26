import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/core/analytics/app_analytics_service.dart';

final appAnalyticsServiceProvider = Provider<AppAnalyticsService>((ref) {
  return const NoOpAppAnalyticsService();
});
