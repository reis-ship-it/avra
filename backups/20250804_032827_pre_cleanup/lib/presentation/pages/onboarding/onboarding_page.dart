import 'package:flutter/material.dart';
import 'package:spots/core/models/unified_models.dart';import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';
import 'package:spots/presentation/pages/onboarding/ai_loading_page.dart';
import 'package:spots/presentation/pages/onboarding/baseline_lists_page.dart';
import 'package:spots/presentation/pages/onboarding/favorite_places_page.dart';
import 'package:spots/presentation/pages/onboarding/friends_respect_page.dart';
import 'package:spots/presentation/pages/onboarding/homebase_selection_page.dart';
import 'package:spots/presentation/pages/onboarding/preference_survey_page.dart';

enum OnboardingStepType {
  homebase,
  favoritePlaces,
  preferences,
  baselineLists,
  friends,
}

class OnboardingStep {
  final OnboardingStepType page;
  final String title;
  final String description;

  const OnboardingStep({
    required this.page,
    required this.title,
    required this.description,
  });
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _selectedHomebase;
  List<String> _favoritePlaces = [];
  Map<String, List<String>> _preferences = {};
  List<String> _baselineLists = [];
  List<String> _respectedFriends = [];

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      page: OnboardingStepType.homebase,
      title: 'Choose Your Homebase',
      description: 'Select your primary location',
    ),
    OnboardingStep(
      page: OnboardingStepType.favoritePlaces,
      title: 'Favorite Places',
      description: 'Tell us about your favorite spots',
    ),
    OnboardingStep(
      page: OnboardingStepType.preferences,
      title: 'Preferences',
      description: 'Customize your experience',
    ),
    OnboardingStep(
      page: OnboardingStepType.baselineLists,
      title: 'Baseline Lists',
      description: 'Set up your initial lists',
    ),
    OnboardingStep(
      page: OnboardingStepType.friends,
      title: 'Friends & Respect',
      description: 'Connect with friends',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to SPOTS'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _currentPage > 0 ? () {
              setState(() {
                _currentPage--;
              });
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } : null,
            child: const Text('Back'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                return _buildStepContent(_steps[index]);
              },
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildStepContent(OnboardingStep step) {
    switch (step.page) {
      case OnboardingStepType.homebase:
        return HomebaseSelectionPage(
          onHomebaseChanged: (homebase) {
            setState(() {
              _selectedHomebase = homebase;
            });
          },
          selectedHomebase: _selectedHomebase,
        );
      case OnboardingStepType.favoritePlaces:
        return FavoritePlacesPage(
          onPlacesChanged: (places) {
            setState(() {
              _favoritePlaces = places;
            });
          },
          favoritePlaces: _favoritePlaces,
        );
      case OnboardingStepType.preferences:
        return PreferenceSurveyPage(
          onPreferencesChanged: (preferences) {
            setState(() {
              _preferences = preferences;
            });
          },
          preferences: _preferences,
        );
      case OnboardingStepType.baselineLists:
        return BaselineListsPage(
          onBaselineListsChanged: (lists) {
            setState(() {
              _baselineLists = lists;
            });
          },
          baselineLists: _baselineLists,
        );
      case OnboardingStepType.friends:
        return FriendsRespectPage(
          onRespectedListsChanged: (friends) {
            setState(() {
              _respectedFriends = friends;
            });
          },
          respectedLists: _respectedFriends,
        );
    }
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceedToNextStep() ? () {
                if (_currentPage == _steps.length - 1) {
                  _completeOnboarding();
                } else {
                  setState(() {
                    _currentPage++;
                  });
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              } : null,
              child: Text(_getNextButtonText()),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceedToNextStep() {
    if (_currentPage >= _steps.length) {
      return false;
    }
    
    switch (_steps[_currentPage].page) {
      case OnboardingStepType.homebase:
        return _selectedHomebase != null && _selectedHomebase!.isNotEmpty;
      case OnboardingStepType.favoritePlaces:
        return _favoritePlaces.isNotEmpty;
      case OnboardingStepType.preferences:
        return _preferences.isNotEmpty;
      case OnboardingStepType.baselineLists:
        return _baselineLists.isNotEmpty;
      case OnboardingStepType.friends:
        return true; // Optional step
    }
  }

  String _getNextButtonText() {
    if (_currentPage == _steps.length - 1) {
      return 'Complete Setup';
    }
    return 'Next';
  }

  void _completeOnboarding() async {
    try {
      print('🎯 Completing Onboarding:');
      print('  Homebase: $_selectedHomebase');
      print('  Favorite Places: $_favoritePlaces');
      print('  Preferences: $_preferences');
      
      // Navigate directly to AI loading page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AILoadingPage(
            userName: "User",
            homebase: _selectedHomebase,
            favoritePlaces: _favoritePlaces,
            preferences: _preferences,
            onLoadingComplete: () async {
              try {
                // Navigate directly to home page, bypassing AuthWrapper
                Navigator.pushReplacementNamed(context, '/home');
                print('✅ Onboarding completed, navigating to home');
              } catch (e) {
                print('Error in onboarding completion: $e');
              }
            },
          ),
        ),
      );
    } catch (e) {
      print('Error completing onboarding: $e');
    }
  }

  Future<void> _saveRespectedLists(List<String> respectedListNames) async {
    try {
      // Save respected lists logic
    } catch (e) {
      // Handle error
    }
  }
}
