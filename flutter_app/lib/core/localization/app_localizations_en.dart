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
  String get journeyMode => 'Journey';

  @override
  String get endlessMode => 'Endless';

  @override
  String get continueEndless => 'Continue Endless';

  @override
  String puzzleLabel(int number) {
    return 'Puzzle $number';
  }

  @override
  String get nextPuzzle => 'Next Puzzle';

  @override
  String get backHome => 'Back Home';

  @override
  String get endlessProgressError =>
      'Endless progress cannot be loaded with this version.';

  @override
  String get resetEndless => 'Reset Endless';

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
  String levelLabel(int number) {
    return 'Level $number';
  }

  @override
  String get calmStartName => 'Calm Start';

  @override
  String get calmStartDescription => 'Begin with simple color harmony.';

  @override
  String get oceanName => 'Ocean';

  @override
  String get oceanDescription => 'Flow through cool blue tones.';

  @override
  String get forestName => 'Forest';

  @override
  String get forestDescription => 'Balance natural greens.';

  @override
  String get sunsetName => 'Sunset';

  @override
  String get sunsetDescription => 'Arrange warm fading colors.';

  @override
  String get lavenderName => 'Lavender';

  @override
  String get lavenderDescription => 'Explore softer violet harmony.';

  @override
  String get auroraName => 'Aurora';

  @override
  String get auroraDescription => 'Master the most subtle color transitions.';

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
  String get hint => 'Hint';

  @override
  String get nextLevel => 'Next Level';

  @override
  String get allLevelsCompleteTitle => 'All Levels Complete';

  @override
  String get allLevelsCompleteSubtitle => 'You restored every harmony.';
}
