---
title: Technology Stack
version: 1.0
status: Active
owner: Beril Bölükbaşı
last_updated: 2026-08-01
---

# Technology Stack

## Purpose

This document defines the approved technology stack for the Pixel Harmony mobile game.

Its purpose is to:

- prevent unnecessary technology changes
- clarify which framework owns each responsibility
- establish architectural boundaries between Flutter and Flame
- guide Codex and future contributors
- keep the project maintainable for a solo developer
- support Android and iOS release from a shared codebase

## Scope

This document covers:

- application framework
- game engine
- state management
- navigation
- local persistence
- cloud services
- analytics
- crash reporting
- remote configuration
- advertisements
- in-app purchases
- animation
- testing
- build and release tooling

This document does not define gameplay rules, level generation formulas, UI specifications, or monetization balance. Those concerns are documented separately.

## Related Documents

- `CODEX.md`
- `PROJECT_RULES.md`
- `docs/product/product_discovery.md`
- `docs/architecture/system_architecture.md`
- `docs/architecture/state_management.md`
- `docs/architecture/folder_structure.md`
- `docs/game_design/core_gameplay.md`
- `docs/algorithms/level_generator.md`

---

# 1. Approved Stack

| Area | Technology | Status |
|---|---|---|
| Application Framework | Flutter | Required |
| Language | Dart | Required |
| Game Engine | Flame | Required |
| State Management | Riverpod | Required |
| Navigation | go_router | Required |
| Local Persistence | Isar | Preferred |
| Analytics | Firebase Analytics | Required for release |
| Crash Reporting | Firebase Crashlytics | Required for release |
| Remote Configuration | Firebase Remote Config | Required for release |
| Ads | Google Mobile Ads | Optional in development, required for monetized release |
| In-App Purchases | in_app_purchase | Required for premium features |
| Animation | Flutter Animations + Flame Effects | Required |
| Advanced Vector Animation | Rive | Optional |
| Dependency Injection | Riverpod providers | Required |
| Testing | flutter_test + integration_test | Required |
| Static Analysis | flutter_lints or stricter custom rules | Required |
| CI/CD | GitHub Actions | Required before beta |

---

# 2. Core Technology Decisions

## 2.1 Flutter

Flutter is the primary application framework.

Flutter owns all non-gameplay product experiences, including:

- splash screen
- onboarding
- home screen
- level selection
- profile
- settings
- achievements
- daily challenges
- statistics
- premium purchase screens
- dialogs
- bottom sheets
- navigation
- localization
- accessibility
- responsive layouts
- store-related flows

### Why Flutter

Flutter is selected because:

- the developer already has Flutter experience
- one codebase can target Android and iOS
- UI implementation is faster than with a traditional game engine
- Firebase integrations are mature
- Material 3 support is strong
- accessibility and localization are easier to manage
- application-style screens are simpler to build than in Unity
- the project can remain manageable for a solo developer

### Flutter Restrictions

Flutter widgets must not contain puzzle-generation logic.

Flutter screens must not access Firebase or Isar directly.

Business logic must not be placed inside `build()` methods.

Gameplay animation that belongs to the puzzle board should not be implemented as deeply nested Flutter widgets when Flame provides a clearer solution.

---

## 2.2 Flame

Flame is the approved game engine for the interactive puzzle board.

Flame owns:

- puzzle-board rendering
- tile components
- drag interactions
- tile swapping
- movement effects
- completion effects
- board scaling
- gameplay input handling
- board-specific visual feedback
- gameplay particles when required
- game-loop updates when required

### Why Flame

Flame is selected because:

- it works naturally inside Flutter
- it allows the product UI to remain Flutter-native
- it is lightweight for a two-dimensional puzzle game
- it supports game components and effects
- it avoids the complexity of Unity for a relatively simple puzzle
- it allows the developer to continue using Dart
- it is appropriate for a solo-developed mobile game

### Flame Restrictions

Flame must not own:

- application navigation
- authentication screens
- purchase screens
- settings forms
- Firebase access
- local database access
- premium entitlement logic
- product analytics policy
- general dialogs unrelated to the board

