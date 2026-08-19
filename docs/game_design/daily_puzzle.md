# Daily Puzzle

Pixel Harmony creates one deterministic Daily Puzzle for each device-local
calendar date. The identity uses an ISO `YYYY-MM-DD` key, the procedural
generation version, and the fixed `pixel_harmony.daily_puzzle` namespace. A
pure-Dart FNV-1a hash derives a stable positive seed; runtime `hashCode` and
random state are not used.

The seed deterministically selects a supported MVP profile: mostly 4×4 medium
or hard puzzles, with occasional 3×3 medium and 5×5 hard puzzles. Generated
tiles are not persisted. Reopening the same local day regenerates the same
puzzle, while a generation-version change intentionally creates a new identity.

Daily progress is stored separately from Journey and Endless progress. It
contains the last completed date, current and longest streaks, and total unique
Daily completions. A first completion starts a streak at one; consecutive local
days increment it; a gap resets it to one; and duplicate same-day completion is
idempotent. If the device clock moves earlier than the last completion, progress
is left unchanged. This is conservative consistency handling, not anti-cheat.

The injectable clock makes date behavior deterministic in tests. When the app
resumes, Daily identity is refreshed against the device-local calendar. A date
change replaces an open Daily session with the new day's deterministic puzzle.
Daily completion never unlocks Journey levels or advances Endless state, and
neither of those modes modifies Daily progress.
