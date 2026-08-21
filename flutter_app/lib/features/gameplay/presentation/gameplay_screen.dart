import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/app/router/app_router.dart';
import 'package:pixel_harmony/features/achievements/application/achievement_providers.dart';
import 'package:pixel_harmony/features/achievements/presentation/achievement_unlock_feedback.dart';
import 'package:pixel_harmony/core/feedback/game_feedback_controller.dart';
import 'package:pixel_harmony/core/feedback/game_feedback_providers.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/core/localization/level_localizations.dart';
import 'package:pixel_harmony/core/theme/app_design_tokens.dart';
import 'package:pixel_harmony/features/gameplay/presentation/gameplay_completion_controller.dart';
import 'package:pixel_harmony/features/level_progress/application/level_progress_providers.dart';
import 'package:pixel_harmony/features/settings/application/game_feedback_settings_providers.dart';
import 'package:pixel_harmony/features/settings/domain/game_feedback_settings.dart';
import 'package:pixel_harmony/features/statistics/application/player_statistics_providers.dart';
import 'package:pixel_harmony/features/statistics/domain/player_statistics.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/levels/level_progression.dart';
import 'package:pixel_harmony/game/pixel_harmony_game.dart';
import 'package:pixel_harmony/game/state/board_state.dart';

enum GameplayContentSource { journey, daily, endless }

class GameplayScreen extends ConsumerStatefulWidget {
  const GameplayScreen({
    super.key,
    required this.level,
    this.completionController,
  }) : contentSource = GameplayContentSource.journey,
       puzzleNumber = null,
       onEndlessCompleted = null,
       onDailyCompleted = null,
       dailyDateKey = null,
       onNextPuzzle = null,
       onBackHome = null;

  const GameplayScreen.endless({
    super.key,
    required this.level,
    required this.puzzleNumber,
    required this.onEndlessCompleted,
    required this.onNextPuzzle,
    required this.onBackHome,
    this.completionController,
  }) : contentSource = GameplayContentSource.endless,
       onDailyCompleted = null,
       dailyDateKey = null;

  const GameplayScreen.daily({
    super.key,
    required this.level,
    required this.dailyDateKey,
    required this.onDailyCompleted,
    required this.onBackHome,
    this.completionController,
  }) : contentSource = GameplayContentSource.daily,
       puzzleNumber = null,
       onEndlessCompleted = null,
       onNextPuzzle = null;