The Flame layer must not become the source of truth for player progression.

The Flame layer must render and animate the current gameplay state, not define the complete product state.

---

# 3. Flutter and Flame Responsibility Boundary

## 3.1 High-Level Flow

```text
Flutter Screen
    ↓
Riverpod Controller
    ↓
Gameplay Use Case
    ↓
Puzzle Domain Engine
    ↓
Gameplay State
    ↓
Flame Rendering Layer
```

## 3.2 Responsibility Matrix

| Responsibility | Flutter | Flame | Domain Layer |
|---|---:|---:|---:|
| Navigation | Yes | No | No |
| Screen layout | Yes | No | No |
| Puzzle rendering | No | Yes | No |
| Drag animation | No | Yes | No |
| Move validation | No | No | Yes |
| Puzzle completion check | No | No | Yes |
| Level generation | No | No | Yes |
| Save progression | No | No | Through use cases |
| Analytics event dispatch | Through service | No | No |
| Settings UI | Yes | No | No |
| Sound trigger | Coordinates | Can request | Rule defined outside rendering |
| Premium state | Yes | No | Through domain/service |
| Rewarded ad flow | Yes | No | Through service |

## 3.3 Communication Rule

Flame components communicate gameplay events upward through callbacks, commands, or a dedicated gameplay bridge.

Example:

```text
Player drags a tile
    ↓
Flame reports requested move
    ↓
Gameplay controller asks domain engine to validate
    ↓
Domain engine returns accepted or rejected state
    ↓
Flame animates the result
```

Flame must not directly mutate persistent player data.

---

# 4. State Management

## 4.1 Riverpod

Riverpod is the approved state-management solution.

It will manage:

- current user profile
- current level
- gameplay session state
- settings
- theme selection
- premium entitlement
- daily challenge state
- achievements
- local persistence access
- remote configuration
- analytics services
- ad services
- purchase services

## 4.2 Rules

- Providers must have clear ownership.
- Feature-specific providers belong inside their feature.
- Global services belong under `core/services` or `app/providers`.
- UI must observe state and dispatch intentions.
- UI must not perform persistence or network operations directly.
- Mutable global singletons are not allowed.
- Service locators are not allowed unless explicitly approved later.
- Riverpod must be used for dependency injection.

## 4.3 Suggested Provider Types

- `Provider` for immutable services
- `FutureProvider` for simple asynchronous reads
- `NotifierProvider` for synchronous state orchestration
- `AsyncNotifierProvider` for asynchronous feature workflows
- family providers for level-specific or user-specific state

The exact provider type should be selected based on lifecycle and ownership, not personal preference.

---

# 5. Navigation

## 5.1 go_router

`go_router` is the approved navigation solution.

It will support:

- onboarding redirects
- nested navigation
- guarded premium routes
- deep links where required
- consistent route naming
- restoration-friendly navigation
- testable navigation behavior

## 5.2 Route Naming

Routes must be named and centralized.

Example:

```dart
abstract final class AppRoutes {
  static const splash = 'splash';
  static const onboarding = 'onboarding';
  static const home = 'home';
  static const levelSelect = 'level-select';
  static const gameplay = 'gameplay';
  static const achievements = 'achievements';
  static const settings = 'settings';
  static const premium = 'premium';
}
```

Hardcoded route strings inside screens are not allowed.

## 5.3 Initial Route Logic

```text
App launch
    ↓
Bootstrap local services
    ↓
Check onboarding completion
    ↓
Check required migration
    ↓
Open onboarding or home
```

---

# 6. Local Persistence

## 6.1 Isar

Isar is the preferred local persistence solution.

It will store:

- player profile
- level progress
- settings
- unlocked themes
- achievements
- daily challenge progress
- best scores
- premium cache
- migration version
- pending analytics events when needed

## 6.2 Offline-First Requirement

The MVP must remain playable without an internet connection.

The following must work offline:

- launching the game
- opening unlocked levels
- completing levels
- saving progress
- changing settings
- viewing achievements
- playing downloaded or bundled daily content
- using owned cosmetic themes

Internet-only features must fail gracefully.

## 6.3 Repository Boundary

The application must use repository interfaces.

Example:

```text
Domain
└── PlayerProgressRepository

Data
└── IsarPlayerProgressRepository
```

Screens and Flame components must not import Isar.

## 6.4 Isar Evaluation Checkpoint

Before final implementation, confirm that the currently maintained Isar package version supports all target platforms and the selected Flutter version.

If Isar becomes unsuitable, Hive CE or another maintained local database may be evaluated through an Architecture Decision Record.

No storage technology may be changed silently.

---

# 7. Firebase Services

Firebase must be introduced only where it provides clear product value.

The offline MVP must not depend on Firebase to run.

## 7.1 Firebase Analytics

Firebase Analytics will measure:

- onboarding completion
- level starts
- level completions
- hint usage
- session duration
- daily challenge participation
- premium screen views
- rewarded ad completion
- purchase funnel
- retention-related behavior

Analytics event names must follow the event taxonomy document.

No personally sensitive data may be placed in event parameters.

## 7.2 Firebase Crashlytics

Crashlytics will capture:

- unhandled Flutter exceptions
- asynchronous errors
- critical gameplay failures
- initialization failures
- purchase-flow errors
- database migration failures

Expected validation errors must not be reported as crashes.

## 7.3 Firebase Remote Config

Remote Config may control:

- rewarded-ad frequency
- premium offer visibility
- feature flags
- daily challenge parameters
- promotional copy
- experimentation values
- minimum supported version messaging

Remote Config must always have safe local defaults.

The app must never become unusable because Remote Config failed.

## 7.4 Firebase App Check

Firebase App Check should be enabled before public release when cloud-backed features are introduced.

---

# 8. Advertising

## 8.1 Google Mobile Ads

Google Mobile Ads is the approved ad platform.

## 8.2 Product Rules

- No interstitial ad may interrupt active gameplay.
- No banner ad may obstruct the puzzle board.
- Rewarded ads must be optional.
- The reward must be clearly stated before the ad starts.
- Failure to load an ad must not block progression.
- Ads must not appear during onboarding.
- Premium users must not see gameplay ads.
- Ad frequency must be remotely configurable.

## 8.3 Approved Rewarded Ad Uses

Examples:

- reveal one helpful tile
- gain one hint
- retry a daily bonus
- unlock a temporary cosmetic preview

Ads must not create a pay-to-win advantage.

---

# 9. In-App Purchases

## 9.1 Package

Flutter's `in_app_purchase` package is the approved starting point.

## 9.2 Supported Product Types

Potential products:

- permanent ad removal
- premium lifetime unlock
- optional subscription
- theme packs
- seasonal cosmetic packs

The MVP should avoid an unnecessarily complex store catalog.

## 9.3 Purchase Rules

- entitlement must be restored
- purchase errors must be recoverable
- loading states must be visible
- purchases must never be granted solely from a UI callback
- receipts and entitlements must be validated appropriately
- premium state must be cached for offline use
- store terms must be transparent

Server-side validation may be introduced before public monetized release if required by the final purchase model.

---

# 10. Animation Stack

## 10.1 Flutter Animations

Use Flutter animations for:

- screen transitions
- buttons
- cards
- dialogs
- progress indicators
- onboarding
- non-game UI feedback

## 10.2 Flame Effects

Use Flame effects for:

- tile movement
- tile scaling
- glow feedback
- board transitions
- completion waves
- board-specific particles
- gameplay-specific easing

## 10.3 Rive

Rive is optional.

Use Rive only when:

- the animation has meaningful interactive value
- it cannot be implemented efficiently with native Flutter or Flame effects
- the asset size is acceptable
- the project can maintain the source animation file

Do not add Rive solely for decorative complexity.

## 10.4 Lottie

Lottie is not part of the default approved stack.

It may be evaluated for isolated marketing or celebration animations through a documented dependency decision.

