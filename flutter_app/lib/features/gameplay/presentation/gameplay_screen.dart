import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/app/router/app_router.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/core/localization/level_localizations.dart';
import 'package:pixel_harmony/core/theme/app_design_tokens.dart';
import 'package:pixel_harmony/features/gameplay/presentation/gameplay_completion_controller.dart';
import 'package:pixel_harmony/features/level_progress/application/level_progress_providers.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/levels/level_progression.dart';
import 'package:pixel_harmony/game/pixel_harmony_game.dart';

class GameplayScreen extends ConsumerStatefulWidget {
  const GameplayScreen({
    super.key,
    required this.level,
    this.completionController,
  });

  final LevelDefinition? level;
  final GameplayCompletionController? completionController;

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen> {
  late final GameplayCompletionController _completionController;
  late final bool _ownsCompletionController;
  PixelHarmonyGame? _game;

  @override
  void initState() {
    super.initState();
    _ownsCompletionController = widget.completionController == null;
    final level = widget.level;
    _completionController =
        widget.completionController ??
        GameplayCompletionController(
          onCompletion:
              level == null
                  ? null
                  : (_) => ref
                      .read(levelProgressControllerProvider.notifier)
                      .markCompleted(level.id),
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
    final level = widget.level;
    if (level == null) {
      return _LevelNotFoundView(
        onBackToLevels: () => context.goNamed(AppRoutes.levelSelect),
      );
    }

    final progress = ref.watch(levelProgressControllerProvider);
    if (progress.isLoading) {
      return const _GameplayLoadingView();
    }

    final completedLevelIds = progress.asData?.value ?? const <String>{};
    final progression = LevelProgression(levels: LevelCatalog.levels);
    if (!progression.isUnlocked(level.id, completedLevelIds)) {
      return _LevelLockedView(
        onBackToLevels: () => context.goNamed(AppRoutes.levelSelect),
      );
    }

    final game =
        _game ??= PixelHarmonyGame(
          level: level,
          onCompleted: _completionController.showCompletion,
        );

    final localizations = AppLocalizations.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Semantics(
                  header: true,
                  child: Text(
                    localizedLevelName(localizations, level),
                    key: const Key('gameplayLevelTitle'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              Expanded(
                child: GameWidget<PixelHarmonyGame>(
                  key: const Key('gameplayGameWidget'),
                  game: game,
                ),
              ),
            ],
          ),
          AnimatedBuilder(
            animation: _completionController,
            builder: (context, child) {
              final completion = _completionController.completion;
              return AnimatedSwitcher(
                duration: reduceMotion ? Duration.zero : AppMotion.gentle,
                switchInCurve: Curves.easeInOut,
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

class _GameplayLoadingView extends StatelessWidget {
  const _GameplayLoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).gameplayTitle)),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _LevelLockedView extends StatelessWidget {
  const _LevelLockedView({required this.onBackToLevels});

  final VoidCallback onBackToLevels;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.gameplayTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 40),
              const SizedBox(height: AppSpacing.md),
              Text(
                localizations.lockedLabel,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(localizations.lockedMessage, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                key: const Key('lockedBackToLevelsButton'),
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
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizations.levelNotFound,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
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
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              color: AppPalette.surface.withValues(alpha: 0.97),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 32,
                      color: AppPalette.completed,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      localizations.completionTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      localizations.completionSubtitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(localizations.completionMoves(moveCount)),
                    const SizedBox(height: AppSpacing.lg),
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
