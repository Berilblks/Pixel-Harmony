import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_harmony/features/gameplay/data/shared_preferences_pixel_picture_onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Pixel Picture tutorial acknowledgement persists', () async {
    final repository = SharedPreferencesPixelPictureOnboardingRepository();
    expect(await repository.hasSeenTutorial(), isFalse);

    await repository.markTutorialSeen();

    final recreated = SharedPreferencesPixelPictureOnboardingRepository();
    expect(await recreated.hasSeenTutorial(), isTrue);
  });

  test('Gradient tutorial acknowledgement persists independently', () async {
    final repository = SharedPreferencesPixelPictureOnboardingRepository();
    expect(await repository.hasSeenGradientTutorial(), isFalse);

    await repository.markGradientTutorialSeen();

    final recreated = SharedPreferencesPixelPictureOnboardingRepository();
    expect(await recreated.hasSeenGradientTutorial(), isTrue);
    expect(await recreated.hasSeenTutorial(), isFalse);
  });
}
