// Signal Protocol X3DH, Encryption, and Decryption Test
// Phase 14: Signal Protocol Implementation - Option 1
//
// Tests the complete flow:
// 1. Identity key generation (Alice and Bob)
// 2. Prekey bundle generation (Bob)
// 3. X3DH key exchange (Alice establishes session with Bob)
// 4. Message encryption (Alice encrypts message for Bob)
// 5. Message decryption (Bob decrypts message from Alice)

import 'dart:io';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spots/core/crypto/signal/signal_platform_bridge_bindings.dart';
import 'package:spots/core/crypto/signal/signal_rust_wrapper_bindings.dart';
import 'package:spots/core/crypto/signal/signal_ffi_store_callbacks.dart';
import 'package:spots/core/crypto/signal/signal_ffi_bindings.dart';
import 'package:spots/core/crypto/signal/signal_key_manager.dart';
import 'package:spots/core/crypto/signal/signal_session_manager.dart';
import 'package:spots/core/crypto/signal/signal_types.dart';
import 'package:spots/core/services/signal_protocol_initialization_service.dart';
import 'package:spots/core/crypto/signal/signal_protocol_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sembast/sembast_memory.dart';

/// Mock FlutterSecureStorage for testing
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

/// Find project root by walking up from the test file to find pubspec.yaml
String? _findProjectRoot() {
  try {
    final testFile = Platform.script.toFilePath();
    var current = Directory(testFile).parent;
    
    // Walk up to find pubspec.yaml (project root)
    while (current.path != current.parent.path) {
      final pubspec = File('${current.path}/pubspec.yaml');
      if (pubspec.existsSync()) {
        return current.path;
      }
      current = current.parent;
    }
  } catch (e) {
    // If we can't determine project root, return null
  }
  return null;
}