---

# 11. Audio

The audio implementation may use Flame Audio or another lightweight maintained package.

Audio responsibilities include:

- background ambient music
- tile interaction sounds
- completion sounds
- UI sounds
- master volume controls
- music volume controls
- sound-effect controls
- lifecycle-aware pausing

Audio must respect device lifecycle and user settings.

Sounds must never play unexpectedly after the app returns from the background.

---

# 12. Testing Stack

## 12.1 Unit Tests

Use Dart and Flutter unit tests for:

- gradient generation
- puzzle validation
- shuffle determinism
- scoring
- progression logic
- entitlement logic
- repository behavior
- remote-config defaults

## 12.2 Widget Tests

Widget tests are required for:

- reusable design-system components
- onboarding
- home screen
- settings
- premium screen
- loading, error, empty, and success states

## 12.3 Flame Tests

Gameplay tests must validate:

- component positioning
- drag handling boundaries
- board initialization
- move commands
- animation state where practical
- completion-event dispatch

Core puzzle correctness must be tested outside Flame.

## 12.4 Integration Tests

Critical integration flows:

```text
Fresh install → onboarding → first level → completion → saved progress
```

```text
Open premium → start purchase → entitlement updated
```

```text
Open level offline → complete level → restart app → progress preserved
```

---

# 13. Static Analysis and Code Quality

The repository must include:

- `analysis_options.yaml`
- strict lint rules
- formatted code
- analyzer checks in CI
- test execution in CI

At minimum, CI must run:

```bash
flutter pub get
flutter analyze
flutter test
```

Generated code must be included or excluded according to the selected generation workflow.

Analyzer warnings must not be ignored without explanation.

---

# 14. Build and Environment Strategy

## 14.1 Environments

Recommended environments:

- development
- staging
- production

Environment-specific values may include:

- Firebase configuration
- ad unit identifiers
- logging verbosity
- premium product identifiers
- feature flags
- API endpoints if introduced later

## 14.2 Secrets

Secrets must not be committed.

Use:

- environment configuration
- platform configuration files where required
- GitHub Actions secrets
- local ignored files

Example files must use placeholder values.

## 14.3 Application Identifiers

Final Android and iOS application identifiers must be decided before store setup.

Do not use `com.example` for release builds.

---

# 15. Performance Requirements

Targets for the MVP:

- gameplay rendering target: 60 FPS
- no visible frame drops during tile movement
- cold start target: under 3 seconds on supported mid-range devices
- level load target: under 500 ms for bundled levels
- no blocking database work on the UI thread
- bounded memory use for assets
- lazy loading for nonessential assets
- audio and visual assets compressed appropriately

Performance targets are goals, not excuses to reduce code clarity prematurely.

Profile before optimizing.

---

# 16. Accessibility Requirements

The Flutter layer must support:

- semantic labels
- minimum 48 dp interaction targets
- scalable text where practical
- high-contrast UI
- screen-reader-friendly navigation
- reduced-motion considerations
- color-blind support

The puzzle must not rely only on color for accessibility modes.

Possible alternatives include:

- tile symbols
- subtle patterns
- outlines
- coordinate hints

Accessibility is part of the product, not a post-release patch.

---

# 17. Localization

The application must be localization-ready from the beginning.

Initial target languages:

- English
- Turkish

English is the canonical repository and source-documentation language.

User-facing strings must not be hardcoded inside widgets.

Localization resources should use Flutter's official localization tooling unless a documented reason requires another approach.

---

# 18. Package Selection Policy

A package may be added only when:

- it solves a real current requirement
- it is actively maintained
- it supports target platforms
- its license is acceptable
- its binary-size impact is reasonable
- its functionality would be costly or risky to reproduce
- it fits the architecture

Before adding a package, document:

- purpose
- alternatives considered
- maintenance status
- platform limitations
- migration risk

Avoid dependency-heavy implementations for simple features.

---

# 19. Architecture Decision Records

Important technology changes require an Architecture Decision Record.

Examples:

