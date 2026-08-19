# Journey Campaign

Journey contains 100 sequential levels across 10 chapters of 10 levels each.
Completing Level N unlocks Level N+1; Level 100 is the final Journey level.

Levels 1–36 retain their original tile colors, board sizes, solutions, and
starting permutations. Levels 37–100 were curated with the deterministic
procedural generator version 1, then frozen as ARGB colors and permutation
indices in the runtime catalog. Journey never invokes the procedural generator
while the app is running, so future generator changes cannot alter released
Journey puzzles.

Each generated-derived level has authoring provenance containing its fixed
seed, palette seed, board size, target difficulty, chapter, and generation
version. The authoring script lives at `flutter_app/tool/freeze_journey_levels.dart`.
Regenerating the frozen file is an explicit content-authoring operation and
requires review; it is not an application build or startup step.

Journey progression and completion persistence remain independent from Endless
Mode progress and deterministic seed advancement.
