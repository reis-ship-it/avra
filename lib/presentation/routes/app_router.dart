import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spots/presentation/pages/auth/auth_wrapper.dart';
import 'package:spots/presentation/pages/auth/login_page.dart';
import 'package:spots/presentation/pages/auth/signup_page.dart';
import 'package:spots/presentation/pages/home/home_page.dart';
import 'package:spots/presentation/pages/spots/spots_page.dart';
import 'package:spots/presentation/pages/lists/lists_page.dart';
import 'package:spots/presentation/pages/map/map_page.dart';
import 'package:spots/presentation/pages/profile/profile_page.dart';
import 'package:spots/presentation/pages/onboarding/onboarding_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spots/presentation/pages/onboarding/ai_loading_page.dart';
import 'package:spots/presentation/pages/supabase_test_page.dart';
import 'package:spots/presentation/pages/search/hybrid_search_page.dart';
import 'package:spots/presentation/blocs/lists/lists_bloc.dart';
import 'package:spots/presentation/blocs/spots/spots_bloc.dart';
import 'package:spots/presentation/blocs/search/hybrid_search_bloc.dart';
import 'package:spots/injection_container.dart' as di;
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';
import 'package:spots/data/datasources/local/onboarding_completion_service.dart';

class AppRouter {
  // Route path helpers for legacy Navigator.pushNamed usages
  static const String home = '/home';
  static const String signup = '/signup';

  static GoRouter build({required AuthBloc authBloc}) {
    const bool goToSupabaseTest = bool.fromEnvironment('GO_TO_SUPABASE_TEST');
    const bool autoDriveSupabase = bool.fromEnvironment('AUTO_DRIVE_SUPABASE_TEST');
    return GoRouter(
      initialLocation: goToSupabaseTest
          ? (autoDriveSupabase ? '/supabase-test?auto=1' : '/supabase-test')
          : '/',
      refreshListenable: _GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) async {
        final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
        final isOnboarding = state.matchedLocation == '/onboarding';
        final isRoot = state.matchedLocation == '/';

        final authState = authBloc.state;

        if (authState is Authenticated) {
          // If authenticated, ensure onboarding completed
          final onboardingDone = await OnboardingCompletionService.isOnboardingCompleted();
          if (!onboardingDone && !isOnboarding) {
            return '/onboarding';
          }
          // After onboarding, ensure critical permissions present
          if (!await _hasCriticalPermissions() && state.matchedLocation != '/onboarding') {
            return '/onboarding?reason=permissions_required';
          }
          // Prevent going back to auth pages
          if (isLoggingIn || isRoot) {
            return '/home';
          }
          return null;
        }

        // Unauthenticated: allow only login/signup/onboarding; send others to login
        if (!(isLoggingIn || isOnboarding || isRoot)) {
          return '/login';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const AuthWrapper(),
          routes: [
            GoRoute(path: 'login', builder: (c, s) => const LoginPage()),
            GoRoute(path: 'signup', builder: (c, s) => const SignupPage()),
            GoRoute(path: 'home', builder: (c, s) => const HomePage()),
            GoRoute(path: 'spots', builder: (c, s) => const SpotsPage()),
            GoRoute(path: 'lists', builder: (c, s) => const ListsPage()),
            GoRoute(
              path: 'map',
              redirect: (context, state) async {
                final locWhenInUse = await Permission.locationWhenInUse.status;
                if (!locWhenInUse.isGranted && !locWhenInUse.isLimited) {
                  return '/onboarding?reason=location_required';
                }
                return null;
              },
              builder: (context, state) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: BlocProvider.of<ListsBloc>(context)),
                  BlocProvider.value(value: BlocProvider.of<SpotsBloc>(context)),
                ],
                child: const MapPage(),
              ),
            ),
            GoRoute(path: 'profile', builder: (c, s) => const ProfilePage()),
            GoRoute(
              path: 'supabase-test',
              builder: (c, s) {
                final auto = s.uri.queryParameters['auto'] == '1';
                return SupabaseTestPage(auto: auto);
              },
            ),
            GoRoute(
              path: 'onboarding',
              builder: (context, state) {
                final reason = state.uri.queryParameters['reason'];
                if (reason != null && reason.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final text = switch (reason) {
                      'permissions_required' => 'Permissions required for ai2ai connectivity. Please enable to continue.',
                      'location_required' => 'Location permission required to use the map.',
                      _ => 'Additional permissions are required.'
                    };
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(text)),
                    );
                  });
                }
                return const OnboardingPage();
              },
            ),
            GoRoute(
              path: 'ai-loading',
              builder: (c, s) => AILoadingPage(
                userName: 'User',
                onLoadingComplete: () => c.go('/lists'),
              ),
            ),
            GoRoute(
              path: 'hybrid-search',
              builder: (context, state) => BlocProvider(
                create: (context) => di.sl<HybridSearchBloc>(),
                child: const HybridSearchPage(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Simple adapter to notify GoRouter when the auth bloc emits a new state
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

Future<bool> _hasCriticalPermissions() async {
  final statuses = await [
    Permission.locationWhenInUse,
    Permission.locationAlways,
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.bluetoothAdvertise,
    Permission.nearbyWifiDevices,
  ].request();

  bool ok(PermissionStatus s) => s.isGranted || s.isLimited || s.isProvisional;

  return statuses.values.where((s) => !ok(s)).isEmpty;
}
