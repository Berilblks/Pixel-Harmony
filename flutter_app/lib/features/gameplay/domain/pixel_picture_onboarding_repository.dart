abstract interface class PixelPictureOnboardingRepository {
  Future<bool> hasSeenTutorial();
  Future<void> markTutorialSeen();
  Future<bool> hasSeenGradientTutorial();
  Future<void> markGradientTutorialSeen();
}
