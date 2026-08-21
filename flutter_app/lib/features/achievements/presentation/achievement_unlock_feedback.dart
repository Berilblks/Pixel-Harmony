import 'package:flutter/material.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/features/achievements/domain/achievement_definition.dart';
import 'package:pixel_harmony/features/achievements/presentation/achievement_localizations.dart';

void showAchievementUnlockFeedback(
  BuildContext context,
  List<AchievementDefinition> newlyUnlocked,
) {
  if (newlyUnlocked.isEmpty) return;
  final localizations = AppLocalizations.of(context);
  final firstTitle = localizedAchievementTitle(
    localizations,
    newlyUnlocked.first,
  );
  final message =
      newlyUnlocked.length == 1
          ? '${localizations.achievementUnlocked}\n$firstTitle'
          : localizations.achievementUnlockedMultiple(
            firstTitle,
            newlyUnlocked.length - 1,
          );
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      key: const Key('achievementUnlockFeedback'),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        (MediaQuery.sizeOf(context).height - 180).clamp(16, double.infinity),
      ),
      content: Text(message),
    ),
  );
}
