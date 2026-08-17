import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/core/theme/app_design_tokens.dart';
import 'package:pixel_harmony/features/settings/application/game_feedback_settings_providers.dart';
import 'package:pixel_harmony/features/settings/domain/game_feedback_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final settingsState = ref.watch(gameFeedbackSettingsControllerProvider);
    final settings = settingsState.value ?? const GameFeedbackSettings();
    final controller = ref.read(
      gameFeedbackSettingsControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    side: const BorderSide(color: AppPalette.border),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        key: const Key('soundEffectsSwitch'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.xs,
                        ),
                        title: Text(localizations.soundEffectsLabel),
                        value: settings.soundEffectsEnabled,
                        onChanged: controller.setSoundEffectsEnabled,
                      ),
                      const Divider(indent: AppSpacing.lg),
                      SwitchListTile(
                        key: const Key('hapticsSwitch'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.xs,
                        ),
                        title: Text(localizations.hapticsLabel),
                        value: settings.hapticsEnabled,
                        onChanged: controller.setHapticsEnabled,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
