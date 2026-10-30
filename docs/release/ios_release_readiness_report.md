# Pixel Harmony — iOS App Store Release Readiness Audit

Audit date: 2026-10-30
Repository: `D:\Projects\Pixel-Harmony`
Flutter application: `D:\Projects\Pixel-Harmony\flutter_app`
Audited commit: `9a6d58283d38a9f1642029da3ff250fd80784845` (`main`)
Toolchain observed on Windows: Flutter 3.29.0, Dart 3.7.0

## Executive summary

Pixel Harmony's Flutter code and checked-in iOS shell are healthy enough to continue release preparation, but the repository is **not currently capable of producing a valid iOS archive**. The blocking items are:

1. **P0 — CocoaPods integration is missing:** `flutter_app/ios/Podfile` does not exist, while the app depends on native iOS plugins.
2. **P0 — iOS deployment target is too low:** the project declares iOS 12.0, but the locked Firebase plugins and `audioplayers_darwin` require iOS 13.0.
3. **P0 — Firebase is Android-only:** no iOS Firebase app options or `GoogleService-Info.plist` are present. The app catches initialization failure and remains playable offline, but Analytics and Crashlytics will not operate on iOS.
4. **P0 — release signing/archive is not configured or verified:** there is no `DEVELOPMENT_TEAM` or provisioning evidence, and an archive cannot be tested on Windows.
5. **P0 — Crashlytics symbol upload is absent:** the Xcode project contains only Flutter build/thin scripts; no Crashlytics dSYM run script is configured.

All audit-time automated checks passed: formatting changed no files, `flutter analyze` found no issues, and all 295 tests passed. An iOS build was **not** attempted because Xcode and CocoaPods iOS builds require macOS.

## 1. iOS project and build configuration

