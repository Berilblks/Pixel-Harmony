import 'dart:async';

import 'package:flame/game.dart' hide Matrix4;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/app/router/app_router.dart';
import 'package:pixel_harmony/core/analytics/analytics_providers.dart';
import 'package:pixel_harmony/core/analytics/analytics_taxonomy.dart';
import 'package:pixel_harmony/features/achievements/application/achievement_providers.dart';
import 'package:pixel_harmony/features/achievements/presentation/achievement_unlock_feedback.dart';
import 'package:pixel_harmony/core/feedback/game_feedback_controller.dart';
import 'package:pixel_harmony/core/feedback/game_feedback_providers.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/core/localization/level_localizations.dart';
import 'package:pixel_harmony/core/localization/pixel_picture_localizations.dart';
import 'package:pixel_harmony/core/theme/app_design_tokens.dart';
import 'package:pixel_harmony/features/gameplay/presentation/gameplay_completion_controller.dart';
import 'package:pixel_harmony/features/gameplay/application/pixel_picture_onboarding_provider.dart';
import 'package:pixel_harmony/features/gameplay/presentation/pixel_art_renderer.dart';
import 'package:pixel_harmony/features/gameplay/presentation/pixel_coloring_viewport.dart';
import 'package:pixel_harmony/features/level_progress/application/level_progress_providers.dart';
import 'package:pixel_harmony/features/settings/application/game_feedback_settings_providers.dart';
import 'package:pixel_harmony/features/settings/domain/game_feedback_settings.dart';
import 'package:pixel_harmony/features/statistics/application/player_statistics_providers.dart';
import 'package:pixel_harmony/features/statistics/domain/player_statistics.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/levels/level_progression.dart';
import 'package:pixel_harmony/game/levels/pixel_picture_catalog.dart';
import 'package:pixel_harmony/game/coloring/pixel_coloring_state.dart';
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
  bool _startLogged = false;
  bool _reduceMotion = false;
  bool _showCompletedPixelArt = false;
  Timer? _completionRevealTimer;
  Timer? _pictureArtworkTimer;
  PixelColoringState? _coloringState;
  late final TransformationController _pixelColoringTransformController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pixelColoringTransformController = TransformationController();
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
    unawaited(
      ref
          .read(appAnalyticsServiceProvider)
          .logEvent(
            AnalyticsEvents.journeyLevelComplete,
            parameters: {
              AnalyticsParameters.levelNumber: level.number,
              AnalyticsParameters.boardSize: level.boardSize,
              AnalyticsParameters.moves: state.moveCount,
              AnalyticsParameters.difficulty: level.difficulty.name,
              AnalyticsParameters.puzzleType:
                  level.puzzleType == JourneyPuzzleType.gradient
                      ? AnalyticsValues.gradient
                      : AnalyticsValues.pixelPicture,
            },
          ),
    );
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
    _completionRevealTimer?.cancel();
    _pictureArtworkTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _pixelColoringTransformController.dispose();
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
    final game = PixelHarmonyGame(
      level: level,
      onTilePickedUp: _feedbackController.tilePickedUp,
      onSwapCompleted: _feedbackController.acceptedSwap,
      onColoringStateChanged: (state) {
        if (mounted) setState(() => _coloringState = state);
      },
      onCompleted: (state) {
        _feedbackController.levelCompleted();
        _completionRevealTimer?.cancel();
        final isPicture = level.puzzleType == JourneyPuzzleType.pixelPicture;
        if (isPicture) {
          final artworkDelay =
              _reduceMotion ? Duration.zero : const Duration(milliseconds: 500);
          _pictureArtworkTimer = Timer(artworkDelay, () {
            if (mounted) setState(() => _showCompletedPixelArt = true);
          });
        }
        final revealDelay =
            isPicture
                ? _reduceMotion
                    ? const Duration(milliseconds: 1500)
                    : const Duration(milliseconds: 2500)
                : Duration.zero;
        if (revealDelay == Duration.zero) {
          _completionController.showCompletion(state);
        } else {
          _completionRevealTimer = Timer(revealDelay, () {
            if (mounted) _completionController.showCompletion(state);
          });
        }
      },
    );
    if (!_startLogged &&
        widget.contentSource == GameplayContentSource.journey) {
      _startLogged = true;
      unawaited(
        ref
            .read(appAnalyticsServiceProvider)
            .logEvent(
              AnalyticsEvents.journeyLevelStart,
              parameters: {
                AnalyticsParameters.levelNumber: level.number,
                AnalyticsParameters.boardSize: level.boardSize,
                AnalyticsParameters.puzzleType:
                    level.puzzleType == JourneyPuzzleType.gradient
                        ? AnalyticsValues.gradient
                        : AnalyticsValues.pixelPicture,
              },
            ),
      );
    }
    return game;
  }

  String get _analyticsMode => switch (widget.contentSource) {
    GameplayContentSource.journey => AnalyticsValues.journey,
    GameplayContentSource.endless => AnalyticsValues.endless,
    GameplayContentSource.daily => AnalyticsValues.daily,
  };

  void _requestHint(PixelHarmonyGame game) {
    if (!game.requestHint()) return;
    unawaited(
      ref
          .read(appAnalyticsServiceProvider)
          .logEvent(
            AnalyticsEvents.hintUsed,
            parameters: {
              AnalyticsParameters.mode: _analyticsMode,
              AnalyticsParameters.boardSize: widget.level!.boardSize,
              if (widget.contentSource == GameplayContentSource.journey)
                AnalyticsParameters.puzzleType:
                    widget.level!.puzzleType == JourneyPuzzleType.gradient
                        ? AnalyticsValues.gradient
                        : AnalyticsValues.pixelPicture,
            },
          ),
    );
  }

  void _restartLevel() {
    final level = widget.level;
    if (level == null) return;

    _completionRevealTimer?.cancel();
    _pictureArtworkTimer?.cancel();
    _pixelColoringTransformController.value = Matrix4.identity();
    setState(() {
      _sessionGeneration++;
      _game = _createGame(level);
      _completionController.reset();
      _feedbackController.resetSession();
      _isNavigatingToNextLevel = false;
      _showCompletedPixelArt = false;
      _coloringState = null;
    });
    unawaited(
      ref
          .read(appAnalyticsServiceProvider)
          .logEvent(
            AnalyticsEvents.levelRestart,
            parameters: {
              AnalyticsParameters.mode: _analyticsMode,
              AnalyticsParameters.boardSize: level.boardSize,
            },
          ),
    );
  }

  Future<void> _openNextLevel(LevelDefinition nextLevel) async {
    if (_isNavigatingToNextLevel) return;
    setState(() => _isNavigatingToNextLevel = true);

    await _completionController.completionPersistence;
    if (!mounted) return;

    final completedLevelIds =
        ref.read(levelProgressControllerProvider).value ?? const <String>{};
    const progression = LevelProgression.journey();
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

    const progression = LevelProgression.journey();
    if (widget.contentSource == GameplayContentSource.journey) {
      final completedLevelIds = progress.asData?.value ?? const <String>{};
      if (!progression.isUnlocked(level.id, completedLevelIds)) {
        return _LevelLockedView(
          onBackToLevels: () => context.goNamed(AppRoutes.levelSelect),
        );
      }
    }

    final game = _game ??= _createGame(level);
    final coloringState = _coloringState ?? game.coloringSession?.state;
    final nextLevel =
        widget.contentSource == GameplayContentSource.journey
            ? progression.nextLevel(level.id)
            : null;

    final localizations = AppLocalizations.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    _reduceMotion = reduceMotion;
    final gradientTutorialSeen =
        level.number == 1 &&
                level.puzzleType == JourneyPuzzleType.gradient &&
                widget.contentSource == GameplayContentSource.journey
            ? ref.watch(gradientTutorialSeenProvider)
            : const AsyncData(true);
    final showGradientTutorial = gradientTutorialSeen.when(
      data: (seen) => !seen,
      loading: () => true,
      error: (_, _) => true,
    );
    final showPixelPictureHeader =
        widget.contentSource == GameplayContentSource.journey &&
        level.puzzleType == JourneyPuzzleType.pixelPicture;
    final pixelPictureCompleted = coloringState?.completed ?? false;
    final isPixelPicture = level.puzzleType == JourneyPuzzleType.pixelPicture;
    final showPixelPictureChrome =
        showPixelPictureHeader && !pixelPictureCompleted;
    final showPixelColorPalette =
        isPixelPicture &&
        coloringState != null &&
        !pixelPictureCompleted &&
        !_showCompletedPixelArt;
    Widget gameSurface = SizedBox.expand(
      key: const Key('gameplayGameWidget'),
      child: GameWidget<PixelHarmonyGame>(
        key: ValueKey(_sessionGeneration),
        game: game,
      ),
    );
    if (isPixelPicture) {
      gameSurface = PixelColoringViewport(
        key: ValueKey('pixelColoringViewport_$_sessionGeneration'),
        controller: _pixelColoringTransformController,
        resetTooltip: localizations.resetZoom,
        onMultiTouchChanged: game.setColoringInteractionBlocked,
        child: gameSurface,
      );
    }
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
          if (showPixelPictureChrome)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Icon(
                Icons.extension_rounded,
                key: Key('pixelPictureModeIcon'),
                size: 20,
                color: AppPalette.mutedInk,
              ),
            ),
          if (!pixelPictureCompleted)
            Semantics(
              label:
                  level.puzzleType == JourneyPuzzleType.pixelPicture
                      ? localizations.pixelPictureHint
                      : localizations.hint,
              button: true,
              excludeSemantics: true,
              child: IconButton(
                key: const Key('hintButton'),
                tooltip:
                    level.puzzleType == JourneyPuzzleType.pixelPicture
                        ? localizations.pixelPictureHint
                        : localizations.hint,
                onPressed: () => _requestHint(game),
                icon: const Icon(Icons.lightbulb_outline),
              ),
            ),
          if (!pixelPictureCompleted)
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
          if (showGradientTutorial ||
              showPixelPictureHeader ||
              showPixelColorPalette)
            Positioned.fill(
              top:
                  showGradientTutorial
                      ? 112
                      : showPixelPictureHeader
                      ? 86
                      : 0,
              bottom: showPixelColorPalette ? 108 : 0,
              child: gameSurface,
            )
          else
            gameSurface,
          if (showGradientTutorial)
            Align(
              alignment: Alignment.topCenter,
              child: _GradientTutorial(
                level: level,
                onAcknowledge:
                    () =>
                        ref
                            .read(gradientTutorialSeenProvider.notifier)
                            .acknowledge(),
              ),
            ),
          if (showPixelPictureChrome)
            Align(
              alignment: Alignment.topCenter,
              child: _PixelPictureGoalHeader(level: level),
            ),
          if (showPixelColorPalette)
            Align(
              alignment: Alignment.bottomCenter,
              child: _PixelColorPalette(
                state: coloringState,
                onSelected: game.selectColor,
              ),
            ),
          IgnorePointer(
            child: AnimatedSwitcher(
              duration:
                  reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 800),
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder:
                  (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween(begin: 0.92, end: 1.0).animate(animation),
                      child: child,
                    ),
                  ),
              child:
                  _showCompletedPixelArt && level.pictureTemplateId != null
                      ? SizedBox.expand(
                        key: const Key('completedPixelArtPresentation'),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: PixelArtRenderer(
                            data: PixelArtRenderData.fromTemplate(
                              PixelPictureCatalog.byId(
                                level.pictureTemplateId!,
                              ),
                            ),
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
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

class _PixelPictureGoalHeader extends StatelessWidget {
  const _PixelPictureGoalHeader({required this.level});

  final LevelDefinition level;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final template = PixelPictureCatalog.byId(level.pictureTemplateId!);
    final figure = localizedPixelFigureName(localizations, template);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.extension_rounded,
                  size: 18,
                  color: AppPalette.completed,
                ),
                const SizedBox(width: AppSpacing.compact),
                Text(
                  localizations.pixelPictureCreateTarget(figure).toUpperCase(),
                  key: const Key('pixelPictureTargetName'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              localizations.pixelPictureSwapInstruction,
              key: const Key('pixelPicturePlayInstruction'),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppPalette.mutedInk),
            ),
          ],
        ),
      ),
    );
  }
}

