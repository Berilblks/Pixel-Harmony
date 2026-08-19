# Endless Mode

Endless Mode is an offline procedural content source that remains independent
from the handcrafted Journey catalog and its unlock/completion progress.

## Progress and Seed Contract

The persisted progress contains the current seed, completed puzzle count,
derived board size/difficulty metadata, and procedural generation version. Tile
arrays and moves are not stored because the current puzzle is recreated from
these deterministic inputs.

Version 1 starts at seed `0x50485831`. After a completed puzzle, the next seed
is calculated with a versioned 31-bit LCG:

```text
nextSeed = (currentSeed * 1664525 + 1013904223 + completedPuzzleCount)
           & 0x7fffffff
```

Advancement compares the expected stored progress before writing, so repeated
completion requests are idempotent. Restarting or leaving an unfinished puzzle
does not advance its identity.

## Difficulty Curve

- Puzzles 1–5: 3×3 easy
- Puzzles 6–10: 3×3 medium
- Puzzles 11–20: 4×4 medium
- Puzzles 21–35: 4×4 hard
- Puzzles 36–50: 5×5 hard
- Puzzles 51+: 5×5 expert

The curve is derived from the completed count. Persisted board/difficulty
metadata is informational and preserves the versioned contract.

## Persistence and Versioning

Endless progress uses its own SharedPreferences key and repository boundary.
Only generation version 1 is supported. Unsupported stored versions are never
used to generate a replacement puzzle; the UI presents a recoverable reset.
For the MVP, reopening an unfinished puzzle restores its identity and original
board arrangement rather than individual moves.

Endless generated definitions feed the existing `GameSession`, Flame board,
hint, restart, completion, sound, and haptic paths. Endless completion never
writes Journey progress, and Journey completion never writes Endless progress.
