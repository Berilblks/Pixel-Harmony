import 'package:pixel_harmony/game/levels/pixel_picture_template.dart';
import 'package:pixel_harmony/game/pixel_art/templates/tier_1_templates.dart';
import 'package:pixel_harmony/game/pixel_art/templates/tier_2_templates.dart';
import 'package:pixel_harmony/game/pixel_art/templates/tier_3_templates.dart';
import 'package:pixel_harmony/game/pixel_art/templates/tier_4_templates.dart';
import 'package:pixel_harmony/game/pixel_art/templates/tier_5_templates.dart';

abstract final class PixelPictureCatalog {
  static const recentAppearanceWindow = 15;

  static final List<PixelPictureTemplate> templates = List.unmodifiable([
    ...tier1Templates,
    ...tier2Templates,
    ...tier3Templates,
    ...tier4Templates,
    ...tier5Templates,
  ]);

  static final Map<String, PixelPictureTemplate> _byId = {
    for (final template in templates) template.id: template,
  };

  static PixelPictureTemplate byId(String id) =>
      _byId[id] ??
      templates.firstWhere(
        (template) => template.familyId == id,
        orElse: () => throw StateError('Unknown Pixel Art template: $id'),
      );

  /// Occurrence order, rather than Journey level modulo, drives content.
  /// Every curated artwork appears once before normal reuse begins.
  static PixelPictureTemplate selectForJourney({
    required int levelNumber,
    required int pictureOrdinal,
  }) {
    if (levelNumber < 1 || pictureOrdinal < 0) {
      throw ArgumentError('Journey inputs must be non-negative.');
    }
    if (pictureOrdinal < templates.length) return templates[pictureOrdinal];
    const advancedStart = 80;
    return templates[advancedStart + (pictureOrdinal - templates.length) % 20];
  }

  static List<PixelPictureTemplate> eligibleForLevel(int levelNumber) {
    if (levelNumber < 1) throw ArgumentError.value(levelNumber, 'levelNumber');
    final unlockedTier = switch (levelNumber) {
      < 101 => 0,
      < 201 => 1,
      < 301 => 2,
      < 401 => 3,
      _ => 4,
    };
    return templates.take((unlockedTier + 1) * 20).toList(growable: false);
  }

  static void validate() {
    if (templates.length != 100) {
      throw StateError(
        'The production Pixel Art catalog must contain 100 items.',
      );
    }
    final ids = <String>{};
    final names = <String>{};
    for (final template in templates) {
      template.validate();
      if (!ids.add(template.id)) {
        throw StateError('Duplicate Pixel Art template ID: ${template.id}');
      }
      final identity = '${template.englishName}|${template.turkishName}';
      if (!names.add(identity)) {
        throw StateError('Duplicate Pixel Art subject: $identity');
      }
    }
  }
}
