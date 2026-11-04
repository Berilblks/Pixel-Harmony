import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/core/links/external_link_providers.dart';
import 'package:pixel_harmony/core/theme/app_design_tokens.dart';
import 'package:pixel_harmony/features/privacy/application/analytics_consent_providers.dart';
import 'package:pixel_harmony/features/privacy/domain/analytics_consent.dart';
import 'package:pixel_harmony/features/settings/application/game_feedback_settings_providers.dart';
import 'package:pixel_harmony/features/settings/domain/game_feedback_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static final _privacyPolicyUri = Uri.parse(
    'https://berilblks.github.io/Pixel-Harmony/privacy.html',
  );
  static final _supportUri = Uri.parse(
    'https://berilblks.github.io/Pixel-Harmony/support.html',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final settingsState = ref.watch(gameFeedbackSettingsControllerProvider);
    final settings = settingsState.value ?? const GameFeedbackSettings();
    final controller = ref.read(
      gameFeedbackSettingsControllerProvider.notifier,
    );
    final analyticsConsent = ref.watch(analyticsConsentControllerProvider);

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
                        key: const Key('hapticsSwitch'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.xs,
                        ),
                        title: Text(localizations.hapticsLabel),
                        value: settings.hapticsEnabled,
                        onChanged: controller.setHapticsEnabled,
                      ),
                      const Divider(indent: AppSpacing.lg),
                      SwitchListTile(
                        key: const Key('analyticsConsentSwitch'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.xs,
                        ),
                        title: Text(localizations.analyticsSettingsTitle),
                        subtitle: Text(
                          localizations.analyticsSettingsDescription,
                        ),
                        value:
                            analyticsConsent.value == AnalyticsConsent.enabled,
                        onChanged:
                            analyticsConsent.isLoading
                                ? null
                                : ref
                                    .read(
                                      analyticsConsentControllerProvider
                                          .notifier,
                                    )
                                    .setEnabled,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
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
                      ListTile(
                        key: const Key('privacyPolicyLink'),
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: Text(localizations.privacyPolicyTitle),
                        trailing: const Icon(Icons.open_in_new_rounded),
                        onTap:
                            () => _openLink(
                              context,
                              ref,
                              _privacyPolicyUri,
                              localizations.linkOpenError,
                            ),
                      ),
                      const Divider(indent: AppSpacing.lg),
                      ListTile(
                        key: const Key('supportLink'),
                        leading: const Icon(Icons.help_outline_rounded),
                        title: Text(localizations.supportTitle),
                        trailing: const Icon(Icons.open_in_new_rounded),
                        onTap:
                            () => _openLink(
                              context,
                              ref,
                              _supportUri,
                              localizations.linkOpenError,
                            ),
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

  Future<void> _openLink(
    BuildContext context,
    WidgetRef ref,
    Uri uri,
    String errorMessage,
  ) async {
    final opened = await ref.read(externalLinkServiceProvider).open(uri);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }
}
