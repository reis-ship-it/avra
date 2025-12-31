// Signal Protocol FFI Bindings for Phase 14: Signal Protocol Implementation
// Option 1: libsignal-ffi via FFI
// 
// This file provides Dart bindings to libsignal-ffi (Rust library)
// 
// NOTE: This is a framework implementation. Actual FFI bindings will be created
// once libsignal-ffi is integrated into the build system.
//
// Architecture:
//   Dart Code → FFI Bindings → libsignal-ffi (Rust) → Signal Protocol

import 'dart:developer' as developer;
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart'; // Required for memory management (malloc, free)
import 'package:spots/core/crypto/signal/signal_types.dart';
import 'package:spots/core/crypto/signal/signal_ffi_store_callbacks.dart';
import 'package:spots/core/crypto/signal/signal_library_manager.dart';

// ============================================================================
// FFI TYPE DEFINITIONS
// ============================================================================

/// C struct: SignalMutPointerPrivateKey
/// Contains a pointer to SignalPrivateKey
final class SignalMutPointerPrivateKey extends Struct {
  external Pointer<Opaque> raw; // SignalPrivateKey* (opaque)
}

/// C struct: SignalMutPointerPublicKey
/// Contains a pointer to SignalPublicKey
final class SignalMutPointerPublicKey extends Struct {
  external Pointer<Opaque> raw; // SignalPublicKey* (opaque)
}

/// C struct: SignalConstPointerPrivateKey
/// Contains a const pointer to SignalPrivateKey
final class SignalConstPointerPrivateKey extends Struct {
  external Pointer<Opaque> raw; // const SignalPrivateKey* (opaque)
}

/// C struct: SignalConstPointerPublicKey
/// Contains a const pointer to SignalPublicKey
final class SignalConstPointerPublicKey extends Struct {
  external Pointer<Opaque> raw; // const SignalPublicKey* (opaque)
}

/// C struct: SignalOwnedBuffer
/// Buffer allocated on Rust heap
final class SignalOwnedBuffer extends Struct {
  external Pointer<Uint8> base; // unsigned char*
  @Size()
  external int length; // size_t
}

/// C struct: SignalBorrowedBuffer
/// Buffer borrowed from caller (not owned by Rust)
final class SignalBorrowedBuffer extends Struct {
  external Pointer<Uint8> base; // const unsigned char*
  @Size()
  external int length; // size_t
}

/// C struct: SignalMutPointerPreKeyBundle
/// Contains a pointer to SignalPreKeyBundle
final class SignalMutPointerPreKeyBundle extends Struct {
  external Pointer<Opaque> raw; // SignalPreKeyBundle* (opaque)
}

/// C struct: SignalConstPointerPreKeyBundle
/// Contains a const pointer to SignalPreKeyBundle
final class SignalConstPointerPreKeyBundle extends Struct {
  external Pointer<Opaque> raw; // const SignalPreKeyBundle* (opaque)
}

/// C struct: SignalMutPointerKyberPublicKey
/// Contains a pointer to SignalKyberPublicKey (which is SignalPublicKey)
final class SignalMutPointerKyberPublicKey extends Struct {
  external Pointer<Opaque> raw; // SignalKyberPublicKey* (opaque, same as SignalPublicKey)
}

/// C struct: SignalConstPointerKyberPublicKey
/// Contains a const pointer to SignalKyberPublicKey
final class SignalConstPointerKyberPublicKey extends Struct {
  external Pointer<Opaque> raw; // const SignalKyberPublicKey* (opaque, same as SignalPublicKey)
}

/// C struct: SignalFfiError (opaque)
/// Error type returned by libsignal-ffi functions
final class SignalFfiError extends Opaque {}

// ============================================================================
// FFI TYPE DEFINITIONS - Store Callbacks (needed for wrapper functions)
// ============================================================================

/// C struct: SignalMutPointerSessionRecord
final class _SignalMutPointerSessionRecord extends Struct {
  external Pointer<Opaque> raw;
}

/// C struct: SignalConstPointerSessionRecord
final class _SignalConstPointerSessionRecord extends Struct {
  external Pointer<Opaque> raw;
}

/// C struct: SignalConstPointerProtocolAddress
final class _SignalConstPointerProtocolAddress extends Struct {
  external Pointer<Opaque> raw;
}

/// C struct: SignalMutPointerProtocolAddress
/// Contains a pointer to SignalProtocolAddress
final class _SignalMutPointerProtocolAddress extends Struct {
  external Pointer<Opaque> raw; // SignalProtocolAddress* (opaque)
}

/// C struct: SignalConstPointerFfiSessionStoreStruct
/// Wrapper for const pointer to SignalFfiSessionStoreStruct
final class _SignalConstPointerFfiSessionStoreStruct extends Struct {
  external Pointer<Void> raw; // const SignalFfiSessionStoreStruct*
}

/// C struct: SignalConstPointerFfiIdentityKeyStoreStruct
/// Wrapper for const pointer to SignalFfiIdentityKeyStoreStruct
final class _SignalConstPointerFfiIdentityKeyStoreStruct extends Struct {
  external Pointer<Void> raw; // const SignalFfiIdentityKeyStoreStruct*
}

// ============================================================================
// FFI FUNCTION TYPEDEFS - Wrapper Functions (for store callbacks)
// ============================================================================
// These are defined at top level so they can be used as type arguments

// Wrapper functions (called by libsignal-ffi)
// These match libsignal-ffi's expected callback signatures exactly
typedef _NativeLoadSessionWrapper = IntPtr Function(Pointer<Void>, Pointer<_SignalMutPointerSessionRecord>, Pointer<_SignalConstPointerProtocolAddress>);
typedef _NativeStoreSessionWrapper = IntPtr Function(Pointer<Void>, Pointer<_SignalConstPointerProtocolAddress>, Pointer<_SignalConstPointerSessionRecord>);
typedef _NativeGetIdentityKeyPairWrapper = IntPtr Function(Pointer<Void>, Pointer<SignalMutPointerPrivateKey>);
typedef _NativeGetLocalRegistrationIdWrapper = IntPtr Function(Pointer<Void>, Pointer<Uint32>);
typedef _NativeSaveIdentityKeyWrapper = IntPtr Function(Pointer<Void>, Pointer<_SignalConstPointerProtocolAddress>, Pointer<SignalConstPointerPublicKey>);
typedef _NativeGetIdentityKeyWrapper = IntPtr Function(Pointer<Void>, Pointer<SignalMutPointerPublicKey>, Pointer<_SignalConstPointerProtocolAddress>);
typedef _NativeIsTrustedIdentityWrapper = IntPtr Function(Pointer<Void>, Pointer<_SignalConstPointerProtocolAddress>, Pointer<SignalConstPointerPublicKey>, Uint32);

// Simplified callback signatures (all pointers as int) for Dart callback registration
// Using int for pointer addresses - NativeCallable requires int, not IntPtr
// On 64-bit platforms, int is 64-bit, same as IntPtr
typedef _SimpleCallback3 = int Function(int, int, int);
typedef _SimpleCallback2 = int Function(int, int);
typedef _SimpleCallback4 = int Function(int, int, int, int);

// ============================================================================
// FFI FUNCTION TYPEDEFS - Identity Key Generation
// ============================================================================

// signal_privatekey_generate(SignalMutPointerPrivateKey *out) -> SignalFfiError*
typedef _NativePrivateKeyGenerate = Pointer<SignalFfiError> Function(
  Pointer<SignalMutPointerPrivateKey>,
);
typedef _PrivateKeyGenerate = Pointer<SignalFfiError> Function(
  Pointer<SignalMutPointerPrivateKey>,
);

// signal_privatekey_get_public_key(SignalMutPointerPublicKey *out, SignalConstPointerPrivateKey k) -> SignalFfiError*
typedef _NativePrivateKeyGetPublicKey = Pointer<SignalFfiError> Function(
  Pointer<SignalMutPointerPublicKey>,
  Pointer<SignalConstPointerPrivateKey>,
);
typedef _PrivateKeyGetPublicKey = Pointer<SignalFfiError> Function(
  Pointer<SignalMutPointerPublicKey>,
  Pointer<SignalConstPointerPrivateKey>,
);

// signal_privatekey_deserialize(SignalMutPointerPrivateKey *out, SignalBorrowedBuffer data) -> SignalFfiError*
typedef _NativePrivateKeyDeserialize = Pointer<SignalFfiError> Function(
  Pointer<SignalMutPointerPrivateKey>,
  SignalBorrowedBuffer,
);
typedef _PrivateKeyDeserialize = Pointer<SignalFfiError> Function(
  Pointer<SignalMutPointerPrivateKey>,
  SignalBorrowedBuffer,
);

// signal_privatekey_serialize(SignalOwnedBuffer *out, SignalConstPointerPrivateKey obj) -> SignalFfiError*
typedef _NativePrivateKeySerialize = Pointer<SignalFfiError> Function(
  Pointer<SignalOwnedBuffer>,
  Pointer<SignalConstPointerPrivateKey>,
);
typedef _PrivateKeySerialize = Pointer<SignalFfiError> Function(
  Pointer<SignalOwnedBuffer>,
  Pointer<SignalConstPointerPrivateKey>,
);

// signal_privatekey_destroy(SignalMutPointerPrivateKey p) -> SignalFfiError*
typedef _NativePrivateKeyDestroy = Pointer<SignalFfiError> Function(
  Pointer<SignalMutPointerPrivateKey>,
);
typedef _PrivateKeyDestroy = Pointer<SignalFfiError> Function(
  Pointer<SignalMutPointerPrivateKey>,
);

// signal_publickey_serialize(SignalOwnedBuffer *out, SignalConstPointerPublicKey obj) -> SignalFfiError*
typedef _NativePublicKeySerialize = Pointer<SignalFfiError> Function(
  Pointer<SignalOwnedBuffer>,
  Pointer<SignalConstPointerPublicKey>,
);
typedef _PublicKeySerialize = Pointer<SignalFfiError> Function(
  Pointer<SignalOwnedBuffer>,
  Pointer<SignalConstPointerPublicKey>,
);

// signal_publickey_destroy(SignalMutPointerPublicKey p) -> SignalFfiError*
typedef _NativePublicKeyDestroy = Pointer<SignalFfiError> Function(
  Pointer<SignalMutPointerPublicKey>,
);
typedef _PublicKeyDestroy = Pointer<SignalFfiError> Function(
  Pointer<SignalMutPointerPublicKey>,
);

// signal_error_get_message(const char **out, SignalUnwindSafeArgSignalFfiError err) -> SignalFfiError*
typedef _NativeErrorGetMessage = Pointer<SignalFfiError> Function(
  Pointer<Pointer<Utf8>>,
  Pointer<SignalFfiError>,
);
typedef _ErrorGetMessage = Pointer<SignalFfiError> Function(
  Pointer<Pointer<Utf8>>,
  Pointer<SignalFfiError>,
);

// signal_error_free(SignalFfiError *err) -> void
typedef _NativeErrorFree = Void Function(
  Pointer<SignalFfiError>,
);
typedef _ErrorFree = void Function(
  Pointer<SignalFfiError>,
);

// ============================================================================
// FFI FUNCTION TYPEDEFS - Prekey Bundle Creation
// ============================================================================

