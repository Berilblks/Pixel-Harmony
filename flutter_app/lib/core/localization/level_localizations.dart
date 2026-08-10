import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';

String localizedLevelName(
  AppLocalizations localizations,
  LevelDefinition level,
) {
  return switch (level.nameKey) {
    LevelNameKeys.level1 => localizations.level1Label,
    LevelNameKeys.level2 => localizations.level2Label,
    LevelNameKeys.level3 => localizations.level3Label,
    _ => throw StateError('Unknown level name key: ${level.nameKey}'),
  };
}