void main() {
  group('Signal Protocol X3DH, Encryption, and Decryption', () {
    late Database database;
    late SignalFFIBindings aliceFFI;
    late SignalFFIBindings bobFFI;
    late SignalPlatformBridgeBindings alicePlatformBridge;
    late SignalPlatformBridgeBindings bobPlatformBridge;
    late SignalRustWrapperBindings aliceRustWrapper;
    late SignalRustWrapperBindings bobRustWrapper;
    late SignalKeyManager aliceKeyManager;
    late SignalKeyManager bobKeyManager;
    late SignalSessionManager aliceSessionManager;
    late SignalSessionManager bobSessionManager;
    late SignalFFIStoreCallbacks aliceStoreCallbacks;
    late SignalFFIStoreCallbacks bobStoreCallbacks;
    late SignalProtocolService aliceProtocol;
    late SignalProtocolService bobProtocol;
    late SignalProtocolInitializationService aliceInitService;
    late SignalProtocolInitializationService bobInitService;
    late MockFlutterSecureStorage mockSecureStorage;
    bool librariesAvailable = false;

    setUpAll(() async {
      database = await databaseFactoryMemory.openDatabase('test.db');
      
      // Check if native libraries are available
      if (Platform.isMacOS) {
        // Try multiple path resolution strategies
        // Flutter tests may run from different working directories
        final pathsToTry = [
          // Strategy 1: Relative to current directory
          'native/signal_ffi/macos/libsignal_ffi.dylib',
          // Strategy 2: Absolute from current directory
          '${Directory.current.path}/native/signal_ffi/macos/libsignal_ffi.dylib',
          // Strategy 3: From test file location (walk up to project root)
          _findProjectRoot() != null
              ? '${_findProjectRoot()}/native/signal_ffi/macos/libsignal_ffi.dylib'
              : null,
        ].whereType<String>().toList();
        
        librariesAvailable = false;
        String? foundPath;
        
        for (final libPath in pathsToTry) {
          final libFile = File(libPath);
          if (libFile.existsSync()) {
            librariesAvailable = true;
            foundPath = libPath;
            developer.log(
              '✅ Native libraries found at: $libPath',
              name: 'SignalProtocolTest',
            );
            break;
          }
        }
        
        if (!librariesAvailable) {
          developer.log(
            '⚠️ Native libraries not found. Tried paths: $pathsToTry',
            name: 'SignalProtocolTest',
          );
          developer.log(
            'Current directory: ${Directory.current.path}',
            name: 'SignalProtocolTest',
          );
          developer.log(
            'Test script: ${Platform.script.toFilePath()}',
            name: 'SignalProtocolTest',
          );
        }
      } else {
        librariesAvailable = false;
      }
    });

    tearDownAll(() async {
      await database.close();
    });

    setUp(() {
      // Set up mock FlutterSecureStorage to avoid MissingPluginException
      mockSecureStorage = MockFlutterSecureStorage();
      
      // In-memory storage to track keys
      final Map<String, String> aliceKeyStorage = {};
      final Map<String, String> bobKeyStorage = {};
      
      // Set up read to return stored value or null
      when(() => mockSecureStorage.read(key: any(named: 'key')))
          .thenAnswer((invocation) async {
        final key = invocation.namedArguments[#key] as String;
        // Use different storage for Alice and Bob based on key prefix
        if (key.startsWith('alice_')) {
          return aliceKeyStorage[key];
        } else if (key.startsWith('bob_')) {
          return bobKeyStorage[key];
        }
        return null;
      });
      
      // Set up write to store value
      when(() => mockSecureStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'))).thenAnswer((invocation) async {
        final key = invocation.namedArguments[#key] as String;
        final value = invocation.namedArguments[#value] as String;
        if (key.startsWith('alice_')) {
          aliceKeyStorage[key] = value;
        } else if (key.startsWith('bob_')) {
          bobKeyStorage[key] = value;
        }
      });
      
      // Set up delete to remove key
      when(() => mockSecureStorage.delete(key: any(named: 'key')))
          .thenAnswer((invocation) async {
        final key = invocation.namedArguments[#key] as String;
        if (key.startsWith('alice_')) {
          aliceKeyStorage.remove(key);
        } else if (key.startsWith('bob_')) {
          bobKeyStorage.remove(key);
        }
      });
      
      // Initialize Alice's components
      aliceFFI = SignalFFIBindings();
      alicePlatformBridge = SignalPlatformBridgeBindings();
      aliceRustWrapper = SignalRustWrapperBindings();
      
      aliceKeyManager = SignalKeyManager(
        secureStorage: mockSecureStorage,
        ffiBindings: aliceFFI,
      );
      
      aliceSessionManager = SignalSessionManager(
        database: database,
        ffiBindings: aliceFFI,
        keyManager: aliceKeyManager,
      );
      
      aliceStoreCallbacks = SignalFFIStoreCallbacks(
        ffiBindings: aliceFFI,
        rustWrapper: aliceRustWrapper,
        platformBridge: alicePlatformBridge,
        sessionManager: aliceSessionManager,
        keyManager: aliceKeyManager,
      );
      
      aliceProtocol = SignalProtocolService(
        ffiBindings: aliceFFI,
        storeCallbacks: aliceStoreCallbacks,
        keyManager: aliceKeyManager,
        sessionManager: aliceSessionManager,
      );
      
      aliceInitService = SignalProtocolInitializationService(
        platformBridge: alicePlatformBridge,
        rustWrapper: aliceRustWrapper,
        storeCallbacks: aliceStoreCallbacks,
        signalProtocol: aliceProtocol,
      );
      
      // Initialize Bob's components
      bobFFI = SignalFFIBindings();
      bobPlatformBridge = SignalPlatformBridgeBindings();
      bobRustWrapper = SignalRustWrapperBindings();
      
      bobKeyManager = SignalKeyManager(
        secureStorage: mockSecureStorage,
        ffiBindings: bobFFI,
      );
      
      bobSessionManager = SignalSessionManager(
        database: database,
        ffiBindings: bobFFI,
        keyManager: bobKeyManager,
      );
      
      bobStoreCallbacks = SignalFFIStoreCallbacks(
        ffiBindings: bobFFI,
        rustWrapper: bobRustWrapper,
        platformBridge: bobPlatformBridge,
        sessionManager: bobSessionManager,
        keyManager: bobKeyManager,
      );
      
      bobProtocol = SignalProtocolService(
        ffiBindings: bobFFI,
        storeCallbacks: bobStoreCallbacks,
        keyManager: bobKeyManager,
        sessionManager: bobSessionManager,
      );
      
      bobInitService = SignalProtocolInitializationService(
        platformBridge: bobPlatformBridge,
        rustWrapper: bobRustWrapper,
        storeCallbacks: bobStoreCallbacks,
        signalProtocol: bobProtocol,
      );
    });

    tearDown(() {
      // Clean up with defensive try-catch to prevent SIGABRT crashes
      try {
        aliceStoreCallbacks.dispose();
      } catch (e) {
        // Ignore cleanup errors
      }
      try {
        bobStoreCallbacks.dispose();
      } catch (e) {
        // Ignore cleanup errors
      }
      try {
        aliceFFI.dispose();
      } catch (e) {
        // Ignore cleanup errors
      }
      try {
        bobFFI.dispose();
      } catch (e) {
        // Ignore cleanup errors
      }
    });

    test('should initialize Alice and Bob Signal Protocol services', () async {
      if (!librariesAvailable) {
        return; // Skip if libraries not available
      }
      
      // Initialize Alice
      await aliceInitService.initialize();
      expect(aliceProtocol.isInitialized, isTrue);
      
      // Initialize Bob
      await bobInitService.initialize();
      expect(bobProtocol.isInitialized, isTrue);
    });

    test('should generate identity keys for Alice and Bob', () async {
      if (!librariesAvailable) {
        return; // Skip if libraries not available
      }
      
      // Initialize Alice
      await aliceInitService.initialize();
      
      // Initialize Bob
      await bobInitService.initialize();
      
      // Generate identity keys
      final aliceIdentityKey = await aliceKeyManager.getOrGenerateIdentityKeyPair();
      final bobIdentityKey = await bobKeyManager.getOrGenerateIdentityKeyPair();
      
      expect(aliceIdentityKey.publicKey, isNotEmpty);
      expect(aliceIdentityKey.privateKey, isNotEmpty);
      expect(bobIdentityKey.publicKey, isNotEmpty);
      expect(bobIdentityKey.privateKey, isNotEmpty);
      
      // Keys should be different
      expect(aliceIdentityKey.publicKey, isNot(equals(bobIdentityKey.publicKey)));
    });

    test('should perform X3DH key exchange and encrypt/decrypt message', () async {
      if (!librariesAvailable) {
        return; // Skip if libraries not available
      }
      
      // Initialize Alice and Bob
      await aliceInitService.initialize();
      await bobInitService.initialize();
      
      // Generate identity keys
      final aliceIdentityKey = await aliceKeyManager.getOrGenerateIdentityKeyPair();
      final bobIdentityKey = await bobKeyManager.getOrGenerateIdentityKeyPair();
      
      // Generate Bob's prekey bundle
      final bobPreKeyBundle = await bobFFI.generatePreKeyBundle(
        identityKeyPair: bobIdentityKey,
        registrationId: 1,
        deviceId: 1,
      );
      
      // Set Bob's prekey bundle in Alice's key manager (simulating key server)
      aliceKeyManager.setTestPreKeyBundle('bob', bobPreKeyBundle);
      
      // Alice encrypts a message for Bob (X3DH will happen automatically)
      final plaintext = Uint8List.fromList([72, 101, 108, 108, 111]); // "Hello"
      final encrypted = await aliceProtocol.encryptMessage(
        plaintext: plaintext,
        recipientId: 'bob',
      );
      
      expect(encrypted.ciphertext, isNotEmpty);
      expect(encrypted.messageType, equals(2)); // SignalCiphertextMessageTypeWhisper
      
      // Bob decrypts the message from Alice
      final decrypted = await bobProtocol.decryptMessage(
        encrypted: SignalEncryptedMessage.fromBytes(encrypted.toBytes()),
        senderId: 'alice',
      );
      
      expect(decrypted, equals(plaintext));
      expect(decrypted, equals([72, 101, 108, 108, 111]));
    });

    test('should generate prekey bundle', () async {
      if (!librariesAvailable) {
        return; // Skip if libraries not available
      }
      
      // Initialize Bob
      await bobInitService.initialize();
      
      // Generate identity key
      final bobIdentityKey = await bobKeyManager.getOrGenerateIdentityKeyPair();
      
      // Generate prekey bundle
      final preKeyBundle = await bobFFI.generatePreKeyBundle(
        identityKeyPair: bobIdentityKey,
        registrationId: 1,
        deviceId: 1,
      );
      
      // Verify bundle has all required fields
      expect(preKeyBundle.identityKey, isNotEmpty);
      expect(preKeyBundle.signedPreKey, isNotEmpty);
      expect(preKeyBundle.signature, isNotEmpty);
      expect(preKeyBundle.signedPreKeyId, isNotNull);
      expect(preKeyBundle.kyberPreKey, isNotNull);
      expect(preKeyBundle.kyberPreKeyId, isNotNull);
      expect(preKeyBundle.kyberPreKeySignature, isNotNull);
      expect(preKeyBundle.registrationId, equals(1));
      expect(preKeyBundle.deviceId, equals(1));
    });

    test('should handle decryption errors gracefully', () async {
      if (!librariesAvailable) {
        return; // Skip if libraries not available
      }
      
      // Initialize Bob
      await bobInitService.initialize();
      await bobKeyManager.getOrGenerateIdentityKeyPair();
      
      // Create a fake encrypted message
      final fakeEncrypted = SignalEncryptedMessage(
        ciphertext: Uint8List.fromList([1, 2, 3, 4, 5]),
        messageType: 2, // SignalCiphertextMessageTypeWhisper
      );
      
      // Try to decrypt (will fail without session or invalid message)
      try {
        await bobFFI.decryptMessage(
          encrypted: fakeEncrypted,
          senderId: 'alice',
          storeCallbacks: bobStoreCallbacks,
        );
        fail('Decryption should fail with invalid message');
      } on SignalProtocolException catch (e) {
        // Expected - decryption should fail
        expect(e.toString(), isNotEmpty);
      } catch (e) {
        // Other errors are also acceptable
        expect(e, isA<Exception>());
      }
    });
  });
}
