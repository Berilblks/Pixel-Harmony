import 'package:pixel_harmony/features/gameplay/domain/pixel_picture_onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesPixelPictureOnboardingRepository
    implements PixelPictureOnboardingRepository {
  static const _pixelKey = 'pixel_picture_tutorial_seen';
  static const _gradientKey = 'gradient_tutorial_seen';

  @override
  Future<bool> hasSeenTutorial() async =>
      (await SharedPreferences.getInstance()).getBool(_pixelKey) ?? false;

  @override
  Future<void> markTutorialSeen() async =>
      (await SharedPreferences.getInstance()).setBool(_pixelKey, true);

  @override
  Future<bool> hasSeenGradientTutorial() async =>
      (await SharedPreferences.getInstance()).getBool(_gradientKey) ?? false;

  @override
  Future<void> markGradientTutorialSeen() async =>
      (await SharedPreferences.getInstance()).setBool(_gradientKey, true);
}
