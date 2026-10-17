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

## Platform setup

Android is registered as `com.berilblks.pixelharmony`. Its official
`google-services.json` and generated `firebase_options.dart` are normal mobile
client configuration and may be tracked; they contain identifiers, not signing
credentials. Upload keystores, `key.properties`, passwords, and service-account
credentials must never be tracked.

iOS still requires platform setup before an iOS Firebase build:

1. Create or select a Firebase project and enable Google Analytics.
2. Register iOS app `com.berilblks.pixelharmony` and place the downloaded
   `GoogleService-Info.plist` at
   `flutter_app/ios/Runner/GoogleService-Info.plist`.
3. Re-run `flutterfire configure --platforms=ios` from `flutter_app/` after the
   iOS app is registered.
4. Revalidate debug/release builds and confirm events in Analytics DebugView and
   non-production Crashlytics testing before release.

## Android verification

Enable Analytics DebugView for the connected development device:

```powershell
adb shell setprop debug.firebase.analytics.app com.berilblks.pixelharmony
```

Launch the app, open a Journey level, and request a hint to exercise `app_open`,
`journey_level_start`, and `hint_used`. Disable DebugView afterward:

```powershell
adb shell setprop debug.firebase.analytics.app .none.
```

Firebase delivery and console visibility require a connected device/emulator,
network access, and access to the Firebase project; automated tests use fakes.

Crashlytics collection is intentionally disabled in debug mode. To verify it,
use a non-production profile build and a temporary local-only call to
`FirebaseCrashlytics.instance.crash()` behind `kProfileMode`. Launch the profile
build, trigger that temporary code once, reopen the app so the report can be
uploaded, verify it in the Firebase console, and remove the temporary code
before committing. Never leave a crash control in release UI or automatically
crash production builds.

## Privacy and store disclosure

Before public distribution, the privacy policy and Google Play Data Safety / App
Store privacy disclosures must accurately describe Firebase Analytics and
Crashlytics collection. Consent requirements must be reviewed for each launch
region. This integration does not add consent UI or identity tracking.
