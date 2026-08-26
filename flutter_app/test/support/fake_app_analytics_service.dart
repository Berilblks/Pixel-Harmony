import 'package:pixel_harmony/core/analytics/app_analytics_service.dart';

class RecordedAnalyticsEvent {
  const RecordedAnalyticsEvent(this.name, this.parameters);

  final String name;
  final Map<String, Object> parameters;
}

class FakeAppAnalyticsService implements AppAnalyticsService {
  FakeAppAnalyticsService({this.fail = false});

  final bool fail;
  final List<RecordedAnalyticsEvent> events = [];

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    if (fail) throw StateError('Analytics unavailable.');
    events.add(RecordedAnalyticsEvent(name, parameters ?? const {}));
  }

  int count(String name) => events.where((event) => event.name == name).length;
}
