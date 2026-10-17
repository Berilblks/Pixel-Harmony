import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/app/router/app_router.dart';
import 'package:pixel_harmony/core/localization/app_localizations.dart';
import 'package:pixel_harmony/core/theme/app_design_tokens.dart';
import 'package:pixel_harmony/features/daily/application/daily_progress_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(dailyPuzzleIdentityProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dailyIdentity = ref.watch(dailyPuzzleIdentityProvider);
    final dailyProgress = ref.watch(dailyProgressControllerProvider).value;
    final todayCompleted =
        dailyProgress?.isCompleted(dailyIdentity.dateKey) ?? false;
    final streak = dailyProgress?.currentStreak ?? 0;

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: _HomeBottomNavigation(
        achievementsLabel: l10n.achievementsTitle,
        statisticsLabel: l10n.statisticsTitle,
        settingsLabel: l10n.settingsTitle,
        onAchievements: () => context.pushNamed(AppRoutes.achievements),
        onStatistics: () => context.pushNamed(AppRoutes.statistics),
        onSettings: () => context.pushNamed(AppRoutes.settings),
      ),
      body: DecoratedBox(
        key: const Key('homeBackground'),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0EBF7), Color(0xFFF8F4F7), Color(0xFFF1F6F3)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder:
                (context, constraints) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.compact,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          constraints.maxHeight -
                          AppSpacing.lg -
                          AppSpacing.compact,
                    ),
                    child: IntrinsicHeight(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _HomeTitle(title: l10n.appTitle),
                              const SizedBox(height: AppSpacing.md),
                              const _LogoSpace(),
                              const SizedBox(height: AppSpacing.xl),
                              _JourneyMapButton(
                                label: l10n.continueJourney,
                                onTap:
                                    () => context.pushNamed(
                                      AppRoutes.levelSelect,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              SizedBox(
                                height: 116,
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: _ModeButton(
                                        key: const Key('homeDailyButton'),
                                        icon:
                                            todayCompleted
                                                ? Icons.check_circle_outline
                                                : Icons.wb_sunny_outlined,
                                        title: l10n.dailyPuzzle,
                                        status:
                                            todayCompleted
                                                ? l10n.completedToday
                                                : l10n.todayPuzzleReady,
                                        statusKey:
                                            todayCompleted
                                                ? const Key(
                                                  'homeDailyCompleted',
                                                )
                                                : null,
                                        badge:
                                            todayCompleted && streak > 0
                                                ? l10n.dailyStreakDays(streak)
                                                : null,
                                        color: const Color(0xFFFFF0E4),
                                        iconColor: const Color(0xFFB86D51),
                                        onTap:
                                            () => context.pushNamed(
                                              AppRoutes.daily,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.compact),
                                    Expanded(
                                      child: _ModeButton(
                                        key: const Key('homeEndlessButton'),
                                        icon: Icons.all_inclusive_rounded,
                                        title: l10n.endlessMode,
                                        status: l10n.freePlayDescription,
                                        color: const Color(0xFFEAF2F7),
                                        iconColor: const Color(0xFF4F7E91),
                                        onTap:
                                            () => context.pushNamed(
                                              AppRoutes.freePlaySetup,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

class _HomeTitle extends StatelessWidget {
  const _HomeTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final words = title.toUpperCase().split(' ');
    final pixel = words.first;
    final harmony = words.skip(1).join(' ');
    final style = Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontSize: 29,
      fontWeight: FontWeight.w700,
      height: 1.05,
      letterSpacing: 3.4,
    );
    return Semantics(
      header: true,
      label: title,
      child: ExcludeSemantics(
        child: Column(
          children: [
            Text(
              pixel,
              textAlign: TextAlign.center,
              style: style?.copyWith(color: const Color(0xFF7458C8)),
            ),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback:
                  (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF765AC8),
                      Color(0xFFDB62A8),
                      Color(0xFFF0A53D),
                      Color(0xFF4E9CD5),
                    ],
                  ).createShader(bounds),
              child: Text(
                harmony,
                textAlign: TextAlign.center,
                style: style?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoSpace extends StatelessWidget {
  const _LogoSpace();

  @override
  Widget build(BuildContext context) => Center(
    child: Image.asset(
      'assets/branding/app_icon/'
      'pixel_harmony_home.png',
      key: const Key('homeLogo'),
      width: 220,
      height: 220,
      fit: BoxFit.contain,
      semanticLabel: AppLocalizations.of(context).appTitle,
    ),
  );
}

class _JourneyMapButton extends StatelessWidget {
  const _JourneyMapButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    key: const Key('homeJourneySemantics'),
    label: label,
    button: true,
    child: SizedBox(
      key: const Key('homeJourneyContinueButton'),
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          gradient: const LinearGradient(
            colors: [Color(0xFF765FD0), Color(0xFF9A67D5)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x30765FD0),
              blurRadius: 16,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: InkWell(
            key: const Key('homePlayButton'),
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    super.key,
    required this.icon,
    required this.title,
    required this.status,
    this.statusKey,
    this.badge,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String status;
  final Key? statusKey;
  final String? badge;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    label: [title, status, if (badge != null) badge].join(', '),
    button: true,
    child: Material(
      color: color,
      elevation: 1,
      shadowColor: const Color(0x1A493D57),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        side: const BorderSide(color: Color(0x14FFFFFF)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.compact),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 27),
              const SizedBox(height: AppSpacing.xs),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                badge ?? status,
                key: statusKey,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppPalette.mutedInk),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _HomeBottomNavigation extends StatelessWidget {
  const _HomeBottomNavigation({
    required this.achievementsLabel,
    required this.statisticsLabel,
    required this.settingsLabel,
    required this.onAchievements,
    required this.onStatistics,
    required this.onSettings,
  });

  final String achievementsLabel;
  final String statisticsLabel;
  final String settingsLabel;
  final VoidCallback onAchievements;
  final VoidCallback onStatistics;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => SafeArea(
    key: const Key('homeUtilityDock'),
    top: false,
    child: Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: SizedBox(
        height: 68,
        child: Row(
          children: [
            _BottomNavigationAction(
              key: const Key('homeAchievementsButton'),
              icon: Icons.emoji_events_outlined,
              label: achievementsLabel,
              iconBackground: const Color(0xFFEDE6FA),
              onTap: onAchievements,
            ),
            _BottomNavigationAction(
              key: const Key('homeStatisticsButton'),
              icon: Icons.insights_outlined,
              label: statisticsLabel,
              iconBackground: const Color(0xFFE6F1F8),
              onTap: onStatistics,
            ),
            _BottomNavigationAction(
              key: const Key('homeSettingsButton'),
              icon: Icons.settings_outlined,
              label: settingsLabel,
              iconBackground: const Color(0xFFE8F3EE),
              onTap: onSettings,
            ),
          ],
        ),
      ),
    ),
  );
}

class _BottomNavigationAction extends StatelessWidget {
  const _BottomNavigationAction({
    super.key,
    required this.icon,
    required this.label,
    required this.iconBackground,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconBackground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      label: label,
      button: true,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconBackground,
                  ),
                  child: Icon(icon, color: const Color(0xFF625E70), size: 23),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF625E70),
                    fontSize: 11,
                    height: 1.05,
                    fontWeight: FontWeight.w600,
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