- replacing Isar
- changing state management
- replacing Flame
- adding a backend API
- adding subscriptions
- introducing code generation
- adding a second analytics provider

Suggested location:

```text
docs/architecture/decisions/
```

Suggested filename:

```text
ADR-001-use-flutter-and-flame.md
```

---

# 20. Proposed Repository Layout

```text
Pixel-Harmony/
├── CODEX.md
├── PROJECT_RULES.md
├── README.md
├── docs/
│   ├── architecture/
│   │   ├── technology_stack.md
│   │   ├── system_architecture.md
│   │   ├── state_management.md
│   │   ├── folder_structure.md
│   │   └── decisions/
│   ├── game_design/
│   ├── algorithms/
│   ├── product/
│   ├── ui/
│   ├── backend/
│   ├── testing/
│   └── release/
└── flutter_app/
    ├── lib/
    │   ├── app/
    │   ├── core/
    │   ├── features/
    │   ├── game/
    │   └── main.dart
    ├── test/
    ├── integration_test/
    ├── assets/
    ├── pubspec.yaml
    └── analysis_options.yaml
```

---

# 21. Initial Package Plan

The exact versions must be selected when the Flutter project is initialized.

Do not copy version numbers from old examples.

Expected packages:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flame:
  flutter_riverpod:
  go_router:
  isar:
  isar_flutter_libs:
  firebase_core:
  firebase_analytics:
  firebase_crashlytics:
  firebase_remote_config:
  google_mobile_ads:
  in_app_purchase:
  shared_preferences:
  intl:

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints:
  build_runner:
  isar_generator:
```

This is a planning list, not a final `pubspec.yaml`.

Every package must be verified against the current Flutter stable release before being added.

---

# 22. MVP Technology Scope

## Included

- Flutter shell
- Flame puzzle board
- Riverpod state management
- go_router navigation
- local progress persistence
- theme and settings persistence
- analytics
- crash reporting
- remote configuration defaults
- optional rewarded ads
- one premium entitlement
- English and Turkish localization
- automated tests
- CI checks

## Deferred

- custom backend
- multiplayer
- social accounts
- leaderboards
- chat
- user-generated content
- real-time cloud synchronization
- complex subscription tiers
- Apple Watch
- Vision Pro
- advanced AR features
- procedural AI image generation

Deferred features must not influence the MVP architecture unless a low-cost extension point is clearly justified.

---

# 23. Implementation Order

Recommended order:

1. Create Flutter project.
2. Add analysis rules.
3. Establish app bootstrap.
4. Configure Riverpod.
5. Configure go_router.
6. Create design tokens and themes.
7. Implement the pure Dart puzzle domain engine.
8. Add unit tests for the puzzle engine.
9. Create the Flame gameplay renderer.
10. Connect Riverpod gameplay state to Flame.
11. Implement local persistence.
12. Implement onboarding and home screens.
13. Implement level selection and progression.
14. Add settings and localization.
15. Add Firebase Analytics and Crashlytics.
16. Add Remote Config with safe defaults.
17. Add premium purchase flow.
18. Add rewarded ads.
19. Add integration tests.
20. Configure CI and release builds.

---

# 24. Acceptance Criteria

This technology decision is considered implemented when:

- Flutter and Flame responsibilities are documented and respected
- Riverpod is the only state-management solution
- go_router manages application navigation
- puzzle logic is testable without Flame
- local progress works offline
- Firebase is nonblocking and optional for core gameplay
- ads never interrupt active gameplay
- purchase state is recoverable and restorable
- packages are justified and maintained
- analyzer and tests run in CI
- Android and iOS builds can be produced
- relevant architecture documentation is updated

---

# 25. Final Decision

Pixel Harmony will be developed with:

```text
Flutter + Flame + Riverpod + go_router + local offline persistence
```

Flutter owns the product application.

Flame owns the interactive puzzle board.

The domain layer owns gameplay truth.

Firebase supports analytics, reliability, and controlled configuration, but does not control the offline gameplay experience.

This decision remains active until replaced by an approved Architecture Decision Record.
