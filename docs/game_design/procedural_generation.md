# Procedural Puzzle Generation

Pixel Harmony's first procedural engine is a pure-Dart content source kept
separate from the handcrafted Journey `LevelCatalog`. It does not change
progression or expose an Endless Mode UI.

## Pipeline

1. Validate the seed, supported board size (3–5), target difficulty, and
   optional identifiers.
2. Create stable row-major tile IDs and solution order.
3. Generate a two-dimensional HSL color field from deterministic horizontal
   and vertical hue/lightness spans.
4. Reject palettes with duplicate or nearly indistinguishable neighboring
   colors.
5. Build an unsolved permutation by applying a bounded, deterministic cycle of
   swaps. Harder targets move more distinct positions.
6. Evaluate board size, minimum permutation swaps, misplaced tiles, average
   Manhattan displacement, neighboring-color similarity, and visually close
   neighbor ratio.
7. Evaluate 32 candidates and return the valid candidate closest to the target
   difficulty midpoint. The returned difficulty and score are always the
   evaluator's actual result, even when the requested band cannot be reached.

## Determinism Contract

The engine uses a local xorshift32 random-number generator. It never reads time,
device entropy, or platform randomness. The seed, palette seed, board size,
target difficulty, and generation version fully determine output. Generated
tile IDs use `generated_<seed>_<index>` and correctness continues to compare
IDs, never colors.

`generationVersion` is currently `1`. Any change that alters seeded output,
palette math, permutation behavior, candidate selection, or scoring must
increase this version. Persisted procedural sessions should store both seed and
generation version.

## Color and Difficulty

Palette saturation and lightness stay within conservative bounds. Easy puzzles
use wider hue and lightness spans; hard and expert puzzles use closer—but still
distinguishable—neighbors. Colors are stored as ARGB integers so generation has
no Flutter dependency.

Difficulty is a documented weighted score from 1–100: board size (8%), minimum
swaps (34%), misplaced tiles (20%), normalized displacement (15%), palette
similarity (17%), and close-neighbor ratio (5%), with a one-point baseline.
Scores map to the existing tutorial/easy/medium/hard/expert ranges. Procedural
requests exclude tutorial.

## Known Limitations

- The RGB-distance palette checks are practical rather than perceptually
  uniform; accessibility modes will need stronger color/pattern validation.
- Difficulty is an initial heuristic and does not model human solving paths.
- Candidate selection is bounded rather than guaranteed to hit the requested
  band.
- Version 1 uses controlled permutation cycles, not procedural generation or
  solving of alternative puzzle mechanics.
