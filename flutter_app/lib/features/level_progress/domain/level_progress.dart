class LevelProgress {
  const LevelProgress({
    required this.levelId,
    required this.completed,
    this.completedAt,
  });

  final String levelId;
  final bool completed;
  final DateTime? completedAt;
}
