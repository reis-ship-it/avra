import 'package:flutter/material.dart';
import 'package:spots/core/models/unified_models.dart';import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';
import 'package:spots/presentation/pages/auth/login_page.dart';
import 'package:spots/presentation/pages/onboarding/onboarding_page.dart';
import 'package:spots/presentation/pages/home/home_page.dart';
import 'package:spots/data/datasources/local/onboarding_completion_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isOnboardingCompleted = false;
  bool _isCheckingOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final isCompleted = await _checkOnboardingCompletion();
      if (mounted) {
        setState(() {
          _isOnboardingCompleted = isCompleted;
          _isCheckingOnboarding = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isOnboardingCompleted = false;
          _isCheckingOnboarding = false;
        });
      }
    }
  }

  Future<bool> _checkOnboardingCompletion() async {
    try {
      return await OnboardingCompletionService.isOnboardingCompleted();
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        try {
          if (state is AuthInitial || state is AuthLoading || _isCheckingOnboarding) {
            // Trigger auth check when app starts
            if (state is AuthInitial) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<AuthBloc>().add(AuthCheckRequested());
              });
            }
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is Authenticated) {
            // Check if onboarding is completed
            if (!_isOnboardingCompleted) {
              return const OnboardingPage();
            } else {
              return const HomePage();
            }
          }

          // User is not authenticated, show login page
          return const LoginPage();
        } catch (e) {
          // Fallback in case of any errors
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('SPOTS App', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  const Text('Loading...', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Force show onboarding for testing
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const OnboardingPage()),
                      );
                    },
                    child: const Text('Go to Onboarding'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
