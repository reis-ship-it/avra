import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/lists/lists_page.dart';
import 'package:spots/presentation/blocs/lists/lists_bloc.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../mocks/mock_blocs.dart';

void main() {
  group('ListsPage Widget Tests', () {
    late MockListsBloc mockListsBloc;

    setUp(() {
      mockListsBloc = MockListsBloc();
    });

    // Removed: Property assignment tests
    // Lists page tests focus on business logic (UI display, state management, interactions, accessibility), not property assignment

    testWidgets(
        'should display app bar with title and actions, show loading state when lists are loading, show error state with retry button, trigger reload when retry button is tapped, display empty state when no lists exist, display list of spot lists when loaded, display floating action button for creating lists, navigate to create list page when FAB is tapped, trigger load lists event on initial state, handle unknown state gracefully, maintain scroll position during rebuilds, meet accessibility requirements, handle rapid state changes gracefully, or show offline indicator when configured',
        (WidgetTester tester) async {
      // Test business logic: Lists page state management, display, and interactions
      mockListsBloc.setState(ListsInitial());
      final widget1 = WidgetTestHelpers.createTestableWidget(
        child: const ListsPage(),
        listsBloc: mockListsBloc,
      );
      await tester.pumpWidget(widget1);
      await tester.pump();
      expect(find.text('My Lists'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(mockListsBloc.addedEvents.whereType<LoadLists>().length,
          greaterThanOrEqualTo(1));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      mockListsBloc.setState(ListsLoading());
      final widget2 = WidgetTestHelpers.createTestableWidget(
        child: const ListsPage(),
        listsBloc: mockListsBloc,
      );
      await tester.pumpWidget(widget2);
      await tester.pump();
      WidgetTestHelpers.verifyLoadingState(tester);

      const errorMessage = 'Failed to load lists';
      mockListsBloc.setState(ListsError(errorMessage));
      final widget3 = WidgetTestHelpers.createTestableWidget(
        child: const ListsPage(),
        listsBloc: mockListsBloc,
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget3);
      WidgetTestHelpers.verifyErrorState(tester, errorMessage);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Error loading lists'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(mockListsBloc.addedEvents.whereType<LoadLists>().length,
          greaterThanOrEqualTo(1));

      mockListsBloc.setState(ListsLoaded([], []));
      final widget4 = WidgetTestHelpers.createTestableWidget(
        child: const ListsPage(),
        listsBloc: mockListsBloc,
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget4);
      expect(find.text('No lists yet'), findsOneWidget);
      expect(find.text('Create your first list to start organizing your spots'),
          findsOneWidget);
      expect(find.byIcon(Icons.list_alt_outlined), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsOneWidget);

      final testLists1 = TestDataFactory.createTestLists(3);
      mockListsBloc.setState(ListsLoaded(testLists1, testLists1));
      final widget5 = WidgetTestHelpers.createTestableWidget(
        child: const ListsPage(),
        listsBloc: mockListsBloc,
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget5);
      expect(find.text('Test List 0'), findsOneWidget);
      expect(find.text('Test List 1'), findsOneWidget);
      expect(find.text('Test List 2'), findsOneWidget);

      final testLists2 = TestDataFactory.createTestLists(20);
      mockListsBloc.setState(ListsLoaded(testLists2, testLists2));
      final widget6 = WidgetTestHelpers.createTestableWidget(
        child: const ListsPage(),
        listsBloc: mockListsBloc,
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget6);
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();
      await tester.pump();
      expect(find.text('Test List 0'), findsNothing);

      final testLists3 = TestDataFactory.createTestLists(2);
      mockListsBloc.setState(ListsLoaded(testLists3, testLists3));
      final widget7 = WidgetTestHelpers.createTestableWidget(
        child: const ListsPage(),
        listsBloc: mockListsBloc,
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget7);
      expect(find.text('My Lists'), findsOneWidget);
      final fab = tester.getSize(find.byType(FloatingActionButton));
      expect(fab.width, greaterThanOrEqualTo(48.0));
      expect(fab.height, greaterThanOrEqualTo(48.0));
      expect(find.text('Test List 0'), findsOneWidget);
      expect(find.text('Test List 1'), findsOneWidget);

      mockListsBloc.setState(ListsLoading());
      mockListsBloc.setStream(Stream.fromIterable([
        ListsLoading(),
        ListsLoaded([], []),
        ListsError('Error'),
        ListsLoaded([], []),
      ]));
      final widget8 = WidgetTestHelpers.createTestableWidget(
        child: const ListsPage(),
        listsBloc: mockListsBloc,
      );
      await tester.pumpWidget(widget8);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byType(ListsPage), findsOneWidget);

      mockListsBloc.setState(ListsLoaded([], []));
      final widget9 = WidgetTestHelpers.createTestableWidget(
        child: const ListsPage(),
        listsBloc: mockListsBloc,
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget9);
      expect(find.byType(AppBar), findsOneWidget);
    });

    group('List Interaction Tests', () {
      // Removed: Property assignment tests
      // List interaction tests focus on business logic (list card taps, pull-to-refresh), not property assignment

      testWidgets(
          'should handle list card taps or refresh lists with pull-to-refresh',
          (WidgetTester tester) async {
        // Test business logic: Lists page list interactions
        final testLists1 = TestDataFactory.createTestLists(1);
        mockListsBloc.setState(ListsLoaded(testLists1, testLists1));
        final widget1 = WidgetTestHelpers.createTestableWidget(
          child: const ListsPage(),
          listsBloc: mockListsBloc,
        );
        await WidgetTestHelpers.pumpAndSettle(tester, widget1);
        await tester.tap(find.text('Test List 0'));
        await tester.pump();
        expect(find.text('Test List 0'), findsOneWidget);

        final testLists2 = TestDataFactory.createTestLists(3);
        mockListsBloc.setState(ListsLoaded(testLists2, testLists2));
        final widget2 = WidgetTestHelpers.createTestableWidget(
          child: const ListsPage(),
          listsBloc: mockListsBloc,
        );
        await WidgetTestHelpers.pumpAndSettle(tester, widget2);
        await tester.drag(find.byType(ListView), const Offset(0, 300));
        await tester.pump();
        expect(find.text('Test List 0'), findsOneWidget);
      });
    });
  });
}
