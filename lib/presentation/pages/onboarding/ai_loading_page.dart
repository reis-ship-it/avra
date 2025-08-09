import 'package:spots/core/services/logger.dart';
import 'package:flutter/material.dart';
import 'package:spots/core/theme/colors.dart';
import 'package:spots/core/models/unified_models.dart';
import 'package:spots/core/theme/app_theme.dart';
import 'package:spots/presentation/blocs/lists/lists_bloc.dart';
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spots/core/models/list.dart';
import 'package:spots/data/datasources/local/onboarding_completion_service.dart';

// Stub class for missing service
class AIListGeneratorService {
  static Future<List<dynamic>> generatePersonalizedLists(
    String userId,
    List<String> homebases,
    Map<String, dynamic> preferences,
  ) async {
    return [];
  }
}

class AILoadingPage extends StatefulWidget {
  final String userName;
  final String? homebase;
  final List<String> favoritePlaces;
  final Map<String, List<String>> preferences;
  final Function() onLoadingComplete;

  const AILoadingPage({
    super.key,
    required this.userName,
    this.homebase,
    this.favoritePlaces = const [],
    this.preferences = const {},
    required this.onLoadingComplete,
  });

  @override
  State<AILoadingPage> createState() => _AILoadingPageState();
}

class _AILoadingPageState extends State<AILoadingPage>
    with TickerProviderStateMixin {
  final AppLogger _logger = const AppLogger(defaultTag: 'SPOTS', minimumLevel: LogLevel.debug);
  bool _isLoading = true;
  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));

    // Start loading animation
    _startLoading();
  }

  void _startLoading() async {
    _loadingController.repeat();

    try {
      // Use actual onboarding data passed to this widget
      String userName = widget.userName;
      String? homebase = widget.homebase;
      List<String> favoritePlaces = widget.favoritePlaces;
      Map<String, List<String>> preferences = widget.preferences;

      _logger.info('🎯 AI Loading Data:', tag: 'AILoadingPage');
      _logger.debug('  User: $userName', tag: 'AILoadingPage');
      _logger.debug('  Homebase: $homebase', tag: 'AILoadingPage');
      _logger.debug('  Favorite Places: $favoritePlaces', tag: 'AILoadingPage');
      _logger.debug('  Preferences: $preferences', tag: 'AILoadingPage');

      // If no data was passed, use fallback values
      if (homebase == null || homebase.isEmpty) {
        homebase = "New York";
        _logger.warn('⚠️ Using fallback homebase: $homebase', tag: 'AILoadingPage');
      }
      if (favoritePlaces.isEmpty) {
        favoritePlaces = [
          "Central Park",
          "Brooklyn Bridge",
          "Times Square",
          "Empire State Building",
          "Statue of Liberty"
        ];
        _logger.warn('⚠️ Using fallback favorite places: $favoritePlaces', tag: 'AILoadingPage');
      }
      if (preferences.isEmpty) {
        preferences = {
          'Food & Drink': ['Coffee & Tea', 'Fine Dining', 'Craft Beer'],
          'Activities': ['Live Music', 'Theaters', 'Shopping'],
          'Outdoor & Nature': ['Parks', 'Hiking Trails', 'Scenic Views']
        };
        _logger.warn('⚠️ Using fallback preferences: $preferences', tag: 'AILoadingPage');
      }

      // Generate personalized lists using AI
      _logger.info('🔄 Generating AI lists...', tag: 'AILoadingPage');
      final generatedLists = await AIListGeneratorService.generatePersonalizedLists(
        userName,
        [homebase ?? "New York"],
        preferences,
      );

      _logger.info('✅ Generated ${generatedLists.length} lists: $generatedLists', tag: 'AILoadingPage');

      // Create the lists in the app
      if (mounted && generatedLists.isNotEmpty) {
        final listsBloc = context.read<ListsBloc>();
        
        for (final listName in generatedLists) {
          final newList = SpotList(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: listName,
            description: 'AI-generated list based on your preferences',
            spots: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            category: 'AI Generated',
            isPublic: true,
            spotIds: [],
            respectCount: 0,
          );
          _logger.debug('📝 Creating list: ${newList.title}', tag: 'AILoadingPage');
          listsBloc.add(CreateList(newList));
        }
      }

      // Add a small delay to show the loading animation
      await Future.delayed(const Duration(seconds: 2));

    } catch (e) {
      // Handle error - still complete onboarding
      _logger.error('Error generating lists', error: e, tag: 'AILoadingPage');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _loadingController.stop();

      // Call the completion callback only if still mounted
      if (mounted) {
        // Mark onboarding as completed
        await _markOnboardingCompleted();
        widget.onLoadingComplete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Welcome to SPOTS!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'re setting up your personalized experience',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.grey600,
                    ),
              ),
              const SizedBox(height: 48),

              // Loading content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // AI Processing Animation
                      AnimatedBuilder(
                        animation: _loadingAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Icon(
                              Icons.psychology,
                              color: AppColors.white,
                              size: 40,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'AI is creating your personalized lists...',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Analyzing your preferences and favorite places to curate the perfect spots just for you.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.grey600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Progress dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              // Info section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personalized Lists',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Based on your homebase, favorite places, and preferences, we\'ll create lists tailored just for you.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.grey700,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _markOnboardingCompleted() async {
    try {
      await OnboardingCompletionService.markOnboardingCompleted();
      _logger.info('✅ Onboarding marked as completed', tag: 'AILoadingPage');
    } catch (e) {
      _logger.error('Error marking onboarding completed', error: e, tag: 'AILoadingPage');
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }
}
