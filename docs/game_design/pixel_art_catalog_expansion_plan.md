# Pixel Art catalog expansion plan

## Current limitation

The 100 approved artworks support one unique pass. The first reuse begins at
Pixel occurrence 101 near Journey level 503. No selection
algorithm can provide endless unique recognizable artwork from a finite catalog.
The version-8 selector broadens sustained expert reuse from 30 to
40 templates from the first
post-catalog appearance. Identical IDs are separated by a complete reuse cycle,
while levels 1–500 retain their first unique appearance mappings.

## Metadata contract

Authored template metadata remains stable and catalog-driven:

- `id` and `familyId`: permanent identity and compatibility keys
- localized English/Turkish names
- category
- minimum Journey level and authored difficulty
- rows, columns, background index, palette, and pixel matrix
- computed complexity: paintable cells, palette count/similarity, region count,
  small regions, and edge-detail ratio
- computed palette-family bucket for visual-repeat avoidance

The selector consumes this metadata list and contains no hardcoded template
IDs. A 200-, 300-, or 500-item catalog therefore uses every supplied item once
before a proportional high-difficulty reuse pool is needed.

## Recommended authored expansion

| Catalog size | Unique Pixel appearances | Approximate Journey reach | Recommendation |
|---:|---:|---:|---|
| 100 | 100 | ~500 | Current approved library; repetition is unavoidable afterward |
| 200 | 200 | ~1000 | Add advanced objects, animals, vehicles, and scenes |
| 300 | 300 | ~1500 | Add visually distinct expert subjects and palettes |
| 500 | 500 | ~2500 | Supports a long unique campaign before controlled reuse |

New artwork should be individually authored and approved. Random pixel patterns,
matrix scaling, recoloring an existing silhouette, or duplicate subject IDs do
not count as catalog growth. Adding artwork changes future deterministic
selection and therefore requires a deliberate Journey generation-version bump;
existing template IDs and completed level IDs remain untouched.
