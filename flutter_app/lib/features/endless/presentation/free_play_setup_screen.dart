import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/app/router/app_router.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/core/theme/app_design_tokens.dart';
import 'package:pixel_harmony/features/endless/domain/free_play_configuration.dart';

class FreePlaySetupScreen extends StatefulWidget {
  const FreePlaySetupScreen({super.key});

  @override
  State<FreePlaySetupScreen> createState() => _FreePlaySetupScreenState();
}

class _FreePlaySetupScreenState extends State<FreePlaySetupScreen> {
  FreePlayPuzzleType _type = FreePlayPuzzleType.gradient;
  FreePlayDifficulty _difficulty = FreePlayDifficulty.relaxed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.endlessMode)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _FreePlayMark(),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.freePlayDescription,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    l10n.puzzleType,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    key: const Key('freePlayPuzzleType'),
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final type in FreePlayPuzzleType.values)
                        ChoiceChip(
                          key: Key('freePlayType_${type.name}'),
                          avatar: Icon(_typeIcon(type), size: 18),
                          label: Text(_typeLabel(l10n, type)),
                          selected: _type == type,
                          onSelected: (_) => setState(() => _type = type),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    l10n.difficulty,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final difficulty in FreePlayDifficulty.values)
                        ChoiceChip(
                          key: Key('freePlayDifficulty_${difficulty.name}'),
                          label: Text(_difficultyLabel(l10n, difficulty)),
                          selected: _difficulty == difficulty,
                          onSelected:
                              (_) => setState(() => _difficulty = difficulty),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton.icon(
                    key: const Key('freePlayStartButton'),
                    onPressed:
                        () => context.pushNamed(
                          AppRoutes.freePlayGame,
                          extra: FreePlayConfiguration(
                            puzzleType: _type,
                            difficulty: _difficulty,
                          ),
                        ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(l10n.playButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _difficultyLabel(
    AppLocalizations l10n,
    FreePlayDifficulty difficulty,
  ) => switch (difficulty) {
    FreePlayDifficulty.relaxed => l10n.difficultyRelaxed,
    FreePlayDifficulty.normal => l10n.difficultyNormal,
    FreePlayDifficulty.hard => l10n.difficultyHard,
    FreePlayDifficulty.expert => l10n.difficultyExpert,
  };

  String _typeLabel(AppLocalizations l10n, FreePlayPuzzleType type) =>
      switch (type) {
        FreePlayPuzzleType.gradient => l10n.gradientPuzzle,
        FreePlayPuzzleType.pixelColoring => l10n.pixelColoringPuzzle,
        FreePlayPuzzleType.mixed => l10n.mixedPuzzle,
      };

  IconData _typeIcon(FreePlayPuzzleType type) => switch (type) {
    FreePlayPuzzleType.gradient => Icons.gradient_rounded,
    FreePlayPuzzleType.pixelColoring => Icons.palette_outlined,
    FreePlayPuzzleType.mixed => Icons.shuffle_rounded,
  };
}

class _FreePlayMark extends StatelessWidget {
  const _FreePlayMark();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Center(
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF8674C9), Color(0xFF5D9ED1), Color(0xFF55A98E)],
            ),
            boxShadow: AppShadows.card,
          ),
          child: const Icon(
            Icons.all_inclusive_rounded,
            color: Colors.white,
            size: 42,
          ),
        ),
      ),
    );
  }
}
