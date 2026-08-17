# Pixel Harmony branding assets

The current artwork is a temporary, project-owned placeholder built from four
rounded palette tiles. It contains no third-party artwork and must be reviewed
or replaced before store submission.

## Source of truth

Replace this file with the approved transparent foreground artwork:

`assets/branding/app_icon/pixel_harmony_icon_foreground_placeholder.png`

Requirements for its replacement:

- 1024 × 1024 PNG
- transparent foreground canvas
- artwork kept inside the central safe area
- no text or fine details
- project-owned or properly licensed artwork only

The generator composites the foreground onto the opaque Pixel Harmony neutral
background for legacy Android and every iOS AppIcon. It also creates the
transparent adaptive-icon foreground and launch marks.

From `flutter_app/` on Windows, regenerate platform outputs with:

```powershell
powershell -ExecutionPolicy Bypass -File tool/generate_branding_assets.ps1
```

Generated resources live in Android `res/` directories and the iOS
`Assets.xcassets` catalog. Commit both the source and generated resources.
