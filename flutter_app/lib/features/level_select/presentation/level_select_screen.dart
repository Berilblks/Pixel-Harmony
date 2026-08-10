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
                  padding: const EdgeInsets.all(AppSpacing.md),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnCount,
                    mainAxisExtent: 184,
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
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor =
        completed
            ? colorScheme.tertiaryContainer.withValues(alpha: 0.28)
            : unlocked
            ? AppPalette.surface
            : AppPalette.surfaceMuted;
    final statusColor = completed ? AppPalette.completed : AppPalette.mutedInk;

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
      child: Opacity(
        opacity: unlocked ? 1 : 0.66,
        child: Card(
          color: cardColor,
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  _LevelColorPreview(level: level),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '$boardSizeLabel: ${level.boardSize} × ${level.boardSize}',
                          key: Key('levelBoardSize_${level.id}'),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                        if (completed) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            key: Key('levelCompleted_${level.id}'),
                            children: [
                              const Icon(Icons.check_circle_outline, size: 18),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                completedLabel,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ] else if (!unlocked) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            key: Key('levelLocked_${level.id}'),
                            children: [
                              const Icon(Icons.lock_outline, size: 18),
                              const SizedBox(width: AppSpacing.sm),
                              Text(lockedLabel),
                            ],
                          ),
                        ],
                      ],
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

class _LevelColorPreview extends StatelessWidget {
  const _LevelColorPreview({required this.level});

  final LevelDefinition level;

  @override
  Widget build(BuildContext context) {
    final tilesById = {for (final tile in level.tiles) tile.id: tile};
    final orderedTiles = [
      for (final id in level.solutionTileOrder) tilesById[id]!,
    ];

    return SizedBox.square(
      dimension: 64,
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
              borderRadius: BorderRadius.circular(AppRadii.sm / 2),
            ),
          );
        },
      ),
    );
  }
}
