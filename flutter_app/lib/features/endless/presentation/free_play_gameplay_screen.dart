import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/app/router/app_router.dart';
import 'package:pixel_harmony/features/endless/domain/free_play_configuration.dart';
import 'package:pixel_harmony/features/endless/domain/free_play_level_factory.dart';
import 'package:pixel_harmony/features/endless/application/free_play_providers.dart';
import 'package:pixel_harmony/features/gameplay/presentation/gameplay_screen.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';

class FreePlayGameplayScreen extends ConsumerStatefulWidget {
  const FreePlayGameplayScreen({super.key, required this.configuration});

  final FreePlayConfiguration configuration;

  @override
  ConsumerState<FreePlayGameplayScreen> createState() =>
      _FreePlayGameplayScreenState();
}

class _FreePlayGameplayScreenState
    extends ConsumerState<FreePlayGameplayScreen> {
  static const _sessionSeed = 0x46524545;
  var _sequence = 0;
  late final FreePlayLevelFactory _factory;
  late LevelDefinition _level;

  @override
  void initState() {
    super.initState();
    _factory = FreePlayLevelFactory(
      pixelTemplateSelector: ref.read(freePlayPixelTemplateSelectorProvider),
    );
    _level = _createLevel();
  }

  LevelDefinition _createLevel() {
    final seed = _sessionSeed + _sequence * 7919;
    return _factory.create(
      configuration: widget.configuration,
      seed: seed,
      sequence: _sequence,
    );
  }

  void _openNextPuzzle() {
    setState(() {
      _sequence++;
      _level = _createLevel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameplayScreen.endless(
      key: ValueKey(
        'free_play_${widget.configuration.puzzleType.name}_${widget.configuration.difficulty.name}_$_sequence',
      ),
      level: _level,
      puzzleNumber: _sequence + 1,
      onEndlessCompleted: (_) async {},
      onNextPuzzle: _openNextPuzzle,
      onBackHome: () => context.goNamed(AppRoutes.home),
    );
  }
}
