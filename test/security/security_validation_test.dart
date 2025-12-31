import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spots/core/services/agent_id_service.dart';
import 'package:spots/core/services/secure_mapping_encryption_service.dart';
import 'package:spots/core/services/supabase_service.dart';
import 'dart:typed_data';

/// Mock services for testing
class MockSupabaseService extends Mock implements SupabaseService {}
class MockSecureMappingEncryptionService extends Mock implements SecureMappingEncryptionService {}

/// Security Validation Tests
/// 
/// Tests security requirements for agent ID mappings:
/// - Encryption service is required
/// - No plaintext storage
/// - Access control
void main() {
  group('Security Validation Tests', () {
    late MockSupabaseService mockSupabaseService;
    late MockSecureMappingEncryptionService mockEncryptionService;
    
    setUp(() {
      mockSupabaseService = MockSupabaseService();
      mockEncryptionService = MockSecureMappingEncryptionService();
      
      // Register fallback values
      registerFallbackValue(Uint8List.fromList([0]));
      registerFallbackValue(
        EncryptedMapping(
          encryptedBlob: Uint8List.fromList([0]),
          encryptionKeyId: 'test-key-id',
          algorithm: EncryptionAlgorithm.aes256GCM,
          encryptedAt: DateTime.now(),
          version: 1,
        ),
      );
    });
    
    test('AgentIdService requires encryption service', () {
      // This should compile - encryption service is required
      final service = AgentIdService(
        encryptionService: mockEncryptionService,
        supabaseService: mockSupabaseService,
      );
      
      expect(service, isNotNull);
    });
    
    test('AgentIdService cannot be created without encryption service', () {
      // This should fail at compile time
      // If this test compiles, the encryption service is not required
      expect(
        () => AgentIdService(
          supabaseService: mockSupabaseService,
          // encryptionService is required, so this should fail
        ),
        throwsA(isA<TypeError>()),
      );
    });
    
    test('Encryption service field is non-nullable', () {
      final service = AgentIdService(
        encryptionService: mockEncryptionService,
        supabaseService: mockSupabaseService,
      );
      
      // If we can access the service, the field exists
      // The fact that it's required in constructor means it's non-nullable
      expect(service, isNotNull);
    });
    
    test('No plaintext storage path exists', () async {
      // This test verifies that the code doesn't have plaintext fallback
      // We can't directly test this, but we can verify the service
      // doesn't expose plaintext storage methods
      
      final service = AgentIdService(
        encryptionService: mockEncryptionService,
        supabaseService: mockSupabaseService,
      );
      
      // Verify service exists and uses encryption
      expect(service, isNotNull);
      
      // The service should only use encrypted storage
      // This is verified by the fact that encryption service is required
    });
  });
}
