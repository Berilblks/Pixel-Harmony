# Pixel Harmony branding assets

The current official artwork is the user-supplied glossy four-color Pixel
Harmony icon. It is used by Home and as the Android launcher-icon source.

## Source of truth

Official source artwork:

`assets/branding/app_icon/pixel_harmony_official.png`

The Flutter Home screen uses the transparency-prepared derivative at
`assets/branding/app_icon/pixel_harmony_home.png`. This removes only the
opaque white canvas outside the mark; launcher resources continue to use the
official source and are unchanged by Home UI work.

The Android adaptive foreground is a transparency-prepared derivative of this
source. Its padded source occupies 82% of the foreground canvas so Android's
circular and rounded-square masks retain the full outer frame. Legacy launcher
icons use 90% of that already-padded source with the neutral Pixel Harmony
background.

Android 11 and earlier splash resources combine the same transparent mark with
the `PIXEL HARMONY` wordmark. Android 12 and later use a separately padded,
icon-only splash drawable because the platform clips the animated-icon slot.
The iOS icon set has not yet been regenerated from this artwork.

The generator composites the foreground onto the opaque Pixel Harmony neutral
background for legacy Android and every iOS AppIcon. It also creates the
transparent adaptive-icon foreground and launch marks.

From `flutter_app/` on Windows, regenerate platform outputs with:

```powershell
powershell -ExecutionPolicy Bypass -File tool/generate_branding_assets.ps1
```

Generated resources live in Android `res/` directories and the iOS
`Assets.xcassets` catalog. Commit both the source and generated resources.
