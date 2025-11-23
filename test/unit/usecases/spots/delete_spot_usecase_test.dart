import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:spots/domain/repositories/spots_repository.dart';
import 'package:spots/domain/usecases/spots/delete_spot_usecase.dart';

import 'delete_spot_usecase_test.mocks.dart';

// Generate mocks
@GenerateMocks([SpotsRepository])
void main() {
  group('DeleteSpotUseCase', () {
    late DeleteSpotUseCase usecase;
    late MockSpotsRepository mockRepository;

    setUp(() {
      mockRepository = MockSpotsRepository();
      usecase = DeleteSpotUseCase(mockRepository);
    });

    group('Successful deletion', () {
      test('should delete spot successfully with valid ID', () async {
        // Arrange
        const spotId = 'test_spot_123';
        when(mockRepository.deleteSpot(spotId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(spotId);

        // Assert
        verify(mockRepository.deleteSpot(spotId)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should delete spot with UUID format ID', () async {
        // Arrange
        const uuidSpotId = '550e8400-e29b-41d4-a716-446655440000';
        when(mockRepository.deleteSpot(uuidSpotId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(uuidSpotId);

        // Assert
        verify(mockRepository.deleteSpot(uuidSpotId)).called(1);
      });

      test('should delete spot with numeric string ID', () async {
        // Arrange
        const numericSpotId = '12345';
        when(mockRepository.deleteSpot(numericSpotId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(numericSpotId);

        // Assert
        verify(mockRepository.deleteSpot(numericSpotId)).called(1);
      });

      test('should delete spot with alphanumeric ID', () async {
        // Arrange
        const alphanumericSpotId = 'spot_abc123_xyz';
        when(mockRepository.deleteSpot(alphanumericSpotId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(alphanumericSpotId);

        // Assert
        verify(mockRepository.deleteSpot(alphanumericSpotId)).called(1);
      });

      test('should handle deletion without returning any value', () async {
        // Arrange
        const spotId = 'spot_void_return';
        when(mockRepository.deleteSpot(spotId))
            .thenAnswer((_) async {});

        // Act
        await usecase.call(spotId);

        // Assert
        verify(mockRepository.deleteSpot(spotId)).called(1);
      });
    });

    group('Edge cases and validation', () {
      test('should handle deletion with empty string ID', () async {
        // Arrange
        const emptySpotId = '';
        when(mockRepository.deleteSpot(emptySpotId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(emptySpotId);

        // Assert
        verify(mockRepository.deleteSpot(emptySpotId)).called(1);
      });

      test('should handle deletion with very long ID', () async {
        // Arrange
        final longSpotId = 'a' * 1000; // Very long ID
        when(mockRepository.deleteSpot(longSpotId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(longSpotId);

        // Assert
        verify(mockRepository.deleteSpot(longSpotId)).called(1);
      });

      test('should handle deletion with special characters in ID', () async {
        // Arrange
        const specialCharId = 'spot_!@#\$%^&*()_+-=[]{}|;:,.<>?';
        when(mockRepository.deleteSpot(specialCharId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(specialCharId);

        // Assert
        verify(mockRepository.deleteSpot(specialCharId)).called(1);
      });

      test('should handle deletion with unicode characters in ID', () async {
        // Arrange
        const unicodeId = 'spot_测试_🏛️_café';
        when(mockRepository.deleteSpot(unicodeId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(unicodeId);

        // Assert
        verify(mockRepository.deleteSpot(unicodeId)).called(1);
      });

      test('should handle deletion with whitespace in ID', () async {
        // Arrange
        const whitespaceId = 'spot with spaces';
        when(mockRepository.deleteSpot(whitespaceId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(whitespaceId);

        // Assert
        verify(mockRepository.deleteSpot(whitespaceId)).called(1);
      });

      test('should handle deletion with ID containing only numbers', () async {
        // Arrange
        const numericId = '123456789';
        when(mockRepository.deleteSpot(numericId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(numericId);

        // Assert
        verify(mockRepository.deleteSpot(numericId)).called(1);
      });

      test('should handle deletion with mixed case ID', () async {
        // Arrange
        const mixedCaseId = 'SpOt_MiXeD_CaSe_123';
        when(mockRepository.deleteSpot(mixedCaseId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(mixedCaseId);

        // Assert
        verify(mockRepository.deleteSpot(mixedCaseId)).called(1);
      });
    });

    group('Error handling', () {
      test('should throw exception when repository throws exception', () async {
        // Arrange
        const spotId = 'error_spot';
        final exception = Exception('Network error during deletion');
        when(mockRepository.deleteSpot(spotId))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () async => await usecase.call(spotId),
          throwsA(exception),
        );
        verify(mockRepository.deleteSpot(spotId)).called(1);
      });

      test('should handle spot not found exception', () async {
        // Arrange
        const nonExistentSpotId = 'non_existent_spot';
        final notFoundError = Exception('Spot not found');
        when(mockRepository.deleteSpot(nonExistentSpotId))
            .thenThrow(notFoundError);

        // Act & Assert
        expect(
          () async => await usecase.call(nonExistentSpotId),
          throwsA(notFoundError),
        );
        verify(mockRepository.deleteSpot(nonExistentSpotId)).called(1);
      });

      test('should handle permission denied exception', () async {
        // Arrange
        const unauthorizedSpotId = 'unauthorized_spot';
        final permissionError = Exception('Permission denied');
        when(mockRepository.deleteSpot(unauthorizedSpotId))
            .thenThrow(permissionError);

        // Act & Assert
        expect(
          () async => await usecase.call(unauthorizedSpotId),
          throwsA(permissionError),
        );
        verify(mockRepository.deleteSpot(unauthorizedSpotId)).called(1);
      });

      test('should handle timeout exception', () async {
        // Arrange
        const timeoutSpotId = 'timeout_spot';
        final timeoutError = Exception('Request timeout');
        when(mockRepository.deleteSpot(timeoutSpotId))
            .thenThrow(timeoutError);

        // Act & Assert
        expect(
          () async => await usecase.call(timeoutSpotId),
          throwsA(timeoutError),
        );
        verify(mockRepository.deleteSpot(timeoutSpotId)).called(1);
      });

      test('should handle database constraint violation', () async {
        // Arrange
        const constraintSpotId = 'constraint_spot';
        final constraintError = Exception('Foreign key constraint violation');
        when(mockRepository.deleteSpot(constraintSpotId))
            .thenThrow(constraintError);

        // Act & Assert
        expect(
          () async => await usecase.call(constraintSpotId),
          throwsA(constraintError),
        );
        verify(mockRepository.deleteSpot(constraintSpotId)).called(1);
      });

      test('should handle argument error for invalid ID format', () async {
        // Arrange
        const invalidSpotId = 'invalid_id';
        final argumentError = ArgumentError('Invalid spot ID format');
        when(mockRepository.deleteSpot(invalidSpotId))
            .thenThrow(argumentError);

        // Act & Assert
        expect(
          () async => await usecase.call(invalidSpotId),
          throwsA(argumentError),
        );
        verify(mockRepository.deleteSpot(invalidSpotId)).called(1);
      });

      test('should handle state error when spot cannot be deleted', () async {
        // Arrange
        const protectedSpotId = 'protected_spot';
        final stateError = StateError('Spot cannot be deleted');
        when(mockRepository.deleteSpot(protectedSpotId))
            .thenThrow(stateError);

        // Act & Assert
        expect(
          () async => await usecase.call(protectedSpotId),
          throwsA(stateError),
        );
        verify(mockRepository.deleteSpot(protectedSpotId)).called(1);
      });

      test('should handle generic runtime error', () async {
        // Arrange
        const errorSpotId = 'runtime_error_spot';
        final runtimeError = Exception('Unexpected runtime error');
        when(mockRepository.deleteSpot(errorSpotId))
            .thenThrow(runtimeError);

        // Act & Assert
        expect(
          () async => await usecase.call(errorSpotId),
          throwsA(runtimeError),
        );
        verify(mockRepository.deleteSpot(errorSpotId)).called(1);
      });
    });

    group('Business logic validation', () {
      test('should pass spot ID exactly as provided to repository', () async {
        // Arrange
        const exactSpotId = 'exact_spot_id_123';
        when(mockRepository.deleteSpot(exactSpotId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(exactSpotId);

        // Assert
        verify(mockRepository.deleteSpot(exactSpotId)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should not modify or validate spot ID before passing to repository', () async {
        // Arrange - Testing that use case doesn't modify the ID
        const rawSpotId = '  spot_with_leading_trailing_spaces  ';
        when(mockRepository.deleteSpot(rawSpotId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(rawSpotId);

        // Assert
        verify(mockRepository.deleteSpot(rawSpotId)).called(1);
        // Verify it was called with the exact string including spaces
        verifyNever(mockRepository.deleteSpot(rawSpotId.trim()));
      });

      test('should handle deletion of spot that may be referenced by lists', () async {
        // Arrange
        const referencedSpotId = 'spot_in_multiple_lists';
        when(mockRepository.deleteSpot(referencedSpotId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(referencedSpotId);

        // Assert
        verify(mockRepository.deleteSpot(referencedSpotId)).called(1);
      });

      test('should handle deletion without any validation or business logic', () async {
        // Arrange
        const businessSpotId = 'business_spot_123';
        when(mockRepository.deleteSpot(businessSpotId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(businessSpotId);

        // Assert
        // Verify that the use case is a simple pass-through
        verify(mockRepository.deleteSpot(businessSpotId)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should complete successfully for deletion of non-existent spot if repository allows', () async {
        // Arrange
        const nonExistentSpotId = 'might_not_exist';
        when(mockRepository.deleteSpot(nonExistentSpotId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(nonExistentSpotId);

        // Assert
        verify(mockRepository.deleteSpot(nonExistentSpotId)).called(1);
      });

      test('should handle multiple deletion attempts of same spot ID', () async {
        // Arrange
        const sameSpotId = 'repeated_deletion_spot';
        when(mockRepository.deleteSpot(sameSpotId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(sameSpotId);
        await usecase.call(sameSpotId);
        await usecase.call(sameSpotId);

        // Assert
        verify(mockRepository.deleteSpot(sameSpotId)).called(3);
      });
    });

    group('Integration scenarios', () {
      test('should handle deletion in offline mode if repository supports it', () async {
        // Arrange
        const offlineSpotId = 'offline_spot';
        when(mockRepository.deleteSpot(offlineSpotId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(offlineSpotId);

        // Assert
        verify(mockRepository.deleteSpot(offlineSpotId)).called(1);
      });

      test('should handle deletion with eventual consistency', () async {
        // Arrange
        const eventualSpotId = 'eventual_consistency_spot';
        when(mockRepository.deleteSpot(eventualSpotId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(eventualSpotId);

        // Assert
        verify(mockRepository.deleteSpot(eventualSpotId)).called(1);
      });

      test('should handle cascading deletion if repository implements it', () async {
        // Arrange
        const cascadeSpotId = 'cascade_delete_spot';
        when(mockRepository.deleteSpot(cascadeSpotId))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(cascadeSpotId);

        // Assert
        verify(mockRepository.deleteSpot(cascadeSpotId)).called(1);
      });
    });
  });
}
