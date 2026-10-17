# Journey

Journey is an effectively endless, deterministic sequence. Completing level N
unlocks level N+1. The first 100 definitions are cached for the level-select UI;
higher levels are generated on demand from their stable number and the Journey
generation version.

Journey mixes two puzzle types:

- Gradient puzzles keep one permanent rule: arrange a single-hue palette from
  dark to light in row-major order. Early levels use broad perceptual separation;
  later levels become subtler. Adjacent shades use CIELAB Delta E 76 floors of
  6.0 (levels 1–10), 3.0 (11–30), 1.0 (31–70), and 0.25 (71+), while strict
  increasing relative luminance remains mandatory. Gradient boards progress
  from 2×2 (levels 1–5), through 3×3, 4×4, 5×5, 6×6, and 7×7 tiers, reaching
  8×8 at level 201 and beyond. Pixel Coloring appearances retain their own
  canonical template dimensions.
- Pixel Coloring puzzles color a predefined 5×5–16×16 figure from a curated
  color-by-number template. They begin at level 5 and occupy about one level in
  five. The template, numbered cells, and required palette are deterministic for
  the Journey level. The canonical template grid is also the final artwork.

The UI teaches the gradient rule once without showing the solved sequence, then
persists that acknowledgement and leaves later boards free of repeated
instruction copy. Pixel Coloring names the target subject and opens directly on
the prepared numbered canvas without a separate tutorial or solution preview.

The player selects a numbered color swatch in the Flutter palette, then taps
matching numbered cells in the Flame canvas. Correct taps fill with a short,
soft animation; incorrect colors are rejected without penalty. Finishing a
palette color marks its swatch complete and selects the next unfinished color.
A hint fills exactly one correct unfinished cell. Restart clears the current
in-memory coloring; partial coloring is intentionally not persisted in this MVP.
The production content library contains 100 individually authored canonical
templates across symbols, nature, food, animals, objects, vehicles, and scenes.
The first 100 Pixel Coloring occurrences present each artwork once in curated
difficulty order before normal deterministic reuse begins. Grid sizes grow from
5×5 to 16×16 and later art contains newly authored detail rather than scaled-up
early silhouettes. Cells have one-logical-pixel grid lines,
square styling, no card shadows, and one outer canvas frame. On completion, the
solved pixel art remains visible for 500 ms. Puzzle assistance then fades away
and the exact same template cells and palette are rendered gaplessly at a larger
scale on a calm presentation background. No template-specific illustration or
artistic substitution exists. Reduced motion removes the scale/fade transition
while retaining a short reward pause.

Tap-to-paint remains the primary interaction. On larger canvases, dragging
across the board paints only cells matching the selected color; wrong and
already-painted cells remain unchanged, and drag painting avoids per-cell
haptic spam. The palette scrolls horizontally when seven colors do not fit.

Ten-level groups remain an internal generation and progress mechanism only.
They have no themed names and do not define a finite end to Journey. Level
selection is one continuous, vertically scrolling path of numbered stops. It
uses lazy rendering, opens near the first incomplete stop, and can continue
beyond the cached first 100 definitions without a visual endpoint. Existing
achievement identifiers remain stable, but their user-facing goals refer to
Journey level milestones rather than chapters.

Journey progression and completion persistence remain independent from Endless
and Daily modes. Those modes retain their separate procedural generator and
generation version.

Analytics continues to emit the existing `pixel_picture` puzzle-type value for
dashboard compatibility even though the user-facing mechanic is now Pixel
Coloring. No event names or historical dimensions were migrated.

Journey generation version 5 intentionally replaces procedural silhouette
recipes with the 100-art curated content library. Gradient seeds remain pinned
to their version-3 inputs, and stable level IDs preserve existing completion
progress. Existing completed levels are not reset; uncompleted Pixel Coloring
levels resolve to their version-5 canonical artwork when opened.
