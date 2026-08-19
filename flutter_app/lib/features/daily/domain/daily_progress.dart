class DailyProgress {
  const DailyProgress({
    this.lastCompletedDateKey,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalDailyCompleted = 0,
  });

  final String? lastCompletedDateKey;
  final int currentStreak;
  final int longestStreak;
  final int totalDailyCompleted;

  bool isCompleted(String dateKey) => lastCompletedDateKey == dateKey;

  DailyProgress complete(String dateKey) {
    final currentDay = _dayOrdinal(dateKey);
    final previousKey = lastCompletedDateKey;
    if (previousKey == dateKey) return this;
    if (previousKey != null) {
      final previousDay = _dayOrdinal(previousKey);
      if (currentDay < previousDay) return this;
    }
    final consecutive =
        previousKey != null && currentDay == _dayOrdinal(previousKey) + 1;
    final nextStreak = consecutive ? currentStreak + 1 : 1;
    return DailyProgress(
      lastCompletedDateKey: dateKey,
      currentStreak: nextStreak,
      longestStreak: nextStreak > longestStreak ? nextStreak : longestStreak,
      totalDailyCompleted: totalDailyCompleted + 1,
    );
  }

  static int _dayOrdinal(String dateKey) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(dateKey);
    if (match == null) {
      throw FormatException('Invalid Daily date key.', dateKey);
    }
    final date = DateTime.utc(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
    if (formatDate(date) != dateKey) {
      throw FormatException('Invalid calendar date.', dateKey);
    }
    return date.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  }

  static String formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is DailyProgress &&
      other.lastCompletedDateKey == lastCompletedDateKey &&
      other.currentStreak == currentStreak &&
      other.longestStreak == longestStreak &&
      other.totalDailyCompleted == totalDailyCompleted;

  @override
  int get hashCode => Object.hash(
    lastCompletedDateKey,
    currentStreak,
    longestStreak,
    totalDailyCompleted,
  );
}
