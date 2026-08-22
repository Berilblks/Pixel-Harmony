import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Pixel Harmony'**
  String get appTitle;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Find calm in color.'**
  String get homeWelcome;

  /// No description provided for @playButton.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playButton;

  /// No description provided for @journeyMode.
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get journeyMode;

  /// No description provided for @dailyPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Daily Puzzle'**
  String get dailyPuzzle;

  /// No description provided for @dailyCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Complete'**
  String get dailyCompleteTitle;

  /// No description provided for @dailyCompleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s harmony is restored.'**
  String get dailyCompleteSubtitle;

  /// No description provided for @endlessMode.
  ///
  /// In en, this message translates to:
  /// **'Endless'**
  String get endlessMode;

  /// No description provided for @continueEndless.
  ///
  /// In en, this message translates to:
  /// **'Continue Endless'**
  String get continueEndless;

  /// No description provided for @puzzleLabel.
  ///
  /// In en, this message translates to:
  /// **'Puzzle {number}'**
  String puzzleLabel(int number);

  /// No description provided for @nextPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Next Puzzle'**
  String get nextPuzzle;

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back Home'**
  String get backHome;

  /// No description provided for @endlessProgressError.
  ///
  /// In en, this message translates to:
  /// **'Endless progress cannot be loaded with this version.'**
  String get endlessProgressError;

  /// No description provided for @resetEndless.
  ///
  /// In en, this message translates to:
  /// **'Reset Endless'**
  String get resetEndless;

  /// No description provided for @gameplayTitle.
  ///
  /// In en, this message translates to:
  /// **'Gameplay'**
  String get gameplayTitle;

  /// No description provided for @completionTitle.
  ///
  /// In en, this message translates to:
  /// **'Harmony Restored'**
  String get completionTitle;

  /// No description provided for @completionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Beautifully done.'**
  String get completionSubtitle;

  /// No description provided for @completionMoves.
  ///
  /// In en, this message translates to:
  /// **'Moves: {count}'**
  String completionMoves(int count);

  /// No description provided for @completionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get completionContinue;

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {number}'**
  String levelLabel(int number);

  /// No description provided for @calmStartName.
  ///
  /// In en, this message translates to:
  /// **'Calm Start'**
  String get calmStartName;

  /// No description provided for @calmStartDescription.
  ///
  /// In en, this message translates to:
  /// **'Begin with simple color harmony.'**
  String get calmStartDescription;

  /// No description provided for @oceanName.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get oceanName;

  /// No description provided for @oceanDescription.
  ///
  /// In en, this message translates to:
  /// **'Flow through cool blue tones.'**
  String get oceanDescription;

  /// No description provided for @forestName.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get forestName;

  /// No description provided for @forestDescription.
  ///
  /// In en, this message translates to:
  /// **'Balance natural greens.'**
  String get forestDescription;

  /// No description provided for @sunsetName.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunsetName;

  /// No description provided for @sunsetDescription.
  ///
  /// In en, this message translates to:
  /// **'Arrange warm fading colors.'**
  String get sunsetDescription;

  /// No description provided for @lavenderName.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get lavenderName;

  /// No description provided for @lavenderDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore softer violet harmony.'**
  String get lavenderDescription;

  /// No description provided for @auroraName.
  ///
  /// In en, this message translates to:
  /// **'Aurora'**
  String get auroraName;

  /// No description provided for @auroraDescription.
  ///
  /// In en, this message translates to:
  /// **'Master the most subtle color transitions.'**
  String get auroraDescription;

  /// No description provided for @midnightName.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get midnightName;

  /// No description provided for @midnightDescription.
  ///
  /// In en, this message translates to:
  /// **'Navigate deep blues and quiet violet light.'**
  String get midnightDescription;

  /// No description provided for @blossomName.
  ///
  /// In en, this message translates to:
  /// **'Blossom'**
  String get blossomName;

  /// No description provided for @blossomDescription.
  ///
  /// In en, this message translates to:
  /// **'Restore a gentle field of petals and blush.'**
  String get blossomDescription;

  /// No description provided for @desertName.
  ///
  /// In en, this message translates to:
  /// **'Desert'**
  String get desertName;

  /// No description provided for @desertDescription.
  ///
  /// In en, this message translates to:
  /// **'Balance warm sand, amber, and terracotta.'**
  String get desertDescription;

  /// No description provided for @northernLightsName.
  ///
  /// In en, this message translates to:
  /// **'Northern Lights'**
  String get northernLightsName;

  /// No description provided for @northernLightsDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete the journey through shifting polar color.'**
  String get northernLightsDescription;

  /// No description provided for @chooseLevel.
  ///
  /// In en, this message translates to:
  /// **'Choose a Level'**
  String get chooseLevel;

  /// No description provided for @boardSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Board Size'**
  String get boardSizeLabel;

  /// No description provided for @levelNotFound.
  ///
  /// In en, this message translates to:
  /// **'Level not found'**
  String get levelNotFound;

  /// No description provided for @backToLevels.
  ///
  /// In en, this message translates to:
  /// **'Back to Levels'**
  String get backToLevels;

  /// No description provided for @completedLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedLabel;

  /// No description provided for @progressLoadError.
  ///
  /// In en, this message translates to:
  /// **'Progress is unavailable. Levels remain playable.'**
  String get progressLoadError;

  /// No description provided for @lockedLabel.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lockedLabel;

  /// No description provided for @lockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Complete the previous level to unlock this one.'**
  String get lockedMessage;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @unlockedLabel.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlockedLabel;

  /// No description provided for @achievementProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get achievementProgressLabel;

  /// No description provided for @achievementsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Achievements are unavailable right now.'**
  String get achievementsLoadError;

  /// No description provided for @achievementProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} / {target}'**
  String achievementProgress(int current, int target);

  /// No description provided for @achievementProgressDays.
  ///
  /// In en, this message translates to:
  /// **'{current} / {target} days'**
  String achievementProgressDays(int current, int target);

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked'**
  String get achievementUnlocked;

  /// No description provided for @achievementUnlockedMultiple.
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked: {title} (+{count} more)'**
  String achievementUnlockedMultiple(String title, int count);

  /// No description provided for @achievementFirstHarmonyTitle.
  ///
  /// In en, this message translates to:
  /// **'First Harmony'**
  String get achievementFirstHarmonyTitle;

  /// No description provided for @achievementFirstHarmonyDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete your first puzzle.'**
  String get achievementFirstHarmonyDescription;

  /// No description provided for @achievementTenHarmoniesTitle.
  ///
  /// In en, this message translates to:
  /// **'Ten Harmonies'**
  String get achievementTenHarmoniesTitle;

  /// No description provided for @achievementTenHarmoniesDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 puzzles.'**
  String get achievementTenHarmoniesDescription;

  /// No description provided for @achievementHundredHarmoniesTitle.
  ///
  /// In en, this message translates to:
  /// **'Hundred Harmonies'**
  String get achievementHundredHarmoniesTitle;

  /// No description provided for @achievementHundredHarmoniesDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete 100 puzzles.'**
  String get achievementHundredHarmoniesDescription;

  /// No description provided for @achievementJourneyBeginsTitle.
  ///
  /// In en, this message translates to:
  /// **'Journey Begins'**
  String get achievementJourneyBeginsTitle;

  /// No description provided for @achievementJourneyBeginsDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 Journey levels.'**
  String get achievementJourneyBeginsDescription;

  /// No description provided for @achievementHalfwayThereTitle.
  ///
  /// In en, this message translates to:
  /// **'Halfway There'**
  String get achievementHalfwayThereTitle;

  /// No description provided for @achievementHalfwayThereDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete 50 Journey levels.'**
  String get achievementHalfwayThereDescription;

  /// No description provided for @achievementJourneyCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Journey Complete'**
  String get achievementJourneyCompleteTitle;

  /// No description provided for @achievementJourneyCompleteDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete all 100 Journey levels.'**
  String get achievementJourneyCompleteDescription;

  /// No description provided for @achievementEndlessExplorerTitle.
  ///
  /// In en, this message translates to:
  /// **'Endless Explorer'**
  String get achievementEndlessExplorerTitle;

  /// No description provided for @achievementEndlessExplorerDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 Endless puzzles.'**
  String get achievementEndlessExplorerDescription;

  /// No description provided for @achievementEndlessWandererTitle.
  ///
  /// In en, this message translates to:
  /// **'Endless Wanderer'**
  String get achievementEndlessWandererTitle;

  /// No description provided for @achievementEndlessWandererDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete 50 Endless puzzles.'**
  String get achievementEndlessWandererDescription;

  /// No description provided for @achievementEndlessDevotionTitle.
  ///
  /// In en, this message translates to:
  /// **'Endless Devotion'**
  String get achievementEndlessDevotionTitle;

  /// No description provided for @achievementEndlessDevotionDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete 100 Endless puzzles.'**
  String get achievementEndlessDevotionDescription;

  /// No description provided for @achievementDailyRhythmTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Rhythm'**
  String get achievementDailyRhythmTitle;

  /// No description provided for @achievementDailyRhythmDescription.
  ///
  /// In en, this message translates to:
  /// **'Reach a 7-day Daily streak.'**
  String get achievementDailyRhythmDescription;

  /// No description provided for @achievementDailyDevotionTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Devotion'**
  String get achievementDailyDevotionTitle;

  /// No description provided for @achievementDailyDevotionDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete 30 Daily puzzles.'**
  String get achievementDailyDevotionDescription;

  /// No description provided for @achievementChapterMasterTitle.
  ///
  /// In en, this message translates to:
  /// **'Chapter Master'**
  String get achievementChapterMasterTitle;

  /// No description provided for @achievementChapterMasterDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete every level in one chapter.'**
  String get achievementChapterMasterDescription;

  /// No description provided for @achievementPerfectJourneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Perfect Journey'**
  String get achievementPerfectJourneyTitle;

  /// No description provided for @achievementPerfectJourneyDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete all 10 Journey chapters.'**
  String get achievementPerfectJourneyDescription;

  /// No description provided for @achievementThousandMovesTitle.
  ///
  /// In en, this message translates to:
  /// **'A Thousand Moves'**
  String get achievementThousandMovesTitle;

  /// No description provided for @achievementThousandMovesDescription.
  ///
  /// In en, this message translates to:
  /// **'Make 1,000 moves in completed puzzles.'**
  String get achievementThousandMovesDescription;

  /// No description provided for @statisticsOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get statisticsOverview;

  /// No description provided for @statisticsModes.
  ///
  /// In en, this message translates to:
  /// **'Modes'**
  String get statisticsModes;

  /// No description provided for @totalPuzzles.
  ///
  /// In en, this message translates to:
  /// **'Total Puzzles'**
  String get totalPuzzles;

  /// No description provided for @totalMoves.
  ///
  /// In en, this message translates to:
  /// **'Total Moves'**
  String get totalMoves;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreak;

  /// No description provided for @statisticsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Statistics are unavailable right now.'**
  String get statisticsLoadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @soundEffectsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffectsLabel;

  /// No description provided for @hapticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get hapticsLabel;

  /// No description provided for @restartLevel.
  ///
  /// In en, this message translates to:
  /// **'Restart Level'**
  String get restartLevel;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// No description provided for @nextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next Level'**
  String get nextLevel;

  /// No description provided for @allLevelsCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'All Levels Complete'**
  String get allLevelsCompleteTitle;

  /// No description provided for @allLevelsCompleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You restored every harmony.'**
  String get allLevelsCompleteSubtitle;

  /// No description provided for @chapterCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Chapter Complete'**
  String get chapterCompleteTitle;

  /// No description provided for @chapterCompleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A new harmony awaits.'**
  String get chapterCompleteSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
