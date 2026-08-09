import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/app/router/app_router.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/features/gameplay/presentation/gameplay_completion_controller.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/pixel_harmony_game.dart';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({
    super.key,
    required this.level,
    this.completionController,
  });

  final LevelDefinition? level;
  final GameplayCompletionController? completionController;

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  late final GameplayCompletionController _completionController;
  late final bool _ownsCompletionController;
  late final PixelHarmonyGame? _game;

  @override
  void initState() {
    super.initState();
    _ownsCompletionController = widget.completionController == null;
    _completionController =
        widget.completionController ?? GameplayCompletionController();
    final level = widget.level;
    _game =
        level == null
            ? null
            : PixelHarmonyGame(
              level: level,
              onCompleted: _completionController.showCompletion,
            );
  }

  @override
  void dispose() {
    if (_ownsCompletionController) {
      _completionController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    if (game == null) {
      return _LevelNotFoundView(
        onBackToLevels: () => context.goNamed(AppRoutes.levelSelect),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).gameplayTitle)),
      body: Stack(
        children: [
          GameWidget<PixelHarmonyGame>(
            key: const Key('gameplayGameWidget'),
            game: game,
          ),
          AnimatedBuilder(
            animation: _completionController,
            builder: (context, child) {
              final completion = _completionController.completion;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOut,
                child:
                    completion == null
                        ? const SizedBox.shrink()
                        : _LevelCompleteOverlay(
                          key: const Key('levelCompleteOverlay'),
                          moveCount: completion.moveCount,
                          onContinue:
                              () => context.goNamed(AppRoutes.levelSelect),
                        ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LevelNotFoundView extends StatelessWidget {
  const _LevelNotFoundView({required this.onBackToLevels});

  final VoidCallback onBackToLevels;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.gameplayTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizations.levelNotFound,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('backToLevelsButton'),
                onPressed: onBackToLevels,
                child: Text(localizations.backToLevels),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelCompleteOverlay extends StatelessWidget {
  const _LevelCompleteOverlay({
    super.key,
    required this.moveCount,
    required this.onContinue,
  });

  final int moveCount;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.96),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      localizations.completionTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.completionSubtitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(localizations.completionMoves(moveCount)),
                    const SizedBox(height: 20),
                    FilledButton(
                      key: const Key('completionContinueButton'),
                      onPressed: onContinue,
                      child: Text(localizations.completionContinue),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
