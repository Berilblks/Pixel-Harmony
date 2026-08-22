import 'package:pixel_harmony/game/levels/chapter_definition.dart';

class ChapterCompletionEvaluator {
  const ChapterCompletionEvaluator({required this.chapters});

  final List<ChapterDefinition> chapters;

  ChapterDefinition? newlyCompletedChapter({
    required String completedLevelId,
    required Set<String> previouslyCompletedLevelIds,
  }) {
    if (previouslyCompletedLevelIds.contains(completedLevelId)) return null;

    final matching = chapters.where(
      (chapter) => chapter.levelIds.contains(completedLevelId),
    );
    if (matching.isEmpty) return null;

    final chapter = matching.single;
    final completedAfter = {...previouslyCompletedLevelIds, completedLevelId};
    return chapter.levelIds.every(completedAfter.contains) ? chapter : null;
  }

  bool isChapterCompleted(
    ChapterDefinition chapter,
    Set<String> completedLevelIds,
  ) {
    return chapter.levelIds.every(completedLevelIds.contains);
  }
}
