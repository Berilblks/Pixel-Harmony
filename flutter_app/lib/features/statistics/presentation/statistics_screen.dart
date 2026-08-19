import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/core/theme/app_design_tokens.dart';
import 'package:pixel_harmony/features/statistics/application/player_statistics_providers.dart';
import 'package:pixel_harmony/features/statistics/domain/player_statistics.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final state = ref.watch(playerStatisticsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.statisticsTitle)),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      localizations.statisticsLoadError,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.tonal(
                      key: const Key('statisticsRetryButton'),
                      onPressed:
                          () =>
                              ref
                                  .read(
                                    playerStatisticsControllerProvider.notifier,
                                  )
                                  .refresh(),
                      child: Text(localizations.retry),
                    ),
                  ],
                ),
              ),
            ),
        data: (statistics) => _StatisticsContent(statistics: statistics),
      ),
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  const _StatisticsContent({required this.statistics});

  final PlayerStatistics statistics;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        key: const Key('statisticsScrollView'),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionTitle(localizations.statisticsOverview),
                const SizedBox(height: AppSpacing.sm),
                _StatRow(
                  key: const Key('statTotalPuzzles'),
                  label: localizations.totalPuzzles,
                  value: statistics.totalPuzzlesCompleted,
                ),
                _StatRow(
                  key: const Key('statTotalMoves'),
                  label: localizations.totalMoves,
                  value: statistics.totalMoves,
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle(localizations.statisticsModes),
                const SizedBox(height: AppSpacing.sm),
                _StatRow(
                  label: localizations.journeyMode,
                  value: statistics.journeyPuzzlesCompleted,
                ),
                _StatRow(
                  label: localizations.endlessMode,
                  value: statistics.endlessPuzzlesCompleted,
                ),
                _StatRow(
                  label: localizations.dailyPuzzle,
                  value: statistics.dailyPuzzlesCompleted,
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle(localizations.dailyPuzzle),
                const SizedBox(height: AppSpacing.sm),
                _StatRow(
                  label: localizations.currentStreak,
                  value: statistics.currentDailyStreak,
                ),
                _StatRow(
                  label: localizations.bestStreak,
                  value: statistics.bestDailyStreak,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({super.key, required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppPalette.border),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.compact,
            ),
            child: Row(
              children: [
                Expanded(child: Text(label)),
                const SizedBox(width: AppSpacing.md),
                Text('$value', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
