import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/features/achievements/domain/achievement_definition.dart';

String localizedAchievementTitle(
  AppLocalizations localizations,
  AchievementDefinition definition,
) => switch (definition.id) {
  'first_harmony' => localizations.achievementFirstHarmonyTitle,
  'ten_harmonies' => localizations.achievementTenHarmoniesTitle,
  'hundred_harmonies' => localizations.achievementHundredHarmoniesTitle,
  'journey_begins' => localizations.achievementJourneyBeginsTitle,
  'halfway_there' => localizations.achievementHalfwayThereTitle,
  'journey_complete' => localizations.achievementJourneyCompleteTitle,
  'endless_explorer' => localizations.achievementEndlessExplorerTitle,
  'endless_wanderer' => localizations.achievementEndlessWandererTitle,
  'endless_devotion' => localizations.achievementEndlessDevotionTitle,
  'daily_rhythm' => localizations.achievementDailyRhythmTitle,
  'daily_devotion' => localizations.achievementDailyDevotionTitle,
  'chapter_master' => localizations.achievementChapterMasterTitle,
  'perfect_journey' => localizations.achievementPerfectJourneyTitle,
  'thousand_moves' => localizations.achievementThousandMovesTitle,
  _ => throw ArgumentError.value(definition.id, 'definition'),
};

String localizedAchievementDescription(
  AppLocalizations localizations,
  AchievementDefinition definition,
) => switch (definition.id) {
  'first_harmony' => localizations.achievementFirstHarmonyDescription,
  'ten_harmonies' => localizations.achievementTenHarmoniesDescription,
  'hundred_harmonies' => localizations.achievementHundredHarmoniesDescription,
  'journey_begins' => localizations.achievementJourneyBeginsDescription,
  'halfway_there' => localizations.achievementHalfwayThereDescription,
  'journey_complete' => localizations.achievementJourneyCompleteDescription,
  'endless_explorer' => localizations.achievementEndlessExplorerDescription,
  'endless_wanderer' => localizations.achievementEndlessWandererDescription,
  'endless_devotion' => localizations.achievementEndlessDevotionDescription,
  'daily_rhythm' => localizations.achievementDailyRhythmDescription,
  'daily_devotion' => localizations.achievementDailyDevotionDescription,
  'chapter_master' => localizations.achievementChapterMasterDescription,
  'perfect_journey' => localizations.achievementPerfectJourneyDescription,
  'thousand_moves' => localizations.achievementThousandMovesDescription,
  _ => throw ArgumentError.value(definition.id, 'definition'),
};
