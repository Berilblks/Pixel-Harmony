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
  String get continuingJourneyName => 'Devam Eden Yolculuk';

  @override
  String get continuingJourneyDescription =>
      'Yeni bir deterministik uyum seni bekliyor.';

  @override
  String get dailyPuzzle => 'Günün Bulmacası';

  @override
  String get dailyCompleteTitle => 'Günün Bulmacası Tamamlandı';

  @override
  String get dailyCompleteSubtitle => 'Bugünün uyumu tamamlandı.';

  @override
  String get endlessMode => 'Serbest Oyun';

  @override
  String get continueEndless => 'Serbest Oyuna Devam Et';

  @override
  String get continueJourney => 'Oyna';

  @override
  String journeyProgressLevel(int number) {
    return 'Seviye $number';
  }

  @override
  String get todayPuzzleReady => 'Bugünkü bulmaca hazır';

  @override
  String get completedToday => 'Bugün tamamlandı';

  @override
  String dailyStreakDays(int count) {
    return '$count günlük seri';
  }

  @override
  String get freePlayDescription =>
      'İlerleme baskısı olmadan istediğin gibi oyna.';

  @override
  String get puzzleType => 'Bulmaca Türü';

  @override
  String get gradientPuzzle => 'Renk Sıralama';

  @override
  String get pixelColoringPuzzle => 'Pixel Boyama';

  @override
  String get mixedPuzzle => 'Karışık';

  @override
  String get difficulty => 'Zorluk';

  @override
  String get difficultyRelaxed => 'Rahat';

  @override
  String get difficultyNormal => 'Normal';

  @override
  String get difficultyHard => 'Zor';

  @override
  String get difficultyExpert => 'Uzman';

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
      'Serbest Oyun ilerlemesi bu sürümle yüklenemiyor.';

  @override
  String get resetEndless => 'Serbest Oyunu Sıfırla';

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
  String get chooseLevel => 'Bölümler';

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
  String get statisticsTitle => 'İstatistikler';

  @override
  String get achievementsTitle => 'Başarımlar';

  @override
  String get unlockedLabel => 'Açıldı';

  @override
  String get achievementProgressLabel => 'İlerleme';

  @override
  String get achievementsLoadError => 'Başarımlara şu anda ulaşılamıyor.';

  @override
  String achievementProgress(int current, int target) {
    return '$current / $target';
  }

  @override
  String achievementProgressDays(int current, int target) {
    return '$current / $target gün';
  }

  @override
  String get achievementUnlocked => 'Başarım Açıldı';

  @override
  String achievementUnlockedMultiple(String title, int count) {
    return 'Başarım Açıldı: $title (+$count tane daha)';
  }

  @override
  String get achievementFirstHarmonyTitle => 'İlk Uyum';

  @override
  String get achievementFirstHarmonyDescription => 'İlk bulmacanı tamamla.';

  @override
  String get achievementTenHarmoniesTitle => 'On Uyum';

  @override
  String get achievementTenHarmoniesDescription => '10 bulmaca tamamla.';

  @override
  String get achievementHundredHarmoniesTitle => 'Yüz Uyum';

  @override
  String get achievementHundredHarmoniesDescription => '100 bulmaca tamamla.';

  @override
  String get achievementJourneyBeginsTitle => 'Yolculuk Başlıyor';

  @override
  String get achievementJourneyBeginsDescription =>
      '10 Yolculuk seviyesi tamamla.';

  @override
  String get achievementHalfwayThereTitle => 'Yolun Yarısı';

  @override
  String get achievementHalfwayThereDescription =>
      '50 Yolculuk seviyesi tamamla.';

  @override
  String get achievementJourneyCompleteTitle => 'Yüz Uyum';

  @override
  String get achievementJourneyCompleteDescription =>
      '100 seviyelik Yolculuk kilometre taşına ulaş.';

  @override
  String get achievementEndlessExplorerTitle => 'Sonsuz Kâşif';

  @override
  String get achievementEndlessExplorerDescription =>
      '10 Sonsuz bulmaca tamamla.';

  @override
  String get achievementEndlessWandererTitle => 'Sonsuz Gezgin';

  @override
  String get achievementEndlessWandererDescription =>
      '50 Sonsuz bulmaca tamamla.';

  @override
  String get achievementEndlessDevotionTitle => 'Sonsuz Bağlılık';

  @override
  String get achievementEndlessDevotionDescription =>
      '100 Sonsuz bulmaca tamamla.';

  @override
  String get achievementDailyRhythmTitle => 'Günlük Ritim';

  @override
  String get achievementDailyRhythmDescription => '7 günlük seri yakala.';

  @override
  String get achievementDailyDevotionTitle => 'Günlük Bağlılık';

  @override
  String get achievementDailyDevotionDescription =>
      '30 Günlük bulmaca tamamla.';

  @override
  String get achievementChapterMasterTitle => 'Yolculuk 10';

  @override
  String get achievementChapterMasterDescription =>
      '10 Yolculuk seviyesini tamamla.';

  @override
  String get achievementPerfectJourneyTitle => 'Yolculuk 100';

  @override
  String get achievementPerfectJourneyDescription =>
      '100 Yolculuk seviyesini tamamla.';

  @override
  String get achievementThousandMovesTitle => 'Bin Hamle';

  @override
  String get achievementThousandMovesDescription =>
      'Tamamlanan bulmacalarda 1.000 hamle yap.';

  @override
  String get statisticsOverview => 'Genel Bakış';

  @override
  String get statisticsModes => 'Modlar';

  @override
  String get totalPuzzles => 'Toplam Bulmaca';

  @override
  String get totalMoves => 'Toplam Hamle';

  @override
  String get currentStreak => 'Mevcut Seri';

  @override
  String get bestStreak => 'En İyi Seri';

  @override
  String get statisticsLoadError => 'İstatistiklere şu anda ulaşılamıyor.';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get soundEffectsLabel => 'Ses Efektleri';

  @override
  String get hapticsLabel => 'Titreşim';

  @override
  String get restartLevel => 'Seviyeyi Yeniden Başlat';

  @override
  String get hint => 'İpucu';

  @override
  String get targetOrder => 'Hedef';

  @override
  String get gradientInstruction =>
      'Aynı rengin tonlarını koyudan açığa doğru sırala.';

  @override
  String get gradientCompactInstruction => 'Koyudan açığa sırala';

  @override
  String get pixelPictureLabel => 'Piksel Boyama';

  @override
  String get pixelPictureInstruction => 'Piksel Boyama';

  @override
  String get pixelPictureTransitionInstruction => 'Numaralı pikselleri boya.';

  @override
  String get pixelPictureTutorialTitle => 'Bu bölüm farklı!';

  @override
  String get pixelPictureTutorialBody =>
      'Bir piksele, sonra diğerine dokun; yerlerini değiştirerek resmi tamamla.';

  @override
  String get pixelPictureTutorialDemo =>
      'Bir pikselin eşleşen hücreye doğru hareketini izle.';

  @override
  String get pixelPictureTutorialTry =>
      'Şimdi sen dene! Doğru pikseller yerlerine oturur.';

  @override
  String get pixelPictureHint => 'Bir pikseli boya';

  @override
  String get resetZoom => 'Yakınlaştırmayı sıfırla';

  @override
  String pixelPictureCreateTarget(String figure) {
    return '$figure RESMİNİ BOYA';
  }

  @override
  String get pixelPicturePlayInstruction =>
      'Numaralı hücreleri boyayarak figürü tamamla.';

  @override
  String get pixelPictureSwapInstruction =>
      'Bir renk seç, sonra eşleşen numaraları boya.';

  @override
  String get pixelFigureHeart => 'Kalp';

  @override
  String get pixelFigureStar => 'Yıldız';

  @override
  String get pixelFigureSmiley => 'Gülen Yüz';

  @override
  String get pixelFigureFlower => 'Çiçek';

  @override
  String get pixelFigureCherries => 'Kiraz';

  @override
  String get pixelFigureMushroom => 'Mantar';

  @override
  String get pixelFigureFish => 'Balık';

  @override
  String get pixelFigureButterfly => 'Kelebek';

  @override
  String get pixelFigureCat => 'Kedi Yüzü';

  @override
  String get pixelFigureSun => 'Güneş';

  @override
  String get pixelFigureMoon => 'Ay';

  @override
  String get pixelFigureCloud => 'Bulut';

  @override
  String get pixelFigureHouse => 'Ev';

  @override
  String get pixelFigureTree => 'Ağaç';

  @override
  String get pixelFigureApple => 'Elma';

  @override
  String get pixelFigureSunset => 'Gün Batımı';

  @override
  String get pixelFigureRainbow => 'Gökkuşağı';

  @override
  String get pixelFigureLightning => 'Şimşek';

  @override
  String get pixelFigureDiamond => 'Elmas';

  @override
  String get pixelFigureTulip => 'Lale';

  @override
  String get pixelFigureCactus => 'Kaktüs';

  @override
  String get pixelFigureLeaf => 'Yaprak';

  @override
  String get pixelFigureStrawberry => 'Çilek';

  @override
  String get pixelFigureWatermelon => 'Karpuz';

  @override
  String get pixelFigureRabbit => 'Tavşan';

  @override
  String get pixelFigureBee => 'Arı';

  @override
  String get pixelFigureLadybug => 'Uğur Böceği';

  @override
  String get pixelFigureTurtle => 'Kaplumbağa';

  @override
  String get pixelFigurePenguin => 'Penguen';

  @override
  String get pixelFigureGift => 'Hediye Kutusu';

  @override
  String get pixelFigureCupcake => 'Kapkek';

  @override
  String get pixelFigureRocket => 'Roket';

  @override
  String get pixelFigureMountainSunset => 'Dağ Gün Batımı';

  @override
  String get continueLabel => 'Devam Et';

  @override
  String get skip => 'Atla';

  @override
  String get gotIt => 'Anladım';

  @override
  String get startPuzzle => 'Bulmacayı Başlat';

  @override
  String get nextLevel => 'Sonraki Seviye';

  @override
  String get allLevelsCompleteTitle => 'Tüm Seviyeler Tamamlandı';

  @override
  String get allLevelsCompleteSubtitle => 'Tüm uyumları yeniden oluşturdun.';

  @override
  String get chapterCompleteTitle => 'Bölüm Tamamlandı';

  @override
  String get chapterCompleteSubtitle => 'Yeni bir uyum seni bekliyor.';
}
