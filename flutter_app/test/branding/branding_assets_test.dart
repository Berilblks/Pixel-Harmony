import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS AppIcon set is complete, correctly sized, and opaque', () {
    final appIconDirectory = Directory(
      'ios/Runner/Assets.xcassets/AppIcon.appiconset',
    );
    final contents =
        jsonDecode(
              File('${appIconDirectory.path}/Contents.json').readAsStringSync(),
            )
            as Map<String, dynamic>;
    final images = contents['images'] as List<dynamic>;

    for (final image in images.cast<Map<String, dynamic>>()) {
      final filename = image['filename'] as String;
      final logicalSize = double.parse(
        (image['size'] as String).split('x').first,
      );
      final scale = int.parse((image['scale'] as String).replaceAll('x', ''));
      final expectedPixels = (logicalSize * scale).round();
      final png = _readPng('${appIconDirectory.path}/$filename');

      expect(png.width, expectedPixels, reason: filename);
      expect(png.height, expectedPixels, reason: filename);
      expect(png.colorType, 2, reason: '$filename must not contain alpha.');
    }
  });

  test('Android launcher and native splash resources are configured', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final adaptiveIcon =
        File(
          'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
        ).readAsStringSync();
    final android12Theme =
        File(
          'android/app/src/main/res/values-v31/styles.xml',
        ).readAsStringSync();

    expect(manifest, contains('android:label="Pixel Harmony"'));
    expect(manifest, contains('android:icon="@mipmap/ic_launcher"'));
    expect(manifest, contains('android:roundIcon="@mipmap/ic_launcher_round"'));
    expect(adaptiveIcon, contains('@drawable/ic_launcher_foreground'));
    expect(adaptiveIcon, contains('@color/ic_launcher_background'));
    expect(android12Theme, contains('android:windowSplashScreenAnimatedIcon'));
    expect(android12Theme, contains('@drawable/launch_mark_android12'));
    expect(android12Theme, contains('android:windowSplashScreenBrandingImage'));
    expect(android12Theme, contains('@drawable/launch_branding_android12'));

    for (final entry
        in const {
          'mipmap-mdpi': 48,
          'mipmap-hdpi': 72,
          'mipmap-xhdpi': 96,
          'mipmap-xxhdpi': 144,
          'mipmap-xxxhdpi': 192,
        }.entries) {
      final png = _readPng(
        'android/app/src/main/res/${entry.key}/ic_launcher.png',
      );
      expect(png.width, entry.value, reason: entry.key);
      expect(png.height, entry.value, reason: entry.key);
    }

    final foreground = _readPng(
      'android/app/src/main/res/drawable-nodpi/ic_launcher_foreground.png',
    );
    expect(foreground.width, 432);
    expect(foreground.height, 432);
    expect(foreground.colorType, 6, reason: 'Adaptive foreground needs alpha.');

    final android12Mark = _readPng(
      'android/app/src/main/res/drawable-nodpi/launch_mark_android12.png',
    );
    expect(android12Mark.width, 288);
    expect(android12Mark.height, 288);
    expect(android12Mark.colorType, 6);

    final android12Branding = _readPng(
      'android/app/src/main/res/drawable-nodpi/launch_branding_android12.png',
    );
    expect(android12Branding.width, 600);
    expect(android12Branding.height, 144);
    expect(android12Branding.colorType, 6);

    for (final entry
        in const {
          'drawable-mdpi': (200, 230),
          'drawable-hdpi': (300, 345),
          'drawable-xhdpi': (400, 460),
          'drawable-xxhdpi': (600, 690),
          'drawable-xxxhdpi': (800, 920),
        }.entries) {
      final splash = _readPng(
        'android/app/src/main/res/${entry.key}/launch_mark.png',
      );
      expect(splash.width, entry.value.$1, reason: entry.key);
      expect(splash.height, entry.value.$2, reason: entry.key);
      expect(splash.colorType, 6, reason: '${entry.key} needs alpha.');
    }
  });

  test('official source and branding documentation exist', () {
    expect(
      File(
        'assets/branding/app_icon/'
        'pixel_harmony_official.png',
      ).existsSync(),
      isTrue,
    );
    expect(
      File(
        'assets/branding/app_icon/'
        'pixel_harmony_home.png',
      ).existsSync(),
      isTrue,
    );
    expect(File('assets/branding/README.md').existsSync(), isTrue);
    expect(File('tool/generate_branding_assets.ps1').existsSync(), isTrue);
  });
}

_PngHeader _readPng(String path) {
  final bytes = File(path).readAsBytesSync();
  expect(bytes.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]);
  final data = ByteData.sublistView(Uint8List.fromList(bytes));
  return _PngHeader(
    width: data.getUint32(16),
    height: data.getUint32(20),
    colorType: bytes[25],
  );
}

class _PngHeader {
  const _PngHeader({
    required this.width,
    required this.height,
    required this.colorType,
  });

  final int width;
  final int height;
  final int colorType;
}
