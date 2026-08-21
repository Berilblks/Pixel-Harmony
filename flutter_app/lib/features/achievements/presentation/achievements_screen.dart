import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/core/theme/app_design_tokens.dart';
import 'package:pixel_harmony/features/achievements/application/achievement_providers.dart';
import 'package:pixel_harmony/features/achievements/domain/achievement_definition.dart';
import 'package:pixel_harmony/features/achievements/domain/achievement_state.dart';
import 'package:pixel_harmony/features/achievements/presentation/achievement_localizations.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final state = ref.watch(achievementControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.achievementsTitle)),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(localizations.achievementsLoadError),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.tonal(
                      key: const Key('achievementsRetryButton'),
                      onPressed:
                          () =>
                              ref
                                  .read(achievementControllerProvider.notifier)
                                  .refresh(),
                      child: Text(localizations.retry),
                    ),
                  ],
                ),
              ),
            ),
        data: (collection) => _AchievementList(collection: collection),
      ),
    );
  }
}

class _AchievementList extends StatelessWidget {
  const _AchievementList({required this.collection});

  final AchievementCollection collection;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.separated(
        key: const Key('achievementsList'),
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: collection.states.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder:
            (context, index) => _AchievementCard(
              key: Key('achievement_${collection.states[index].definition.id}'),
              state: collection.states[index],
            ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({super.key, required this.state});

  final AchievementState state;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final unlocked = state.unlocked;
    return Semantics(
      label:
          '${localizedAchievementTitle(localizations, state.definition)}, '
          '${unlocked ? localizations.unlockedLabel : localizations.lockedLabel}',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: unlocked ? AppPalette.surfaceCompleted : AppPalette.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: unlocked ? AppPalette.completed : AppPalette.border,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                unlocked
                    ? Icons.verified_rounded
                    : _icon(state.definition.iconType),
                color: unlocked ? AppPalette.completed : AppPalette.mutedInk,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizedAchievementTitle(
                        localizations,
                        state.definition,
                      ),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      localizedAchievementDescription(
                        localizations,
                        state.definition,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPalette.mutedInk,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      state.definition.conditionType ==
                              AchievementConditionType.currentDailyStreak
                          ? localizations.achievementProgressDays(
                            state.displayedCurrentValue,
                            state.targetValue,
                          )
                          : localizations.achievementProgress(
                            state.displayedCurrentValue,
                            state.targetValue,
                          ),
                      key: Key('achievementProgress_${state.definition.id}'),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                unlocked
                    ? localizations.unlockedLabel
                    : localizations.lockedLabel,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(AchievementIconType type) => switch (type) {
    AchievementIconType.harmony => Icons.auto_awesome_outlined,
    AchievementIconType.journey => Icons.route_outlined,
    AchievementIconType.endless => Icons.all_inclusive,
    AchievementIconType.daily => Icons.calendar_today_outlined,
    AchievementIconType.chapter => Icons.menu_book_outlined,
    AchievementIconType.moves => Icons.swap_horiz_rounded,
  };
}
