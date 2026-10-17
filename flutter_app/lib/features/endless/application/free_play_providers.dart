import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/features/endless/domain/free_play_pixel_template_selector.dart';

final freePlayPixelTemplateSelectorProvider =
    Provider<FreePlayPixelTemplateSelector>(
      (ref) => PixelPictureShuffleBag(random: Random()),
    );
