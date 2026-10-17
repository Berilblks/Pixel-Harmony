import 'dart:math';

import 'package:pixel_harmony/features/endless/domain/free_play_configuration.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_catalog.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_template.dart';

abstract interface class FreePlayPixelTemplateSelector {
  PixelPictureTemplate next(FreePlayDifficulty difficulty);

  int poolSize(FreePlayDifficulty difficulty);
}

class PixelPictureShuffleBag implements FreePlayPixelTemplateSelector {
  PixelPictureShuffleBag({required Random random}) : _random = random {
    PixelPictureCatalog.validate();
  }

  final Random _random;
  final Map<FreePlayDifficulty, _ShuffleBagState> _states = {};

  @override
  PixelPictureTemplate next(FreePlayDifficulty difficulty) {
    final state = _states.putIfAbsent(
      difficulty,
      () => _ShuffleBagState(_eligibleTemplates(difficulty)),
    );
    if (state.remaining.isEmpty) {
      state.remaining.addAll(state.candidates);
      state.remaining.shuffle(_random);
      if (state.remaining.length > 1 &&
          state.remaining.first.id == state.lastTemplateId) {
        final replacement = state.remaining.indexWhere(
          (template) => template.id != state.lastTemplateId,
        );
        final first = state.remaining.first;
        state.remaining[0] = state.remaining[replacement];
        state.remaining[replacement] = first;
      }
    }
    final selected = state.remaining.removeAt(0);
    state.lastTemplateId = selected.id;
    return selected;
  }

  @override
  int poolSize(FreePlayDifficulty difficulty) =>
      _eligibleTemplates(difficulty).length;

  static List<PixelPictureTemplate> _eligibleTemplates(
    FreePlayDifficulty difficulty,
  ) {
    final accepted = switch (difficulty) {
      FreePlayDifficulty.relaxed => PixelPictureDifficulty.beginner,
      FreePlayDifficulty.normal => PixelPictureDifficulty.early,
      FreePlayDifficulty.hard => PixelPictureDifficulty.medium,
      FreePlayDifficulty.expert => PixelPictureDifficulty.advanced,
    };
    final candidates = PixelPictureCatalog.templates
        .where((template) => template.difficulty == accepted)
        .toList(growable: false);
    if (candidates.isEmpty) {
      throw StateError(
        'No Pixel Art templates are available for ${difficulty.name}.',
      );
    }
    return candidates;
  }
}

class _ShuffleBagState {
  _ShuffleBagState(this.candidates);

  final List<PixelPictureTemplate> candidates;
  final List<PixelPictureTemplate> remaining = [];
  String? lastTemplateId;
}
