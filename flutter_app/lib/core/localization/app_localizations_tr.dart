// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Pixel Harmony';

  @override
  String get homeWelcome => 'Renklerle huzur bul.';

  @override
  String get playButton => 'Oyna';

  @override
  String get gameplayTitle => 'Oyun';

  @override
  String get completionTitle => 'Uyum Tamamlandı';

  @override
  String get completionSubtitle => 'Harika tamamladın.';

  @override
  String completionMoves(int count) {
    return 'Hamle: $count';
  }

  @override
  String get completionContinue => 'Devam Et';

  @override
  String get level1Label => 'Seviye 1';

  @override
  String get level2Label => 'Seviye 2';

  @override
  String get level3Label => 'Seviye 3';
}
