import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/app/router/app_router.dart';
import 'package:pixel_harmony/core/feedback/game_feedback_controller.dart';
import 'package:pixel_harmony/core/feedback/game_feedback_providers.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/core/localization/level_localizations.dart';
import 'package:pixel_harmony/core/theme/app_design_tokens.dart';
import 'package:pixel_harmony/features/gameplay/presentation/gameplay_completion_controller.dart';
import 'package:pixel_harmony/features/level_progress/application/level_progress_providers.dart';
import 'package:pixel_harmony/features/settings/application/game_feedback_settings_providers.dart';
import 'package:pixel_harmony/features/settings/domain/game_feedback_settings.dart';
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

class _GameplayScreenState extends ConsumerState<GameplayScreen>
    with WidgetsBindingObserver {
  late final GameplayCompletionController _completionController;
  late final bool _ownsCompletionController;
  PixelHarmonyGame? _game;
  late final GameFeedbackController _feedbackController;
  int _sessionGeneration = 0;
  bool _isNavigatingToNextLevel = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _feedbackController = GameFeedbackController(
      audioService: ref.read(gameAudioServiceProvider),
      hapticService: ref.read(hapticServiceProvider),
    );
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
    WidgetsBinding.instance.removeObserver(this);
    if (_ownsCompletionController) {
      _completionController.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _feedbackController.setAppActive(state == AppLifecycleState.resumed);
  }

  PixelHarmonyGame _createGame(LevelDefinition level) {
    return PixelHarmonyGame(
      level: level,
      onTilePickedUp: _feedbackController.tilePickedUp,
      onSwapCompleted: _feedbackController.acceptedSwap,
      onCompleted: (state) {
        _feedbackController.levelCompleted();
        _completionController.showCompletion(state);
      },
    );
  }

  void _restartLevel() {
    final level = widget.level;
    if (level == null) return;

    setState(() {
      _sessionGeneration++;
      _game = _createGame(level);
      _completionController.reset();
      _feedbackController.resetSession();
      _isNavigatingToNextLevel = false;
    });
  }

  Future<void> _openNextLevel(LevelDefinition nextLevel) async {
    if (_isNavigatingToNextLevel) return;
    setState(() => _isNavigatingToNextLevel = true);

    await _completionController.completionPersistence;
    if (!mounted) return;

    final completedLevelIds =
        ref.read(levelProgressControllerProvider).value ?? const <String>{};
    final progression = LevelProgression(levels: LevelCatalog.levels);
    if (!progression.isUnlocked(nextLevel.id, completedLevelIds)) {
      setState(() => _isNavigatingToNextLevel = false);
      return;
    }

    context.pushReplacementNamed(
      AppRoutes.gameplay,
      pathParameters: {'levelId': nextLevel.id},
    );
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
    final feedbackSettings = ref.watch(gameFeedbackSettingsControllerProvider);
    _feedbackController.updateSettings(
      feedbackSettings.value ??
          const GameFeedbackSettings(
            soundEffectsEnabled: false,
            hapticsEnabled: false,
          ),
    );
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

    final game = _game ??= _createGame(level);
    final nextLevel = progression.nextLevel(level.id);

    final localizations = AppLocalizations.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            key: const Key('restartLevelButton'),
            tooltip: localizations.restartLevel,
            onPressed: _restartLevel,
            icon: const Icon(Icons.restart_alt),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
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
                child: SizedBox.expand(
                  key: const Key('gameplayGameWidget'),
                  child: GameWidget<PixelHarmonyGame>(
                    key: ValueKey(_sessionGeneration),
                    game: game,
                  ),
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
                          isFinalLevel: nextLevel == null,
                          onNextLevel:
                              nextLevel == null || _isNavigatingToNextLevel
                                  ? null
                                  : () => _openNextLevel(nextLevel),
                          onBackToLevels:
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
    required this.isFinalLevel,
    required this.onNextLevel,
    required this.onBackToLevels,
  });

  final int moveCount;
  final bool isFinalLevel;
  final VoidCallback? onNextLevel;
  final VoidCallback onBackToLevels;

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
                      isFinalLevel
                          ? localizations.allLevelsCompleteTitle
                          : localizations.completionTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      isFinalLevel
                          ? localizations.allLevelsCompleteSubtitle
                          : localizations.completionSubtitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(localizations.completionMoves(moveCount)),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      key: Key(
                        isFinalLevel
                            ? 'finalBackToLevelsButton'
                            : 'nextLevelButton',
                      ),
                      onPressed: isFinalLevel ? onBackToLevels : onNextLevel,
                      child: Text(
                        isFinalLevel
                            ? localizations.backToLevels
                            : localizations.nextLevel,
                      ),
                    ),
                    if (!isFinalLevel) ...[
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        key: const Key('completionBackToLevelsButton'),
                        onPressed: onBackToLevels,
                        child: Text(localizations.backToLevels),
                      ),
                    ],
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
