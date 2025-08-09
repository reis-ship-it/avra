import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spots/presentation/pages/auth/auth_wrapper.dart';
import 'package:spots/presentation/pages/auth/login_page.dart';
import 'package:spots/presentation/pages/auth/signup_page.dart';
import 'package:spots/presentation/pages/home/home_page.dart';
import 'package:spots/presentation/pages/spots/spots_page.dart';
import 'package:spots/presentation/pages/lists/lists_page.dart';
import 'package:spots/presentation/pages/map/map_page.dart';
import 'package:spots/presentation/pages/profile/profile_page.dart';
import 'package:spots/presentation/pages/onboarding/onboarding_page.dart';
import 'package:spots/presentation/pages/onboarding/ai_loading_page.dart';
import 'package:spots/presentation/blocs/lists/lists_bloc.dart';
import 'package:spots/presentation/blocs/spots/spots_bloc.dart';

class AppRouter {
  static const String initial = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String spots = '/spots';
  static const String lists = '/lists';
  static const String map = '/map';
  static const String profile = '/profile';
  static const String onboarding = '/onboarding';
  static const String aiLoading = '/ai-loading';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/home?tab=lists':
        return MaterialPageRoute(
            builder: (_) => const HomePage(initialTabIndex: 2));
      case spots:
        return MaterialPageRoute(builder: (_) => const SpotsPage());
      case lists:
        return MaterialPageRoute(builder: (_) => const ListsPage());
      case map:
        return MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: BlocProvider.of<ListsBloc>(context)),
              BlocProvider.value(value: BlocProvider.of<SpotsBloc>(context)),
            ],
            child: const MapPage(),
          ),
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case aiLoading:
        return MaterialPageRoute(
          builder: (_) => AILoadingPage(
            userName: 'User',
            onLoadingComplete: () {
              // This route is mainly for testing - in normal flow it's called from onboarding
              Navigator.pushReplacementNamed(_, '/lists');
            },
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
    }
  }
}
