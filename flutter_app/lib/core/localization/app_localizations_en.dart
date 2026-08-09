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
  String get homeWelcome => 'Find calm through color.';

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
}
