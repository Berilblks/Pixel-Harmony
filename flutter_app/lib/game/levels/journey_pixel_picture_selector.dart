import 'package:pixel_harmony/game/levels/pixel_picture_difficulty.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_template.dart';

class JourneyPixelTemplateMetadata {
  const JourneyPixelTemplateMetadata({
    required this.assessment,
    required this.paletteFamily,
  });

  final PixelPictureDifficultyAssessment assessment;
  final int paletteFamily;

  PixelPictureTemplate get template => assessment.template;
  int get score => assessment.score;
}

/// Deterministic Journey selection independent of a fixed catalog size.
///
/// Each catalog entry is used once in its supplied difficulty order. For the
/// original 100-art catalog, version 8 changes only post-catalog reuse. Reuse
/// draws from a broad high-difficulty pool and spaces identical IDs by a full
/// cycle.
class JourneyPixelPictureSelector {
  JourneyPixelPictureSelector({
    required List<JourneyPixelTemplateMetadata> metadata,
  }) : _metadata = List.unmodifiable(metadata),
       _reuseOrder = List.unmodifiable(_buildReuseOrder(metadata)) {
    if (_metadata.isEmpty) {
      throw ArgumentError.value(metadata, 'metadata', 'Cannot be empty.');
    }
    final ids = _metadata.map((item) => item.template.id).toSet();
    if (ids.length != _metadata.length) {
      throw ArgumentError.value(metadata, 'metadata', 'IDs must be unique.');
    }
  }

  static const originalCatalogSize = 100;
  static const minimumReusePoolSize = 40;

  final List<JourneyPixelTemplateMetadata> _metadata;
  final List<JourneyPixelTemplateMetadata> _reuseOrder;

  int get catalogSize => _metadata.length;
  int get reusePoolSize => _reuseOrder.length;

  PixelPictureTemplate select(int pictureOrdinal) {
    if (pictureOrdinal < 0) {
      throw ArgumentError.value(pictureOrdinal, 'pictureOrdinal');
    }
    if (pictureOrdinal < _metadata.length) {
      return _metadata[pictureOrdinal].template;
    }

    final reusableOrdinal = pictureOrdinal - _metadata.length;
    final position = reusableOrdinal % _reuseOrder.length;
    return _reuseOrder[position].template;
  }

  static List<JourneyPixelTemplateMetadata> _buildReuseOrder(
    List<JourneyPixelTemplateMetadata> metadata,
  ) {
    final targetPoolSize = (metadata.length * 0.4).ceil().clamp(
      metadata.length < minimumReusePoolSize
          ? metadata.length
          : minimumReusePoolSize,
      metadata.length,
    );
    final remaining = metadata
        .skip(metadata.length - targetPoolSize)
        .toList(growable: true);
    final result = <JourneyPixelTemplateMetadata>[];
    final recent = <JourneyPixelTemplateMetadata>[];
    recent.addAll(
      metadata.skip((metadata.length - 15).clamp(0, metadata.length)),
    );
    while (remaining.isNotEmpty) {
      remaining.sort((first, second) {
        final firstPenalty = _penalty(recent, first);
        final secondPenalty = _penalty(recent, second);
        if (firstPenalty != secondPenalty) {
          return firstPenalty.compareTo(secondPenalty);
        }
        final previous = recent.last;
        final scoreGap = (first.score - previous.score).abs().compareTo(
          (second.score - previous.score).abs(),
        );
        return scoreGap != 0
            ? scoreGap
            : first.template.id.compareTo(second.template.id);
      });
      final selected = remaining.removeAt(0);
      result.add(selected);
      recent.add(selected);
      if (recent.length > 15) recent.removeAt(0);
    }
    return result;
  }

  static int _penalty(
    List<JourneyPixelTemplateMetadata> recent,
    JourneyPixelTemplateMetadata current,
  ) {
    if (recent.isEmpty) return 0;
    final previous = recent.last;
    var penalty = 0;
    final recentIndex = recent.indexWhere(
      (item) => item.template.id == current.template.id,
    );
    if (recentIndex != -1) penalty += 100000 + recentIndex * 100;
    if (previous.template.category == current.template.category) {
      penalty += 1000;
    }
    if (previous.paletteFamily == current.paletteFamily) penalty += 300;
    return penalty;
  }
}
