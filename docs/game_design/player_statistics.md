# Player Statistics

Player Statistics is a local, offline summary of completions recorded after the
feature was introduced. It tracks total, Journey, Endless, and Daily puzzle
completions; total moves on those completions; and the current and best Daily
streaks. It stores no player, account, or device-identifying information.

Journey progress, Endless progress, and Daily progress remain authoritative.
Statistics is not used for unlocking, seed advancement, streak calculation, or
gameplay decisions. Daily streak values are copied only from the successfully
persisted authoritative Daily result. Existing progress is not converted into
historical completion or move totals because past move counts are unavailable.

Every completion has a stable namespaced identity:

- Journey: level ID
- Endless: generation version and puzzle seed
- Daily: generation version and local date key

The statistics repository stores processed identities with the aggregate under
its own SharedPreferences namespace. Repeated callbacks, replays, rebuilds, and
retries therefore do not double-count an event. This small identity ledger may
grow with Endless play and can be compacted by a future storage migration if it
becomes material.

Progress is persisted before its corresponding statistics write. Statistics
failures are caught at the Riverpod controller boundary and never block puzzle
completion, progression, completion feedback, or navigation. Because the stores
are intentionally isolated rather than transactional, terminating the process
between those two writes can omit that completion from statistics; progression
remains correct and statistics never becomes a second progression system.