class _PixelColorPalette extends StatelessWidget {
  const _PixelColorPalette({required this.state, required this.onSelected});

  final PixelColoringState state;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final template = state.template;
    final indices = template.requiredPaletteIndices.toList()..sort();
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Material(
          color: AppPalette.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                key: const Key('pixelColorPalette'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final paletteIndex in indices)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _PixelColorSwatch(
                        identifier: template.identifierForPalette(paletteIndex),
                        color: Color(template.palette[paletteIndex]),
                        selected: state.selectedPaletteIndex == paletteIndex,
                        completed: state.isPaletteComplete(paletteIndex),
                        onTap: () => onSelected(paletteIndex),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PixelColorSwatch extends StatelessWidget {
  const _PixelColorSwatch({
    required this.identifier,
    required this.color,
    required this.selected,
    required this.completed,
    required this.onTap,
  });

  final int identifier;
  final Color color;
  final bool selected;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Color $identifier',
      selected: selected,
      button: true,
      child: InkWell(
        key: Key('pixelColorSwatch_$identifier'),
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedScale(
          scale: selected ? 1.08 : 1,
          duration: AppMotion.quick,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: selected ? AppPalette.ink : AppPalette.surface,
                width: selected ? 3 : 2,
              ),
              boxShadow:
                  selected
                      ? const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
            alignment: Alignment.center,
            child:
                completed
                    ? const Icon(Icons.check_rounded, size: 22)
                    : Text(
                      '$identifier',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color:
                            ThemeData.estimateBrightnessForColor(color) ==
                                    Brightness.dark
                                ? Colors.white
                                : AppPalette.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}

class _GradientTutorial extends StatelessWidget {
  const _GradientTutorial({required this.level, required this.onAcknowledge});

  final LevelDefinition level;
  final VoidCallback onAcknowledge;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final tilesById = {
      for (final tile in level.tiles) tile.id: Color(tile.colorValue),
    };
    final startColor = tilesById[level.solutionTileOrder.first]!;
    final endColor = tilesById[level.solutionTileOrder.last]!;

    return SafeArea(
      bottom: false,
      child: Semantics(
        label: localizations.targetOrder,
        container: true,
        child: Container(
          key: const Key('journeyRuleCue'),
          margin: const EdgeInsets.only(top: AppSpacing.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppPalette.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppPalette.border),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizations.gradientInstruction,
                key: const Key('gradientInstruction'),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppPalette.mutedInk),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _EndpointDot(
                    key: const Key('gradientStartIndicator'),
                    color: startColor,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Icon(
                      Icons.south_east_rounded,
                      key: Key('gradientDirectionArrow'),
                      size: 22,
                      color: AppPalette.mutedInk,
                    ),
                  ),
                  _EndpointDot(
                    key: const Key('gradientEndIndicator'),
                    color: endColor,
                  ),
                ],
              ),
              TextButton(
                key: const Key('gradientTutorialAcknowledge'),
                onPressed: onAcknowledge,
                child: Text(localizations.gotIt),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EndpointDot extends StatelessWidget {
  const _EndpointDot({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: AppShadows.card,
      ),
      child: const SizedBox.square(dimension: 20),
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
