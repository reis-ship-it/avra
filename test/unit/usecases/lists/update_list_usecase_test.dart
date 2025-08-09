import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:spots/core/models/list.dart';
import 'package:spots/domain/repositories/lists_repository.dart';
import 'package:spots/domain/usecases/lists/update_list_usecase.dart';

import 'update_list_usecase_test.mocks.dart';

// Generate mocks
@GenerateMocks([ListsRepository])
void main() {
  group('UpdateListUseCase', () {
    late UpdateListUseCase usecase;
    late MockListsRepository mockRepository;
    late SpotList originalList;
    late SpotList updatedList;

    setUp(() {
      mockRepository = MockListsRepository();
      usecase = UpdateListUseCase(mockRepository);
      
      originalList = SpotList(
        id: 'list_123',
        title: 'Original Title',
        description: 'Original description',
        spots: [],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        category: 'original',
        isPublic: true,
        respectCount: 10,
      );

      updatedList = originalList.copyWith(
        title: 'Updated Title',
        description: 'Updated description',
        updatedAt: DateTime(2024, 1, 2),
        category: 'updated',
        respectCount: 15,
      );
    });

    group('Successful updates', () {
      test('should update list successfully', () async {
        // Arrange
        when(mockRepository.updateList(updatedList))
            .thenAnswer((_) async => updatedList);

        // Act
        final result = await usecase.call(updatedList);

        // Assert
        expect(result, equals(updatedList));
        expect(result.title, equals('Updated Title'));
        expect(result.description, equals('Updated description'));
        expect(result.category, equals('updated'));
        expect(result.respectCount, equals(15));
        verify(mockRepository.updateList(updatedList)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should update privacy setting', () async {
        // Arrange
        final privacyUpdate = originalList.copyWith(
          isPublic: false,
          updatedAt: DateTime(2024, 1, 3),
        );

        when(mockRepository.updateList(privacyUpdate))
            .thenAnswer((_) async => privacyUpdate);

        // Act
        final result = await usecase.call(privacyUpdate);

        // Assert
        expect(result.isPublic, isFalse);
        expect(result.title, equals(originalList.title)); // Preserved
        verify(mockRepository.updateList(privacyUpdate)).called(1);
      });

      test('should preserve immutable fields', () async {
        // Arrange
        when(mockRepository.updateList(updatedList))
            .thenAnswer((_) async => updatedList);

        // Act
        final result = await usecase.call(updatedList);

        // Assert
        expect(result.id, equals(originalList.id)); // Should be preserved
        expect(result.createdAt, equals(originalList.createdAt)); // Should be preserved
        verify(mockRepository.updateList(updatedList)).called(1);
      });
    });

    group('Error handling', () {
      test('should throw exception when repository throws exception', () async {
        // Arrange
        final exception = Exception('Update failed');
        when(mockRepository.updateList(updatedList))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () async => await usecase.call(updatedList),
          throwsA(exception),
        );
        verify(mockRepository.updateList(updatedList)).called(1);
      });

      test('should handle not found error', () async {
        // Arrange
        final notFoundError = Exception('List not found');
        when(mockRepository.updateList(updatedList))
            .thenThrow(notFoundError);

        // Act & Assert
        expect(
          () async => await usecase.call(updatedList),
          throwsA(notFoundError),
        );
        verify(mockRepository.updateList(updatedList)).called(1);
      });
    });

    group('Business logic validation', () {
      test('should pass list exactly as provided to repository', () async {
        // Arrange
        when(mockRepository.updateList(updatedList))
            .thenAnswer((_) async => updatedList);

        // Act
        final result = await usecase.call(updatedList);

        // Assert
        expect(result, equals(updatedList));
        verify(mockRepository.updateList(updatedList)).called(1);
      });

      test('should handle concurrent updates', () async {
        // Arrange
        when(mockRepository.updateList(updatedList))
            .thenAnswer((_) async => updatedList);

        // Act
        final futures = List.generate(3, (_) => usecase.call(updatedList));
        final results = await Future.wait(futures);

        // Assert
        for (final result in results) {
          expect(result, equals(updatedList));
        }
        verify(mockRepository.updateList(updatedList)).called(3);
      });
    });
  });
}