| Alan | Durum | Kanıt / Dosya | Risk | Yapılacak işlem |
|---|---|---|---|---|
| iOS project directory | PASS | `flutter_app/ios/` | — | Keep the checked-in iOS project under source control. |
| Xcode project | PASS | `flutter_app/ios/Runner.xcodeproj` | — | Open on a supported macOS/Xcode host after P0 fixes. |
| Xcode workspace | WARNING | `flutter_app/ios/Runner.xcworkspace` exists, but references only `Runner.xcodeproj` because no Pods integration exists | Native plugins cannot be linked as-is. | Regenerate/restore a Flutter-standard Podfile, run `flutter pub get` and `pod install` on macOS, then open the workspace rather than the project. |
| Podfile | FAIL | `flutter_app/ios/Podfile` is absent | **P0:** Firebase, shared preferences, audio, and other native plugins cannot be integrated into an archive. | Add the standard Flutter iOS Podfile with `platform :ios, '13.0'`; do not hand-pin individual pod versions unless CocoaPods resolution requires it. Commit `Podfile` and normally `Podfile.lock`. |
| Info.plist | PASS | `flutter_app/ios/Runner/Info.plist` | Core bundle metadata, launch storyboard, and orientations are defined. | Revalidate with Xcode's built product after Pods/Firebase setup. |
| Language / native entry point | PASS | `flutter_app/ios/Runner/AppDelegate.swift`; `SWIFT_VERSION = 5.0`; bridging header present | — | Swift configuration is suitable for current plugins. |
| Bundle identifier | PASS | `PRODUCT_BUNDLE_IDENTIFIER = com.berilblks.pixelharmony` in `Runner.xcodeproj/project.pbxproj` | Must exactly match Apple and Firebase registrations. | Create/select this exact Bundle ID in Apple Developer and the existing Firebase project. |
| Display name | PASS | `CFBundleDisplayName` and `CFBundleName` are `Pixel Harmony` in `Runner/Info.plist` | — | Confirm the name is available in App Store Connect. |
| Version / build number | WARNING | `flutter_app/pubspec.yaml`: `1.0.0+1`; Info.plist uses `FLUTTER_BUILD_NAME` / `FLUTTER_BUILD_NUMBER` | Build 1 is valid for a first upload but every subsequent upload needs a higher build number. | Establish release versioning procedure; verify Xcode archive shows marketing version 1.0.0 and build 1. |
| Minimum iOS version | FAIL | `IPHONEOS_DEPLOYMENT_TARGET = 12.0`; `AppFrameworkInfo.plist` minimum 12.0. Locked `firebase_core`, `firebase_analytics`, `firebase_crashlytics`, and `audioplayers_darwin` podspecs require 13.0 | **P0:** CocoaPods resolution/build conflict. | Raise the project, AppFrameworkInfo, and Podfile target consistently to iOS 13.0 (or the minimum required by the resolved pods) and test on the oldest supported device/simulator. |
| Signing mode | NOT VERIFIED | No `DEVELOPMENT_TEAM`, explicit provisioning profile, or distribution certificate is checked in; Runner target inherits Xcode defaults | **P0:** Archive/export may fail. | On macOS, select the Apple team, use automatic signing initially, confirm App Store distribution provisioning, then archive Release. Never commit certificates/private keys. |
| Debug / Release separation | PASS | `Flutter/Debug.xcconfig`, `Flutter/Release.xcconfig`, and Xcode Debug/Profile/Release configurations exist | Release behavior still needs archive validation. | Confirm `dart.vm.product` and Crashlytics collection behavior in a TestFlight build. |
| Supported devices | WARNING | `TARGETED_DEVICE_FAMILY = "1,2"` | iPad is enabled, so iPad layout testing and 13-inch iPad screenshots are required. | Either fully support and test iPad or deliberately change device family before first release. Do not leave accidental iPad support. |
| Orientations | WARNING | iPhone: portrait plus both landscapes; iPad: all four orientations in `Runner/Info.plist` | UI is primarily designed/tested in portrait; landscape and iPad behavior are not proven. | Decide product orientation policy. If landscape remains enabled, test every principal flow in both landscape directions; otherwise intentionally restrict before submission. |
| App Transport Security | PASS | No ATS exception or arbitrary-load key in `Runner/Info.plist` | Default secure HTTPS policy applies. | Keep ATS exceptions absent unless a justified endpoint requires one. |
| Protected-resource permissions | PASS | No camera, microphone, photo, location, Bluetooth, tracking, or notification package/use was found; no usage-description keys are present | Adding such a feature later without a purpose string would crash/reject. | No permission text is needed for the audited feature set; re-audit if capabilities change. |
| Entitlements / capabilities | PASS | No Runner entitlements file; no push, Sign in with Apple, iCloud, Game Center, or associated domains are used | — | Keep capabilities minimal. Add only when a product feature requires them. |
| App icon set | PASS | Complete iPhone, iPad, and 1024×1024 marketing entries in `Runner/Assets.xcassets/AppIcon.appiconset` | Visual masking/alpha cannot be fully approved from inventory alone. | Validate in Xcode asset catalog and on physical iPhone/iPad; ensure the 1024 icon has no alpha channel. |
| Native splash | PASS | `LaunchScreen.storyboard` uses centered `LaunchImage` on a pastel background | Device-specific rendering is not verified. | Check cold launch on small iPhone, Dynamic Island iPhone, and iPad; verify no white flash/cropping. |

## 2. Flutter package iOS compatibility

The versions below are the locked versions. The minimums were read from the packages' locally installed iOS podspecs where applicable; final compatibility must still be confirmed by CocoaPods on macOS.

