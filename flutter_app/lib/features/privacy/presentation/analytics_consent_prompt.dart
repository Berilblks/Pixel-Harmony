import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/features/privacy/application/analytics_consent_providers.dart';
import 'package:pixel_harmony/features/privacy/domain/analytics_consent.dart';

class AnalyticsConsentPrompt extends ConsumerWidget {
  const AnalyticsConsentPrompt({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consent = ref.watch(analyticsConsentControllerProvider);
    final shouldAsk = consent.value == AnalyticsConsent.undecided;
    final localizations = AppLocalizations.of(context);

    return PopScope(
      canPop: !shouldAsk,
      child: Stack(
        children: [
          child,
          if (shouldAsk) ...[
            const Positioned.fill(
              child: ModalBarrier(dismissible: false, color: Colors.black54),
            ),
            Positioned.fill(
              child: SafeArea(
                child: Center(
                  child: AlertDialog(
                    key: const Key('analyticsConsentDialog'),
                    scrollable: true,
                    title: Text(localizations.analyticsConsentTitle),
                    content: Text(localizations.analyticsConsentDescription),
                    actions: [
                      TextButton(
                        key: const Key('analyticsConsentDecline'),
                        onPressed:
                            () => ref
                                .read(
                                  analyticsConsentControllerProvider.notifier,
                                )
                                .setEnabled(false),
                        child: Text(localizations.analyticsConsentDecline),
                      ),
                      FilledButton(
                        key: const Key('analyticsConsentAccept'),
                        onPressed:
                            () => ref
                                .read(
                                  analyticsConsentControllerProvider.notifier,
                                )
                                .setEnabled(true),
                        child: Text(localizations.analyticsConsentAccept),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
