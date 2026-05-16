import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/home/presentation/pages/learner_home_screen.dart';
import '../../features/home/presentation/pages/main_scaffold.dart';

// Keys for nested navigation
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _practiceNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'practice');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const LearnerHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _practiceNavigatorKey,
            routes: [
              GoRoute(
                path: '/practice',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Practice Screen')),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Profile Screen')),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
