abstract interface class DailyClock {
  DateTime now();
}

class SystemDailyClock implements DailyClock {
  const SystemDailyClock();

  @override
  DateTime now() => DateTime.now();
}
