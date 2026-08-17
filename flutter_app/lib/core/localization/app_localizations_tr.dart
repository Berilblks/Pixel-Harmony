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
  String get homeWelcome => 'Renklerin içinde huzuru bul.';

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

  @override
  String get level4Label => 'Seviye 4';

  @override
  String get level5Label => 'Seviye 5';

  @override
  String get level6Label => 'Seviye 6';

  @override
  String get level7Label => 'Seviye 7';

  @override
  String get level8Label => 'Seviye 8';

  @override
  String get level9Label => 'Seviye 9';

  @override
  String get level10Label => 'Seviye 10';

  @override
  String get level11Label => 'Seviye 11';

  @override
  String get level12Label => 'Seviye 12';

  @override
  String get chooseLevel => 'Bir Seviye Seç';

  @override
  String get boardSizeLabel => 'Tahta Boyutu';

  @override
  String get levelNotFound => 'Seviye bulunamadı';

  @override
  String get backToLevels => 'Seviyelere Dön';

  @override
  String get completedLabel => 'Tamamlandı';

  @override
  String get progressLoadError =>
      'İlerleme bilgisi kullanılamıyor. Seviyeleri oynamaya devam edebilirsin.';

  @override
  String get lockedLabel => 'Kilitli';

  @override
  String get lockedMessage => 'Bu seviyeyi açmak için önceki seviyeyi tamamla.';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get soundEffectsLabel => 'Ses Efektleri';

  @override
  String get hapticsLabel => 'Titreşim';

  @override
  String get restartLevel => 'Seviyeyi Yeniden Başlat';

  @override
  String get nextLevel => 'Sonraki Seviye';

  @override
  String get allLevelsCompleteTitle => 'Tüm Seviyeler Tamamlandı';

  @override
  String get allLevelsCompleteSubtitle => 'Tüm uyumları yeniden oluşturdun.';
}
