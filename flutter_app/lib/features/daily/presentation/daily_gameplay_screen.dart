import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/app/router/app_router.dart';
import 'package:pixel_harmony/features/daily/application/daily_progress_providers.dart';
import 'package:pixel_harmony/features/daily/domain/daily_puzzle_identity.dart';
import 'package:pixel_harmony/features/gameplay/presentation/gameplay_screen.dart';
import 'package:pixel_harmony/features/statistics/application/player_statistics_providers.dart';
import 'package:pixel_harmony/features/statistics/domain/player_statistics.dart';
import 'package:pixel_harmony/game/generation/procedural_level_providers.dart';
import 'package:pixel_harmony/game/generation/procedural_level_request.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/state/board_state.dart';

class DailyGameplayScreen extends ConsumerStatefulWidget {
  const DailyGameplayScreen({super.key});

  @override
  ConsumerState<DailyGameplayScreen> createState() =>
      _DailyGameplayScreenState();
}

class _DailyGameplayScreenState extends ConsumerState<DailyGameplayScreen>
    with WidgetsBindingObserver {
  late DailyPuzzleIdentity _identity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _identity = ref.read(dailyPuzzleIdentityProvider);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    ref.invalidate(dailyPuzzleIdentityProvider);
    final current = DailyPuzzleIdentity.forLocalDate(
      ref.read(dailyClockProvider).now(),
    );
    if (current != _identity && mounted) {
      setState(() => _identity = current);
    }
  }

  Future<void> _complete(BoardState state) async {
    if (!state.completed) return;
    final progress = await ref
        .read(dailyProgressControllerProvider.notifier)
        .complete(_identity.dateKey);
    if (progress == null || !progress.isCompleted(_identity.dateKey)) return;
    await ref
        .read(playerStatisticsControllerProvider.notifier)
        .record(
          PuzzleCompletionRecord(
            id: 'daily:v${_identity.generationVersion}:${_identity.dateKey}',
            mode: PuzzleCompletionMode.daily,
            moveCount: state.moveCount,
            currentDailyStreak: progress.currentStreak,
            bestDailyStreak: progress.longestStreak,
          ),
        );
  }

  LevelDefinition _generateLevel() {
    final generated = ref
        .read(proceduralLevelGeneratorProvider)
        .generate(
          ProceduralLevelRequest(
            seed: _identity.seed,
            paletteSeed: _identity.seed ^ 0x4441494c,
            boardSize: _identity.boardSize,
            targetDifficulty: _identity.targetDifficulty,
            generatedLevelId:
                'daily_v${_identity.generationVersion}_${_identity.dateKey}',
          ),
        );
    return generated.toLevelDefinition(nameKey: 'dailyPuzzle');
  }

  @override
  Widget build(BuildContext context) {
    return GameplayScreen.daily(
      key: ValueKey(
        'daily_${_identity.generationVersion}_${_identity.dateKey}',
      ),
      level: _generateLevel(),
      dailyDateKey: _identity.dateKey,
      onDailyCompleted: _complete,
      onBackHome: () => context.goNamed(AppRoutes.home),
    );
  }
}