// signal_pre_key_bundle_new(SignalMutPointerPreKeyBundle *out, uint32_t registration_id, uint32_t device_id, uint32_t prekey_id, SignalConstPointerPublicKey prekey, uint32_t signed_prekey_id, SignalConstPointerPublicKey signed_prekey, SignalBorrowedBuffer signed_prekey_signature, SignalConstPointerPublicKey identity_key, uint32_t kyber_prekey_id, SignalConstPointerKyberPublicKey kyber_prekey, SignalBorrowedBuffer kyber_prekey_signature) -> SignalFfiError*
typedef _NativePreKeyBundleNew = Pointer<SignalFfiError> Function(
  Pointer<SignalMutPointerPreKeyBundle>,
  Uint32 registrationId,
  Uint32 deviceId,
  Uint32 prekeyId,
  Pointer<SignalConstPointerPublicKey> prekey,
  Uint32 signedPrekeyId,
  Pointer<SignalConstPointerPublicKey> signedPrekey,
  SignalBorrowedBuffer signedPrekeySignature,
  Pointer<SignalConstPointerPublicKey> identityKey,
  Uint32 kyberPrekeyId,
  Pointer<SignalConstPointerKyberPublicKey> kyberPrekey,
  SignalBorrowedBuffer kyberPrekeySignature,
);
typedef _PreKeyBundleNew = Pointer<SignalFfiError> Function(
  Pointer<SignalMutPointerPreKeyBundle>,
  int registrationId,
  int deviceId,
  int prekeyId,
  Pointer<SignalConstPointerPublicKey> prekey,
  int signedPrekeyId,
  Pointer<SignalConstPointerPublicKey> signedPrekey,
  SignalBorrowedBuffer signedPrekeySignature,
  Pointer<SignalConstPointerPublicKey> identityKey,
  int kyberPrekeyId,
  Pointer<SignalConstPointerKyberPublicKey> kyberPrekey,
  SignalBorrowedBuffer kyberPrekeySignature,
);

// signal_pre_key_bundle_destroy(SignalMutPointerPreKeyBundle p) -> SignalFfiError*
typedef _NativePreKeyBundleDestroy = Pointer<SignalFfiError> Function(
  Pointer<SignalMutPointerPreKeyBundle>,
);
typedef _PreKeyBundleDestroy = Pointer<SignalFfiError> Function(
  Pointer<SignalMutPointerPreKeyBundle>,
);

// signal_pre_key_bundle_get_identity_key - Not used in current implementation
// typedef _NativePreKeyBundleGetIdentityKey = Pointer<SignalFfiError> Function(...);
// typedef _PreKeyBundleGetIdentityKey = Pointer<SignalFfiError> Function(...);

// ============================================================================
// FFI FUNCTION TYPEDEFS - Key Deserialization
// ============================================================================

// signal_publickey_deserialize(SignalMutPointerPublicKey *out, SignalBorrowedBuffer data) -> SignalFfiError*
typedef _NativePublicKeyDeserialize = Pointer<SignalFfiError> Function(
  Pointer<SignalMutPointerPublicKey>,
  SignalBorrowedBuffer,
);
typedef _PublicKeyDeserialize = Pointer<SignalFfiError> Function(
  Pointer<SignalMutPointerPublicKey>,
  SignalBorrowedBuffer,
);

// signal_kyber_public_key_deserialize(SignalMutPointerKyberPublicKey *out, SignalBorrowedBuffer data) -> SignalFfiError*
typedef _NativeKyberPublicKeyDeserialize = Pointer<SignalFfiError> Function(
  Pointer<SignalMutPointerKyberPublicKey>,
  SignalBorrowedBuffer,
);
typedef _KyberPublicKeyDeserialize = Pointer<SignalFfiError> Function(
  Pointer<SignalMutPointerKyberPublicKey>,
  SignalBorrowedBuffer,
);

// signal_kyber_public_key_serialize(SignalOwnedBuffer *out, SignalConstPointerKyberPublicKey obj) -> SignalFfiError*
typedef _NativeKyberPublicKeySerialize = Pointer<SignalFfiError> Function(
  Pointer<SignalOwnedBuffer>,
  Pointer<SignalConstPointerKyberPublicKey>,
);
typedef _KyberPublicKeySerialize = Pointer<SignalFfiError> Function(
  Pointer<SignalOwnedBuffer>,
  Pointer<SignalConstPointerKyberPublicKey>,
);

// signal_kyber_public_key_destroy(SignalMutPointerKyberPublicKey p) -> SignalFfiError*
typedef _NativeKyberPublicKeyDestroy = Pointer<SignalFfiError> Function(
  Pointer<SignalMutPointerKyberPublicKey>,
);
typedef _KyberPublicKeyDestroy = Pointer<SignalFfiError> Function(
  Pointer<SignalMutPointerKyberPublicKey>,
);

// signal_kyber_key_pair_generate(SignalMutPointerKyberKeyPair *out) -> SignalFfiError*
final class _SignalMutPointerKyberKeyPair extends Struct {
  external Pointer<Opaque> raw;
}
typedef _NativeKyberKeyPairGenerate = Pointer<SignalFfiError> Function(
  Pointer<_SignalMutPointerKyberKeyPair>,
);
typedef _KyberKeyPairGenerate = Pointer<SignalFfiError> Function(
  Pointer<_SignalMutPointerKyberKeyPair>,
);

// signal_kyber_key_pair_get_public_key(SignalMutPointerKyberPublicKey *out, SignalConstPointerKyberKeyPair key_pair) -> SignalFfiError*
final class _SignalConstPointerKyberKeyPair extends Struct {
  external Pointer<Opaque> raw;
}
typedef _NativeKyberKeyPairGetPublicKey = Pointer<SignalFfiError> Function(
  Pointer<SignalMutPointerKyberPublicKey>,
  Pointer<_SignalConstPointerKyberKeyPair>,
);
typedef _KyberKeyPairGetPublicKey = Pointer<SignalFfiError> Function(
  Pointer<SignalMutPointerKyberPublicKey>,
  Pointer<_SignalConstPointerKyberKeyPair>,
);

// signal_kyber_key_pair_destroy(SignalMutPointerKyberKeyPair p) -> SignalFfiError*
typedef _NativeKyberKeyPairDestroy = Pointer<SignalFfiError> Function(
  Pointer<_SignalMutPointerKyberKeyPair>,
);
typedef _KyberKeyPairDestroy = Pointer<SignalFfiError> Function(
  Pointer<_SignalMutPointerKyberKeyPair>,
);

// signal_privatekey_sign(SignalOwnedBuffer *out, SignalConstPointerPrivateKey key, SignalBorrowedBuffer message) -> SignalFfiError*
typedef _NativePrivateKeySign = Pointer<SignalFfiError> Function(
  Pointer<SignalOwnedBuffer>,
  Pointer<SignalConstPointerPrivateKey>,
  SignalBorrowedBuffer,
);
typedef _PrivateKeySign = Pointer<SignalFfiError> Function(
  Pointer<SignalOwnedBuffer>,
  Pointer<SignalConstPointerPrivateKey>,
  SignalBorrowedBuffer,
);

// ============================================================================
// FFI TYPE DEFINITIONS - Message Encryption/Decryption
// ============================================================================

final class _SignalMutPointerCiphertextMessage extends Struct {
  external Pointer<Opaque> raw;
}

final class _SignalConstPointerCiphertextMessage extends Struct {
  external Pointer<Opaque> raw;
}

final class _SignalMutPointerSignalMessage extends Struct {
  external Pointer<Opaque> raw;
}

final class _SignalConstPointerSignalMessage extends Struct {
  external Pointer<Opaque> raw;
}

// ============================================================================
// FFI FUNCTION TYPEDEFS - Message Encryption/Decryption
// ============================================================================

// signal_encrypt_message(SignalMutPointerCiphertextMessage *out, SignalBorrowedBuffer ptext, SignalConstPointerProtocolAddress protocol_address, SignalConstPointerFfiSessionStoreStruct session_store, SignalConstPointerFfiIdentityKeyStoreStruct identity_key_store, uint64_t now) -> SignalFfiError*
typedef _NativeEncryptMessage = Pointer<SignalFfiError> Function(
  Pointer<_SignalMutPointerCiphertextMessage>,
  SignalBorrowedBuffer,
  Pointer<_SignalConstPointerProtocolAddress>,
  Pointer<_SignalConstPointerFfiSessionStoreStruct>,
  Pointer<_SignalConstPointerFfiIdentityKeyStoreStruct>,
  Uint64,
);
typedef _EncryptMessage = Pointer<SignalFfiError> Function(
  Pointer<_SignalMutPointerCiphertextMessage>,
  SignalBorrowedBuffer,
  Pointer<_SignalConstPointerProtocolAddress>,
  Pointer<_SignalConstPointerFfiSessionStoreStruct>,
  Pointer<_SignalConstPointerFfiIdentityKeyStoreStruct>,
  int,
);

// signal_ciphertext_message_serialize(SignalOwnedBuffer *out, SignalConstPointerCiphertextMessage obj) -> SignalFfiError*
typedef _NativeCiphertextMessageSerialize = Pointer<SignalFfiError> Function(
  Pointer<SignalOwnedBuffer>,
  Pointer<_SignalConstPointerCiphertextMessage>,
);
typedef _CiphertextMessageSerialize = Pointer<SignalFfiError> Function(
  Pointer<SignalOwnedBuffer>,
  Pointer<_SignalConstPointerCiphertextMessage>,
);

// signal_ciphertext_message_destroy(SignalMutPointerCiphertextMessage p) -> SignalFfiError*
typedef _NativeCiphertextMessageDestroy = Pointer<SignalFfiError> Function(
  Pointer<_SignalMutPointerCiphertextMessage>,
);
typedef _CiphertextMessageDestroy = Pointer<SignalFfiError> Function(
  Pointer<_SignalMutPointerCiphertextMessage>,
);

// signal_free_buffer(const unsigned char *buf, size_t buf_len) -> void
typedef _NativeFreeBuffer = Void Function(
  Pointer<Uint8>,
  IntPtr,
);
typedef _FreeBuffer = void Function(
  Pointer<Uint8>,
  int,
);

// signal_message_deserialize(SignalMutPointerSignalMessage *out, SignalBorrowedBuffer data) -> SignalFfiError*
typedef _NativeMessageDeserialize = Pointer<SignalFfiError> Function(
  Pointer<_SignalMutPointerSignalMessage>,
  SignalBorrowedBuffer,
);
typedef _MessageDeserialize = Pointer<SignalFfiError> Function(
  Pointer<_SignalMutPointerSignalMessage>,
  SignalBorrowedBuffer,
);

// signal_message_destroy(SignalMutPointerSignalMessage p) -> SignalFfiError*
typedef _NativeMessageDestroy = Pointer<SignalFfiError> Function(
  Pointer<_SignalMutPointerSignalMessage>,
);
typedef _MessageDestroy = Pointer<SignalFfiError> Function(
  Pointer<_SignalMutPointerSignalMessage>,
);

// signal_decrypt_message(SignalOwnedBuffer *out, SignalConstPointerSignalMessage message, SignalConstPointerProtocolAddress protocol_address, SignalConstPointerFfiSessionStoreStruct session_store, SignalConstPointerFfiIdentityKeyStoreStruct identity_key_store) -> SignalFfiError*
typedef _NativeDecryptMessage = Pointer<SignalFfiError> Function(
  Pointer<SignalOwnedBuffer>,
  Pointer<_SignalConstPointerSignalMessage>,
  Pointer<_SignalConstPointerProtocolAddress>,
  Pointer<_SignalConstPointerFfiSessionStoreStruct>,
  Pointer<_SignalConstPointerFfiIdentityKeyStoreStruct>,
);
typedef _DecryptMessage = Pointer<SignalFfiError> Function(
  Pointer<SignalOwnedBuffer>,
  Pointer<_SignalConstPointerSignalMessage>,
  Pointer<_SignalConstPointerProtocolAddress>,
  Pointer<_SignalConstPointerFfiSessionStoreStruct>,
  Pointer<_SignalConstPointerFfiIdentityKeyStoreStruct>,
);

// ============================================================================
// FFI FUNCTION TYPEDEFS - X3DH Key Exchange
// ============================================================================

// signal_address_new(SignalMutPointerProtocolAddress *out, const char *name, uint32_t device_id) -> SignalFfiError*
typedef _NativeAddressNew = Pointer<SignalFfiError> Function(
  Pointer<_SignalMutPointerProtocolAddress>,
  Pointer<Utf8>,
  Uint32,
);
typedef _AddressNew = Pointer<SignalFfiError> Function(
  Pointer<_SignalMutPointerProtocolAddress>,
  Pointer<Utf8>,
  int,
);

