import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/game/levels/chapter_completion_evaluator.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';

void main() {
  final evaluator = ChapterCompletionEvaluator(chapters: LevelCatalog.chapters);

  test('only the final remaining level completes a chapter', () {
    final calmStart = LevelCatalog.chapters.first;

    expect(
      evaluator.newlyCompletedChapter(
        completedLevelId: 'level_009',
        previouslyCompletedLevelIds: calmStart.levelIds.take(8).toSet(),
      ),
      isNull,
    );
    expect(
      evaluator.newlyCompletedChapter(
        completedLevelId: 'level_010',
        previouslyCompletedLevelIds: calmStart.levelIds.take(9).toSet(),
      ),
      same(calmStart),
    );
  });

  test('replaying a completed chapter level does not emit completion', () {
    expect(
      evaluator.newlyCompletedChapter(
        completedLevelId: 'level_010',
        previouslyCompletedLevelIds:
            LevelCatalog.chapters.first.levelIds.toSet(),
      ),
      isNull,
    );
  });

  test('Ocean, Desert, and Northern Lights boundaries are detected', () {
    for (final chapter in [
      LevelCatalog.chapters[1],
      LevelCatalog.chapters[8],
      LevelCatalog.chapters[9],
    ]) {
      expect(
        evaluator
            .newlyCompletedChapter(
              completedLevelId: chapter.levelIds.last,
              previouslyCompletedLevelIds: chapter.levelIds.take(9).toSet(),
            )
            ?.id,
        chapter.id,
      );
    }
  });
}
