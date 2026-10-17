import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/features/gameplay/data/shared_preferences_pixel_picture_onboarding_repository.dart';
import 'package:pixel_harmony/features/gameplay/domain/pixel_picture_onboarding_repository.dart';

final pixelPictureOnboardingRepositoryProvider =
    Provider<PixelPictureOnboardingRepository>(
      (ref) => SharedPreferencesPixelPictureOnboardingRepository(),
    );

final gradientTutorialSeenProvider =
    AsyncNotifierProvider<GradientTutorialSeenController, bool>(
      GradientTutorialSeenController.new,
    );

class GradientTutorialSeenController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() =>
      ref
          .read(pixelPictureOnboardingRepositoryProvider)
          .hasSeenGradientTutorial();

  Future<void> acknowledge() async {
    await ref
        .read(pixelPictureOnboardingRepositoryProvider)
        .markGradientTutorialSeen();
    state = const AsyncData(true);
  }
}
