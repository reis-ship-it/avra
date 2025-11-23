import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:spots/core/models/list.dart';
import 'package:spots/domain/repositories/lists_repository.dart';
import 'package:spots/domain/usecases/lists/get_lists_usecase.dart';

import 'get_lists_usecase_test.mocks.dart';

// Generate mocks
@GenerateMocks([ListsRepository])
void main() {
  group('GetListsUseCase', () {
    late GetListsUseCase usecase;
    late MockListsRepository mockRepository;
    late List<SpotList> testLists;

    setUp(() {
      mockRepository = MockListsRepository();
      usecase = GetListsUseCase(mockRepository);
      
      testLists = [
        SpotList(
          id: 'list_1',
          title: 'Favorite Restaurants',
          description: 'My favorite dining spots',
          spots: [],
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          category: 'food',
          isPublic: true,
          respectCount: 25,
        ),
        SpotList(
          id: 'list_2',
          title: 'Weekend Adventures',
          description: 'Places for weekend getaways',
          spots: [],
          createdAt: DateTime(2024, 1, 2),
          updatedAt: DateTime(2024, 1, 2),
          category: 'outdoor',
          isPublic: false,
          respectCount: 12,
        ),
        SpotList(
          id: 'list_3',
          title: 'Art & Culture',
          description: 'Museums and galleries',
          spots: [],
          createdAt: DateTime(2024, 1, 3),
          updatedAt: DateTime(2024, 1, 3),
          category: 'culture',
          isPublic: true,
          respectCount: 45,
        ),
      ];
    });

    group('Successful retrieval', () {
      test('should return all lists successfully', () async {
        // Arrange
        when(mockRepository.getLists())
            .thenAnswer((_) async => testLists);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, equals(testLists));
        expect(result, hasLength(3));
        expect(result[0].title, equals('Favorite Restaurants'));
        expect(result[1].title, equals('Weekend Adventures'));
        expect(result[2].title, equals('Art & Culture'));
        verify(mockRepository.getLists()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return empty list when no lists exist', () async {
        // Arrange
        when(mockRepository.getLists())
            .thenAnswer((_) async => <SpotList>[]);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, isEmpty);
        expect(result, isA<List<SpotList>>());
        verify(mockRepository.getLists()).called(1);
      });

      test('should preserve all list properties', () async {
        // Arrange
        when(mockRepository.getLists())
            .thenAnswer((_) async => testLists);

        // Act
        final result = await usecase.call();

        // Assert
        final firstList = result.first;
        expect(firstList.id, equals('list_1'));
        expect(firstList.title, equals('Favorite Restaurants'));
        expect(firstList.description, equals('My favorite dining spots'));
        expect(firstList.category, equals('food'));
        expect(firstList.isPublic, isTrue);
        expect(firstList.respectCount, equals(25));
        verify(mockRepository.getLists()).called(1);
      });
    });

    group('Edge cases', () {
      test('should handle lists with different privacy settings', () async {
        // Arrange
        final mixedPrivacyLists = [
          testLists[0].copyWith(isPublic: true),
          testLists[1].copyWith(isPublic: false),
          testLists[2].copyWith(isPublic: true),
        ];

        when(mockRepository.getLists())
            .thenAnswer((_) async => mixedPrivacyLists);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result[0].isPublic, isTrue);
        expect(result[1].isPublic, isFalse);
        expect(result[2].isPublic, isTrue);
        verify(mockRepository.getLists()).called(1);
      });

      test('should handle large number of lists', () async {
        // Arrange
        final largeLists = List.generate(100, (index) => SpotList(
          id: 'list_$index',
          title: 'List $index',
          description: 'Description $index',
          spots: [],
          createdAt: DateTime(2024, 1, index % 30 + 1),
          updatedAt: DateTime(2024, 1, index % 30 + 1),
          respectCount: index,
        ));

        when(mockRepository.getLists())
            .thenAnswer((_) async => largeLists);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(100));
        expect(result.first.id, equals('list_0'));
        expect(result.last.id, equals('list_99'));
        verify(mockRepository.getLists()).called(1);
      });
    });

    group('Error handling', () {
      test('should throw exception when repository throws exception', () async {
        // Arrange
        final exception = Exception('Failed to load lists');
        when(mockRepository.getLists())
            .thenThrow(exception);

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(exception),
        );
        verify(mockRepository.getLists()).called(1);
      });

      test('should handle network timeout', () async {
        // Arrange
        final timeoutError = Exception('Network timeout');
        when(mockRepository.getLists())
            .thenThrow(timeoutError);

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(timeoutError),
        );
        verify(mockRepository.getLists()).called(1);
      });
    });

    group('Business logic validation', () {
      test('should not modify lists from repository', () async {
        // Arrange
        when(mockRepository.getLists())
            .thenAnswer((_) async => testLists);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, equals(testLists));
        expect(identical(result, testLists), isTrue);
        verify(mockRepository.getLists()).called(1);
      });

      test('should be idempotent', () async {
        // Arrange
        when(mockRepository.getLists())
            .thenAnswer((_) async => testLists);

        // Act
        final result1 = await usecase.call();
        final result2 = await usecase.call();

        // Assert
        expect(result1, equals(result2));
        verify(mockRepository.getLists()).called(2);
      });
    });
  });
}
