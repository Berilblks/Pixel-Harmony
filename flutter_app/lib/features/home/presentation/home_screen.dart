import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/app/router/app_router.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';
import 'package:pixel_harmony/game/levels/level_definition.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.appTitle)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localizations.homeWelcome),
            const SizedBox(height: 24),
            for (final level in LevelCatalog.levels) ...[
              FilledButton(
                key: Key('levelButton_${level.id}'),
                onPressed:
                    () => context.goNamed(
                      AppRoutes.gameplay,
                      pathParameters: {'levelId': level.id},
                    ),
                child: Text(_localizedLevelName(localizations, level)),
              ),
              if (level != LevelCatalog.levels.last) const SizedBox(height: 12),
            ],
          ],
        ),
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