  final LevelDefinition? level;
  final GameplayCompletionController? completionController;
  final GameplayContentSource contentSource;
  final int? puzzleNumber;
  final Future<void> Function(BoardState state)? onEndlessCompleted;
  final Future<void> Function(BoardState state)? onDailyCompleted;
  final String? dailyDateKey;
  final VoidCallback? onNextPuzzle;
  final VoidCallback? onBackHome;

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
                  : widget.contentSource == GameplayContentSource.endless
                  ? widget.onEndlessCompleted
                  : widget.contentSource == GameplayContentSource.daily
                  ? widget.onDailyCompleted
                  : (state) => _completeJourney(level, state),
        );
  }

  Future<void> _completeJourney(LevelDefinition level, BoardState state) async {
    final persisted = await ref
        .read(levelProgressControllerProvider.notifier)
        .markCompleted(level.id);
    if (!persisted) return;
    final recorded = await ref
        .read(playerStatisticsControllerProvider.notifier)
        .record(
          PuzzleCompletionRecord(
            id: 'journey:${level.id}',
            mode: PuzzleCompletionMode.journey,
            moveCount: state.moveCount,
          ),
        );
    if (!recorded) return;
    final statistics = ref.read(playerStatisticsControllerProvider).value;
    if (statistics == null) return;
    final newlyUnlocked = await ref
        .read(achievementControllerProvider.notifier)
        .evaluateAfterCompletion(statistics);
    if (mounted) showAchievementUnlockFeedback(context, newlyUnlocked);
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

  Future<void> _openNextPuzzle() async {
    if (_isNavigatingToNextLevel) return;
    setState(() => _isNavigatingToNextLevel = true);
    await _completionController.completionPersistence;
    if (!mounted) return;
    widget.onNextPuzzle?.call();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(achievementControllerProvider);
    final level = widget.level;
    if (level == null) {
      return _LevelNotFoundView(
        onBackToLevels: () => context.goNamed(AppRoutes.levelSelect),
      );
    }

    AsyncValue<Set<String>> progress = const AsyncData({});
    if (widget.contentSource == GameplayContentSource.journey) {
      progress = ref.watch(levelProgressControllerProvider);
    }
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

    final progression = LevelProgression(levels: LevelCatalog.levels);
    if (widget.contentSource == GameplayContentSource.journey) {
      final completedLevelIds = progress.asData?.value ?? const <String>{};
      if (!progression.isUnlocked(level.id, completedLevelIds)) {
        return _LevelLockedView(
          onBackToLevels: () => context.goNamed(AppRoutes.levelSelect),
        );
      }
    }

    final game = _game ??= _createGame(level);
    final nextLevel =
        widget.contentSource == GameplayContentSource.journey
            ? progression.nextLevel(level.id)
            : null;

    final localizations = AppLocalizations.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: Text(
            widget.contentSource == GameplayContentSource.endless
                ? localizations.puzzleLabel(widget.puzzleNumber!)
                : widget.contentSource == GameplayContentSource.daily
                ? localizations.dailyPuzzle
                : localizedLevelName(localizations, level),
            key: const Key('gameplayLevelTitle'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppPalette.mutedInk),
          ),
        ),
        actions: [
          Semantics(
            label: localizations.hint,
            button: true,
            excludeSemantics: true,
            child: IconButton(
              key: const Key('hintButton'),
              tooltip: localizations.hint,
              onPressed: () => game.requestHint(),
              icon: const Icon(Icons.lightbulb_outline),
            ),
          ),
          Semantics(
            label: localizations.restartLevel,
            button: true,
            excludeSemantics: true,
            child: IconButton(
              key: const Key('restartLevelButton'),
              tooltip: localizations.restartLevel,
              onPressed: _restartLevel,
              icon: const Icon(Icons.restart_alt),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            key: const Key('gameplayGameWidget'),
            child: GameWidget<PixelHarmonyGame>(
              key: ValueKey(_sessionGeneration),
              game: game,
            ),
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
                          puzzleNumber: widget.puzzleNumber,
                          isEndless:
                              widget.contentSource ==
                              GameplayContentSource.endless,
                          isDaily:
                              widget.contentSource ==
                              GameplayContentSource.daily,
                          isFinalLevel: nextLevel == null,
                          onNextLevel:
                              widget.contentSource ==
                                      GameplayContentSource.endless
                                  ? _isNavigatingToNextLevel
                                      ? null
                                      : _openNextPuzzle
                                  : nextLevel == null ||
                                      _isNavigatingToNextLevel
                                  ? null
                                  : () => _openNextLevel(nextLevel),
                          onBackToLevels:
                              widget.contentSource !=
                                      GameplayContentSource.journey
                                  ? widget.onBackHome!
                                  : () =>
                                      context.goNamed(AppRoutes.levelSelect),
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
    required this.puzzleNumber,
    required this.isEndless,
    required this.isDaily,
    required this.isFinalLevel,
    required this.onNextLevel,
    required this.onBackToLevels,
  });

  final int moveCount;
  final int? puzzleNumber;
  final bool isEndless;
  final bool isDaily;
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
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppPalette.surface.withValues(alpha: 0.98),
                borderRadius: BorderRadius.circular(AppRadii.xl),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.65),
                ),
                boxShadow: AppShadows.floating,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DecoratedBox(
                      decoration: const BoxDecoration(
                        color: AppPalette.surfaceCompleted,
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        child: Icon(
                          Icons.check_rounded,
                          size: 24,
                          color: AppPalette.completed,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.compact),
                    Text(
                      isDaily
                          ? localizations.dailyCompleteTitle
                          : isEndless
                          ? localizations.completionTitle
                          : isFinalLevel
                          ? localizations.allLevelsCompleteTitle
                          : localizations.completionTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      isDaily
                          ? localizations.dailyCompleteSubtitle
                          : isEndless
                          ? localizations.completionSubtitle
                          : isFinalLevel
                          ? localizations.allLevelsCompleteSubtitle
                          : localizations.completionSubtitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (isEndless) ...[
                      Text(
                        localizations.puzzleLabel(puzzleNumber!),
                        key: const Key('endlessCompletionPuzzleLabel'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppPalette.surfaceMuted,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Text(
                          localizations.completionMoves(moveCount),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: Key(
                          isDaily
                              ? 'dailyBackHomeButton'
                              : isEndless
                              ? 'nextPuzzleButton'
                              : isFinalLevel
                              ? 'finalBackToLevelsButton'
                              : 'nextLevelButton',
                        ),
                        onPressed:
                            isDaily || (!isEndless && isFinalLevel)
                                ? onBackToLevels
                                : onNextLevel,
                        child: Text(
                          isDaily
                              ? localizations.backHome
                              : isEndless
                              ? localizations.nextPuzzle
                              : isFinalLevel
                              ? localizations.backToLevels
                              : localizations.nextLevel,
                        ),
                      ),
                    ),
                    if (!isDaily && (isEndless || !isFinalLevel)) ...[
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        key: Key(
                          isEndless
                              ? 'endlessBackHomeButton'
                              : 'completionBackToLevelsButton',
                        ),
                        onPressed: onBackToLevels,
                        child: Text(
                          isEndless
                              ? localizations.backHome
                              : localizations.backToLevels,
                        ),
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
