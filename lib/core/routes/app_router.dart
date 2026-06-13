import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/auth/presentation/pages/onboarding_screen.dart';
import '../../features/home/presentation/pages/learner_home_screen.dart';
import '../../features/home/presentation/pages/main_scaffold.dart';
import '../../features/home/presentation/pages/profile_screen.dart';
import '../../features/home/presentation/pages/leaderboard_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/curriculum/presentation/bloc/curriculum_bloc.dart';
import '../../features/curriculum/presentation/screens/languages_screen.dart';
import '../../features/curriculum/presentation/screens/units_screen.dart';
import '../../features/curriculum/presentation/screens/lessons_screen.dart';
import '../../features/practice/presentation/screens/practice_screen.dart';
import '../../features/practice/presentation/screens/attempts_history_screen.dart';
import '../../features/practice/presentation/bloc/practice_bloc.dart';

import '../../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../../features/notifications/presentation/bloc/notifications_event.dart';
import '../../features/notifications/presentation/pages/notifications_screen.dart';
import '../../injection_container.dart';

// Keys for nested navigation
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _practiceNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'practice');
final _leaderboardNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'leaderboard');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/units/:languageId',
        builder: (context, state) {
          final languageId = state.pathParameters['languageId']!;
          return BlocProvider(
            create: (_) => sl<CurriculumBloc>(),
            child: UnitsScreen(languageId: languageId),
          );
        },
      ),
      GoRoute(
        path: '/units/:languageId/lessons/:unitId',
        builder: (context, state) {
          final unitId = state.pathParameters['unitId']!;
          return BlocProvider(
            create: (_) => sl<CurriculumBloc>(),
            child: LessonsScreen(unitId: unitId),
          );
        },
      ),
      GoRoute(
        path: '/practice_lesson/:lessonId',
        builder: (context, state) {
          final lessonId = state.pathParameters['lessonId']!;
          return BlocProvider(
            create: (_) => sl<PracticeBloc>(),
            child: PracticeScreen(lessonId: lessonId),
          );
        },
      ),
      GoRoute(
        path: '/attempts',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => sl<PracticeBloc>()..add(ListAttemptsEvent()),
            child: const AttemptsHistoryScreen(),
          );
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => sl<NotificationsBloc>()..add(LoadNotificationsEvent()),
            child: const NotificationsScreen(),
          );
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<CurriculumBloc>(),
          child: const OnboardingScreen(),
        ),
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
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<HomeBloc>()..add(LoadDashboardEvent()),
                  child: const LearnerHomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _practiceNavigatorKey,
            routes: [
              GoRoute(
                path: '/practice',
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<CurriculumBloc>(),
                  child: const LanguagesScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _leaderboardNavigatorKey,
            routes: [
              GoRoute(
                path: '/leaderboard',
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<HomeBloc>()..add(LoadLeaderboardEvent()),
                  child: const LeaderboardScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<CurriculumBloc>(),
                  child: const ProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