| Alan | Durum | Kanıt / Dosya | Risk | Yapılacak işlem |
|---|---|---|---|---|
| `firebase_core 3.11.0` | FAIL | `pubspec.lock`; podspec declares iOS 13.0 | Current project target is 12.0; Firebase iOS app is not configured. | Raise target to 13.0 and configure the existing Firebase project for iOS. |
| `firebase_analytics 11.4.2` | FAIL | `pubspec.lock`; podspec declares iOS 13.0 | No iOS Firebase options; App Privacy declarations required for actual collection. | Configure iOS and audit Firebase's current Apple privacy documentation before submission. |
| `firebase_crashlytics 4.3.2` | FAIL | `pubspec.lock`; podspec declares iOS 13.0; no Crashlytics Xcode build phase | No iOS reporting and no dSYM upload. | Add official Crashlytics setup/run script via current FlutterFire guidance; verify a non-production TestFlight crash and symbolication. |
| `audioplayers 6.6.0` / Darwin 6.4.0 | WARNING | `pubspec.lock`; Darwin podspec declares iOS 13.0 | Raises the app minimum; production sound files are absent (only `assets/audio/sfx/README.md`). | Raise target; add properly licensed production effects before claiming sound in store metadata, or clearly accept silent fallback. |
| `shared_preferences 2.5.3` / Foundation 2.5.4 | PASS | Foundation podspec supports iOS 12.0 and bundles `PrivacyInfo.xcprivacy` for UserDefaults | Local progress is device-local and can be removed with app deletion. | Verify migration/persistence on upgrade and disclose accurately; no account/cloud restore exists. |
| `flame 1.30.1` | PASS | Flutter package; no direct iOS native setup found | GPU/input performance must be tested on device. | Profile 5×5+ gameplay and long Journey scrolling on representative iPhones/iPad. |
| `flutter_riverpod 3.3.2`, `go_router 17.0.0`, `intl 0.19.0`, `cupertino_icons 1.0.8` | PASS | `pubspec.yaml` / `pubspec.lock` | No special iOS native configuration identified. | Keep locked for this release; do not upgrade solely for the audit. |
| Flutter SDK localization | PASS | English and Turkish generated localizations in `lib/core/localization/`; `app.dart` registers both locales | App Store metadata still requires separate EN/TR entries. | Add localized App Store Connect metadata and test system-language switching. |
| Privacy manifests | WARNING | No app-level `PrivacyInfo.xcprivacy` in `ios/`; `shared_preferences_foundation` supplies its own manifest | Apple requires valid manifests for listed SDKs and required-reason APIs; the final archive's aggregate privacy report is unknown. | After Pods resolve, generate Xcode privacy report; add an app manifest only for actual app-level APIs/data practices. Apple rejects invalid manifests. See official guidance: https://developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk |
| Package licenses | WARNING | Package cache contains licenses; root `LICENSE` file is empty although README claims MIT | Store/legal attribution and project license are ambiguous; visual/audio asset provenance is undocumented. | Restore the intended license text and create an asset/third-party attribution inventory before release. Do not assume downloaded/generated artwork rights without records. |

## 3. Firebase audit

| Alan | Durum | Kanıt / Dosya | Risk | Yapılacak işlem |
|---|---|---|---|---|
| Firebase iOS app registration | NOT VERIFIED | No Apple configuration in repository; Firebase Console not inspected | **P0:** cannot confirm an iOS app exists in the Pixel Harmony project. | In the existing Firebase project, register/select `com.berilblks.pixelharmony`; do not create a duplicate project. |
| `GoogleService-Info.plist` | FAIL | Not present under `flutter_app/ios/` or Runner | **P0:** native Firebase configuration absent. | Download the plist for the exact iOS app, add it to the Runner target in Xcode, and keep identifiers out of prose reports. Firebase mobile config is not a signing secret, but repository policy should be explicit. |
| Generated Firebase options | FAIL | `lib/firebase_options.dart` throws `UnsupportedError` for `TargetPlatform.iOS` and defines Android only | **P0:** `initializeOptionalFirebase` always falls back to no-op on iOS. | Re-run `flutterfire configure` for the existing project and existing iOS app, selecting iOS without duplicating Android registrations. Review the generated diff. Official setup: https://firebase.google.com/docs/flutter/setup |
| Optional/offline fallback | PASS | `lib/app/firebase_support.dart` catches initialization failure; `bootstrap.dart` starts UI before optional init | Core play remains available offline. | Preserve this architecture after iOS configuration. Test airplane-mode cold start. |
| Analytics | WARNING | Analytics adapter and events exist; unavailable Firebase becomes no-op | iOS events are currently not delivered; App Privacy declarations must include third-party collection. | Validate `app_open`, Journey start/completion, hint, settings, achievement, and Endless events in Firebase DebugView from a non-production iOS build. |
| Crashlytics collection policy | WARNING | Collection is enabled only when `!kDebugMode` | Correct for avoiding debug noise, but Release/TestFlight behavior is unverified. | Use a profile/release-style internal build, send one controlled non-production exception, remove any temporary trigger, and confirm symbolication. |
| Crashlytics dSYM upload | FAIL | No Crashlytics script/build phase in `Runner.xcodeproj/project.pbxproj` | **P0:** crashes may be unsymbolicated or missing. | Follow current Firebase Apple/Flutter setup and verify dSYM upload. Firebase notes that missing scripts cause missing dSYMs: https://firebase.google.com/docs/crashlytics/troubleshooting |
| Firebase project identity consistency | NOT VERIFIED | Android options exist, but values were intentionally not copied into this report; no iOS config exists | Wrong-project registration would split analytics/crashes. | Compare Android and iOS app registrations in Firebase Console under the same project before generating config. |
| App Privacy declarations | MANUAL ACTION | Analytics and Crashlytics are embedded dependencies | Incorrect answers can block review or mislead users. | Complete App Store Connect disclosures for all data collected by app and third parties (likely identifiers, usage data, and diagnostics—confirm against the resolved SDK and actual configuration). Apple requires third-party practices to be included: https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy |

