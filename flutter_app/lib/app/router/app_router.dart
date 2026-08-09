import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_harmony/features/gameplay/presentation/gameplay_screen.dart';
import 'package:pixel_harmony/features/home/presentation/home_screen.dart';
import 'package:pixel_harmony/game/levels/level_catalog.dart';

abstract final class AppRoutes {
  static const home = 'home';
  static const gameplay = 'gameplay';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/gameplay/:levelId',
        name: AppRoutes.gameplay,
        builder:
            (context, state) => GameplayScreen(
              level: LevelCatalog.byId(state.pathParameters['levelId']!),
            ),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
