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
  String get journeyMode => 'Yolculuk';

  @override
  String get dailyPuzzle => 'Günün Bulmacası';

  @override
  String get dailyCompleteTitle => 'Günün Bulmacası Tamamlandı';

  @override
  String get dailyCompleteSubtitle => 'Bugünün uyumu tamamlandı.';

  @override
  String get endlessMode => 'Sonsuz';

  @override
  String get continueEndless => 'Sonsuz Moda Devam Et';

  @override
  String puzzleLabel(int number) {
    return 'Bulmaca $number';
  }

  @override
  String get nextPuzzle => 'Sonraki Bulmaca';

  @override
  String get backHome => 'Ana Sayfaya Dön';

  @override
  String get endlessProgressError =>
      'Sonsuz mod ilerlemesi bu sürümle yüklenemiyor.';

  @override
  String get resetEndless => 'Sonsuz Modu Sıfırla';

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
  String levelLabel(int number) {
    return 'Seviye $number';
  }

  @override
  String get calmStartName => 'Sakin Başlangıç';

  @override
  String get calmStartDescription => 'Basit renk uyumlarıyla başla.';

  @override
  String get oceanName => 'Okyanus';

  @override
  String get oceanDescription => 'Serin mavi tonların akışına katıl.';

  @override
  String get forestName => 'Orman';

  @override
  String get forestDescription => 'Doğal yeşilleri dengele.';

  @override
  String get sunsetName => 'Gün Batımı';

  @override
  String get sunsetDescription => 'Sıcak ve solgun renkleri düzenle.';

  @override
  String get lavenderName => 'Lavanta';

  @override
  String get lavenderDescription => 'Yumuşak mor tonlarının uyumunu keşfet.';

  @override
  String get auroraName => 'Kutup Işıkları';

  @override
  String get auroraDescription => 'En ince renk geçişlerinde ustalaş.';

  @override
  String get midnightName => 'Gece Yarısı';

  @override
  String get midnightDescription =>
      'Derin maviler ve sakin mor ışıklar arasında ilerle.';

  @override
  String get blossomName => 'Çiçeklenme';

  @override
  String get blossomDescription =>
      'Yumuşak çiçek ve pembe tonlarının uyumunu yeniden kur.';

  @override
  String get desertName => 'Çöl';

  @override
  String get desertDescription =>
      'Sıcak kum, kehribar ve terakota tonlarını dengele.';

  @override
  String get northernLightsName => 'Kuzey Işıkları';

  @override
  String get northernLightsDescription =>
      'Değişen kutup renkleriyle yolculuğu tamamla.';

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
  String get hint => 'İpucu';

  @override
  String get nextLevel => 'Sonraki Seviye';

  @override
  String get allLevelsCompleteTitle => 'Tüm Seviyeler Tamamlandı';

  @override
  String get allLevelsCompleteSubtitle => 'Tüm uyumları yeniden oluşturdun.';
}