## 4. iOS UI, accessibility, and device audit

| Alan | Durum | Kanıt / Dosya | Risk | Yapılacak işlem |
|---|---|---|---|---|
| Safe areas / home indicator | PASS | Home, gameplay, level select, settings, achievements, and statistics use `SafeArea`; Home bottom actions have a bottom SafeArea | Code coverage is good, but device rendering is not proven. | Test on Face ID/Dynamic Island iPhones and an iPhone SE-size viewport. |
| Dynamic Island / notch | NOT VERIFIED | No physical iOS execution in this Windows audit | Content may clip in unusual insets. | Manual device/simulator matrix: current Dynamic Island size, older notch, and non-notch small phone. |
| Text scaling | WARNING | Many labels use ellipsis; several narrow-layout widget tests exist | Large Accessibility sizes may truncate essential text or push controls off-screen. | Run iOS accessibility text sizes through Home, settings, map, palette, completion overlays, and error states. |
| Touch targets / semantics | PASS | Home actions and key controls use `Semantics`; bottom actions occupy accessible rows; IconButtons use standard Material constraints | Full VoiceOver order and labels are unverified. | Run VoiceOver audit and Accessibility Inspector on macOS/iPhone. |
| Pixel Coloring zoom/pan | PASS | `PixelColoringViewport` uses `InteractiveViewer`, scale 1×–4×, `TransformationController`, pointer-count reporting, clipping, reset semantics; tests cover pinch, pan, reset, and multitouch | iOS gesture arbitration/precision still needs device testing. | Test pinch, two-finger pan, single-tap painting after transform, wrong-color taps, and reset on 12×12/14×14/16×16 art. |
| Palette accessibility | WARNING | Palette behavior is widget-tested; gameplay content is inside SafeArea | Small iPhone, landscape, VoiceOver, and very large text could reduce access. | Manually verify all colors/numbers remain reachable and distinguishable without relying on color alone. |
| Journey infinite scrolling | WARNING | Lazy `ListView.builder` with batches/prefetch and tests beyond level 100 | Long-session memory, frame pacing, and auto-positioning are not profiled on iOS. | Profile levels 1, 100, 500, 1000+ on an older supported iPhone and iPad. |
| iPad layout | NOT VERIFIED | Device family includes iPad; UI has responsive constraints but no iPad-specific release evidence | Poor tablet composition can trigger review-quality concerns and requires screenshots. | Test portrait/landscape on 11-inch and 13-inch simulators; decide whether iPad support is intentional. |
| Orientation consistency | WARNING | iPhone landscape and iPad all orientations are enabled | Pixel boards, completion overlays, and Home may not match approved portrait design. | Either test/fix landscape comprehensively or restrict orientations intentionally. |
| Reduced motion | PASS | Journey/gameplay query `MediaQuery.disableAnimationsOf(context)` | Not all animations/effects were audited individually. | Verify Reduce Motion in iOS Settings and ensure no essential information depends on animation. |
| Color accessibility | WARNING | Color is central to gameplay; UI adds numbers/icons for Pixel Coloring and status semantics | Gradient puzzles inherently depend on color discrimination. | Test Increase Contrast, Differentiate Without Color, grayscale/color filters, and document accessibility limits honestly. |

### Required manual iOS device matrix

