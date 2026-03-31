import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/problems/presentation/screens/home_screen.dart';
import '../features/problems/presentation/screens/problem_detail_screen.dart';
import '../features/problems/data/models/problem_model.dart';
import '../features/editor/presentation/screens/code_editor_screen.dart';
import '../features/explore/presentation/screens/explore_screen.dart';
import '../features/explore/presentation/screens/topic_problems_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreScreen(),
            routes: [
              GoRoute(
                path: ':tag',
                builder: (context, state) => TopicProblemsScreen(
                  tag: state.pathParameters['tag']!,
                ),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ]),
      ],
    ),
    GoRoute(
      path: '/problem/:slug',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => ProblemDetailScreen(
        slug: state.pathParameters['slug']!,
      ),
      routes: [
        GoRoute(
          path: 'editor',
          builder: (context, state) {
            final slug = state.pathParameters['slug']!;
            final extra = state.extra;
            Problem? problem;
            String? initialCode;
            if (extra is Problem) {
              problem = extra;
            } else if (extra is Map) {
              problem = extra['problem'] as Problem?;
              initialCode = extra['initialCode'] as String?;
            }
            debugPrint('[ROUTER] editor route builder: slug=$slug, problem=${problem?.title}, hasInitialCode=${initialCode != null}');
            return CodeEditorScreen(slug: slug, problem: problem, initialCode: initialCode);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
