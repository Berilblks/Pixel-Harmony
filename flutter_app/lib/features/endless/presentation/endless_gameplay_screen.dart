import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/app/router/app_router.dart';
import 'package:pixel_harmony/features/achievements/application/achievement_providers.dart';
import 'package:pixel_harmony/features/achievements/presentation/achievement_unlock_feedback.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/core/theme/app_design_tokens.dart';
import 'package:pixel_harmony/features/endless/application/endless_progress_providers.dart';
import 'package:pixel_harmony/features/endless/domain/endless_progress.dart';
import 'package:pixel_harmony/features/gameplay/presentation/gameplay_screen.dart';
import 'package:pixel_harmony/features/statistics/application/player_statistics_providers.dart';
import 'package:pixel_harmony/features/statistics/domain/player_statistics.dart';
import 'package:pixel_harmony/game/generation/procedural_level_request.dart';
import 'package:pixel_harmony/game/generation/procedural_level_providers.dart';
import 'package:pixel_harmony/game/state/board_state.dart';

class EndlessGameplayScreen extends ConsumerStatefulWidget {
  const EndlessGameplayScreen({super.key});

  @override
  ConsumerState<EndlessGameplayScreen> createState() =>
      _EndlessGameplayScreenState();
}

class _EndlessGameplayScreenState extends ConsumerState<EndlessGameplayScreen> {
  EndlessProgress? _displayedProgress;

  Future<void> _completePuzzle(
    EndlessProgress progress,
    BoardState state,
  ) async {
    if (!state.completed) return;
    await ref
        .read(endlessProgressControllerProvider.notifier)
        .advance(progress);
    final recorded = await ref
        .read(playerStatisticsControllerProvider.notifier)
        .record(
          PuzzleCompletionRecord(
            id: 'endless:v${progress.generationVersion}:${progress.currentSeed}',
            mode: PuzzleCompletionMode.endless,
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

  void _showNextPuzzle() {
    final next = ref.read(endlessProgressControllerProvider).value;
    if (next == null || !mounted) return;
    setState(() => _displayedProgress = next);
  }

  @override
  Widget build(BuildContext context) {
    final progressState = ref.watch(endlessProgressControllerProvider);
    return progressState.when(
      loading: () => const _EndlessLoadingView(),
      error:
          (error, stackTrace) => _EndlessErrorView(
            onReset:
                () =>
                    ref
                        .read(endlessProgressControllerProvider.notifier)
                        .reset(),
          ),
      data: (storedProgress) {
        final progress = _displayedProgress ??= storedProgress;
        final generated = ref
            .read(proceduralLevelGeneratorProvider)
            .generate(
              ProceduralLevelRequest(
                seed: progress.currentSeed,
                boardSize: progress.currentBoardSize,
                targetDifficulty: progress.currentTargetDifficulty,
                generatedLevelId:
                    'endless_v${progress.generationVersion}_${progress.currentSeed}',
              ),
            );
        final level = generated.toLevelDefinition(
          number: progress.puzzleNumber,
          nameKey: 'endlessPuzzle',
        );
        return GameplayScreen.endless(
          key: ValueKey(
            'endless_${progress.generationVersion}_${progress.currentSeed}',
          ),
          level: level,
          puzzleNumber: progress.puzzleNumber,
          onEndlessCompleted: (state) => _completePuzzle(progress, state),
          onNextPuzzle: _showNextPuzzle,
          onBackHome: () => context.goNamed(AppRoutes.home),
        );
      },
    );
  }
}

class _EndlessLoadingView extends StatelessWidget {
  const _EndlessLoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).endlessMode)),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _EndlessErrorView extends StatelessWidget {
  const _EndlessErrorView({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.endlessMode)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizations.endlessProgressError,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                key: const Key('resetEndlessButton'),
                onPressed: onReset,
                child: Text(localizations.resetEndless),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
