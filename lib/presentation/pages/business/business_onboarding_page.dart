import 'package:flutter/material.dart';
import 'package:spots/core/models/business_account.dart';
import 'package:spots/core/theme/app_theme.dart';
import 'package:spots/core/theme/colors.dart';
import 'package:spots/presentation/pages/business/business_dashboard_page.dart';

/// Business Onboarding Page
///
/// Multi-step onboarding flow for new business accounts.
/// Similar to user onboarding but tailored for businesses.
class BusinessOnboardingPage extends StatefulWidget {
  final BusinessAccount businessAccount;

  const BusinessOnboardingPage({
    super.key,
    required this.businessAccount,
  });

  @override
  State<BusinessOnboardingPage> createState() => _BusinessOnboardingPageState();
}

class _BusinessOnboardingPageState extends State<BusinessOnboardingPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Onboarding data
  Map<String, dynamic> _expertPreferences = {};
  Map<String, dynamic> _patronPreferences = {};
  List<String> _teamMembers = [];
  bool _setupSharedAgent = true;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Welcome',
      description: 'Let\'s set up your business profile',
    ),
    OnboardingStep(
      title: 'Expert Preferences',
      description: 'What experts do you want to connect with?',
    ),
    OnboardingStep(
      title: 'Customer Preferences',
      description: 'What customers are you looking for?',
    ),
    OnboardingStep(
      title: 'Team Setup',
      description: 'Invite team members (optional)',
    ),
    OnboardingStep(
      title: 'AI Agent Setup',
      description: 'Set up your shared business AI agent',
    ),
    OnboardingStep(
      title: 'Complete',
      description: 'You\'re all set!',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    // TODO: Save onboarding data
    // TODO: Initialize shared business AI agent if _setupSharedAgent is true
    // TODO: Create business credentials if not already created

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BusinessDashboardPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text(_steps[_currentStep].title),
        backgroundColor: Colors.transparent,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : null,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(
                _steps.length,
                (index) => Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= _currentStep
                          ? AppTheme.primaryColor
                          : AppColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Step content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildWelcomeStep(),
                _buildExpertPreferencesStep(),
                _buildPatronPreferencesStep(),
                _buildTeamSetupStep(),
                _buildAIAgentSetupStep(),
                _buildCompleteStep(),
              ],
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  OutlinedButton(
                    onPressed: _previousStep,
                    child: const Text('Back'),
                  )
                else
                  const SizedBox.shrink(),
                ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppColors.white,
                  ),
                  child: Text(
                    _currentStep == _steps.length - 1 ? 'Complete' : 'Next',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_center,
            size: 80,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome, ${widget.businessAccount.name}!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Let\'s set up your business profile to help you connect with the right experts and customers.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExpertPreferencesStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What experts are you looking for?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about the expertise you need for your business',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          // TODO: Add expert preferences form
          Expanded(
            child: Center(
              child: Text(
                'Expert preferences form coming soon',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatronPreferencesStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What customers are you looking for?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Describe your ideal customers and patrons',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          // TODO: Add patron preferences form
          Expanded(
            child: Center(
              child: Text(
                'Patron preferences form coming soon',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSetupStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invite Team Members',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add team members to your business account (optional)',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          // TODO: Add team member invitation form
          Expanded(
            child: Center(
              child: Text(
                'Team member invitation coming soon',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAgentSetupStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set Up Shared AI Agent',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your business will have a shared AI agent that learns from all team members',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Card(
            child: SwitchListTile(
              title: const Text('Enable Shared AI Agent'),
              subtitle: const Text(
                'All team members will contribute to a shared business personality',
              ),
              value: _setupSharedAgent,
              onChanged: (value) {
                setState(() {
                  _setupSharedAgent = value;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          if (_setupSharedAgent)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your shared agent will learn from all team member interactions and create a unified business personality for better matching.',
                      style: TextStyle(color: AppColors.success),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompleteStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 80,
            color: AppColors.success,
          ),
          const SizedBox(height: 24),
          Text(
            'You\'re All Set!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your business account is ready. Start connecting with experts and growing your business!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String description;

  const OnboardingStep({
    required this.title,
    required this.description,
  });
}
