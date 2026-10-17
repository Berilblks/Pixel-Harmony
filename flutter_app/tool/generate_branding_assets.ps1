param(
    [string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$sourcePath = Join-Path $ProjectRoot 'assets/branding/app_icon/pixel_harmony_official.png'
$transparentLogoPath = Join-Path $ProjectRoot 'assets/branding/app_icon/pixel_harmony_home.png'
$backgroundColor = [System.Drawing.ColorTranslator]::FromHtml('#F3F6F3')

function New-DirectoryForFile([string]$Path) {
    $directory = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory | Out-Null
    }
}

function Add-RoundedRectangle(
    [System.Drawing.Drawing2D.GraphicsPath]$Path,
    [float]$X,
    [float]$Y,
    [float]$Width,
    [float]$Height,
    [float]$Radius
) {
    $diameter = $Radius * 2
    $Path.AddArc($X, $Y, $diameter, $diameter, 180, 90)
    $Path.AddArc($X + $Width - $diameter, $Y, $diameter, $diameter, 270, 90)
    $Path.AddArc($X + $Width - $diameter, $Y + $Height - $diameter, $diameter, $diameter, 0, 90)
    $Path.AddArc($X, $Y + $Height - $diameter, $diameter, $diameter, 90, 90)
    $Path.CloseFigure()
}

function New-PlaceholderForeground([string]$Path) {
    New-DirectoryForFile $Path
    $bitmap = [System.Drawing.Bitmap]::new(1024, 1024, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.Clear([System.Drawing.Color]::Transparent)
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $tiles = @(
            @{ X = 212; Y = 212; Color = '#5BC0EB' },
            @{ X = 536; Y = 212; Color = '#9BC53D' },
            @{ X = 212; Y = 536; Color = '#FDE74C' },
            @{ X = 536; Y = 536; Color = '#E55934' }
        )
        foreach ($tile in $tiles) {
            $pathShape = [System.Drawing.Drawing2D.GraphicsPath]::new()
            $brush = [System.Drawing.SolidBrush]::new(
                [System.Drawing.ColorTranslator]::FromHtml($tile.Color)
            )
            try {
                Add-RoundedRectangle $pathShape $tile.X $tile.Y 276 276 48
                $graphics.FillPath($brush, $pathShape)
            } finally {
                $brush.Dispose()
                $pathShape.Dispose()
            }
        }
        $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

function Export-Icon(
    [System.Drawing.Image]$Source,
    [int]$Size,
    [string]$Path,
    [bool]$OpaqueBackground
) {
    New-DirectoryForFile $Path
    $pixelFormat = if ($OpaqueBackground) {
        [System.Drawing.Imaging.PixelFormat]::Format24bppRgb
    } else {
        [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
    }
    $bitmap = [System.Drawing.Bitmap]::new($Size, $Size, $pixelFormat)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.Clear($(if ($OpaqueBackground) { $backgroundColor } else { [System.Drawing.Color]::Transparent }))
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.DrawImage($Source, 0, 0, $Size, $Size)
        $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

function Export-PaddedLogo(
    [System.Drawing.Image]$Source,
    [int]$Size,
    [double]$ArtworkFraction,
    [string]$Path,
    [bool]$OpaqueBackground
) {
    New-DirectoryForFile $Path
    $pixelFormat = if ($OpaqueBackground) {
        [System.Drawing.Imaging.PixelFormat]::Format24bppRgb
    } else {
        [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
    }
    $bitmap = [System.Drawing.Bitmap]::new($Size, $Size, $pixelFormat)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.Clear($(if ($OpaqueBackground) { $backgroundColor } else { [System.Drawing.Color]::Transparent }))
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $artworkSize = [int][Math]::Round($Size * $ArtworkFraction)
        $offset = [int][Math]::Round(($Size - $artworkSize) / 2)
        $graphics.DrawImage($Source, $offset, $offset, $artworkSize, $artworkSize)
        $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

function Export-SplashComposition(
    [System.Drawing.Image]$Source,
    [double]$Density,
    [string]$Path
) {
    New-DirectoryForFile $Path
    $width = [int][Math]::Round(200 * $Density)
    $height = [int][Math]::Round(230 * $Density)
    $logoSize = [int][Math]::Round(156 * $Density)
    $bitmap = [System.Drawing.Bitmap]::new($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.Clear([System.Drawing.Color]::Transparent)
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
        $logoX = [int](($width - $logoSize) / 2)
        $graphics.DrawImage($Source, $logoX, 0, $logoSize, $logoSize)

        $font = [System.Drawing.Font]::new(
            [System.Drawing.FontFamily]::GenericSansSerif,
            18 * $Density,
            [System.Drawing.FontStyle]::Bold,
            [System.Drawing.GraphicsUnit]::Pixel
        )
        $brush = [System.Drawing.SolidBrush]::new(
            [System.Drawing.ColorTranslator]::FromHtml('#7458C8')
        )
        $format = [System.Drawing.StringFormat]::new()
        try {
            $format.Alignment = [System.Drawing.StringAlignment]::Center
            $format.LineAlignment = [System.Drawing.StringAlignment]::Center
            $titleBounds = [System.Drawing.RectangleF]::new(
                0,
                170 * $Density,
                $width,
                30 * $Density
            )
            $graphics.DrawString('PIXEL HARMONY', $font, $brush, $titleBounds, $format)
        } finally {
            $format.Dispose()
            $brush.Dispose()
            $font.Dispose()
        }
        $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

function Export-SplashBranding([string]$Path) {
    New-DirectoryForFile $Path
    $bitmap = [System.Drawing.Bitmap]::new(600, 144, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.Clear([System.Drawing.Color]::Transparent)
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
        $font = [System.Drawing.Font]::new(
            [System.Drawing.FontFamily]::GenericSansSerif,
            54,
            [System.Drawing.FontStyle]::Bold,
            [System.Drawing.GraphicsUnit]::Pixel
        )
        $brush = [System.Drawing.SolidBrush]::new(
            [System.Drawing.ColorTranslator]::FromHtml('#7458C8')
        )
        $format = [System.Drawing.StringFormat]::new()
        try {
            $format.Alignment = [System.Drawing.StringAlignment]::Center
            $format.LineAlignment = [System.Drawing.StringAlignment]::Center
            $graphics.DrawString(
                'PIXEL HARMONY',
                $font,
                $brush,
                [System.Drawing.RectangleF]::new(0, 0, 600, 144),
                $format
            )
        } finally {
            $format.Dispose()
            $brush.Dispose()
            $font.Dispose()
        }
        $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

function Export-LaunchMark(
    [System.Drawing.Image]$Source,
    [int]$Size,
    [string]$Path
) {
    New-DirectoryForFile $Path
    $bitmap = [System.Drawing.Bitmap]::new($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.Clear([System.Drawing.Color]::Transparent)
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $destination = [System.Drawing.Rectangle]::new(0, 0, $Size, $Size)
        $sourceCrop = [System.Drawing.Rectangle]::new(164, 164, 696, 696)
        $graphics.DrawImage($Source, $destination, $sourceCrop, [System.Drawing.GraphicsUnit]::Pixel)
        $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

if (-not (Test-Path -LiteralPath $sourcePath)) {
    throw "Official Pixel Harmony source artwork not found: $sourcePath"
}
if (-not (Test-Path -LiteralPath $transparentLogoPath)) {
    throw "Transparent Pixel Harmony artwork not found: $transparentLogoPath"
}

$source = [System.Drawing.Image]::FromFile($sourcePath)
$transparentLogo = [System.Drawing.Image]::FromFile($transparentLogoPath)
try {
    $androidIconSizes = @{
        'mipmap-mdpi' = 48
        'mipmap-hdpi' = 72
        'mipmap-xhdpi' = 96
        'mipmap-xxhdpi' = 144
        'mipmap-xxxhdpi' = 192
    }
    foreach ($entry in $androidIconSizes.GetEnumerator()) {
        $directory = Join-Path $ProjectRoot "android/app/src/main/res/$($entry.Key)"
        Export-PaddedLogo $transparentLogo $entry.Value 0.90 (Join-Path $directory 'ic_launcher.png') $true
        Export-PaddedLogo $transparentLogo $entry.Value 0.90 (Join-Path $directory 'ic_launcher_round.png') $true
    }

    # The adaptive layer is intentionally smaller than the legacy artwork so
    # circular and rounded-square launcher masks retain the complete frame.
    Export-PaddedLogo $transparentLogo 432 0.82 (Join-Path $ProjectRoot 'android/app/src/main/res/drawable-nodpi/ic_launcher_foreground.png') $false
    Export-PaddedLogo $transparentLogo 288 0.72 (Join-Path $ProjectRoot 'android/app/src/main/res/drawable-nodpi/launch_mark_android12.png') $false
    Export-SplashBranding (Join-Path $ProjectRoot 'android/app/src/main/res/drawable-nodpi/launch_branding_android12.png')

    $androidSplashDensities = @{
        'drawable-mdpi' = 1
        'drawable-hdpi' = 1.5
        'drawable-xhdpi' = 2
        'drawable-xxhdpi' = 3
        'drawable-xxxhdpi' = 4
    }
    foreach ($entry in $androidSplashDensities.GetEnumerator()) {
        Export-SplashComposition $transparentLogo $entry.Value (Join-Path $ProjectRoot "android/app/src/main/res/$($entry.Key)/launch_mark.png")
    }

    $iosIconDirectory = Join-Path $ProjectRoot 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    $iosIcons = @{
        'Icon-App-20x20@1x.png' = 20
        'Icon-App-20x20@2x.png' = 40
        'Icon-App-20x20@3x.png' = 60
        'Icon-App-29x29@1x.png' = 29
        'Icon-App-29x29@2x.png' = 58
        'Icon-App-29x29@3x.png' = 87
        'Icon-App-40x40@1x.png' = 40
        'Icon-App-40x40@2x.png' = 80
        'Icon-App-40x40@3x.png' = 120
        'Icon-App-60x60@2x.png' = 120
        'Icon-App-60x60@3x.png' = 180
        'Icon-App-76x76@1x.png' = 76
        'Icon-App-76x76@2x.png' = 152
        'Icon-App-83.5x83.5@2x.png' = 167
        'Icon-App-1024x1024@1x.png' = 1024
    }
    foreach ($entry in $iosIcons.GetEnumerator()) {
        Export-Icon $source $entry.Value (Join-Path $iosIconDirectory $entry.Key) $true
    }

    $iosLaunchDirectory = Join-Path $ProjectRoot 'ios/Runner/Assets.xcassets/LaunchImage.imageset'
    Export-LaunchMark $source 120 (Join-Path $iosLaunchDirectory 'LaunchImage.png')
    Export-LaunchMark $source 240 (Join-Path $iosLaunchDirectory 'LaunchImage@2x.png')
    Export-LaunchMark $source 360 (Join-Path $iosLaunchDirectory 'LaunchImage@3x.png')
} finally {
    $transparentLogo.Dispose()
    $source.Dispose()
}

Write-Output "Generated Pixel Harmony branding resources from $sourcePath"