- Small phone: iPhone SE-sized simulator/device, portrait and enabled landscape.
- Dynamic Island phone: current medium/large display, portrait and enabled landscape.
- Oldest supported runtime after target is raised (expected iOS 13 if the build toolchain still permits deployment testing).
- iPad 11-inch and 13-inch, both orientations, if iPad remains supported.
- Settings: Turkish/English, maximum text size, VoiceOver, Reduce Motion, Increase Contrast, offline/airplane mode.
- Gameplay: Gradient drag/swap/hint/restart/completion; Pixel Coloring palette, 4× zoom/pan, transformed taps, completion; Free Play; long Journey map; persistence after force quit/update.

## 5. App Store Review risk audit

| Alan | Durum | Kanıt / Dosya | Risk | Yapılacak işlem |
|---|---|---|---|---|
| Debug banner / visible test UI | PASS | `app.dart` disables debug banner; debug Pixel Art contact sheet is not routed from production navigation | Debug-only source still ships in source tree but is not accessible via the production router. | Confirm release binary has no hidden/test route and no temporary crash trigger. |
| Unlock-all flag | PASS | `LevelProgression` permits `PIXEL_HARMONY_UNLOCK_ALL` only when requested **and** `dart.vm.product` is false | Release build cannot unlock all through this flag. | Add a release-mode regression check in CI if desired; never ship a custom non-product build to review. |
| Removed Daily Puzzle | PASS | No Daily route/screen in `app_router.dart`; widget test asserts removed route cannot open gameplay | Legacy analytics constants and statistics fields remain for saved-data compatibility but are not user-accessible. | Keep legacy data fields unless a migration is designed; do not advertise Daily Puzzle in App Store copy. README/product docs are stale and should be updated before marketing review. |
| Offline behavior | PASS | Firebase initialization is optional; repositories use SharedPreferences; automated fallback test passes | Firebase calls must remain non-blocking. | Manual airplane-mode cold-start and full puzzle completion test on iOS. |
| Local progress / deletion | WARNING | SharedPreferences repositories persist progress, settings, achievements, statistics, Endless state | No cloud restore/account; uninstall removes data. | Explain local-only behavior in support/privacy documentation; test upgrades without data loss. |
| Crash / infinite loading risk | WARNING | 295 tests pass; progress load has fallback UI; Firebase failures are swallowed | Native iOS plugin/archive behavior remains untested. | Run TestFlight soak tests, background/foreground cycles, force quit, low-memory scenarios, and Crashlytics validation. |
| Ads / payments / subscriptions / tracking | PASS | No ads, IAP, subscription, ATT, or ad-tracking SDK dependency found | Analytics still collects app usage unless configured otherwise. | Answer App Privacy based on Analytics/Crashlytics; do not request ATT without tracking behavior. |
| Audio release quality | WARNING | Audio service exists but production SFX files are absent; failures are safely skipped | Store copy promising sound may not match binary. | Add owned/licensed short effects in a separately approved task, or omit sound claims. |
| Visual/font/art licensing | WARNING | Root `LICENSE` is empty; no attribution/provenance document found | Rights for logo, 100 Pixel Art templates, icon, and future audio cannot be demonstrated from repository evidence. | Create a release asset register: creator/source, license/assignment, modification rights, and attribution requirement. |
| Privacy policy | MANUAL ACTION | No privacy/support document or URL found | Required for App Store submission. | Publish a public privacy policy covering Firebase Analytics/Crashlytics and local data. Apple requires a Privacy Policy URL for all apps: https://developer.apple.com/help/app-store-connect/reference/app-information/app-privacy/ |

## 6. App Store Connect preparation

The text below is a release-ready **draft**, not confirmation that the Apple account/app record exists.

