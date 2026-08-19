import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/game/levels/chapter_definition.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';

String localizedLevelName(
  AppLocalizations localizations,
  LevelDefinition level,
) {
  if (level.nameKey != LevelNameKeys.numbered) {
    throw StateError('Unknown level name key: ${level.nameKey}');
  }
  return localizations.levelLabel(level.number);
}

String localizedChapterName(
  AppLocalizations localizations,
  ChapterDefinition chapter,
) {
  return switch (chapter.nameKey) {
    'calmStartName' => localizations.calmStartName,
    'oceanName' => localizations.oceanName,
    'forestName' => localizations.forestName,
    'sunsetName' => localizations.sunsetName,
    'lavenderName' => localizations.lavenderName,
    'auroraName' => localizations.auroraName,
    'midnightName' => localizations.midnightName,
    'blossomName' => localizations.blossomName,
    'desertName' => localizations.desertName,
    'northernLightsName' => localizations.northernLightsName,
    _ => throw StateError('Unknown chapter name key: ${chapter.nameKey}'),
  };
}

String localizedChapterDescription(
  AppLocalizations localizations,
  ChapterDefinition chapter,
) {
  return switch (chapter.descriptionKey) {
    'calmStartDescription' => localizations.calmStartDescription,
    'oceanDescription' => localizations.oceanDescription,
    'forestDescription' => localizations.forestDescription,
    'sunsetDescription' => localizations.sunsetDescription,
    'lavenderDescription' => localizations.lavenderDescription,
    'auroraDescription' => localizations.auroraDescription,
    'midnightDescription' => localizations.midnightDescription,
    'blossomDescription' => localizations.blossomDescription,
    'desertDescription' => localizations.desertDescription,
    'northernLightsDescription' => localizations.northernLightsDescription,
    _ =>
      throw StateError(
        'Unknown chapter description key: ${chapter.descriptionKey}',
      ),
  };
}
