import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/app/app.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PixelHarmonyApp()));
}
