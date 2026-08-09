import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/app/router/app_router.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';

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
            FilledButton(
              key: const Key('homePlayButton'),
              onPressed: () => context.pushNamed(AppRoutes.levelSelect),
              child: Text(localizations.playButton),
            ),
          ],
        ),
      ),
    );
  }
}
