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
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          SwitchListTile(
            key: const Key('soundEffectsSwitch'),
            title: Text(localizations.soundEffectsLabel),
            value: settings.soundEffectsEnabled,
            onChanged: controller.setSoundEffectsEnabled,
          ),
          SwitchListTile(
            key: const Key('hapticsSwitch'),
            title: Text(localizations.hapticsLabel),
            value: settings.hapticsEnabled,
            onChanged: controller.setHapticsEnabled,
          ),
        ],
      ),
    );
  }
}
