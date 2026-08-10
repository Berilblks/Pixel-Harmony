import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/features/gameplay/presentation/gameplay_screen.dart';
import 'package:pixel_harmony/features/home/presentation/home_screen.dart';
import 'package:pixel_harmony/features/level_select/presentation/level_select_screen.dart';
import 'package:pixel_harmony/features/settings/presentation/settings_screen.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';

abstract final class AppRoutes {
  static const home = 'home';
  static const levelSelect = 'level-select';
  static const gameplay = 'gameplay';
  static const settings = 'settings';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/settings',
        name: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/',
        name: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/levels',
        name: AppRoutes.levelSelect,
        builder: (context, state) => const LevelSelectScreen(),
      ),
      GoRoute(
        path: '/gameplay/:levelId',
        name: AppRoutes.gameplay,
        builder:
            (context, state) => GameplayScreen(
              level: LevelCatalog.findById(state.pathParameters['levelId']!),
            ),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
