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
    LevelNameKeys.level4 => localizations.level4Label,
    LevelNameKeys.level5 => localizations.level5Label,
    LevelNameKeys.level6 => localizations.level6Label,
    LevelNameKeys.level7 => localizations.level7Label,
    LevelNameKeys.level8 => localizations.level8Label,
    LevelNameKeys.level9 => localizations.level9Label,
    LevelNameKeys.level10 => localizations.level10Label,
    LevelNameKeys.level11 => localizations.level11Label,
    LevelNameKeys.level12 => localizations.level12Label,
    _ => throw StateError('Unknown level name key: ${level.nameKey}'),
  };
}
