import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:spots/presentation/pages/auth/login_page.dart';
import 'package:spots/presentation/pages/onboarding/onboarding_page.dart';
import 'package:spots/presentation/pages/lists/lists_page.dart';
import 'package:spots/presentation/widgets/common/universal_ai_search.dart';
import '../helpers/widget_test_helpers.dart';
import '../mocks/mock_blocs.dart';

void main() {
  group('Golden File Tests - Visual Regression Protection', () {
    
    setUp(() {
      // Load fonts for consistent golden tests
      return loadAppFonts();
    });

    group('Authentication Pages Golden Tests', () {
      testGoldens('Login page renders correctly', (tester) async {
        // Arrange
        final mockAuthBloc = MockBlocFactory.createUnauthenticatedAuthBloc();
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const LoginPage(),
          authBloc: mockAuthBloc,
        );

        // Act
        await tester.pumpWidgetBuilder(
          widget,
          surfaceSize: const Size(400, 800),
        );

        // Assert - Generate golden file
        await screenMatchesGolden(tester, 'login_page');
      });

      testGoldens('Login page in loading state', (tester) async {
        // Arrange
        final mockAuthBloc = MockBlocFactory.createLoadingAuthBloc();
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const LoginPage(),
          authBloc: mockAuthBloc,
        );

        // Act
        await tester.pumpWidgetBuilder(
          widget,
          surfaceSize: const Size(400, 800),
        );

        // Assert
        await screenMatchesGolden(tester, 'login_page_loading');
      });

      testGoldens('Login page with error state', (tester) async {
        // Arrange
        final mockAuthBloc = MockBlocFactory.createErrorAuthBloc('Invalid credentials');
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const LoginPage(),
          authBloc: mockAuthBloc,
        );

        // Act
        await tester.pumpWidgetBuilder(
          widget,
          surfaceSize: const Size(400, 800),
        );

        // Assert
        await screenMatchesGolden(tester, 'login_page_error');
      });
    });

    group('Onboarding Pages Golden Tests', () {
      testGoldens('Onboarding page initial step', (tester) async {
        // Arrange
        final mockAuthBloc = MockBlocFactory.createAuthenticatedAuthBloc();
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const OnboardingPage(),
          authBloc: mockAuthBloc,
        );

        // Act
        await tester.pumpWidgetBuilder(
          widget,
          surfaceSize: const Size(400, 800),
        );

        // Assert
        await screenMatchesGolden(tester, 'onboarding_page_initial');
      });

      testGoldens('Onboarding page landscape orientation', (tester) async {
        // Arrange
        final mockAuthBloc = MockBlocFactory.createAuthenticatedAuthBloc();
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const OnboardingPage(),
          authBloc: mockAuthBloc,
        );

        // Act
        await tester.pumpWidgetBuilder(
          widget,
          surfaceSize: const Size(800, 400), // Landscape
        );

        // Assert
        await screenMatchesGolden(tester, 'onboarding_page_landscape');
      });
    });

    group('Lists Page Golden Tests', () {
      testGoldens('Lists page with empty state', (tester) async {
        // Arrange
        final mockListsBloc = MockBlocFactory.createLoadedListsBloc([]);
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const ListsPage(),
          listsBloc: mockListsBloc,
        );

        // Act
        await tester.pumpWidgetBuilder(
          widget,
          surfaceSize: const Size(400, 800),
        );

        // Assert
        await screenMatchesGolden(tester, 'lists_page_empty');
      });

      testGoldens('Lists page with data', (tester) async {
        // Arrange
        final testLists = TestDataFactory.createTestLists(3);
        final mockListsBloc = MockBlocFactory.createLoadedListsBloc(testLists);
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const ListsPage(),
          listsBloc: mockListsBloc,
        );

        // Act
        await tester.pumpWidgetBuilder(
          widget,
          surfaceSize: const Size(400, 800),
        );

        // Assert
        await screenMatchesGolden(tester, 'lists_page_with_data');
      });

      testGoldens('Lists page loading state', (tester) async {
        // Arrange
        final mockListsBloc = MockBlocFactory.createLoadingListsBloc();
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const ListsPage(),
          listsBloc: mockListsBloc,
        );

        // Act
        await tester.pumpWidgetBuilder(
          widget,
          surfaceSize: const Size(400, 800),
        );

        // Assert
        await screenMatchesGolden(tester, 'lists_page_loading');
      });

      testGoldens('Lists page error state', (tester) async {
        // Arrange
        final mockListsBloc = MockBlocFactory.createErrorListsBloc('Network error');
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const ListsPage(),
          listsBloc: mockListsBloc,
        );

        // Act
        await tester.pumpWidgetBuilder(
          widget,
          surfaceSize: const Size(400, 800),
        );

        // Assert
        await screenMatchesGolden(tester, 'lists_page_error');
      });
    });

    group('Component Golden Tests', () {
      testGoldens('Universal AI Search component', (tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: UniversalAISearch(
                hintText: 'Search for anything...',
              ),
            ),
          ),
        );

        // Act
        await tester.pumpWidgetBuilder(
          widget,
          surfaceSize: const Size(400, 200),
        );

        // Assert
        await screenMatchesGolden(tester, 'universal_ai_search');
      });

      testGoldens('Universal AI Search loading state', (tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: UniversalAISearch(
                hintText: 'Loading...',
                isLoading: true,
              ),
            ),
          ),
        );

        // Act
        await tester.pumpWidgetBuilder(
          widget,
          surfaceSize: const Size(400, 200),
        );

        // Assert
        await screenMatchesGolden(tester, 'universal_ai_search_loading');
      });

      testGoldens('Universal AI Search disabled state', (tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: UniversalAISearch(
                hintText: 'Disabled search',
                enabled: false,
              ),
            ),
          ),
        );

        // Act
        await tester.pumpWidgetBuilder(
          widget,
          surfaceSize: const Size(400, 200),
        );

        // Assert
        await screenMatchesGolden(tester, 'universal_ai_search_disabled');
      });
    });

    group('Dialog Golden Tests', () {
      testGoldens('Age verification dialog', (tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: Builder(
            builder: (context) {
              // Show dialog immediately for golden test
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Age Verification'),
                    content: const Text('Are you 18 or older?'),
                    actions: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                );
              });
              return const Scaffold(
                body: Center(child: Text('Background')),
              );
            },
          ),
        );

        // Act
        await tester.pumpWidgetBuilder(widget);
        await tester.pump(); // Show dialog

        // Assert
        await screenMatchesGolden(tester, 'age_verification_dialog');
      });

      testGoldens('Delete confirmation dialog', (tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: const Text('This action cannot be undone. Are you sure?'),
                    actions: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              });
              return const Scaffold(
                body: Center(child: Text('Background')),
              );
            },
          ),
        );

        // Act
        await tester.pumpWidgetBuilder(widget);
        await tester.pump();

        // Assert
        await screenMatchesGolden(tester, 'delete_confirmation_dialog');
      });
    });

    group('Theme Variation Golden Tests', () {
      testGoldens('Login page with dark theme', (tester) async {
        // Arrange
        final mockAuthBloc = MockBlocFactory.createUnauthenticatedAuthBloc();
        final widget = MaterialApp(
          theme: ThemeData.dark(),
          home: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: mockAuthBloc),
            ],
            child: const LoginPage(),
          ),
        );

        // Act
        await tester.pumpWidgetBuilder(
          widget,
          surfaceSize: const Size(400, 800),
        );

        // Assert
        await screenMatchesGolden(tester, 'login_page_dark_theme');
      });
    });

    group('Responsive Design Golden Tests', () {
      testGoldens('Login page on tablet', (tester) async {
        // Arrange
        final mockAuthBloc = MockBlocFactory.createUnauthenticatedAuthBloc();
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const LoginPage(),
          authBloc: mockAuthBloc,
        );

        // Act
        await tester.pumpWidgetBuilder(
          widget,
          surfaceSize: const Size(768, 1024), // Tablet size
        );

        // Assert
        await screenMatchesGolden(tester, 'login_page_tablet');
      });

      testGoldens('Lists page on tablet landscape', (tester) async {
        // Arrange
        final testLists = TestDataFactory.createTestLists(5);
        final mockListsBloc = MockBlocFactory.createLoadedListsBloc(testLists);
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const ListsPage(),
          listsBloc: mockListsBloc,
        );

        // Act
        await tester.pumpWidgetBuilder(
          widget,
          surfaceSize: const Size(1024, 768), // Tablet landscape
        );

        // Assert
        await screenMatchesGolden(tester, 'lists_page_tablet_landscape');
      });
    });

    group('Accessibility Golden Tests', () {
      testGoldens('Login page with large text', (tester) async {
        // Arrange
        final mockAuthBloc = MockBlocFactory.createUnauthenticatedAuthBloc();
        final widget = MaterialApp(
          theme: ThemeData(
            textTheme: ThemeData().textTheme.apply(fontSizeFactor: 1.5),
          ),
          home: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: mockAuthBloc),
            ],
            child: const LoginPage(),
          ),
        );

        // Act
        await tester.pumpWidgetBuilder(
          widget,
          surfaceSize: const Size(400, 800),
        );

        // Assert
        await screenMatchesGolden(tester, 'login_page_large_text');
      });
    });
  });
}

/// Custom golden test configuration
GoldenToolkitConfiguration get goldenToolkitConfiguration {
  return GoldenToolkitConfiguration(
    enableRealShadows: true,
    fileNameFactory: (name) => '$name.png',
  );
}
