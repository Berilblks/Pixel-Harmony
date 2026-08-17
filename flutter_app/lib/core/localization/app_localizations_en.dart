// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pixel Harmony';

  @override
  String get homeWelcome => 'Find calm in color.';

  @override
  String get playButton => 'Play';

  @override
  String get gameplayTitle => 'Gameplay';

  @override
  String get completionTitle => 'Harmony Restored';

  @override
  String get completionSubtitle => 'Beautifully done.';

  @override
  String completionMoves(int count) {
    return 'Moves: $count';
  }

  @override
  String get completionContinue => 'Continue';

  @override
  String get level1Label => 'Level 1';

  @override
  String get level2Label => 'Level 2';

  @override
  String get level3Label => 'Level 3';

  @override
  String get level4Label => 'Level 4';

  @override
  String get level5Label => 'Level 5';

  @override
  String get level6Label => 'Level 6';

  @override
  String get level7Label => 'Level 7';

  @override
  String get level8Label => 'Level 8';

  @override
  String get level9Label => 'Level 9';

  @override
  String get level10Label => 'Level 10';

  @override
  String get level11Label => 'Level 11';

  @override
  String get level12Label => 'Level 12';

  @override
  String get chooseLevel => 'Choose a Level';

  @override
  String get boardSizeLabel => 'Board Size';

  @override
  String get levelNotFound => 'Level not found';

  @override
  String get backToLevels => 'Back to Levels';

  @override
  String get completedLabel => 'Completed';

  @override
  String get progressLoadError =>
      'Progress is unavailable. Levels remain playable.';

  @override
  String get lockedLabel => 'Locked';

  @override
  String get lockedMessage => 'Complete the previous level to unlock this one.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get soundEffectsLabel => 'Sound Effects';

  @override
  String get hapticsLabel => 'Haptics';

  @override
  String get restartLevel => 'Restart Level';

  @override
  String get nextLevel => 'Next Level';

  @override
  String get allLevelsCompleteTitle => 'All Levels Complete';

  @override
  String get allLevelsCompleteSubtitle => 'You restored every harmony.';
}
