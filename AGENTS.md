# Pixel Harmony Development Rules

## Purpose

Pixel Harmony is a calm, offline-first color puzzle game for Android and iOS, designed to remain maintainable by a solo developer.

## Approved Stack

- Dart and Flutter for the application.
- Flame for the interactive puzzle board only.
- Riverpod for state management and dependency injection.
- `go_router` for navigation.
- Isar is the preferred local store, subject to the documented compatibility check.
- Firebase Analytics, Crashlytics, and Remote Config are later supporting services; core play must not depend on them.

Do not add or replace dependencies, frameworks, or product decisions without approval. Record significant technology changes in an ADR.

## Responsibility Boundaries

- Flutter owns navigation and every non-game screen, including onboarding, settings, level selection, achievements, and premium flows.
- Flame owns board rendering, tile input, swaps, board animations, and board effects. It must not own navigation, persistence, progression, or product state.
- Pure Dart owns puzzle generation, move validation, scoring, and completion rules. Domain code must not depend on Flutter, Flame, storage, or Firebase.
- UI and Flame report intentions to controllers/use cases; repositories and services sit behind interfaces. Never access persistence or Firebase directly from screens or Flame components.

## Working Rules

- Before each task, read this file and the relevant documents under `docs/`; also read `PROJECT_RULES.md` and `CODEX.md` when they contain guidance.
- Preserve offline-first behavior and safe local defaults. Network and ad failures must never block core gameplay.
- Never interrupt active gameplay with ads.
- Keep changes small, focused, reviewable, and practical for one developer.
- Keep business logic out of widget `build()` methods and avoid mutable global state or service locators.
- Centralize named routes and user-facing localized strings; target English and Turkish.
- Do not commit secrets. Explain ignored analyzer warnings and justify new packages before adding them.
- Prefer clear code over premature abstractions or optimization; profile performance before optimizing.

## Testing and Quality

- Unit-test pure Dart puzzle and domain rules independently of Flutter and Flame.
- Add widget tests for reusable UI and important screen states, Flame tests for board behavior, and integration tests for critical offline flows.
- Add regression tests with bug fixes when practical. Keep formatting, analysis, and tests passing.
- Once the Flutter project exists, run from `flutter_app/`:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter test integration_test
```