| Alan | Durum | Kanıt / Dosya | Risk | Yapılacak işlem |
|---|---|---|---|---|
| Bundle ID | MANUAL ACTION | Expected: `com.berilblks.pixelharmony` | Apple registration not visible from repository. | Register/select exact ID in Apple Developer and App Store Connect. |
| App name | MANUAL ACTION | Draft: **Pixel Harmony**; matches Info.plist | Availability/trademark not verified. | Reserve/confirm in App Store Connect. |
| Subtitle EN | MANUAL ACTION | Draft: **Relaxing Color Puzzles** | Marketing approval required. | Enter localized EN subtitle. |
| Subtitle TR | MANUAL ACTION | Draft: **Rahatlatıcı Renk Bulmacaları** | Verify App Store character limit in UI. | Enter localized TR subtitle. |
| Description EN | MANUAL ACTION | Draft below | Must describe current build only; no Daily Puzzle, ads, purchases, or absent sound claims. | Review and enter as English localization. |
| Description TR | MANUAL ACTION | Draft below | Same scope constraint. | Review and enter as Turkish localization. |
| Keywords EN | MANUAL ACTION | Draft: `color,puzzle,relaxing,gradient,pixel art,calm,mindful,offline` | App/company names must not be repeated; 100-byte maximum. | Validate byte count in App Store Connect. Apple guidance: https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information/ |
| Keywords TR | MANUAL ACTION | Draft: `renk,bulmaca,rahatlatıcı,gradyan,piksel,sakin,çevrimdışı` | Localized search behavior and byte count need checking. | Validate in App Store Connect. |
| Category | MANUAL ACTION | Recommended primary: **Games / Puzzle**; secondary: **Games / Casual** | Category taxonomy/account choices cannot be verified locally. | Confirm current App Store Connect category options. |
| Age rating | MANUAL ACTION | Game appears suitable for broad audiences; no violence, gambling, UGC, or purchases found | Only Apple's questionnaire determines the rating. | Complete questionnaire accurately. Unrated apps cannot publish: https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating |
| Privacy Policy URL | FAIL | No URL found | **P1:** required metadata. | Publish stable HTTPS policy URL before submission. |
| Support URL | FAIL | No URL found | **P1:** required version metadata and user contact path. | Publish a support page with real contact information. |
| App Privacy | MANUAL ACTION | Firebase Analytics/Crashlytics dependencies; local SharedPreferences | Misdeclaration is a review/compliance risk. | Complete data-type/purpose/linking/tracking answers using the final archive and Firebase documentation. |
| iPhone screenshots | MANUAL ACTION | No App Store screenshot set found | Required for submission. | Capture localized EN/TR screens on required iPhone size(s), 1–10 per device class. Current requirements: https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications |
| iPad screenshots | MANUAL ACTION | iPad support enabled (`TARGETED_DEVICE_FAMILY = "1,2"`) | 13-inch iPad screenshots required while iPad support remains. | Capture tested 13-inch iPad screenshots or intentionally remove iPad support before submission. |
| TestFlight | MANUAL ACTION | No App Store Connect access in audit | Native and review-path risks remain. | Internal testing → external beta if needed → production candidate; verify crash-free sessions and offline behavior. |
| Export compliance | MANUAL ACTION | App uses Firebase HTTPS/TLS through platform SDKs; no custom cryptography found | Apple questionnaire/account evidence unavailable. | Answer encryption/export questions for the final binary; determine exemption/documentation in App Store Connect rather than assuming. |
| Pricing / availability | MANUAL ACTION | Product docs mention premium vision but current code has no purchase system | Pricing decision is unresolved. | Choose free/paid and storefront availability. Do not promise IAP/subscriptions not present. |
| Copyright / content rights | MANUAL ACTION | Artwork and empty root license need resolution | Submission requires rights to all content. | Record legal owner/year and preserve proof of rights for logo, templates, icons, and audio. |

### Draft English description

> Find calm in color with Pixel Harmony, a relaxing offline-first puzzle game. Restore smooth gradients, complete detailed pixel-coloring artwork, and follow an ever-growing Journey at your own pace. Use hints when you need them, revisit completed levels, or create a fresh challenge in Free Play. There are no timers and no pressure—just thoughtful color puzzles, gentle interactions, achievements, and progress stored on your device.

### Draft Turkish description

> Pixel Harmony ile renklerin içinde huzur bul. Yumuşak renk geçişlerini düzenle, ayrıntılı piksel boyama görsellerini tamamla ve sürekli genişleyen Yolculuk'ta kendi hızında ilerle. İhtiyacın olduğunda ipucu kullan, tamamladığın bölümlere dön veya Serbest Oyun'da yeni bir bulmaca başlat. Süre baskısı yok; yalnızca sakin renk bulmacaları, yumuşak etkileşimler, başarımlar ve cihazında saklanan ilerlemen var.

## 7. Automated validation

