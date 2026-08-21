# Achievements

Pixel Harmony has 14 local, non-competitive achievements: First Harmony, Ten
Harmonies, Hundred Harmonies, Journey Begins, Halfway There, Journey Complete,
Endless Explorer, Endless Wanderer, Endless Devotion, Daily Rhythm, Daily
Devotion, Chapter Master, Perfect Journey, and A Thousand Moves. Achievements
grant no currency, progression, or gameplay advantage.

The pure-Dart evaluator reads Player Statistics plus authoritative Journey
completion IDs. Daily streak and mode totals come from Player Statistics only
after its successful synchronization with the underlying progress repositories.
Chapter Master is derived when all 10 IDs in any actual LevelCatalog chapter
are complete; Perfect Journey requires all 10 chapters. No separate chapter
progress is stored.

Persistence contains only unlocked achievement IDs and their first local unlock
timestamps under an independent SharedPreferences namespace. Current progress
is always recalculated. Unlock writes validate IDs and are idempotent, so an
achievement never relocks and duplicate completion callbacks cannot unlock it
again.

Evaluation runs outside Flame after a successful statistics write. A newly
unlocked batch produces at most one quiet Flutter snackbar; multiple unlocks are
summarized rather than stacked. Repository or evaluation failures are contained
and never block puzzle completion, Journey progression, Endless advancement,
Daily progress, completion overlays, or navigation.