// signal_address_destroy(SignalMutPointerProtocolAddress p) -> SignalFfiError*
typedef _NativeAddressDestroy = Pointer<SignalFfiError> Function(
  Pointer<_SignalMutPointerProtocolAddress>,
);
typedef _AddressDestroy = Pointer<SignalFfiError> Function(
  Pointer<_SignalMutPointerProtocolAddress>,
);

// signal_process_prekey_bundle(SignalConstPointerPreKeyBundle bundle, SignalConstPointerProtocolAddress protocol_address, SignalConstPointerFfiSessionStoreStruct session_store, SignalConstPointerFfiIdentityKeyStoreStruct identity_key_store, uint64_t now) -> SignalFfiError*
typedef _NativeProcessPreKeyBundle = Pointer<SignalFfiError> Function(
  Pointer<SignalConstPointerPreKeyBundle>,
  Pointer<_SignalConstPointerProtocolAddress>,
  Pointer<_SignalConstPointerFfiSessionStoreStruct>,
  Pointer<_SignalConstPointerFfiIdentityKeyStoreStruct>,
  Uint64,
);
typedef _ProcessPreKeyBundle = Pointer<SignalFfiError> Function(
  Pointer<SignalConstPointerPreKeyBundle>,
  Pointer<_SignalConstPointerProtocolAddress>,
  Pointer<_SignalConstPointerFfiSessionStoreStruct>,
  Pointer<_SignalConstPointerFfiIdentityKeyStoreStruct>,
  int, // uint64_t as int (64-bit on most platforms)
);

/// Signal Protocol FFI Bindings
/// 
/// Provides Dart interface to libsignal-ffi Rust library via FFI.
/// 
/// **Production Lifecycle:**
/// - Registered as singleton in dependency injection (`registerLazySingleton`)
/// - Lives for app's lifetime (never disposed in production)
/// - Library unloaded by OS on app termination
/// - No explicit disposal needed or called in production
/// 
/// **Test Lifecycle:**
/// - Created per test
/// - May be disposed in `tearDown()`
/// - SIGABRT during finalization is expected (OS-level cleanup during test process exit)
/// - Crash occurs after all Dart code completes successfully
/// 
/// Phase 14: Signal Protocol Implementation - Option 1
class SignalFFIBindings {
  static const String _logName = 'SignalFFIBindings';
  
  // Use unified library manager for all library loading
  final SignalLibraryManager _libManager = SignalLibraryManager();
  
  DynamicLibrary? _lib;
  DynamicLibrary? _wrapperLib;
  bool _initialized = false;
  bool _wrapperInitialized = false;
  
  // ============================================================================
  // FFI FUNCTION BINDINGS - Identity Key Generation
  // ============================================================================
  
  late final _PrivateKeyGenerate _privateKeyGenerate;
  late final _PrivateKeyDeserialize _privateKeyDeserialize;
  late final _PrivateKeyGetPublicKey _privateKeyGetPublicKey;
  late final _PrivateKeySerialize _privateKeySerialize;
  late final _PrivateKeyDestroy _privateKeyDestroy;
  late final _PublicKeySerialize _publicKeySerialize;
  late final _PublicKeyDestroy _publicKeyDestroy;
  late final _ErrorGetMessage _errorGetMessage;
  late final _ErrorFree _errorFree;
  
  // Prekey bundle functions
  late final _PreKeyBundleNew _preKeyBundleNew;
  late final _PreKeyBundleDestroy _preKeyBundleDestroy;
  // Note: _preKeyBundleGetIdentityKey removed - not used in current implementation
  
  // Key deserialization functions
  late final _PublicKeyDeserialize _publicKeyDeserialize;
  late final _KyberPublicKeyDeserialize _kyberPublicKeyDeserialize;
  late final _KyberPublicKeySerialize _kyberPublicKeySerialize;
  late final _KyberPublicKeyDestroy _kyberPublicKeyDestroy;
  
  // Kyber key pair functions
  late final _KyberKeyPairGenerate _kyberKeyPairGenerate;
  late final _KyberKeyPairGetPublicKey _kyberKeyPairGetPublicKey;
  late final _KyberKeyPairDestroy _kyberKeyPairDestroy;
  
  // Signing functions
  late final _PrivateKeySign _privateKeySign;
  
  // X3DH key exchange functions
  late final _AddressNew _addressNew;
  late final _AddressDestroy _addressDestroy;
  late final _ProcessPreKeyBundle _processPreKeyBundle;
  
  // Message encryption/decryption functions
  late final _EncryptMessage _encryptMessage;
  late final _CiphertextMessageSerialize _ciphertextMessageSerialize;
  late final _CiphertextMessageDestroy _ciphertextMessageDestroy;
  late final _FreeBuffer _freeBuffer;
  late final _MessageDeserialize _messageDeserialize;
  late final _MessageDestroy _messageDestroy;
  late final _DecryptMessage _decryptMessage;
  
  // ============================================================================
  // FFI FUNCTION BINDINGS - Wrapper Library (for store callbacks)
  // ============================================================================
  
  // Registration functions (take function pointers as void*)
  // Note: Function pointers are passed as Pointer<Void> to avoid Dart FFI limitations
  // Using function signature directly (not typedef) to avoid Dart FFI limitations
  late final void Function(Pointer<Void>) _registerLoadSessionCallback;
  late final void Function(Pointer<Void>) _registerStoreSessionCallback;
  late final void Function(Pointer<Void>) _registerGetIdentityKeyPairCallback;
  late final void Function(Pointer<Void>) _registerGetLocalRegistrationIdCallback;
  late final void Function(Pointer<Void>) _registerSaveIdentityKeyCallback;
  late final void Function(Pointer<Void>) _registerGetIdentityKeyCallback;
  late final void Function(Pointer<Void>) _registerIsTrustedIdentityCallback;
  
  // Wrapper function pointers (cached after initialization)
  // These are looked up from the wrapper library and stored for use in store structs
  
  // Library loading is now handled by SignalLibraryManager
  // Removed _loadLibrary() and _loadWrapperLibrary() methods
  
