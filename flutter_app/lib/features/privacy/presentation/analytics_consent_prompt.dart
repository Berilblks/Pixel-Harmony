import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/features/privacy/application/analytics_consent_providers.dart';
import 'package:pixel_harmony/features/privacy/domain/analytics_consent.dart';

class AnalyticsConsentPrompt extends ConsumerStatefulWidget {
  const AnalyticsConsentPrompt({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AnalyticsConsentPrompt> createState() =>
      _AnalyticsConsentPromptState();
}

class _AnalyticsConsentPromptState
    extends ConsumerState<AnalyticsConsentPrompt> {
  bool _dialogScheduled = false;

  @override
  Widget build(BuildContext context) {
    final consent = ref.watch(analyticsConsentControllerProvider);
    if (consent.value == AnalyticsConsent.undecided && !_dialogScheduled) {
      _dialogScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _showPrompt());
    }
    return widget.child;
  }

  Future<void> _showPrompt() async {
    if (!mounted) {
      return;
    }
    final localizations = AppLocalizations.of(context);
    final enabled = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            key: const Key('analyticsConsentDialog'),
            scrollable: true,
            title: Text(localizations.analyticsConsentTitle),
            content: Text(localizations.analyticsConsentDescription),
            actions: [
              TextButton(
                key: const Key('analyticsConsentDecline'),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(localizations.analyticsConsentDecline),
              ),
              FilledButton(
                key: const Key('analyticsConsentAccept'),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(localizations.analyticsConsentAccept),
              ),
            ],
          ),
    );
    if (enabled != null && mounted) {
      await ref
          .read(analyticsConsentControllerProvider.notifier)
          .setEnabled(enabled);
    }
  }
}
