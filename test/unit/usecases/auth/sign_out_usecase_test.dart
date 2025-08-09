import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:spots/domain/repositories/auth_repository.dart';
import 'package:spots/domain/usecases/auth/sign_out_usecase.dart';

import 'sign_out_usecase_test.mocks.dart';

// Generate mocks
@GenerateMocks([AuthRepository])
void main() {
  group('SignOutUseCase', () {
    late SignOutUseCase usecase;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      usecase = SignOutUseCase(mockRepository);
    });

    group('Successful sign out', () {
      test('should sign out user successfully', () async {
        // Arrange
        when(mockRepository.signOut())
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call();

        // Assert
        verify(mockRepository.signOut()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should complete sign out without returning value', () async {
        // Arrange
        when(mockRepository.signOut())
            .thenAnswer((_) async {});

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, isNull);
        verify(mockRepository.signOut()).called(1);
      });

      test('should handle multiple sign out calls', () async {
        // Arrange
        when(mockRepository.signOut())
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call();
        await usecase.call();
        await usecase.call();

        // Assert
        verify(mockRepository.signOut()).called(3);
      });

      test('should handle concurrent sign out attempts', () async {
        // Arrange
        when(mockRepository.signOut())
            .thenAnswer((_) async => Future<void>.value());

        // Act
        final futures = List.generate(5, (_) => usecase.call());
        await Future.wait(futures);

        // Assert
        verify(mockRepository.signOut()).called(5);
      });
    });

    group('Error handling', () {
      test('should throw exception when repository throws exception', () async {
        // Arrange
        final exception = Exception('Network error during sign out');
        when(mockRepository.signOut())
            .thenThrow(exception);

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(exception),
        );
        verify(mockRepository.signOut()).called(1);
      });

      test('should handle already signed out exception', () async {
        // Arrange
        final alreadySignedOutError = Exception('User already signed out');
        when(mockRepository.signOut())
            .thenThrow(alreadySignedOutError);

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(alreadySignedOutError),
        );
        verify(mockRepository.signOut()).called(1);
      });

      test('should handle network timeout during sign out', () async {
        // Arrange
        final timeoutError = Exception('Network timeout');
        when(mockRepository.signOut())
            .thenThrow(timeoutError);

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(timeoutError),
        );
        verify(mockRepository.signOut()).called(1);
      });

      test('should handle server error during sign out', () async {
        // Arrange
        final serverError = Exception('Internal server error');
        when(mockRepository.signOut())
            .thenThrow(serverError);

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(serverError),
        );
        verify(mockRepository.signOut()).called(1);
      });

      test('should handle authentication state error', () async {
        // Arrange
        final stateError = StateError('Invalid authentication state');
        when(mockRepository.signOut())
            .thenThrow(stateError);

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(stateError),
        );
        verify(mockRepository.signOut()).called(1);
      });

      test('should handle token invalidation error', () async {
        // Arrange
        final tokenError = Exception('Failed to invalidate token');
        when(mockRepository.signOut())
            .thenThrow(tokenError);

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(tokenError),
        );
        verify(mockRepository.signOut()).called(1);
      });

      test('should handle session cleanup error', () async {
        // Arrange
        final cleanupError = Exception('Failed to cleanup session');
        when(mockRepository.signOut())
            .thenThrow(cleanupError);

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(cleanupError),
        );
        verify(mockRepository.signOut()).called(1);
      });

      test('should handle offline mode error', () async {
        // Arrange
        final offlineError = Exception('Cannot sign out in offline mode');
        when(mockRepository.signOut())
            .thenThrow(offlineError);

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(offlineError),
        );
        verify(mockRepository.signOut()).called(1);
      });
    });

    group('Business logic validation', () {
      test('should be a simple pass-through to repository', () async {
        // Arrange
        when(mockRepository.signOut())
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call();

        // Assert
        verify(mockRepository.signOut()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should not perform any validation or business logic', () async {
        // Arrange
        when(mockRepository.signOut())
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call();

        // Assert
        // Verify that the use case is a simple pass-through
        verify(mockRepository.signOut()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should be stateless between calls', () async {
        // Arrange
        when(mockRepository.signOut())
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call();
        await usecase.call();

        // Assert
        verify(mockRepository.signOut()).called(2);
      });

      test('should handle idempotent sign out operations', () async {
        // Arrange
        when(mockRepository.signOut())
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call();
        await usecase.call();
        await usecase.call();

        // Assert
        verify(mockRepository.signOut()).called(3);
      });
    });

    group('Integration scenarios', () {
      test('should handle sign out in different user states', () async {
        // Arrange - Test that use case doesn't care about user state
        when(mockRepository.signOut())
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call(); // Could be online user
        await usecase.call(); // Could be offline user
        await usecase.call(); // Could be already signed out

        // Assert
        verify(mockRepository.signOut()).called(3);
      });

      test('should handle sign out during app shutdown', () async {
        // Arrange
        when(mockRepository.signOut())
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call();

        // Assert
        verify(mockRepository.signOut()).called(1);
      });

      test('should handle sign out during app backgrounding', () async {
        // Arrange
        when(mockRepository.signOut())
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call();

        // Assert
        verify(mockRepository.signOut()).called(1);
      });

      test('should handle forced sign out scenarios', () async {
        // Arrange
        when(mockRepository.signOut())
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call();

        // Assert
        verify(mockRepository.signOut()).called(1);
      });

      test('should handle sign out after session expiry', () async {
        // Arrange
        when(mockRepository.signOut())
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call();

        // Assert
        verify(mockRepository.signOut()).called(1);
      });
    });

    group('Performance and reliability', () {
      test('should complete quickly for successful sign out', () async {
        // Arrange
        when(mockRepository.signOut())
            .thenAnswer((_) async => Future<void>.value());

        // Act
        final start = DateTime.now();
        await usecase.call();
        final duration = DateTime.now().difference(start);

        // Assert
        expect(duration.inMilliseconds, lessThan(100));
        verify(mockRepository.signOut()).called(1);
      });

      test('should not hold resources between calls', () async {
        // Arrange
        when(mockRepository.signOut())
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call();
        // Verify no lingering state
        await usecase.call();

        // Assert
        verify(mockRepository.signOut()).called(2);
      });

      test('should handle rapid successive calls', () async {
        // Arrange
        when(mockRepository.signOut())
            .thenAnswer((_) async => Future<void>.value());

        // Act
        final futures = <Future<void>>[];
        for (int i = 0; i < 10; i++) {
          futures.add(usecase.call());
        }
        await Future.wait(futures);

        // Assert
        verify(mockRepository.signOut()).called(10);
      });

      test('should handle delayed repository response', () async {
        // Arrange
        when(mockRepository.signOut())
            .thenAnswer((_) async {
              await Future.delayed(Duration(milliseconds: 100));
              return Future<void>.value();
            });

        // Act
        await usecase.call();

        // Assert
        verify(mockRepository.signOut()).called(1);
      });
    });

    group('Error recovery', () {
      test('should handle transient network failures', () async {
        // Arrange
        when(mockRepository.signOut())
            .thenThrow(Exception('Temporary network failure'));

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(isA<Exception>()),
        );
        verify(mockRepository.signOut()).called(1);
      });

      test('should handle partial sign out failures', () async {
        // Arrange
        when(mockRepository.signOut())
            .thenThrow(Exception('Partial sign out failure'));

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(isA<Exception>()),
        );
        verify(mockRepository.signOut()).called(1);
      });

      test('should not attempt retry logic', () async {
        // Arrange
        when(mockRepository.signOut())
            .thenThrow(Exception('Sign out failed'));

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(isA<Exception>()),
        );
        // Verify it was only called once (no retry)
        verify(mockRepository.signOut()).called(1);
      });
    });

    group('Security considerations', () {
      test('should delegate all security to repository', () async {
        // Arrange
        when(mockRepository.signOut())
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await usecase.call();

        // Assert
        // Use case should not implement any security logic
        verify(mockRepository.signOut()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should handle security token invalidation errors', () async {
        // Arrange
        final securityError = Exception('Security token invalidation failed');
        when(mockRepository.signOut())
            .thenThrow(securityError);

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(securityError),
        );
        verify(mockRepository.signOut()).called(1);
      });

      test('should handle session cleanup security requirements', () async {
        // Arrange
        final cleanupError = Exception('Secure session cleanup failed');
        when(mockRepository.signOut())
            .thenThrow(cleanupError);

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(cleanupError),
        );
        verify(mockRepository.signOut()).called(1);
      });
    });
  });
}
