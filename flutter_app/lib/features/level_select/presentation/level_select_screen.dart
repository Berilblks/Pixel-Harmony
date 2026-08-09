import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/app/router/app_router.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/features/level_progress/application/level_progress_providers.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';

class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final progress = ref.watch(levelProgressControllerProvider);
    final completedLevelIds = progress.asData?.value ?? const <String>{};

    return Scaffold(
      appBar: AppBar(title: Text(localizations.chooseLevel)),
      body: Column(
        children: [
          if (progress.isLoading) const LinearProgressIndicator(),
          if (progress.hasError)
            Padding(
              key: const Key('levelProgressError'),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
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
                  padding: const EdgeInsets.all(24),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnCount,
                    mainAxisExtent: 176,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: LevelCatalog.levels.length,
                  itemBuilder: (context, index) {
                    final level = LevelCatalog.levels[index];
                    return _LevelCard(
                      level: level,
                      label: _localizedLevelName(localizations, level),
                      boardSizeLabel: localizations.boardSizeLabel,
                      completedLabel: localizations.completedLabel,
                      completed: completedLevelIds.contains(level.id),
                      onTap:
                          () => context.pushNamed(
                            AppRoutes.gameplay,
                            pathParameters: {'levelId': level.id},
                          ),
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

  String _localizedLevelName(
    AppLocalizations localizations,
    LevelDefinition level,
  ) {
    return switch (level.nameKey) {
      LevelNameKeys.level1 => localizations.level1Label,
      LevelNameKeys.level2 => localizations.level2Label,
      LevelNameKeys.level3 => localizations.level3Label,
      _ => throw StateError('Unknown level name key: ${level.nameKey}'),
    };
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.label,
    required this.boardSizeLabel,
    required this.completedLabel,
    required this.completed,
    required this.onTap,
  });

  final LevelDefinition level;
  final String label;
  final String boardSizeLabel;
  final String completedLabel;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: InkWell(
        key: Key('levelCard_${level.id}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              _LevelColorPreview(level: level),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      '$boardSizeLabel: ${level.boardSize} × ${level.boardSize}',
                      key: Key('levelBoardSize_${level.id}'),
                    ),
                    if (completed) ...[
                      const SizedBox(height: 8),
                      Row(
                        key: Key('levelCompleted_${level.id}'),
                        children: [
                          const Icon(Icons.check_circle_outline, size: 18),
                          const SizedBox(width: 6),
                          Text(completedLabel),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
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
      dimension: 72,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: level.boardSize,
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
        ),
        itemCount: orderedTiles.length,
        itemBuilder: (context, index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: Color(orderedTiles[index].colorValue),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        },
      ),
    );
  }
}
