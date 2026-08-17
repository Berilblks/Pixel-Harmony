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
    expect(android12Theme, contains('@drawable/launch_mark'));
  });

  test('central placeholder source and replacement documentation exist', () {
    expect(
      File(
        'assets/branding/app_icon/'
        'pixel_harmony_icon_foreground_placeholder.png',
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
