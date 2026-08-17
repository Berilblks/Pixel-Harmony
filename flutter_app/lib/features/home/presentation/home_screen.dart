import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/app/router/app_router.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/core/theme/app_design_tokens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          Semantics(
            label: localizations.settingsTitle,
            button: true,
            excludeSemantics: true,
            child: IconButton(
              key: const Key('homeSettingsButton'),
              tooltip: localizations.settingsTitle,
              onPressed: () => context.pushNamed(AppRoutes.settings),
              icon: const Icon(Icons.settings_outlined),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _HarmonyMark(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    localizations.appTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    localizations.homeWelcome,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl + AppSpacing.sm),
                  SizedBox(
                    width: 220,
                    child: FilledButton(
                      key: const Key('homePlayButton'),
                      onPressed: () => context.pushNamed(AppRoutes.levelSelect),
                      child: Text(localizations.playButton),
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

class _HarmonyMark extends StatelessWidget {
  const _HarmonyMark();

  static const _colors = [
    AppPalette.sky,
    AppPalette.leaf,
    AppPalette.sun,
    AppPalette.coral,
  ];

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: 120,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppPalette.surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: AppPalette.border),
            boxShadow: AppShadows.card,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
              ),
              itemCount: _colors.length,
              itemBuilder: (context, index) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: _colors[index],
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
