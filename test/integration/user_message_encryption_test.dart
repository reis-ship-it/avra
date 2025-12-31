// Simple test to verify user-to-user message encryption works end-to-end
// Tests the complete flow: User A sends encrypted message to User B

import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/services/message_encryption_service.dart';
import 'package:spots/core/services/hybrid_encryption_service.dart';
import 'package:spots/core/services/signal_protocol_encryption_service.dart';
import 'package:spots/core/services/agent_id_service.dart';
import 'package:spots/core/services/supabase_service.dart';
import 'package:spots/core/crypto/signal/signal_protocol_service.dart';
import 'package:spots/core/crypto/signal/signal_ffi_bindings.dart';
import 'package:spots/core/crypto/signal/signal_key_manager.dart';
import 'package:spots/core/crypto/signal/signal_session_manager.dart';
import 'package:spots/core/crypto/signal/signal_ffi_store_callbacks.dart';
import 'package:spots/core/crypto/signal/signal_platform_bridge_bindings.dart';
import 'package:spots/core/crypto/signal/signal_rust_wrapper_bindings.dart';
import 'package:sembast/sembast_memory.dart';
import '../mocks/in_memory_flutter_secure_storage.dart';
import 'dart:io';
import 'dart:developer' as developer;

void main() {
  group('User-to-User Message Encryption', () {
    late InMemoryFlutterSecureStorage aliceStorage;
    late InMemoryFlutterSecureStorage bobStorage;
    late AgentIdService agentIdService;
    late SupabaseService supabaseService;
    
    // Mock user IDs
    const aliceUserId = 'alice-user-123';
    const bobUserId = 'bob-user-456';
    
    // Agent IDs (will be resolved)
    String? aliceAgentId;
    String? bobAgentId;
    
    // Signal Protocol services for Alice
    late SignalFFIBindings aliceFFI;
    late SignalPlatformBridgeBindings alicePlatformBridge;
    late SignalRustWrapperBindings aliceRustWrapper;
    late SignalKeyManager aliceKeyManager;
    late SignalSessionManager aliceSessionManager;
    late SignalFFIStoreCallbacks aliceStoreCallbacks;
    late SignalProtocolService aliceProtocol;
    late SignalProtocolEncryptionService aliceEncryptionService;
    
    // Signal Protocol services for Bob
    late SignalFFIBindings bobFFI;
    late SignalPlatformBridgeBindings bobPlatformBridge;
    late SignalRustWrapperBindings bobRustWrapper;
    late SignalKeyManager bobKeyManager;
    late SignalSessionManager bobSessionManager;
    late SignalFFIStoreCallbacks bobStoreCallbacks;
    late SignalProtocolService bobProtocol;
    late SignalProtocolEncryptionService bobEncryptionService;
    
    // Encryption services
    late MessageEncryptionService aliceMessageEncryption;
    late MessageEncryptionService bobMessageEncryption;
    
    bool librariesAvailable = false;
    
    setUpAll(() async {
      // Check if native libraries are available
      try {
        final currentDir = Directory.current.path;
        final libPath = '$currentDir/native/signal_ffi/macos/libsignal_ffi.dylib';
        final libFile = File(libPath);
        librariesAvailable = libFile.existsSync();
        
        if (!librariesAvailable) {
          developer.log('⚠️ Native libraries not found, skipping Signal Protocol tests');
        }
      } catch (e) {
        developer.log('⚠️ Error checking for native libraries: $e');
        librariesAvailable = false;
      }
    });
    
    setUp(() async {
      if (!librariesAvailable) {
        return; // Skip setup if libraries not available
      }
      
      // Initialize storage
      aliceStorage = InMemoryFlutterSecureStorage();
      bobStorage = InMemoryFlutterSecureStorage();
      
      // Initialize services
      agentIdService = AgentIdService();
      supabaseService = SupabaseService();
      
      // Resolve agent IDs
      aliceAgentId = await agentIdService.getUserAgentId(aliceUserId);
      bobAgentId = await agentIdService.getUserAgentId(bobUserId);
      
      developer.log('✅ Alice agent ID: $aliceAgentId');
      developer.log('✅ Bob agent ID: $bobAgentId');
      
      // Initialize Alice's Signal Protocol services
      aliceFFI = SignalFFIBindings();
      await aliceFFI.initialize();
      
      alicePlatformBridge = SignalPlatformBridgeBindings();
      await alicePlatformBridge.initialize();
      
      aliceRustWrapper = SignalRustWrapperBindings();
      await aliceRustWrapper.initialize();
      
      aliceKeyManager = SignalKeyManager(
        secureStorage: aliceStorage,
        ffiBindings: aliceFFI,
        supabaseService: supabaseService,
      );
      
      final aliceDatabase = await databaseFactoryMemory.openDatabase('alice_sessions.db');
      aliceSessionManager = SignalSessionManager(
        database: aliceDatabase,
        ffiBindings: aliceFFI,
        keyManager: aliceKeyManager,
      );
      
      aliceStoreCallbacks = SignalFFIStoreCallbacks(
        keyManager: aliceKeyManager,
        sessionManager: aliceSessionManager,
        ffiBindings: aliceFFI,
        rustWrapper: aliceRustWrapper,
        platformBridge: alicePlatformBridge,
      );
      
      aliceProtocol = SignalProtocolService(
        ffiBindings: aliceFFI,
        storeCallbacks: aliceStoreCallbacks,
        keyManager: aliceKeyManager,
        sessionManager: aliceSessionManager,
      );
      
      await aliceProtocol.initialize();
      
      // Generate and upload Alice's prekey bundle
      final alicePreKeyBundle = await aliceKeyManager.generatePreKeyBundle();
      await aliceKeyManager.uploadPreKeyBundle(
        agentId: aliceAgentId!,
        preKeyBundle: alicePreKeyBundle,
      );
      
      aliceEncryptionService = SignalProtocolEncryptionService(
        signalProtocol: aliceProtocol,
        agentIdService: agentIdService,
        supabaseService: supabaseService,
      );
      
      // Initialize Bob's Signal Protocol services
      bobFFI = SignalFFIBindings();
      await bobFFI.initialize();
      
      bobPlatformBridge = SignalPlatformBridgeBindings();
      await bobPlatformBridge.initialize();
      
      bobRustWrapper = SignalRustWrapperBindings();
      await bobRustWrapper.initialize();
      
      bobKeyManager = SignalKeyManager(
        secureStorage: bobStorage,
        ffiBindings: bobFFI,
        supabaseService: supabaseService,
      );
      
      final bobDatabase = await databaseFactoryMemory.openDatabase('bob_sessions.db');
      bobSessionManager = SignalSessionManager(
        database: bobDatabase,
        ffiBindings: bobFFI,
        keyManager: bobKeyManager,
      );
      
      bobStoreCallbacks = SignalFFIStoreCallbacks(
        keyManager: bobKeyManager,
        sessionManager: bobSessionManager,
        ffiBindings: bobFFI,
        rustWrapper: bobRustWrapper,
        platformBridge: bobPlatformBridge,
      );
      
      bobProtocol = SignalProtocolService(
        ffiBindings: bobFFI,
        storeCallbacks: bobStoreCallbacks,
        keyManager: bobKeyManager,
        sessionManager: bobSessionManager,
      );
      
      await bobProtocol.initialize();
      
      // Generate and upload Bob's prekey bundle
      final bobPreKeyBundle = await bobKeyManager.generatePreKeyBundle();
      await bobKeyManager.uploadPreKeyBundle(
        agentId: bobAgentId!,
        preKeyBundle: bobPreKeyBundle,
      );
      
      bobEncryptionService = SignalProtocolEncryptionService(
        signalProtocol: bobProtocol,
        agentIdService: agentIdService,
        supabaseService: supabaseService,
      );
      
      // Create hybrid encryption services
      aliceMessageEncryption = HybridEncryptionService(
        signalProtocolService: aliceEncryptionService,
      );
      
      bobMessageEncryption = HybridEncryptionService(
        signalProtocolService: bobEncryptionService,
      );
      
      developer.log('✅ Test setup complete');
    });
    
    tearDown(() async {
      // Note: We don't call dispose() to avoid SIGABRT crashes during test finalization
      // This is expected behavior - see PHASE_14_SIGABRT_FINAL_ANALYSIS.md
    });
    
    test('Alice should encrypt message for Bob, Bob should decrypt it', () async {
      if (!librariesAvailable) {
        // ignore: avoid_print
        print('⚠️ Skipping test - native libraries not available');
        return;
      }
      
      // Original message
      const originalMessage = 'Hello Bob! This is a test message from Alice.';
      
      developer.log('📝 Original message: $originalMessage');
      
      // Step 1: Alice encrypts message for Bob
      developer.log('🔐 Step 1: Alice encrypting message for Bob...');
      final encrypted = await aliceMessageEncryption.encrypt(
        originalMessage,
        bobAgentId!,
      );
      
      expect(encrypted, isNotNull);
      expect(encrypted.encryptedContent, isNotEmpty);
      expect(encrypted.encryptionType, isNotNull);
      
      developer.log('✅ Message encrypted');
      developer.log('   Encryption type: ${encrypted.encryptionType}');
      developer.log('   Encrypted length: ${encrypted.encryptedContent.length} bytes');
      
      // Step 2: Bob decrypts message from Alice
      developer.log('🔓 Step 2: Bob decrypting message from Alice...');
      final decrypted = await bobMessageEncryption.decrypt(
        encrypted,
        aliceAgentId!,
      );
      
      expect(decrypted, isNotNull);
      expect(decrypted, equals(originalMessage));
      
      developer.log('✅ Message decrypted successfully');
      developer.log('   Decrypted message: $decrypted');
      
      // Verify round-trip
      expect(decrypted, equals(originalMessage), 
        reason: 'Decrypted message should match original');
      
      developer.log('✅ Round-trip encryption/decryption successful!');
    });
    
    test('Multiple messages should work correctly', () async {
      if (!librariesAvailable) {
        // ignore: avoid_print
        print('⚠️ Skipping test - native libraries not available');
        return;
      }
      
      final messages = [
        'First message',
        'Second message',
        'Third message with special chars: !@#\$%^&*()',
      ];
      
      for (final message in messages) {
        developer.log('📝 Testing message: $message');
        
        // Alice encrypts
        final encrypted = await aliceMessageEncryption.encrypt(
          message,
          bobAgentId!,
        );
        
        expect(encrypted, isNotNull);
        
        // Bob decrypts
        final decrypted = await bobMessageEncryption.decrypt(
          encrypted,
          aliceAgentId!,
        );
        
        expect(decrypted, equals(message),
          reason: 'Message "$message" should decrypt correctly');
        
        developer.log('✅ Message "$message" encrypted and decrypted successfully');
      }
      
      developer.log('✅ All multiple messages encrypted/decrypted successfully!');
    });
  });
}
