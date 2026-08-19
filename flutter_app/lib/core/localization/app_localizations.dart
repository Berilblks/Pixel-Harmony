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
