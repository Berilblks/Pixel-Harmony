# Firebase Analytics and Crashlytics

Pixel Harmony uses Firebase Analytics and Firebase Crashlytics as optional,
non-blocking supporting services. Journey, Endless, Daily, settings,
achievements, and all core gameplay remain fully usable offline when Firebase
is unavailable.

## Initialization

The Flutter app starts immediately with no-op analytics and crash-reporting
services. Firebase initialization runs asynchronously. On success, the service
delegates switch to Firebase implementations; on failure they remain no-op and
only a safe debug message is written. Release builds enable Crashlytics
collection. Uncaught Flutter framework and asynchronous Dart errors are routed
through the crash-reporting abstraction. Expected validation and persistence
failures are not reported as crashes.

## Event taxonomy

- `app_open`
- `journey_level_start`, `journey_level_complete`
- `endless_puzzle_start`, `endless_puzzle_complete`
- `daily_puzzle_start`, `daily_puzzle_complete`
- `hint_used`, `level_restart`
- `achievement_unlocked`, `settings_changed`

Event and parameter names are centralized in `AnalyticsEvents` and
`AnalyticsParameters`. Parameters are limited to anonymous gameplay metadata:
level/puzzle number, chapter ID, board size, difficulty, generation version,
moves, current Daily streak, mode, achievement ID, and changed setting.

Never log tile colors, board contents, procedural seeds, signing information,
user IDs, email, advertising IDs, location, or personal profile data.

## Required platform setup

The repository intentionally contains no fabricated Firebase configuration.
Before enabling Firebase for a release:

1. Create or select a Firebase project and enable Google Analytics.
2. Register Android app `com.berilblks.pixelharmony` and place the downloaded
   `google-services.json` at `flutter_app/android/app/google-services.json`.
3. Register iOS app `com.berilblks.pixelharmony` and place the downloaded
   `GoogleService-Info.plist` at
   `flutter_app/ios/Runner/GoogleService-Info.plist`.
4. Install/login to the Firebase and FlutterFire CLIs, then run
   `flutterfire configure` from `flutter_app/` for Android and iOS. This creates
   the platform options and adds required Android Crashlytics Gradle wiring.
5. Revalidate debug/release builds and confirm events in Analytics DebugView and
   non-production Crashlytics testing before release.

## Privacy and store disclosure

Before public distribution, the privacy policy and Google Play Data Safety / App
Store privacy disclosures must accurately describe Firebase Analytics and
Crashlytics collection. Consent requirements must be reviewed for each launch
region. This integration does not add consent UI or identity tracking.
