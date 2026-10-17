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
  String get continuingJourneyName => 'Continuing Journey';

  @override
  String get continuingJourneyDescription =>
      'A new deterministic harmony awaits.';

  @override
  String get dailyPuzzle => 'Daily Puzzle';

  @override
  String get dailyCompleteTitle => 'Daily Complete';

  @override
  String get dailyCompleteSubtitle => 'Today\'s harmony is restored.';

  @override
  String get endlessMode => 'Free Play';

  @override
  String get continueEndless => 'Continue Free Play';

  @override
  String get continueJourney => 'Play';

  @override
  String journeyProgressLevel(int number) {
    return 'Level $number';
  }

  @override
  String get todayPuzzleReady => 'Today\'s puzzle is ready';

  @override
  String get completedToday => 'Completed today';

  @override
  String dailyStreakDays(int count) {
    return '$count day streak';
  }

  @override
  String get freePlayDescription =>
      'Play your way, without progression pressure.';

  @override
  String get puzzleType => 'Puzzle Type';

  @override
  String get gradientPuzzle => 'Gradient';

  @override
  String get pixelColoringPuzzle => 'Pixel Coloring';

  @override
  String get mixedPuzzle => 'Mixed';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get difficultyRelaxed => 'Relaxed';

  @override
  String get difficultyNormal => 'Normal';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get difficultyExpert => 'Expert';

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
      'Free Play progress cannot be loaded with this version.';

  @override
  String get resetEndless => 'Reset Free Play';

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
  String get midnightName => 'Midnight';

  @override
  String get midnightDescription =>
      'Navigate deep blues and quiet violet light.';

  @override
  String get blossomName => 'Blossom';

  @override
  String get blossomDescription =>
      'Restore a gentle field of petals and blush.';

  @override
  String get desertName => 'Desert';

  @override
  String get desertDescription => 'Balance warm sand, amber, and terracotta.';

  @override
  String get northernLightsName => 'Northern Lights';

  @override
  String get northernLightsDescription =>
      'Complete the journey through shifting polar color.';

  @override
  String get chooseLevel => 'Levels';

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
  String get statisticsTitle => 'Statistics';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get unlockedLabel => 'Unlocked';

  @override
  String get achievementProgressLabel => 'Progress';

  @override
  String get achievementsLoadError => 'Achievements are unavailable right now.';

  @override
  String achievementProgress(int current, int target) {
    return '$current / $target';
  }

  @override
  String achievementProgressDays(int current, int target) {
    return '$current / $target days';
  }

  @override
  String get achievementUnlocked => 'Achievement Unlocked';

  @override
  String achievementUnlockedMultiple(String title, int count) {
    return 'Achievement Unlocked: $title (+$count more)';
  }

  @override
  String get achievementFirstHarmonyTitle => 'First Harmony';

  @override
  String get achievementFirstHarmonyDescription =>
      'Complete your first puzzle.';

  @override
  String get achievementTenHarmoniesTitle => 'Ten Harmonies';

  @override
  String get achievementTenHarmoniesDescription => 'Complete 10 puzzles.';

  @override
  String get achievementHundredHarmoniesTitle => 'Hundred Harmonies';

  @override
  String get achievementHundredHarmoniesDescription => 'Complete 100 puzzles.';

  @override
  String get achievementJourneyBeginsTitle => 'Journey Begins';

  @override
  String get achievementJourneyBeginsDescription =>
      'Complete 10 Journey levels.';

  @override
  String get achievementHalfwayThereTitle => 'Halfway There';

  @override
  String get achievementHalfwayThereDescription =>
      'Complete 50 Journey levels.';

  @override
  String get achievementJourneyCompleteTitle => 'A Century of Harmony';

  @override
  String get achievementJourneyCompleteDescription =>
      'Reach the 100-level Journey milestone.';

  @override
  String get achievementEndlessExplorerTitle => 'Endless Explorer';

  @override
  String get achievementEndlessExplorerDescription =>
      'Complete 10 Endless puzzles.';

  @override
  String get achievementEndlessWandererTitle => 'Endless Wanderer';

  @override
  String get achievementEndlessWandererDescription =>
      'Complete 50 Endless puzzles.';

  @override
  String get achievementEndlessDevotionTitle => 'Endless Devotion';

  @override
  String get achievementEndlessDevotionDescription =>
      'Complete 100 Endless puzzles.';

  @override
  String get achievementDailyRhythmTitle => 'Daily Rhythm';

  @override
  String get achievementDailyRhythmDescription => 'Reach a 7-day Daily streak.';

  @override
  String get achievementDailyDevotionTitle => 'Daily Devotion';

  @override
  String get achievementDailyDevotionDescription =>
      'Complete 30 Daily puzzles.';

  @override
  String get achievementChapterMasterTitle => 'Journey 10';

  @override
  String get achievementChapterMasterDescription =>
      'Complete 10 Journey levels.';

  @override
  String get achievementPerfectJourneyTitle => 'Journey 100';

  @override
  String get achievementPerfectJourneyDescription =>
      'Complete 100 Journey levels.';

  @override
  String get achievementThousandMovesTitle => 'A Thousand Moves';

  @override
  String get achievementThousandMovesDescription =>
      'Make 1,000 moves in completed puzzles.';

  @override
  String get statisticsOverview => 'Overview';

  @override
  String get statisticsModes => 'Modes';

  @override
  String get totalPuzzles => 'Total Puzzles';

  @override
  String get totalMoves => 'Total Moves';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get bestStreak => 'Best Streak';

  @override
  String get statisticsLoadError => 'Statistics are unavailable right now.';

  @override
  String get retry => 'Retry';

  @override
  String get soundEffectsLabel => 'Sound Effects';

  @override
  String get hapticsLabel => 'Haptics';

  @override
  String get restartLevel => 'Restart Level';

  @override
  String get hint => 'Hint';

  @override
  String get targetOrder => 'Target';

  @override
  String get gradientInstruction =>
      'Arrange shades of the same color from dark to light.';

  @override
  String get gradientCompactInstruction => 'Arrange dark to light';

  @override
  String get pixelPictureLabel => 'Pixel Coloring';

  @override
  String get pixelPictureInstruction => 'Pixel Coloring';

  @override
  String get pixelPictureTransitionInstruction => 'Color the numbered pixels.';

  @override
  String get pixelPictureTutorialTitle => 'This puzzle is different!';

  @override
  String get pixelPictureTutorialBody =>
      'Tap one pixel, then another, to swap them and complete the picture.';

  @override
  String get pixelPictureTutorialDemo =>
      'Watch one pixel move toward its matching cell.';

  @override
  String get pixelPictureTutorialTry =>
      'Now you try! Correct pixels settle into place.';

  @override
  String get pixelPictureHint => 'Color one pixel';

  @override
  String get resetZoom => 'Reset zoom';

  @override
  String pixelPictureCreateTarget(String figure) {
    return 'COLOR THE $figure';
  }

  @override
  String get pixelPicturePlayInstruction =>
      'Color the numbered cells to complete the figure.';

  @override
  String get pixelPictureSwapInstruction =>
      'Choose a color, then paint the matching numbers.';

  @override
  String get pixelFigureHeart => 'Heart';

  @override
  String get pixelFigureStar => 'Star';

  @override
  String get pixelFigureSmiley => 'Smiley';

  @override
  String get pixelFigureFlower => 'Flower';

  @override
  String get pixelFigureCherries => 'Cherries';

  @override
  String get pixelFigureMushroom => 'Mushroom';

  @override
  String get pixelFigureFish => 'Fish';

  @override
  String get pixelFigureButterfly => 'Butterfly';

  @override
  String get pixelFigureCat => 'Cat Face';

  @override
  String get pixelFigureSun => 'Sun';

  @override
  String get pixelFigureMoon => 'Moon';

  @override
  String get pixelFigureCloud => 'Cloud';

  @override
  String get pixelFigureHouse => 'House';

  @override
  String get pixelFigureTree => 'Tree';

  @override
  String get pixelFigureApple => 'Apple';

  @override
  String get pixelFigureSunset => 'Sunset';

  @override
  String get pixelFigureRainbow => 'Rainbow';

  @override
  String get pixelFigureLightning => 'Lightning';

  @override
  String get pixelFigureDiamond => 'Diamond';

  @override
  String get pixelFigureTulip => 'Tulip';

  @override
  String get pixelFigureCactus => 'Cactus';

  @override
  String get pixelFigureLeaf => 'Leaf';

  @override
  String get pixelFigureStrawberry => 'Strawberry';

  @override
  String get pixelFigureWatermelon => 'Watermelon';

  @override
  String get pixelFigureRabbit => 'Rabbit';

  @override
  String get pixelFigureBee => 'Bee';

  @override
  String get pixelFigureLadybug => 'Ladybug';

  @override
  String get pixelFigureTurtle => 'Turtle';

  @override
  String get pixelFigurePenguin => 'Penguin';

  @override
  String get pixelFigureGift => 'Gift Box';

  @override
  String get pixelFigureCupcake => 'Cupcake';

  @override
  String get pixelFigureRocket => 'Rocket';

  @override
  String get pixelFigureMountainSunset => 'Mountain Sunset';

  @override
  String get continueLabel => 'Continue';

  @override
  String get skip => 'Skip';

  @override
  String get gotIt => 'Got it';

  @override
  String get startPuzzle => 'Start Puzzle';

  @override
  String get nextLevel => 'Next Level';

  @override
  String get allLevelsCompleteTitle => 'All Levels Complete';

  @override
  String get allLevelsCompleteSubtitle => 'You restored every harmony.';

  @override
  String get chapterCompleteTitle => 'Chapter Complete';

  @override
  String get chapterCompleteSubtitle => 'A new harmony awaits.';
}
