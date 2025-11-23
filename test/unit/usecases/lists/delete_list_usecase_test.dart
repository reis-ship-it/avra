import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:spots/domain/repositories/lists_repository.dart';
import 'package:spots/domain/usecases/lists/delete_list_usecase.dart';

import 'delete_list_usecase_test.mocks.dart';

// Generate mocks
@GenerateMocks([ListsRepository])
void main() {
  group('DeleteListUseCase', () {
    late DeleteListUseCase usecase;
    late MockListsRepository mockRepository;

    setUp(() {
      mockRepository = MockListsRepository();
      usecase = DeleteListUseCase(mockRepository);
    });

    group('Successful deletion', () {
      test('should delete list successfully with valid ID', () async {
        // Arrange
        const listId = 'list_123';
        when(mockRepository.deleteList(listId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(listId);

        // Assert
        verify(mockRepository.deleteList(listId)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should handle different ID formats', () async {
        // Arrange
        final idFormats = [
          'simple_id',
          'uuid_550e8400-e29b-41d4-a716-446655440000',
          '12345',
          'list_with_special_chars_!@#',
        ];

        for (final listId in idFormats) {
          when(mockRepository.deleteList(listId))
              .thenAnswer((_) async => Future<void>.value());

          // Act
          await usecase.call(listId);

          // Assert
          verify(mockRepository.deleteList(listId)).called(1);
        }
      });

      test('should complete without returning value', () async {
        // Arrange
        const listId = 'test_list';
        when(mockRepository.deleteList(listId))
            .thenAnswer((_) async {});

        // Act
        await usecase.call(listId);

        // Assert
        verify(mockRepository.deleteList(listId)).called(1);
      });
    });

    group('Error handling', () {
      test('should throw exception when repository throws exception', () async {
        // Arrange
        const listId = 'error_list';
        final exception = Exception('Failed to delete list');
        when(mockRepository.deleteList(listId))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () async => await usecase.call(listId),
          throwsA(exception),
        );
        verify(mockRepository.deleteList(listId)).called(1);
      });

      test('should handle list not found error', () async {
        // Arrange
        const listId = 'non_existent_list';
        final notFoundError = Exception('List not found');
        when(mockRepository.deleteList(listId))
            .thenThrow(notFoundError);

        // Act & Assert
        expect(
          () async => await usecase.call(listId),
          throwsA(notFoundError),
        );
        verify(mockRepository.deleteList(listId)).called(1);
      });

      test('should handle permission denied error', () async {
        // Arrange
        const listId = 'protected_list';
        final permissionError = Exception('Permission denied');
        when(mockRepository.deleteList(listId))
            .thenThrow(permissionError);

        // Act & Assert
        expect(
          () async => await usecase.call(listId),
          throwsA(permissionError),
        );
        verify(mockRepository.deleteList(listId)).called(1);
      });
    });

    group('Business logic validation', () {
      test('should pass ID exactly as provided to repository', () async {
        // Arrange
        const exactId = 'exact_list_id';
        when(mockRepository.deleteList(exactId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(exactId);

        // Assert
        verify(mockRepository.deleteList(exactId)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should handle multiple deletion attempts', () async {
        // Arrange
        const listId = 'repeated_delete';
        when(mockRepository.deleteList(listId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(listId);
        await usecase.call(listId);

        // Assert
        verify(mockRepository.deleteList(listId)).called(2);
      });

      test('should handle concurrent deletion attempts', () async {
        // Arrange
        const listId = 'concurrent_delete';
        when(mockRepository.deleteList(listId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        final futures = List.generate(3, (_) => usecase.call(listId));
        await Future.wait(futures);

        // Assert
        verify(mockRepository.deleteList(listId)).called(3);
      });
    });
  });
}