  /// Initialize FFI bindings
  /// 
  /// Loads the libsignal-ffi native library for the current platform.
  /// 
  /// **Hybrid Approach:**
  /// - Android: Uses pre-built libraries from Maven (Option A)
  /// - iOS: Uses framework built from source (Option B)
  /// - Desktop: Uses pre-built libraries from Maven (Option A)
  Future<void> initialize() async {
    if (_initialized) {
      developer.log('Signal FFI bindings already initialized', name: _logName);
      return;
    }
    
    try {
      // Use unified library manager for loading
      _lib = _libManager.getMainLibrary();
      
      // Bind identity key generation functions
      _privateKeyGenerate = _lib!
          .lookup<NativeFunction<_NativePrivateKeyGenerate>>('signal_privatekey_generate')
          .asFunction<_PrivateKeyGenerate>();
      
      _privateKeyDeserialize = _lib!
          .lookup<NativeFunction<_NativePrivateKeyDeserialize>>('signal_privatekey_deserialize')
          .asFunction<_PrivateKeyDeserialize>();
      
      _privateKeyGetPublicKey = _lib!
          .lookup<NativeFunction<_NativePrivateKeyGetPublicKey>>('signal_privatekey_get_public_key')
          .asFunction<_PrivateKeyGetPublicKey>();
      
      _privateKeySerialize = _lib!
          .lookup<NativeFunction<_NativePrivateKeySerialize>>('signal_privatekey_serialize')
          .asFunction<_PrivateKeySerialize>();
      
      _privateKeyDestroy = _lib!
          .lookup<NativeFunction<_NativePrivateKeyDestroy>>('signal_privatekey_destroy')
          .asFunction<_PrivateKeyDestroy>();
      
      _publicKeySerialize = _lib!
          .lookup<NativeFunction<_NativePublicKeySerialize>>('signal_publickey_serialize')
          .asFunction<_PublicKeySerialize>();
      
      _publicKeyDestroy = _lib!
          .lookup<NativeFunction<_NativePublicKeyDestroy>>('signal_publickey_destroy')
          .asFunction<_PublicKeyDestroy>();
      
      _errorGetMessage = _lib!
          .lookup<NativeFunction<_NativeErrorGetMessage>>('signal_error_get_message')
          .asFunction<_ErrorGetMessage>();
      
          _errorFree = _lib!
              .lookup<NativeFunction<_NativeErrorFree>>('signal_error_free')
              .asFunction<_ErrorFree>();
          
          // Prekey bundle functions
          _preKeyBundleNew = _lib!
              .lookup<NativeFunction<_NativePreKeyBundleNew>>('signal_pre_key_bundle_new')
              .asFunction<_PreKeyBundleNew>();
          _preKeyBundleDestroy = _lib!
              .lookup<NativeFunction<_NativePreKeyBundleDestroy>>('signal_pre_key_bundle_destroy')
              .asFunction<_PreKeyBundleDestroy>();
          // Note: _preKeyBundleGetIdentityKey removed - not used in current implementation
          // _preKeyBundleGetIdentityKey = _lib!
          //     .lookup<NativeFunction<_NativePreKeyBundleGetIdentityKey>>('signal_pre_key_bundle_get_identity_key')
          //     .asFunction<_PreKeyBundleGetIdentityKey>();
          
          // Key deserialization functions
          _publicKeyDeserialize = _lib!
              .lookup<NativeFunction<_NativePublicKeyDeserialize>>('signal_publickey_deserialize')
              .asFunction<_PublicKeyDeserialize>();
          _kyberPublicKeyDeserialize = _lib!
              .lookup<NativeFunction<_NativeKyberPublicKeyDeserialize>>('signal_kyber_public_key_deserialize')
              .asFunction<_KyberPublicKeyDeserialize>();
          _kyberPublicKeySerialize = _lib!
              .lookup<NativeFunction<_NativeKyberPublicKeySerialize>>('signal_kyber_public_key_serialize')
              .asFunction<_KyberPublicKeySerialize>();
          _kyberPublicKeyDestroy = _lib!
              .lookup<NativeFunction<_NativeKyberPublicKeyDestroy>>('signal_kyber_public_key_destroy')
              .asFunction<_KyberPublicKeyDestroy>();
          _kyberKeyPairGenerate = _lib!
              .lookup<NativeFunction<_NativeKyberKeyPairGenerate>>('signal_kyber_key_pair_generate')
              .asFunction<_KyberKeyPairGenerate>();
          _kyberKeyPairGetPublicKey = _lib!
              .lookup<NativeFunction<_NativeKyberKeyPairGetPublicKey>>('signal_kyber_key_pair_get_public_key')
              .asFunction<_KyberKeyPairGetPublicKey>();
          _kyberKeyPairDestroy = _lib!
              .lookup<NativeFunction<_NativeKyberKeyPairDestroy>>('signal_kyber_key_pair_destroy')
              .asFunction<_KyberKeyPairDestroy>();
          _privateKeySign = _lib!
              .lookup<NativeFunction<_NativePrivateKeySign>>('signal_privatekey_sign')
              .asFunction<_PrivateKeySign>();
          
          // X3DH key exchange functions
          _addressNew = _lib!
              .lookup<NativeFunction<_NativeAddressNew>>('signal_address_new')
              .asFunction<_AddressNew>();
          _addressDestroy = _lib!
              .lookup<NativeFunction<_NativeAddressDestroy>>('signal_address_destroy')
              .asFunction<_AddressDestroy>();
          _processPreKeyBundle = _lib!
              .lookup<NativeFunction<_NativeProcessPreKeyBundle>>('signal_process_prekey_bundle')
              .asFunction<_ProcessPreKeyBundle>();
          
          // Message encryption/decryption functions
          _encryptMessage = _lib!
              .lookup<NativeFunction<_NativeEncryptMessage>>('signal_encrypt_message')
              .asFunction<_EncryptMessage>();
          _ciphertextMessageSerialize = _lib!
              .lookup<NativeFunction<_NativeCiphertextMessageSerialize>>('signal_ciphertext_message_serialize')
              .asFunction<_CiphertextMessageSerialize>();
          _ciphertextMessageDestroy = _lib!
              .lookup<NativeFunction<_NativeCiphertextMessageDestroy>>('signal_ciphertext_message_destroy')
              .asFunction<_CiphertextMessageDestroy>();
          _freeBuffer = _lib!
              .lookup<NativeFunction<_NativeFreeBuffer>>('signal_free_buffer')
              .asFunction<_FreeBuffer>();
          _messageDeserialize = _lib!
              .lookup<NativeFunction<_NativeMessageDeserialize>>('signal_message_deserialize')
              .asFunction<_MessageDeserialize>();
          _messageDestroy = _lib!
              .lookup<NativeFunction<_NativeMessageDestroy>>('signal_message_destroy')
              .asFunction<_MessageDestroy>();
          _decryptMessage = _lib!
              .lookup<NativeFunction<_NativeDecryptMessage>>('signal_decrypt_message')
              .asFunction<_DecryptMessage>();
          
          _initialized = true;
          developer.log('✅ Signal FFI bindings initialized', name: _logName);
          
          // Try to initialize wrapper library (optional - may not be built yet)
          try {
            await initializeWrapperLibrary();
          } catch (e) {
            developer.log(
              'Warning: Wrapper library not available: $e',
              name: _logName,
            );
            // Wrapper library is optional - continue without it
          }
    } catch (e, stackTrace) {
      developer.log(
        'Error initializing Signal FFI bindings: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      // Note: This is expected if libraries are not yet extracted/built
      // The error will be caught and handled gracefully by SignalProtocolService
      throw SignalProtocolException(
        'Failed to initialize Signal FFI bindings: $e',
        originalError: e,
      );
    }
  }
  
  /// Check if bindings are initialized
  bool get isInitialized => _initialized;
  
  /// Check for FFI errors and throw if present
  void _checkError(Pointer<SignalFfiError>? error) {
    if (error != null && error.address != 0) {
      // Get error message
      final messagePtr = malloc<Pointer<Utf8>>();
      final getMessageError = _errorGetMessage(messagePtr, error);
      
      String errorMessage = 'Unknown error';
      if (getMessageError.address == 0) {
        if (messagePtr.value.address != 0) {
          errorMessage = messagePtr.value.toDartString();
        }
      }
      
      // Free error
      _errorFree(error);
      malloc.free(messagePtr);
      
      throw SignalProtocolException(
        'Signal FFI error: $errorMessage',
        code: 'FFI_ERROR',
      );
    }
  }
  
  /// Generate Identity Key Pair
  /// 
  /// Generates a new Signal Protocol identity key pair.
  /// This is a long-term key used for authentication.
  Future<SignalIdentityKeyPair> generateIdentityKeyPair() async {
    if (!_initialized) {
      throw SignalProtocolException('FFI bindings not initialized. Call initialize() first.');
    }
    
    // Allocate memory for private key pointer
    final privateKeyPtr = malloc<SignalMutPointerPrivateKey>();
    
    try {
      // Generate private key
      final error = _privateKeyGenerate(privateKeyPtr);
      _checkError(error);
      
      // Get public key from private key
      final publicKeyPtr = malloc<SignalMutPointerPublicKey>();
      try {
        // Create const pointer wrapper for private key
        final constPrivateKeyPtr = malloc<SignalConstPointerPrivateKey>();
        constPrivateKeyPtr.ref.raw = privateKeyPtr.ref.raw;
        
        final getPublicKeyError = _privateKeyGetPublicKey(publicKeyPtr, constPrivateKeyPtr);
        _checkError(getPublicKeyError);
        
        malloc.free(constPrivateKeyPtr);
        
        // Serialize private key (create const pointer wrapper)
        final constPrivateKeyPtrForSerialize = malloc<SignalConstPointerPrivateKey>();
        constPrivateKeyPtrForSerialize.ref.raw = privateKeyPtr.ref.raw;
        
        final privateKeyBufferPtr = malloc<SignalOwnedBuffer>();
        final serializePrivateError = _privateKeySerialize(
          privateKeyBufferPtr,
          constPrivateKeyPtrForSerialize,
        );
        _checkError(serializePrivateError);
        
        malloc.free(constPrivateKeyPtrForSerialize);
        
        final privateKeyBytes = privateKeyBufferPtr.ref.base
            .asTypedList(privateKeyBufferPtr.ref.length)
            .toList();
        
        // Serialize public key (create const pointer wrapper)
        final constPublicKeyPtr = malloc<SignalConstPointerPublicKey>();
        constPublicKeyPtr.ref.raw = publicKeyPtr.ref.raw;
        
        final publicKeyBufferPtr = malloc<SignalOwnedBuffer>();
        final serializePublicError = _publicKeySerialize(
          publicKeyBufferPtr,
          constPublicKeyPtr,
        );
        _checkError(serializePublicError);
        
        malloc.free(constPublicKeyPtr);
        
        final publicKeyBytes = publicKeyBufferPtr.ref.base
            .asTypedList(publicKeyBufferPtr.ref.length)
            .toList();
        
        // Clean up
        _privateKeyDestroy(privateKeyPtr);
        _publicKeyDestroy(publicKeyPtr);
        
        // Note: SignalOwnedBuffer memory is managed by Rust, we don't free it
        
        return SignalIdentityKeyPair(
          publicKey: Uint8List.fromList(publicKeyBytes),
          privateKey: Uint8List.fromList(privateKeyBytes),
        );
      } finally {
        malloc.free(publicKeyPtr);
      }
    } finally {
      malloc.free(privateKeyPtr);
    }
  }
  
  /// Generate Prekey Bundle
  /// 
  /// Generates a prekey bundle for X3DH key exchange.
  /// 
  /// **Parameters:**
  /// - `identityKeyPair`: Our identity key pair (used for signing)
  /// - `registrationId`: Registration ID (defaults to 1)
  /// - `deviceId`: Device ID (defaults to 1)
  /// 
  /// **Returns:**
  /// Prekey bundle ready for X3DH key exchange
  Future<SignalPreKeyBundle> generatePreKeyBundle({
    required SignalIdentityKeyPair identityKeyPair,
    int registrationId = 1,
    int deviceId = 1,
  }) async {
    if (!_initialized) {
      throw SignalProtocolException('FFI bindings not initialized. Call initialize() first.');
    }
    
    // Step 1: Deserialize identity key pair
    final identityPrivateKeyPtr = malloc<SignalMutPointerPrivateKey>();
    final identityPublicKeyPtr = malloc<SignalMutPointerPublicKey>();
    
    try {
      // Deserialize identity private key
      final identityPrivateKeyBuffer = malloc<SignalBorrowedBuffer>();
      final identityPrivateKeyData = malloc<Uint8>(identityKeyPair.privateKey.length);
      identityPrivateKeyData.asTypedList(identityKeyPair.privateKey.length)
          .setAll(0, identityKeyPair.privateKey);
      identityPrivateKeyBuffer.ref.base = identityPrivateKeyData;
      identityPrivateKeyBuffer.ref.length = identityKeyPair.privateKey.length;
      
      final identityPrivateKeyError = _privateKeyDeserialize(identityPrivateKeyPtr, identityPrivateKeyBuffer.ref);
      _checkError(identityPrivateKeyError);
      malloc.free(identityPrivateKeyData);
      malloc.free(identityPrivateKeyBuffer);
      
      // Deserialize identity public key
      final identityPublicKeyBuffer = malloc<SignalBorrowedBuffer>();
      final identityPublicKeyData = malloc<Uint8>(identityKeyPair.publicKey.length);
      identityPublicKeyData.asTypedList(identityKeyPair.publicKey.length)
          .setAll(0, identityKeyPair.publicKey);
      identityPublicKeyBuffer.ref.base = identityPublicKeyData;
      identityPublicKeyBuffer.ref.length = identityKeyPair.publicKey.length;
      
      final identityPublicKeyError = _publicKeyDeserialize(identityPublicKeyPtr, identityPublicKeyBuffer.ref);
      _checkError(identityPublicKeyError);
      malloc.free(identityPublicKeyData);
      malloc.free(identityPublicKeyBuffer);
      
      // Create const pointer wrappers
      final constIdentityPrivateKeyPtr = malloc<SignalConstPointerPrivateKey>();
      constIdentityPrivateKeyPtr.ref.raw = identityPrivateKeyPtr.ref.raw;
      
      final constIdentityPublicKeyPtr = malloc<SignalConstPointerPublicKey>();
      constIdentityPublicKeyPtr.ref.raw = identityPublicKeyPtr.ref.raw;
      
      // Step 2: Generate signed prekey pair
      final signedPrekeyPrivateKeyPtr = malloc<SignalMutPointerPrivateKey>();
      final signedPrekeyError = _privateKeyGenerate(signedPrekeyPrivateKeyPtr);
      _checkError(signedPrekeyError);
      
      final signedPrekeyPublicKeyPtr = malloc<SignalMutPointerPublicKey>();
      final constSignedPrekeyPrivateKeyPtr = malloc<SignalConstPointerPrivateKey>();
      constSignedPrekeyPrivateKeyPtr.ref.raw = signedPrekeyPrivateKeyPtr.ref.raw;
      
      final getSignedPrekeyPublicKeyError = _privateKeyGetPublicKey(signedPrekeyPublicKeyPtr, constSignedPrekeyPrivateKeyPtr);
      _checkError(getSignedPrekeyPublicKeyError);
      malloc.free(constSignedPrekeyPrivateKeyPtr);
      
      // Serialize signed prekey public key for signing
      final constSignedPrekeyPublicKeyPtr = malloc<SignalConstPointerPublicKey>();
      constSignedPrekeyPublicKeyPtr.ref.raw = signedPrekeyPublicKeyPtr.ref.raw;
      
      final signedPrekeyPublicKeyBufferPtr = malloc<SignalOwnedBuffer>();
      final serializeSignedPrekeyError = _publicKeySerialize(signedPrekeyPublicKeyBufferPtr, constSignedPrekeyPublicKeyPtr);
      _checkError(serializeSignedPrekeyError);
      malloc.free(constSignedPrekeyPublicKeyPtr);
      
      final signedPrekeyPublicKeyBytes = signedPrekeyPublicKeyBufferPtr.ref.base
          .asTypedList(signedPrekeyPublicKeyBufferPtr.ref.length)
          .toList();
      
      // Step 3: Sign signed prekey with identity key
      final signedPrekeySignatureBufferPtr = malloc<SignalOwnedBuffer>();
      final signedPrekeyMessageBuffer = malloc<SignalBorrowedBuffer>();
      final signedPrekeyMessageData = malloc<Uint8>(signedPrekeyPublicKeyBytes.length);
      signedPrekeyMessageData.asTypedList(signedPrekeyPublicKeyBytes.length)
          .setAll(0, signedPrekeyPublicKeyBytes);
      signedPrekeyMessageBuffer.ref.base = signedPrekeyMessageData;
      signedPrekeyMessageBuffer.ref.length = signedPrekeyPublicKeyBytes.length;
      
      final signSignedPrekeyError = _privateKeySign(
        signedPrekeySignatureBufferPtr,
        constIdentityPrivateKeyPtr,
        signedPrekeyMessageBuffer.ref,
      );
      _checkError(signSignedPrekeyError);
      
      final signedPrekeySignatureBytes = signedPrekeySignatureBufferPtr.ref.base
          .asTypedList(signedPrekeySignatureBufferPtr.ref.length)
          .toList();
      
      // Free signed prekey message buffer
      _freeBuffer(signedPrekeyPublicKeyBufferPtr.ref.base, signedPrekeyPublicKeyBufferPtr.ref.length);
      malloc.free(signedPrekeyPublicKeyBufferPtr);
      malloc.free(signedPrekeyMessageData);
      malloc.free(signedPrekeyMessageBuffer);
      
      // Step 4: Generate kyber prekey pair
      final kyberKeyPairPtr = malloc<_SignalMutPointerKyberKeyPair>();
      final kyberKeyPairError = _kyberKeyPairGenerate(kyberKeyPairPtr);
      _checkError(kyberKeyPairError);
      
      final kyberPublicKeyPtr = malloc<SignalMutPointerKyberPublicKey>();
      final constKyberKeyPairPtr = malloc<_SignalConstPointerKyberKeyPair>();
      constKyberKeyPairPtr.ref.raw = kyberKeyPairPtr.ref.raw;
      
      final getKyberPublicKeyError = _kyberKeyPairGetPublicKey(kyberPublicKeyPtr, constKyberKeyPairPtr);
      _checkError(getKyberPublicKeyError);
      malloc.free(constKyberKeyPairPtr);
      
      // Serialize kyber prekey public key for signing
      final constKyberPublicKeyPtr = malloc<SignalConstPointerKyberPublicKey>();
      constKyberPublicKeyPtr.ref.raw = kyberPublicKeyPtr.ref.raw;
      
      final kyberPublicKeyBufferPtr = malloc<SignalOwnedBuffer>();
      final serializeKyberError = _kyberPublicKeySerialize(kyberPublicKeyBufferPtr, constKyberPublicKeyPtr);
      _checkError(serializeKyberError);
      malloc.free(constKyberPublicKeyPtr);
      
      final kyberPublicKeyBytes = kyberPublicKeyBufferPtr.ref.base
          .asTypedList(kyberPublicKeyBufferPtr.ref.length)
          .toList();
      
      // Step 5: Sign kyber prekey with identity key
      final kyberSignatureBufferPtr = malloc<SignalOwnedBuffer>();
      final kyberMessageBuffer = malloc<SignalBorrowedBuffer>();
      final kyberMessageData = malloc<Uint8>(kyberPublicKeyBytes.length);
      kyberMessageData.asTypedList(kyberPublicKeyBytes.length)
          .setAll(0, kyberPublicKeyBytes);
      kyberMessageBuffer.ref.base = kyberMessageData;
      kyberMessageBuffer.ref.length = kyberPublicKeyBytes.length;
      
      final signKyberError = _privateKeySign(
        kyberSignatureBufferPtr,
        constIdentityPrivateKeyPtr,
        kyberMessageBuffer.ref,
      );
      _checkError(signKyberError);
      
      final kyberSignatureBytes = kyberSignatureBufferPtr.ref.base
          .asTypedList(kyberSignatureBufferPtr.ref.length)
          .toList();
      
      // Free kyber message buffer
      _freeBuffer(kyberPublicKeyBufferPtr.ref.base, kyberPublicKeyBufferPtr.ref.length);
      malloc.free(kyberPublicKeyBufferPtr);
      malloc.free(kyberMessageData);
      malloc.free(kyberMessageBuffer);
      
      // Step 6: Create prekey bundle
      // Use random IDs for prekeys (in production, these would be stored and managed)
      final signedPrekeyId = DateTime.now().millisecondsSinceEpoch % 0xFFFFFFFF;
      final kyberPrekeyId = (DateTime.now().millisecondsSinceEpoch + 1) % 0xFFFFFFFF;
      
      final constSignedPrekeyPublicKeyForBundle = malloc<SignalConstPointerPublicKey>();
      constSignedPrekeyPublicKeyForBundle.ref.raw = signedPrekeyPublicKeyPtr.ref.raw;
      
      final constKyberPublicKeyForBundle = malloc<SignalConstPointerKyberPublicKey>();
      constKyberPublicKeyForBundle.ref.raw = kyberPublicKeyPtr.ref.raw;
      
      final constIdentityPublicKeyForBundle = malloc<SignalConstPointerPublicKey>();
      constIdentityPublicKeyForBundle.ref.raw = identityPublicKeyPtr.ref.raw;
      
      final bundlePtr = _createPreKeyBundle(
        registrationId: registrationId,
        deviceId: deviceId,
        prekeyId: 0, // No one-time prekey for now
        prekey: null,
        signedPrekeyId: signedPrekeyId,
        signedPrekey: constSignedPrekeyPublicKeyForBundle,
        signedPrekeySignature: Uint8List.fromList(signedPrekeySignatureBytes),
        identityKey: constIdentityPublicKeyForBundle,
        kyberPrekeyId: kyberPrekeyId,
        kyberPrekey: constKyberPublicKeyForBundle,
        kyberPrekeySignature: Uint8List.fromList(kyberSignatureBytes),
      );
      
      // Step 7: Extract bundle components
      // Serialize signed prekey public key
      final constSignedPrekeyPublicKeyForExtract = malloc<SignalConstPointerPublicKey>();
      constSignedPrekeyPublicKeyForExtract.ref.raw = signedPrekeyPublicKeyPtr.ref.raw;
      
      final signedPrekeyExtractBufferPtr = malloc<SignalOwnedBuffer>();
      final extractSignedPrekeyError = _publicKeySerialize(signedPrekeyExtractBufferPtr, constSignedPrekeyPublicKeyForExtract);
      _checkError(extractSignedPrekeyError);
      malloc.free(constSignedPrekeyPublicKeyForExtract);
      
      final signedPrekeyBytes = signedPrekeyExtractBufferPtr.ref.base
          .asTypedList(signedPrekeyExtractBufferPtr.ref.length)
          .toList();
      
      // Serialize identity public key
      final constIdentityPublicKeyForExtract = malloc<SignalConstPointerPublicKey>();
      constIdentityPublicKeyForExtract.ref.raw = identityPublicKeyPtr.ref.raw;
      
      final identityExtractBufferPtr = malloc<SignalOwnedBuffer>();
      final extractIdentityError = _publicKeySerialize(identityExtractBufferPtr, constIdentityPublicKeyForExtract);
      _checkError(extractIdentityError);
      malloc.free(constIdentityPublicKeyForExtract);
      
      final identityKeyBytes = identityExtractBufferPtr.ref.base
          .asTypedList(identityExtractBufferPtr.ref.length)
          .toList();
      
      // Serialize kyber public key
      final constKyberPublicKeyForExtract = malloc<SignalConstPointerKyberPublicKey>();
      constKyberPublicKeyForExtract.ref.raw = kyberPublicKeyPtr.ref.raw;
      
      final kyberExtractBufferPtr = malloc<SignalOwnedBuffer>();
      final extractKyberError = _kyberPublicKeySerialize(kyberExtractBufferPtr, constKyberPublicKeyForExtract);
      _checkError(extractKyberError);
      malloc.free(constKyberPublicKeyForExtract);
      
      final kyberPrekeyBytes = kyberExtractBufferPtr.ref.base
          .asTypedList(kyberExtractBufferPtr.ref.length)
          .toList();
      
      // Clean up extraction buffers
      _freeBuffer(signedPrekeyExtractBufferPtr.ref.base, signedPrekeyExtractBufferPtr.ref.length);
      malloc.free(signedPrekeyExtractBufferPtr);
      _freeBuffer(identityExtractBufferPtr.ref.base, identityExtractBufferPtr.ref.length);
      malloc.free(identityExtractBufferPtr);
      _freeBuffer(kyberExtractBufferPtr.ref.base, kyberExtractBufferPtr.ref.length);
      malloc.free(kyberExtractBufferPtr);
      
      // Clean up signatures
      _freeBuffer(signedPrekeySignatureBufferPtr.ref.base, signedPrekeySignatureBufferPtr.ref.length);
      malloc.free(signedPrekeySignatureBufferPtr);
      _freeBuffer(kyberSignatureBufferPtr.ref.base, kyberSignatureBufferPtr.ref.length);
      malloc.free(kyberSignatureBufferPtr);
      
      // Clean up bundle pointers
      destroyPreKeyBundle(bundlePtr);
      malloc.free(constSignedPrekeyPublicKeyForBundle);
      malloc.free(constKyberPublicKeyForBundle);
      malloc.free(constIdentityPublicKeyForBundle);
      
      // Clean up keys
      _kyberKeyPairDestroy(kyberKeyPairPtr);
      malloc.free(kyberKeyPairPtr);
      _kyberPublicKeyDestroy(kyberPublicKeyPtr);
      malloc.free(kyberPublicKeyPtr);
      _publicKeyDestroy(signedPrekeyPublicKeyPtr);
      malloc.free(signedPrekeyPublicKeyPtr);
      _privateKeyDestroy(signedPrekeyPrivateKeyPtr);
      malloc.free(signedPrekeyPrivateKeyPtr);
      _publicKeyDestroy(identityPublicKeyPtr);
      malloc.free(identityPublicKeyPtr);
      _privateKeyDestroy(identityPrivateKeyPtr);
      malloc.free(identityPrivateKeyPtr);
      malloc.free(constIdentityPrivateKeyPtr);
      malloc.free(constIdentityPublicKeyPtr);
      
      // Return prekey bundle
      return SignalPreKeyBundle(
        preKeyId: '0', // No one-time prekey
        signedPreKey: Uint8List.fromList(signedPrekeyBytes),
        signedPreKeyId: signedPrekeyId,
        signature: Uint8List.fromList(signedPrekeySignatureBytes),
        identityKey: Uint8List.fromList(identityKeyBytes),
        registrationId: registrationId,
        deviceId: deviceId,
        kyberPreKeyId: kyberPrekeyId,
        kyberPreKey: Uint8List.fromList(kyberPrekeyBytes),
        kyberPreKeySignature: Uint8List.fromList(kyberSignatureBytes),
      );
    } catch (e) {
      // Clean up on error
      _privateKeyDestroy(identityPrivateKeyPtr);
      _publicKeyDestroy(identityPublicKeyPtr);
      malloc.free(identityPrivateKeyPtr);
      malloc.free(identityPublicKeyPtr);
      rethrow;
    }
  }
  
  /// Create Prekey Bundle from Components
  /// 
  /// Creates a prekey bundle from pre-generated keys and signatures.
  /// This is a lower-level function that can be used once keys are generated.
  /// 
  /// **Parameters:**
  /// - `registrationId`: Registration ID (typically 1 for first device)
  /// - `deviceId`: Device ID
  /// - `prekeyId`: One-time prekey ID (optional, use 0 if not provided)
  /// - `prekey`: One-time prekey public key (optional)
  /// - `signedPrekeyId`: Signed prekey ID
  /// - `signedPrekey`: Signed prekey public key
  /// - `signedPrekeySignature`: Signature of signed prekey
  /// - `identityKey`: Identity public key
  /// - `kyberPrekeyId`: Kyber prekey ID
  /// - `kyberPrekey`: Kyber prekey public key
  /// - `kyberPrekeySignature`: Signature of kyber prekey
  /// 
  /// **Returns:**
  /// Pointer to created prekey bundle (must be destroyed with destroyPreKeyBundle)
  /// 
  /// **Note:** This is an internal function. Use generatePreKeyBundle() for the high-level API.
  Pointer<SignalMutPointerPreKeyBundle> _createPreKeyBundle({
    required int registrationId,
    required int deviceId,
    required int prekeyId,
    Pointer<SignalConstPointerPublicKey>? prekey,
    required int signedPrekeyId,
    required Pointer<SignalConstPointerPublicKey> signedPrekey,
    required Uint8List signedPrekeySignature,
    required Pointer<SignalConstPointerPublicKey> identityKey,
    required int kyberPrekeyId,
    required Pointer<SignalConstPointerKyberPublicKey> kyberPrekey,
    required Uint8List kyberPrekeySignature,
  }) {
    if (!_initialized) {
      throw SignalProtocolException('FFI bindings not initialized. Call initialize() first.');
    }
    
    // Allocate output pointer
    final bundlePtr = malloc<SignalMutPointerPreKeyBundle>();
    
    // Prepare borrowed buffers for signatures
    final signedPrekeySigBuffer = malloc<SignalBorrowedBuffer>();
    final signedPrekeySigData = malloc<Uint8>(signedPrekeySignature.length);
    signedPrekeySigData.asTypedList(signedPrekeySignature.length)
        .setAll(0, signedPrekeySignature);
    signedPrekeySigBuffer.ref.base = signedPrekeySigData;
    signedPrekeySigBuffer.ref.length = signedPrekeySignature.length;
    
    final kyberPrekeySigBuffer = malloc<SignalBorrowedBuffer>();
    final kyberPrekeySigData = malloc<Uint8>(kyberPrekeySignature.length);
    kyberPrekeySigData.asTypedList(kyberPrekeySignature.length)
        .setAll(0, kyberPrekeySignature);
    kyberPrekeySigBuffer.ref.base = kyberPrekeySigData;
    kyberPrekeySigBuffer.ref.length = kyberPrekeySignature.length;
    
    try {
      // Handle optional prekey (use null pointer if not provided)
      final prekeyPtr = prekey ?? nullptr.cast<SignalConstPointerPublicKey>();
      
      // Call FFI function
      final error = _preKeyBundleNew(
        bundlePtr,
        registrationId,
        deviceId,
        prekeyId,
        prekeyPtr,
        signedPrekeyId,
        signedPrekey,
        signedPrekeySigBuffer.ref,
        identityKey,
        kyberPrekeyId,
        kyberPrekey,
        kyberPrekeySigBuffer.ref,
      );
      
      _checkError(error);
      
      return bundlePtr;
    } finally {
      // Free signature buffers (data is copied by Rust, so we can free)
      malloc.free(signedPrekeySigData);
      malloc.free(signedPrekeySigBuffer);
      malloc.free(kyberPrekeySigData);
      malloc.free(kyberPrekeySigBuffer);
    }
  }
  
  /// Destroy Prekey Bundle
  /// 
  /// Frees memory allocated for a prekey bundle.
  void destroyPreKeyBundle(Pointer<SignalMutPointerPreKeyBundle> bundlePtr) {
    if (!_initialized) {
      throw SignalProtocolException('FFI bindings not initialized. Call initialize() first.');
    }
    
    final error = _preKeyBundleDestroy(bundlePtr);
    _checkError(error);
    malloc.free(bundlePtr);
  }
  
  /// Encrypt Message
  /// 
  /// Encrypts a message using Signal Protocol (Double Ratchet).
  /// 
  /// **Parameters:**
  /// - `plaintext`: Message to encrypt
  /// - `recipientId`: Recipient's agent ID
  /// - `deviceId`: Recipient's device ID (defaults to 1)
  /// - `storeCallbacks`: Store callbacks for session and identity key storage
  /// 
  /// **Returns:**
  /// Encrypted message with header for Double Ratchet
  /// 
  /// **Note:** This function requires an established session. If no session exists,
  /// use performX3DHKeyExchange() first to establish a session.
  Future<SignalEncryptedMessage> encryptMessage({
    required Uint8List plaintext,
    required String recipientId,
    int deviceId = 1,
    required SignalFFIStoreCallbacks storeCallbacks,
  }) async {
    if (!_initialized) {
      throw SignalProtocolException('FFI bindings not initialized. Call initialize() first.');
    }
    
    if (!storeCallbacks.isInitialized) {
      throw SignalProtocolException(
        'Store callbacks not initialized. Call SignalFFIStoreCallbacks.initialize() first.',
      );
    }
    
    // Step 1: Create ProtocolAddress from recipientId
    final addressPtr = malloc<_SignalMutPointerProtocolAddress>();
    final recipientIdUtf8 = recipientId.toNativeUtf8();
    
    try {
      final addressError = _addressNew(addressPtr, recipientIdUtf8, deviceId);
      _checkError(addressError);
      
      // Create const pointer wrapper for address
      final constAddressPtr = malloc<_SignalConstPointerProtocolAddress>();
      constAddressPtr.ref.raw = addressPtr.ref.raw;
      
      // Step 2: Get store structs from storeCallbacks
      final sessionStorePtr = storeCallbacks.createSessionStore();
      final identityStorePtr = storeCallbacks.createIdentityKeyStore();
      
      // Create const pointer wrappers for store structs
      final constSessionStorePtr = malloc<_SignalConstPointerFfiSessionStoreStruct>();
      constSessionStorePtr.ref.raw = sessionStorePtr.cast();
      
      final constIdentityStorePtr = malloc<_SignalConstPointerFfiIdentityKeyStoreStruct>();
      constIdentityStorePtr.ref.raw = identityStorePtr.cast();
      
      // Step 3: Prepare plaintext buffer
      final plaintextBuffer = malloc<SignalBorrowedBuffer>();
      final plaintextData = malloc<Uint8>(plaintext.length);
      plaintextData.asTypedList(plaintext.length).setAll(0, plaintext);
      plaintextBuffer.ref.base = plaintextData;
      plaintextBuffer.ref.length = plaintext.length;
      
      // Step 4: Allocate output pointer for ciphertext message
      final ciphertextMessagePtr = malloc<_SignalMutPointerCiphertextMessage>();
      
      try {
        // Step 5: Call signal_encrypt_message
        // Note: now is in milliseconds since epoch, but libsignal-ffi expects seconds since epoch
        final now = (DateTime.now().millisecondsSinceEpoch / 1000).round();
        final encryptError = _encryptMessage(
          ciphertextMessagePtr,
          plaintextBuffer.ref,
          constAddressPtr,
          constSessionStorePtr,
          constIdentityStorePtr,
          now,
        );
        _checkError(encryptError);
        
        // Step 6: Serialize ciphertext message to bytes
        final constCiphertextMessagePtr = malloc<_SignalConstPointerCiphertextMessage>();
        constCiphertextMessagePtr.ref.raw = ciphertextMessagePtr.ref.raw;
        
        final serializedBuffer = malloc<SignalOwnedBuffer>();
        final serializeError = _ciphertextMessageSerialize(serializedBuffer, constCiphertextMessagePtr);
        _checkError(serializeError);
        
        // Step 7: Extract serialized bytes
        final serializedBytes = serializedBuffer.ref.base
            .asTypedList(serializedBuffer.ref.length)
            .toList();
        final ciphertext = Uint8List.fromList(serializedBytes);
        
        // Step 8: Free serialized buffer (owned by Rust)
        // SignalOwnedBuffer is owned by Rust and must be freed using signal_free_buffer
        _freeBuffer(serializedBuffer.ref.base, serializedBuffer.ref.length);
        malloc.free(serializedBuffer);
        
        // Clean up
        malloc.free(constCiphertextMessagePtr);
        _ciphertextMessageDestroy(ciphertextMessagePtr);
        malloc.free(ciphertextMessagePtr);
        
        // Clean up store structs
        malloc.free(constSessionStorePtr);
        malloc.free(constIdentityStorePtr);
        malloc.free(sessionStorePtr);
        malloc.free(identityStorePtr);
        
        // Clean up address
        malloc.free(constAddressPtr);
        _addressDestroy(addressPtr);
        
        // Clean up plaintext buffer
        malloc.free(plaintextData);
        malloc.free(plaintextBuffer);
        
        // Return encrypted message
        // Note: The serialized ciphertext message includes both the message type and the encrypted data
        // For SignalEncryptedMessage, we'll use the full serialized bytes as ciphertext
        // The messageHeader can be extracted if needed, but the serialized format is self-contained
        return SignalEncryptedMessage(
          ciphertext: ciphertext,
          messageType: 2, // SignalCiphertextMessageTypeWhisper (regular message)
          timestamp: DateTime.now(),
        );
      } catch (e) {
        // Clean up on error
        _ciphertextMessageDestroy(ciphertextMessagePtr);
        malloc.free(ciphertextMessagePtr);
        rethrow;
      }
    } finally {
      malloc.free(recipientIdUtf8);
      malloc.free(addressPtr);
    }
  }
  
  /// Decrypt Message
  /// 
  /// Decrypts a message using Signal Protocol (Double Ratchet).
  /// 
  /// **Parameters:**
  /// - `encrypted`: Encrypted message (serialized CiphertextMessage bytes)
  /// - `senderId`: Sender's agent ID
  /// - `deviceId`: Sender's device ID (defaults to 1)
  /// - `storeCallbacks`: Store callbacks for session and identity key storage
  /// 
  /// **Returns:**
  /// Decrypted plaintext
  /// 
  /// **Note:** This function handles both SignalMessage (established session) and
  /// PreKeySignalMessage (new session). For PreKey messages, use decryptPreKeyMessage().
  Future<Uint8List> decryptMessage({
    required SignalEncryptedMessage encrypted,
    required String senderId,
    int deviceId = 1,
    required SignalFFIStoreCallbacks storeCallbacks,
  }) async {
    if (!_initialized) {
      throw SignalProtocolException('FFI bindings not initialized. Call initialize() first.');
    }
    
    if (!storeCallbacks.isInitialized) {
      throw SignalProtocolException(
        'Store callbacks not initialized. Call SignalFFIStoreCallbacks.initialize() first.',
      );
    }
    
    // Step 1: Deserialize ciphertext bytes into SignalMessage
    // Note: The encrypted.ciphertext contains the serialized CiphertextMessage
    // For established sessions, this should be a SignalMessage (type 2)
    final messagePtr = malloc<_SignalMutPointerSignalMessage>();
    final ciphertextBuffer = malloc<SignalBorrowedBuffer>();
    final ciphertextData = malloc<Uint8>(encrypted.ciphertext.length);
    ciphertextData.asTypedList(encrypted.ciphertext.length)
        .setAll(0, encrypted.ciphertext);
    ciphertextBuffer.ref.base = ciphertextData;
    ciphertextBuffer.ref.length = encrypted.ciphertext.length;
    
    try {
      final deserializeError = _messageDeserialize(messagePtr, ciphertextBuffer.ref);
      _checkError(deserializeError);
      
      // Create const pointer wrapper for message
      final constMessagePtr = malloc<_SignalConstPointerSignalMessage>();
      constMessagePtr.ref.raw = messagePtr.ref.raw;
      
      // Step 2: Create ProtocolAddress from senderId
      final addressPtr = malloc<_SignalMutPointerProtocolAddress>();
      final senderIdUtf8 = senderId.toNativeUtf8();
      
      try {
        final addressError = _addressNew(addressPtr, senderIdUtf8, deviceId);
        _checkError(addressError);
        
        // Create const pointer wrapper for address
        final constAddressPtr = malloc<_SignalConstPointerProtocolAddress>();
        constAddressPtr.ref.raw = addressPtr.ref.raw;
        
        // Step 3: Get store structs from storeCallbacks
        final sessionStorePtr = storeCallbacks.createSessionStore();
        final identityStorePtr = storeCallbacks.createIdentityKeyStore();
        
        // Create const pointer wrappers for store structs
        final constSessionStorePtr = malloc<_SignalConstPointerFfiSessionStoreStruct>();
        constSessionStorePtr.ref.raw = sessionStorePtr.cast();
        
        final constIdentityStorePtr = malloc<_SignalConstPointerFfiIdentityKeyStoreStruct>();
        constIdentityStorePtr.ref.raw = identityStorePtr.cast();
        
        // Step 4: Allocate output buffer for plaintext
        final plaintextBuffer = malloc<SignalOwnedBuffer>();
        
        try {
          // Step 5: Call signal_decrypt_message
          final decryptError = _decryptMessage(
            plaintextBuffer,
            constMessagePtr,
            constAddressPtr,
            constSessionStorePtr,
            constIdentityStorePtr,
          );
          _checkError(decryptError);
          
          // Step 6: Extract decrypted plaintext
          final plaintextBytes = plaintextBuffer.ref.base
              .asTypedList(plaintextBuffer.ref.length)
              .toList();
          final plaintext = Uint8List.fromList(plaintextBytes);
          
          // Step 7: Free plaintext buffer (owned by Rust)
          _freeBuffer(plaintextBuffer.ref.base, plaintextBuffer.ref.length);
          malloc.free(plaintextBuffer);
          
          // Clean up
          malloc.free(constMessagePtr);
          malloc.free(constSessionStorePtr);
          malloc.free(constIdentityStorePtr);
          malloc.free(sessionStorePtr);
          malloc.free(identityStorePtr);
          malloc.free(constAddressPtr);
          _addressDestroy(addressPtr);
          
          return plaintext;
        } catch (e) {
          // Clean up on error
          malloc.free(plaintextBuffer);
          rethrow;
        } finally {
          malloc.free(constMessagePtr);
          malloc.free(constSessionStorePtr);
          malloc.free(constIdentityStorePtr);
          malloc.free(sessionStorePtr);
          malloc.free(identityStorePtr);
          malloc.free(constAddressPtr);
          _addressDestroy(addressPtr);
        }
      } finally {
        malloc.free(senderIdUtf8);
        malloc.free(addressPtr);
      }
    } finally {
      // Clean up message
      _messageDestroy(messagePtr);
      malloc.free(messagePtr);
      malloc.free(ciphertextData);
      malloc.free(ciphertextBuffer);
    }
  }
  
  /// Perform X3DH Key Exchange
  /// 
  /// Initiates or completes X3DH key exchange to establish a Signal Protocol session.
  /// 
  /// **Parameters:**
  /// - `recipientId`: Recipient's agent ID
  /// - `preKeyBundle`: Recipient's prekey bundle
  /// - `identityKeyPair`: Our identity key pair
  /// - `storeCallbacks`: Store callbacks for session and identity key storage
  /// 
  /// **Returns:**
  /// Initial session state for Double Ratchet
  /// 
  /// **Note:** This function processes the prekey bundle and creates a session.
  /// The session is stored via the store callbacks. To retrieve it, use
  /// SignalSessionManager.loadSession() after this function completes.
  Future<SignalSessionState> performX3DHKeyExchange({
    required String recipientId,
    required SignalPreKeyBundle preKeyBundle,
    required SignalIdentityKeyPair identityKeyPair,
    required SignalFFIStoreCallbacks storeCallbacks,
  }) async {
    if (!_initialized) {
      throw SignalProtocolException('FFI bindings not initialized. Call initialize() first.');
    }
    
    if (!storeCallbacks.isInitialized) {
      throw SignalProtocolException(
        'Store callbacks not initialized. Call SignalFFIStoreCallbacks.initialize() first.',
      );
    }
    
    // Step 1: Deserialize keys from SignalPreKeyBundle to C key objects
    final identityKeyPtr = malloc<SignalMutPointerPublicKey>();
    final signedPrekeyPtr = malloc<SignalMutPointerPublicKey>();
    Pointer<SignalMutPointerPublicKey>? oneTimePrekeyPtr;
    Pointer<SignalMutPointerKyberPublicKey>? kyberPrekeyPtr;
    
    try {
      // Deserialize identity key
      final identityKeyBuffer = malloc<SignalBorrowedBuffer>();
      final identityKeyData = malloc<Uint8>(preKeyBundle.identityKey.length);
      identityKeyData.asTypedList(preKeyBundle.identityKey.length)
          .setAll(0, preKeyBundle.identityKey);
      identityKeyBuffer.ref.base = identityKeyData;
      identityKeyBuffer.ref.length = preKeyBundle.identityKey.length;
      
      final identityError = _publicKeyDeserialize(identityKeyPtr, identityKeyBuffer.ref);
      _checkError(identityError);
      malloc.free(identityKeyData);
      malloc.free(identityKeyBuffer);
      
      // Create const pointer wrapper for identity key
      final constIdentityKeyPtr = malloc<SignalConstPointerPublicKey>();
      constIdentityKeyPtr.ref.raw = identityKeyPtr.ref.raw;
      
      // Deserialize signed prekey
      final signedPrekeyBuffer = malloc<SignalBorrowedBuffer>();
      final signedPrekeyData = malloc<Uint8>(preKeyBundle.signedPreKey.length);
      signedPrekeyData.asTypedList(preKeyBundle.signedPreKey.length)
          .setAll(0, preKeyBundle.signedPreKey);
      signedPrekeyBuffer.ref.base = signedPrekeyData;
      signedPrekeyBuffer.ref.length = preKeyBundle.signedPreKey.length;
      
      final signedPrekeyError = _publicKeyDeserialize(signedPrekeyPtr, signedPrekeyBuffer.ref);
      _checkError(signedPrekeyError);
      malloc.free(signedPrekeyData);
      malloc.free(signedPrekeyBuffer);
      
      // Create const pointer wrapper for signed prekey
      final constSignedPrekeyPtr = malloc<SignalConstPointerPublicKey>();
      constSignedPrekeyPtr.ref.raw = signedPrekeyPtr.ref.raw;
      
      // Deserialize one-time prekey (if provided)
      Pointer<SignalConstPointerPublicKey>? constOneTimePrekeyPtr;
      if (preKeyBundle.oneTimePreKey != null) {
        oneTimePrekeyPtr = malloc<SignalMutPointerPublicKey>();
        final oneTimePrekeyBuffer = malloc<SignalBorrowedBuffer>();
        final oneTimePrekeyData = malloc<Uint8>(preKeyBundle.oneTimePreKey!.length);
        oneTimePrekeyData.asTypedList(preKeyBundle.oneTimePreKey!.length)
            .setAll(0, preKeyBundle.oneTimePreKey!);
        oneTimePrekeyBuffer.ref.base = oneTimePrekeyData;
        oneTimePrekeyBuffer.ref.length = preKeyBundle.oneTimePreKey!.length;
        
        final oneTimePrekeyError = _publicKeyDeserialize(oneTimePrekeyPtr, oneTimePrekeyBuffer.ref);
        _checkError(oneTimePrekeyError);
        malloc.free(oneTimePrekeyData);
        malloc.free(oneTimePrekeyBuffer);
        
        constOneTimePrekeyPtr = malloc<SignalConstPointerPublicKey>();
        constOneTimePrekeyPtr.ref.raw = oneTimePrekeyPtr.ref.raw;
      }
      
      // Deserialize kyber prekey (required for PQXDH)
      if (preKeyBundle.kyberPreKey == null || 
          preKeyBundle.kyberPreKeyId == null ||
          preKeyBundle.kyberPreKeySignature == null) {
        throw SignalProtocolException(
          'Kyber prekey is required for X3DH key exchange (PQXDH). '
          'SignalPreKeyBundle must include kyberPreKey, kyberPreKeyId, and kyberPreKeySignature.',
          code: 'MISSING_KYBER_PREKEY',
        );
      }
      
      kyberPrekeyPtr = malloc<SignalMutPointerKyberPublicKey>();
      final kyberPrekeyBuffer = malloc<SignalBorrowedBuffer>();
      final kyberPrekeyData = malloc<Uint8>(preKeyBundle.kyberPreKey!.length);
      kyberPrekeyData.asTypedList(preKeyBundle.kyberPreKey!.length)
          .setAll(0, preKeyBundle.kyberPreKey!);
      kyberPrekeyBuffer.ref.base = kyberPrekeyData;
      kyberPrekeyBuffer.ref.length = preKeyBundle.kyberPreKey!.length;
      
      final kyberPrekeyError = _kyberPublicKeyDeserialize(kyberPrekeyPtr, kyberPrekeyBuffer.ref);
      _checkError(kyberPrekeyError);
      malloc.free(kyberPrekeyData);
      malloc.free(kyberPrekeyBuffer);
      
      // Create const pointer wrapper for kyber prekey
      final constKyberPrekeyPtr = malloc<SignalConstPointerKyberPublicKey>();
      constKyberPrekeyPtr.ref.raw = kyberPrekeyPtr.ref.raw;
      
      // Step 2: Create C prekey bundle from deserialized keys
      final registrationId = preKeyBundle.registrationId ?? 1; // Default to 1 if not provided
      final deviceId = preKeyBundle.deviceId ?? 1; // Default to 1 if not provided
      
      final bundlePtr = _createPreKeyBundle(
        registrationId: registrationId,
        deviceId: deviceId,
        prekeyId: preKeyBundle.oneTimePreKeyId ?? 0,
        prekey: constOneTimePrekeyPtr,
        signedPrekeyId: preKeyBundle.signedPreKeyId,
        signedPrekey: constSignedPrekeyPtr,
        signedPrekeySignature: preKeyBundle.signature,
        identityKey: constIdentityKeyPtr,
        kyberPrekeyId: preKeyBundle.kyberPreKeyId!,
        kyberPrekey: constKyberPrekeyPtr,
        kyberPrekeySignature: preKeyBundle.kyberPreKeySignature!,
      );
      
      // Create const pointer wrapper for bundle
      final constBundlePtr = malloc<SignalConstPointerPreKeyBundle>();
      constBundlePtr.ref.raw = bundlePtr.ref.raw;
      
      // Step 3: Create ProtocolAddress from recipientId
      final addressPtr = malloc<_SignalMutPointerProtocolAddress>();
      final recipientIdUtf8 = recipientId.toNativeUtf8();
      try {
        final addressError = _addressNew(addressPtr, recipientIdUtf8, deviceId);
        _checkError(addressError);
        
        // Create const pointer wrapper for address
        final constAddressPtr = malloc<_SignalConstPointerProtocolAddress>();
        constAddressPtr.ref.raw = addressPtr.ref.raw;
        
        // Step 4: Get store structs from storeCallbacks
        final sessionStorePtr = storeCallbacks.createSessionStore();
        final identityStorePtr = storeCallbacks.createIdentityKeyStore();
        
        // Create const pointer wrappers for store structs
        final constSessionStorePtr = malloc<_SignalConstPointerFfiSessionStoreStruct>();
        constSessionStorePtr.ref.raw = sessionStorePtr.cast();
        
        final constIdentityStorePtr = malloc<_SignalConstPointerFfiIdentityKeyStoreStruct>();
        constIdentityStorePtr.ref.raw = identityStorePtr.cast();
        
        // Step 5: Call signal_process_prekey_bundle
        // Note: now is in milliseconds since epoch, but libsignal-ffi expects seconds since epoch
        final now = (DateTime.now().millisecondsSinceEpoch / 1000).round();
        final processError = _processPreKeyBundle(
          constBundlePtr,
          constAddressPtr,
          constSessionStorePtr,
          constIdentityStorePtr,
          now,
        );
        _checkError(processError);
        
        // Step 6: Load session from store and return as SignalSessionState
        // The session is stored via callbacks, so we need to load it from the session manager
        // After signal_process_prekey_bundle completes, the session is stored via store callbacks
        // We need to get the sessionManager from storeCallbacks to load the session
        
        // Get session from session manager (stored via callbacks during X3DH)
        // Note: We need to access sessionManager through storeCallbacks
        // The session should be available immediately after signal_process_prekey_bundle
        final session = await storeCallbacks.getSessionAfterX3DH(recipientId);
        
        if (session == null) {
          developer.log(
            'Warning: Session not found after X3DH key exchange. Creating placeholder session state.',
            name: _logName,
          );
          // Return placeholder session state if session not found
          // This should not happen, but handle gracefully
          return SignalSessionState(
            recipientId: recipientId,
            rootKey: null,
            sendingChainKey: null,
            receivingChainKey: null,
            createdAt: DateTime.now(),
          );
        }
        
        developer.log(
          '✅ X3DH key exchange completed, session loaded for recipient: $recipientId',
          name: _logName,
        );
        
        // Clean up
        _addressDestroy(addressPtr);
        malloc.free(constAddressPtr);
        malloc.free(constBundlePtr);
        destroyPreKeyBundle(bundlePtr);
        malloc.free(constSessionStorePtr);
        malloc.free(constIdentityStorePtr);
        malloc.free(sessionStorePtr);
        malloc.free(identityStorePtr);
        
        // Clean up const pointer wrappers
        malloc.free(constIdentityKeyPtr);
        malloc.free(constSignedPrekeyPtr);
        if (constOneTimePrekeyPtr != null) {
          malloc.free(constOneTimePrekeyPtr);
        }
        malloc.free(constKyberPrekeyPtr);
        
        return SignalSessionState(
          recipientId: recipientId,
          createdAt: DateTime.now(),
        );
      } finally {
        malloc.free(recipientIdUtf8);
        malloc.free(addressPtr);
      }
    } finally {
      // Clean up key pointers
      _publicKeyDestroy(identityKeyPtr);
      _publicKeyDestroy(signedPrekeyPtr);
      if (oneTimePrekeyPtr != null) {
        _publicKeyDestroy(oneTimePrekeyPtr);
        malloc.free(oneTimePrekeyPtr);
      }
      if (kyberPrekeyPtr != null) {
        _kyberPublicKeyDestroy(kyberPrekeyPtr);
        malloc.free(kyberPrekeyPtr);
      }
      malloc.free(identityKeyPtr);
      malloc.free(signedPrekeyPtr);
    }
  }
  
  /// Initialize wrapper library
  /// 
  /// Loads the C wrapper library and binds its functions.
  /// This is optional - if the wrapper library is not available, store callbacks
  /// will not work, but other FFI functions will still function.
  Future<void> initializeWrapperLibrary() async {
    if (_wrapperInitialized) {
      developer.log('Wrapper library already initialized', name: _logName);
      return;
    }
    
    try {
      // Use unified library manager for loading
      _wrapperLib = _libManager.getWrapperLibrary();
      
      // Bind registration functions (all take void* for function pointer)
      _registerLoadSessionCallback = _wrapperLib!
          .lookup<NativeFunction<Void Function(Pointer<Void>)>>('spots_register_load_session_callback')
          .asFunction<void Function(Pointer<Void>)>();
      _registerStoreSessionCallback = _wrapperLib!
          .lookup<NativeFunction<Void Function(Pointer<Void>)>>('spots_register_store_session_callback')
          .asFunction<void Function(Pointer<Void>)>();
      _registerGetIdentityKeyPairCallback = _wrapperLib!
          .lookup<NativeFunction<Void Function(Pointer<Void>)>>('spots_register_get_identity_key_pair_callback')
          .asFunction<void Function(Pointer<Void>)>();
      _registerGetLocalRegistrationIdCallback = _wrapperLib!
          .lookup<NativeFunction<Void Function(Pointer<Void>)>>('spots_register_get_local_registration_id_callback')
          .asFunction<void Function(Pointer<Void>)>();
      _registerSaveIdentityKeyCallback = _wrapperLib!
          .lookup<NativeFunction<Void Function(Pointer<Void>)>>('spots_register_save_identity_key_callback')
          .asFunction<void Function(Pointer<Void>)>();
      _registerGetIdentityKeyCallback = _wrapperLib!
          .lookup<NativeFunction<Void Function(Pointer<Void>)>>('spots_register_get_identity_key_callback')
          .asFunction<void Function(Pointer<Void>)>();
      _registerIsTrustedIdentityCallback = _wrapperLib!
          .lookup<NativeFunction<Void Function(Pointer<Void>)>>('spots_register_is_trusted_identity_callback')
          .asFunction<void Function(Pointer<Void>)>();
      
      // Get function pointers for wrapper functions (these are what libsignal-ffi will call)
      // We don't need to call these from Dart - we just need the function pointers
      _loadSessionWrapperPtr = _wrapperLib!
          .lookup<NativeFunction<_NativeLoadSessionWrapper>>('spots_load_session_wrapper');
      _storeSessionWrapperPtr = _wrapperLib!
          .lookup<NativeFunction<_NativeStoreSessionWrapper>>('spots_store_session_wrapper');
      _getIdentityKeyPairWrapperPtr = _wrapperLib!
          .lookup<NativeFunction<_NativeGetIdentityKeyPairWrapper>>('spots_get_identity_key_pair_wrapper');
      _getLocalRegistrationIdWrapperPtr = _wrapperLib!
          .lookup<NativeFunction<_NativeGetLocalRegistrationIdWrapper>>('spots_get_local_registration_id_wrapper');
      _saveIdentityKeyWrapperPtr = _wrapperLib!
          .lookup<NativeFunction<_NativeSaveIdentityKeyWrapper>>('spots_save_identity_key_wrapper');
      _getIdentityKeyWrapperPtr = _wrapperLib!
          .lookup<NativeFunction<_NativeGetIdentityKeyWrapper>>('spots_get_identity_key_wrapper');
      _isTrustedIdentityWrapperPtr = _wrapperLib!
          .lookup<NativeFunction<_NativeIsTrustedIdentityWrapper>>('spots_is_trusted_identity_wrapper');
      
      _wrapperInitialized = true;
      developer.log('✅ Wrapper library initialized', name: _logName);
    } catch (e, stackTrace) {
      developer.log(
        'Error initializing wrapper library: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      throw SignalProtocolException(
        'Failed to initialize wrapper library: $e',
        originalError: e,
      );
    }
  }
  
  /// Check if wrapper library is initialized
  bool get isWrapperInitialized => _wrapperInitialized;
  
  /// Register a callback for load_session
  /// 
  /// The callback should be created using Pointer.fromFunction<_SimpleCallback3>()
  void registerLoadSessionCallback(Pointer<NativeFunction<_SimpleCallback3>> callback) {
    if (!_wrapperInitialized) {
      throw SignalProtocolException('Wrapper library not initialized. Call initializeWrapperLibrary() first.');
    }
    _registerLoadSessionCallback(callback.cast<Void>());
  }
  
  /// Register a callback for store_session
  void registerStoreSessionCallback(Pointer<NativeFunction<_SimpleCallback3>> callback) {
    if (!_wrapperInitialized) {
      throw SignalProtocolException('Wrapper library not initialized. Call initializeWrapperLibrary() first.');
    }
    _registerStoreSessionCallback(callback.cast<Void>());
  }
  
  /// Register a callback for get_identity_key_pair
  void registerGetIdentityKeyPairCallback(Pointer<NativeFunction<_SimpleCallback2>> callback) {
    if (!_wrapperInitialized) {
      throw SignalProtocolException('Wrapper library not initialized. Call initializeWrapperLibrary() first.');
    }
    _registerGetIdentityKeyPairCallback(callback.cast<Void>());
  }
  
  /// Register a callback for get_local_registration_id
  void registerGetLocalRegistrationIdCallback(Pointer<NativeFunction<_SimpleCallback2>> callback) {
    if (!_wrapperInitialized) {
      throw SignalProtocolException('Wrapper library not initialized. Call initializeWrapperLibrary() first.');
    }
    _registerGetLocalRegistrationIdCallback(callback.cast<Void>());
  }
  
  /// Register a callback for save_identity_key
  void registerSaveIdentityKeyCallback(Pointer<NativeFunction<_SimpleCallback3>> callback) {
    if (!_wrapperInitialized) {
      throw SignalProtocolException('Wrapper library not initialized. Call initializeWrapperLibrary() first.');
    }
    _registerSaveIdentityKeyCallback(callback.cast<Void>());
  }
  
  /// Register a callback for get_identity_key
  void registerGetIdentityKeyCallback(Pointer<NativeFunction<_SimpleCallback3>> callback) {
    if (!_wrapperInitialized) {
      throw SignalProtocolException('Wrapper library not initialized. Call initializeWrapperLibrary() first.');
    }
    _registerGetIdentityKeyCallback(callback.cast<Void>());
  }
  
  /// Register a callback for is_trusted_identity
  void registerIsTrustedIdentityCallback(Pointer<NativeFunction<_SimpleCallback4>> callback) {
    if (!_wrapperInitialized) {
      throw SignalProtocolException('Wrapper library not initialized. Call initializeWrapperLibrary() first.');
    }
    _registerIsTrustedIdentityCallback(callback.cast<Void>());
  }
  
  // Cached function pointers (looked up once during initialization)
  late final Pointer<NativeFunction<_NativeLoadSessionWrapper>> _loadSessionWrapperPtr;
  late final Pointer<NativeFunction<_NativeStoreSessionWrapper>> _storeSessionWrapperPtr;
  late final Pointer<NativeFunction<_NativeGetIdentityKeyPairWrapper>> _getIdentityKeyPairWrapperPtr;
  late final Pointer<NativeFunction<_NativeGetLocalRegistrationIdWrapper>> _getLocalRegistrationIdWrapperPtr;
  late final Pointer<NativeFunction<_NativeSaveIdentityKeyWrapper>> _saveIdentityKeyWrapperPtr;
  late final Pointer<NativeFunction<_NativeGetIdentityKeyWrapper>> _getIdentityKeyWrapperPtr;
  late final Pointer<NativeFunction<_NativeIsTrustedIdentityWrapper>> _isTrustedIdentityWrapperPtr;
  
  /// Get wrapper function pointer for load_session (for use in store structs)
  /// 
  /// Returns a function pointer that can be assigned to store struct fields.
  /// The function pointer type matches libsignal-ffi's expected callback signature.
  /// 
  /// Note: The return type uses dynamic to allow assignment to store struct fields
  /// which may have slightly different but compatible typedefs.
  dynamic get loadSessionWrapperPtr {
    if (!_wrapperInitialized) {
      throw SignalProtocolException('Wrapper library not initialized. Call initializeWrapperLibrary() first.');
    }
    return _loadSessionWrapperPtr;
  }
  
  /// Get wrapper function pointer for store_session
  dynamic get storeSessionWrapperPtr {
    if (!_wrapperInitialized) {
      throw SignalProtocolException('Wrapper library not initialized. Call initializeWrapperLibrary() first.');
    }
    return _storeSessionWrapperPtr;
  }
  
  /// Get wrapper function pointer for get_identity_key_pair
  dynamic get getIdentityKeyPairWrapperPtr {
    if (!_wrapperInitialized) {
      throw SignalProtocolException('Wrapper library not initialized. Call initializeWrapperLibrary() first.');
    }
    return _getIdentityKeyPairWrapperPtr;
  }
  
  /// Get wrapper function pointer for get_local_registration_id
  dynamic get getLocalRegistrationIdWrapperPtr {
    if (!_wrapperInitialized) {
      throw SignalProtocolException('Wrapper library not initialized. Call initializeWrapperLibrary() first.');
    }
    return _getLocalRegistrationIdWrapperPtr;
  }
  
  /// Get wrapper function pointer for save_identity_key
  dynamic get saveIdentityKeyWrapperPtr {
    if (!_wrapperInitialized) {
      throw SignalProtocolException('Wrapper library not initialized. Call initializeWrapperLibrary() first.');
    }
    return _saveIdentityKeyWrapperPtr;
  }
  
  /// Get wrapper function pointer for get_identity_key
  dynamic get getIdentityKeyWrapperPtr {
    if (!_wrapperInitialized) {
      throw SignalProtocolException('Wrapper library not initialized. Call initializeWrapperLibrary() first.');
    }
    return _getIdentityKeyWrapperPtr;
  }
  
  /// Get wrapper function pointer for is_trusted_identity
  dynamic get isTrustedIdentityWrapperPtr {
    if (!_wrapperInitialized) {
      throw SignalProtocolException('Wrapper library not initialized. Call initializeWrapperLibrary() first.');
    }
    return _isTrustedIdentityWrapperPtr;
  }
  
  /// Dispose resources
  /// 
  /// **Production Safety:**
  /// - This method should never be called in production
  /// - In production, the library lives for the app's lifetime
  /// - Library is unloaded by OS on app termination
  /// 
  /// **Test Usage:**
  /// - May be called in test `tearDown()` to clean up
  /// - SIGABRT during finalization is expected (OS-level cleanup)
  /// - Crash occurs after all Dart code completes successfully
  void dispose() {
    // PRODUCTION SAFETY: In production, libraries should never be disposed
    // They live for the app's lifetime. Only dispose in tests.
    // We check if we're in a test environment by checking if dispose is being
    // called explicitly (production code never calls dispose)
    
    // Note: DynamicLibrary doesn't need explicit cleanup in Dart FFI
    // The library will be unloaded when the DynamicLibrary object is garbage collected
    // Static references (_staticLib, _staticWrapperLib) prevent GC during test finalization
    
    // Log disposal for debugging (helps identify if called in production)
    developer.log(
      'Signal FFI bindings dispose() called',
      name: _logName,
    );
    
    _lib = null;
    _wrapperLib = null;
    _initialized = false;
    _wrapperInitialized = false;
  }
}