| Alan | Durum | Kanıt / Dosya | Risk | Yapılacak işlem |
|---|---|---|---|---|
| Git baseline | PASS | HEAD exactly `9a6d58283d38a9f1642029da3ff250fd80784845`; working tree was clean before this report | — | This report is the only intended audit change. |
| Dart formatting | PASS | `dart format --output=none --set-exit-if-changed .` → 191 files, 0 changed | — | Keep in CI. |
| Static analysis | PASS | `flutter analyze` → no issues | — | Repeat on macOS after iOS config changes. |
| Automated tests | PASS | `flutter test` → **295 tests passed** | Native iOS behavior is outside these Windows tests. | Repeat on macOS and add iOS integration/smoke tests where practical. |
| Whitespace validation | PASS | `git diff --check` after report generation | — | Run again before any future commit. |
| iOS build/archive | NOT VERIFIED | Windows host has no Xcode/CocoaPods iOS build chain | **P0:** no successful iOS build exists from this audit. | On macOS: resolve P0 configuration, `flutter build ios --release`, then Xcode Archive/Validate/Distribute to TestFlight. |

## 8. Prioritized gaps

### P0 — blocks iOS build or App Store upload

1. Add a Flutter-standard `ios/Podfile` and install pods on macOS.
2. Raise the effective deployment target from iOS 12.0 to at least iOS 13.0 everywhere.
3. Register/select the existing Firebase project's iOS app for `com.berilblks.pixelharmony`; add `GoogleService-Info.plist` and generated iOS `FirebaseOptions`.
4. Add and verify official Crashlytics dSYM upload configuration.
5. Configure Apple Development/Distribution signing team, provisioning, and App Store Connect app record.
6. Produce and validate a real Release archive on macOS/Xcode.

### P1 — must be completed before review

1. Decide whether iPad and landscape are genuinely supported; test or restrict intentionally.
2. Publish Privacy Policy and Support URLs; complete App Privacy declarations for Firebase and local data.
3. Test through TestFlight across the manual device/accessibility/offline matrix.
4. Supply localized iPhone and, if retained, iPad screenshots and metadata.
5. Resolve asset/license provenance and the empty root `LICENSE` file.
6. Decide whether silent audio fallback is acceptable or provide licensed production effects.
7. Complete age rating, export compliance, pricing, availability, content rights, and review information.

### P2 — release quality improvements

1. Add macOS CI for pod resolution, iOS Release build, tests, archive checks, and privacy-manifest validation.
2. Add explicit iPad, landscape, VoiceOver, and maximum-text-scale widget/integration coverage.
3. Profile Journey scrolling and Flame rendering on an older supported iPhone.
4. Update stale README/product claims (for example Daily Challenges) so public documentation matches the shipped app.

## 9. Ordered iOS release roadmap

1. **Mac build host:** prepare a supported macOS machine with current supported Xcode, CocoaPods, Flutter 3.29.0, and Dart 3.7.0; do not upgrade the project yet.
2. **Native baseline:** restore/create the standard Podfile, set iOS 13.0 consistently, run `flutter pub get` and `pod install`, and open `Runner.xcworkspace`.
3. **Firebase iOS:** add the existing-project iOS registration/config, regenerate FlutterFire options, add Crashlytics upload phase, and confirm offline fallback remains intact.
4. **Signing:** register Bundle ID, choose team, enable automatic signing, and build a signed device Release.
5. **Build gate:** run formatting, analysis, all tests, `flutter build ios --release`, Xcode Archive, Validate App, privacy report, and symbol/dSYM checks.
6. **Product decisions:** decide iPad and orientation scope; implement only the minimum release configuration changes needed.
7. **Manual QA:** execute the device/accessibility/localization/offline matrix; log and fix all P0/P1 issues.
8. **Legal/privacy:** publish policy/support pages, complete Firebase data inventory, asset-rights register, export compliance, and age rating.
9. **Store assets:** finalize EN/TR name/subtitle/description/keywords, screenshots, category, pricing, availability, and review notes.
10. **TestFlight:** upload an internal candidate, verify Analytics events and one controlled Crashlytics event with symbolication, then remove any temporary verification trigger.
11. **Release candidate:** increment build number, rerun the complete gate, freeze the candidate, submit for review, and monitor Crashlytics after release.

## Scope note

This was a read-only audit of application and platform code. No gameplay, Journey content, Pixel Art template, saved-progress schema, dependency, signing file, or Firebase configuration was changed. The only created file is this report.
