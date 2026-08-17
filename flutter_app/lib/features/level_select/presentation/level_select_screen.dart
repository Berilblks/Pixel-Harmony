import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/app/router/app_router.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/core/localization/level_localizations.dart';
import 'package:pixel_harmony/core/theme/app_design_tokens.dart';
import 'package:pixel_harmony/features/level_progress/application/level_progress_providers.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';
import 'package:pixel_harmony/game/levels/level_progression.dart';

class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final progress = ref.watch(levelProgressControllerProvider);
    final completedLevelIds = progress.asData?.value ?? const <String>{};
    final progression = LevelProgression(levels: LevelCatalog.levels);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.chooseLevel)),
      body: Column(
        children: [
          if (progress.isLoading) const LinearProgressIndicator(),
          if (progress.hasError)
            Padding(
              key: const Key('levelProgressError'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                0,
              ),
              child: Text(
                localizations.progressLoadError,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columnCount = switch (constraints.maxWidth) {
                  >= 840 => 3,
                  >= 560 => 2,
                  _ => 1,
                };

                return GridView.builder(
                  key: const Key('levelSelectGrid'),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.xl,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnCount,
                    mainAxisExtent: 180,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                  ),
                  itemCount: LevelCatalog.levels.length,
                  itemBuilder: (context, index) {
                    final level = LevelCatalog.levels[index];
                    final completed = completedLevelIds.contains(level.id);
                    final unlocked = progression.isUnlocked(
                      level.id,
                      completedLevelIds,
                    );
                    return _LevelCard(
                      level: level,
                      label: localizedLevelName(localizations, level),
                      boardSizeLabel: localizations.boardSizeLabel,
                      completedLabel: localizations.completedLabel,
                      lockedLabel: localizations.lockedLabel,
                      completed: completed,
                      unlocked: unlocked,
                      onTap:
                          unlocked
                              ? () => context.pushNamed(
                                AppRoutes.gameplay,
                                pathParameters: {'levelId': level.id},
                              )
                              : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.label,
    required this.boardSizeLabel,
    required this.completedLabel,
    required this.lockedLabel,
    required this.completed,
    required this.unlocked,
    required this.onTap,
  });

  final LevelDefinition level;
  final String label;
  final String boardSizeLabel;
  final String completedLabel;
  final String lockedLabel;
  final bool completed;
  final bool unlocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardColor =
        completed
            ? AppPalette.surfaceCompleted
            : unlocked
            ? AppPalette.surface
            : AppPalette.surfaceLocked;
    final statusColor = completed ? AppPalette.completed : AppPalette.mutedInk;
    final borderColor =
        completed
            ? AppPalette.completed.withValues(alpha: 0.28)
            : unlocked
            ? AppPalette.border
            : AppPalette.borderStrong;

    return Semantics(
      key: Key('levelCard_${level.id}'),
      container: true,
      button: true,
      enabled: unlocked,
      label:
          '$label, $boardSizeLabel ${level.boardSize} × ${level.boardSize}'
          '${completed
              ? ', $completedLabel'
              : !unlocked
              ? ', $lockedLabel'
              : ''}',
      child: Card(
        color: cardColor,
        clipBehavior: Clip.antiAlias,
        elevation: unlocked ? 1 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(color: borderColor),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                _LevelColorPreview(level: level, muted: !unlocked),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color:
                              unlocked ? AppPalette.ink : AppPalette.mutedInk,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '$boardSizeLabel: ${level.boardSize} × ${level.boardSize}',
                        key: Key('levelBoardSize_${level.id}'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.compact),
                      if (completed)
                        _LevelStatus(
                          key: Key('levelCompleted_${level.id}'),
                          icon: Icons.check_circle_outline,
                          label: completedLabel,
                          color: statusColor,
                        )
                      else if (!unlocked)
                        _LevelStatus(
                          key: Key('levelLocked_${level.id}'),
                          icon: Icons.lock_outline,
                          label: lockedLabel,
                          color: statusColor,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelStatus extends StatelessWidget {
  const _LevelStatus({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _LevelColorPreview extends StatelessWidget {
  const _LevelColorPreview({required this.level, required this.muted});

  final LevelDefinition level;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final tilesById = {for (final tile in level.tiles) tile.id: tile};
    final orderedTiles = [
      for (final id in level.solutionTileOrder) tilesById[id]!,
    ];

    return Opacity(
      opacity: muted ? 0.58 : 1,
      child: Container(
        width: 76,
        height: 76,
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: AppPalette.border),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: level.boardSize,
            mainAxisSpacing: AppSpacing.xs,
            crossAxisSpacing: AppSpacing.xs,
          ),
          itemCount: orderedTiles.length,
          itemBuilder: (context, index) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: Color(orderedTiles[index].colorValue),
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
            );
          },
        ),
      ),
    );
  }
}
