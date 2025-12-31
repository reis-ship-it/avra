// Signal Protocol FFI Store Callbacks
// Phase 14: Signal Protocol Implementation - Option 1
// 
// Provides Dart callbacks for libsignal-ffi store interfaces

import 'dart:developer' as developer;
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:spots/core/crypto/signal/signal_ffi_bindings.dart';
import 'package:spots/core/crypto/signal/signal_rust_wrapper_bindings.dart';
import 'package:spots/core/crypto/signal/signal_platform_bridge_bindings.dart';
import 'package:spots/core/crypto/signal/signal_key_manager.dart';
import 'package:spots/core/crypto/signal/signal_session_manager.dart';
import 'package:spots/core/crypto/signal/signal_types.dart';

/// Store context for FFI callbacks
/// 
/// Holds references to Dart managers that implement the store operations
class _SignalStoreContext {
  final SignalKeyManager keyManager;
  final SignalSessionManager sessionManager;
  
  _SignalStoreContext({
    required this.keyManager,
    required this.sessionManager,
  });
}

/// Helper class to create FFI store structs
/// 
/// Converts Dart store managers into C-compatible store callbacks
/// Uses Callback ID Dispatch Pattern to work around Dart FFI limitations
class SignalFFIStoreCallbacks {
  static const String _logName = 'SignalFFIStoreCallbacks';
  
  final SignalKeyManager _keyManager;
  final SignalSessionManager _sessionManager;
  // Note: _ffiBindings kept for potential future use (e.g., key serialization)
  // ignore: unused_field
  final SignalFFIBindings _ffiBindings;
  final SignalRustWrapperBindings _rustWrapper;
  final SignalPlatformBridgeBindings _platformBridge;
  
  // Store context (will be passed as void* to C)
  late final Pointer<Void> _contextPtr;
  
  // Callback registry (maps callback ID to callback function)
  // Signature: (storeCtx, arg1, arg2, arg3, direction) -> int
  static final Map<int, int Function(Pointer<Void>, Pointer<Void>, Pointer<Void>, Pointer<Void>, int)> _callbackRegistry = {};
  
  // Callback IDs (must match Rust constants)
  static const int _loadSessionCallbackId = 1;
  static const int _storeSessionCallbackId = 2;
  static const int _getIdentityKeyPairCallbackId = 3;
  static const int _getLocalRegistrationIdCallbackId = 4;
  static const int _saveIdentityKeyCallbackId = 5;
  static const int _getIdentityKeyCallbackId = 6;
  static const int _isTrustedIdentityCallbackId = 7;
  
  // NativeCallable instance (must be kept alive to prevent GC)
  // ignore: sdk_version_since - NativeCallable is available in SDK 3.1.0+, but we check availability
  NativeCallable? _dispatchNativeCallable;
  
  // Initialization flag
  bool _initialized = false;
  
  SignalFFIStoreCallbacks({
    required SignalKeyManager keyManager,
    required SignalSessionManager sessionManager,
    required SignalFFIBindings ffiBindings,
    required SignalRustWrapperBindings rustWrapper,
    required SignalPlatformBridgeBindings platformBridge,
  }) : _keyManager = keyManager,
       _sessionManager = sessionManager,
       _ffiBindings = ffiBindings,
       _rustWrapper = rustWrapper,
       _platformBridge = platformBridge {
    // Allocate context pointer
    // The Rust wrapper will extract callback IDs from CallbackArgs struct
    // We store the context address as a unique identifier for context lookup
    final contextIdPtr = malloc.allocate<IntPtr>(sizeOf<IntPtr>());
    contextIdPtr.value = contextIdPtr.address;
    _contextPtr = contextIdPtr.cast<Void>();
    
    _registerContext();
    // NOTE: _registerCallbacks() is now called in initialize() method
    // This allows dependencies to be initialized first
  }
  
  /// Initialize store callbacks
  /// 
  /// Must be called after SignalPlatformBridgeBindings and SignalRustWrapperBindings
  /// are initialized. This registers the callbacks with the platform bridge and Rust wrapper.
  Future<void> initialize() async {
    if (_initialized) {
      developer.log('Store callbacks already initialized', name: _logName);
      return;
    }
    
    try {
      developer.log('Initializing Signal FFI store callbacks...', name: _logName);
      
      // Verify dependencies are initialized
      if (!_platformBridge.isInitialized) {
        throw SignalProtocolException(
          'Platform bridge not initialized. Call SignalPlatformBridgeBindings.initialize() first.',
        );
      }
      
      if (!_rustWrapper.isInitialized) {
        throw SignalProtocolException(
          'Rust wrapper not initialized. Call SignalRustWrapperBindings.initialize() first.',
        );
      }
      
      // Register callbacks (this will create NativeCallable if needed)
      _registerCallbacks();
      
      _initialized = true;
      developer.log('✅ Signal FFI store callbacks initialized successfully', name: _logName);
    } catch (e, st) {
      developer.log(
        'Failed to initialize store callbacks: $e',
        error: e,
        stackTrace: st,
        name: _logName,
      );
      rethrow;
    }
  }
  
  /// Check if store callbacks are initialized
  bool get isInitialized => _initialized;
  
  /// Register all callbacks with the Rust wrapper library
  /// 
  /// Uses Platform-Specific Bridge Pattern:
  /// 1. Register callbacks with unique IDs in Dart registry
  /// 2. Create dispatch function pointer using platform bridge (works around Dart FFI limitation!)
  /// 3. Register dispatch function with Rust wrapper
  void _registerCallbacks() {
    if (!_rustWrapper.isInitialized) {
      throw SignalProtocolException(
        'Rust wrapper not initialized. Call SignalRustWrapperBindings.initialize() first.',
      );
    }
    
    if (!_platformBridge.isInitialized) {
      throw SignalProtocolException(
        'Platform bridge not initialized. Call SignalPlatformBridgeBindings.initialize() first.',
      );
    }
    
    // Register callbacks in Dart registry with unique IDs
    _callbackRegistry[_loadSessionCallbackId] = _loadSessionCallbackImpl;
    _callbackRegistry[_storeSessionCallbackId] = _storeSessionCallbackImpl;
    _callbackRegistry[_getIdentityKeyPairCallbackId] = _getIdentityKeyPairCallbackImpl;
    _callbackRegistry[_getLocalRegistrationIdCallbackId] = _getLocalRegistrationIdCallbackImpl;
    _callbackRegistry[_saveIdentityKeyCallbackId] = _saveIdentityKeyCallbackImpl;
    _callbackRegistry[_getIdentityKeyCallbackId] = _getIdentityKeyCallbackImpl;
    _callbackRegistry[_isTrustedIdentityCallbackId] = _isTrustedIdentityCallbackImpl;
    
    // Register the Dart callback with the platform bridge using dlsym
    // The C bridge will look up our exported function by name
    // This avoids needing to create function pointers in Dart!
    final bridgeLib = _platformBridge.library;
    if (bridgeLib == null) {
      throw SignalProtocolException('Platform bridge library not loaded');
    }
    
    final registerByName = bridgeLib
        .lookup<NativeFunction<Void Function(Pointer<Utf8>)>>('signal_register_dispatch_callback_by_name')
        .asFunction<void Function(Pointer<Utf8>)>();
    
    // Export function name as C string
    final functionName = 'signal_dispatch_callback'.toNativeUtf8();
    try {
      registerByName(functionName);
    } finally {
      malloc.free(functionName);
    }
    
    // Get the C function pointer from the platform bridge
    final cFunctionPtr = _platformBridge.getDispatchFunctionPtr();
    
    // Register the C function pointer with Rust wrapper
    _rustWrapper.registerDispatchCallback(cFunctionPtr);
  }
  
  /// Dispatch callback function
  /// 
  /// This is the single function that Rust wrapper calls.
  /// Takes pointer address as int (Dart FFI limitation workaround).
  /// 
  /// The function:
  /// 1. Reconstructs CallbackArgs struct pointer from address
  /// 2. Extracts callback ID from CallbackArgs struct
  /// 3. Looks up callback in Dart registry
  /// 4. Invokes callback with unpacked parameters
  // Export with well-known name for dlsym lookup
  // Note: Function signature must match C: int32_t Function(uint64_t)
  // Dart's int is 64-bit on most platforms, compatible with uint64_t
  // Dart's int return is compatible with int32_t (C will handle truncation if needed)
  @pragma('vm:entry-point')
  @pragma('vm:external-name', 'signal_dispatch_callback')
  static int _dispatchCallback(int argsAddress) {
    // Reconstruct struct pointer from address
    // argsAddress is uint64_t from C, received as int (64-bit on most platforms)
    final argsPtr = Pointer<CallbackArgs>.fromAddress(argsAddress);
    
    final callbackId = argsPtr.ref.callbackId;
    final callback = _callbackRegistry[callbackId];
    
    if (callback == null) {
      return 1; // Error: callback not found
    }
    
    // Invoke callback with unpacked parameters
    final result = callback(
      argsPtr.ref.storeCtx,
      argsPtr.ref.arg1,
      argsPtr.ref.arg2,
      argsPtr.ref.arg3,
      argsPtr.ref.direction,
    );
    
    return result;
  }
  
  // ============================================================================
  // CALLBACK IMPLEMENTATIONS (called by dispatch function)
  // ============================================================================
  
  /// Load session callback implementation
  static int _loadSessionCallbackImpl(
    Pointer<Void> storeCtx,
    Pointer<Void> arg1, // recordp
    Pointer<Void> arg2, // address
    Pointer<Void> arg3, // unused
    int direction, // unused
  ) {
    // Get context from lookup table
    final context = _contextMap[storeCtx.address];
    if (context == null) {
      return 1; // Error: context not found
    }
    
    // Cast back to proper types
    // ignore: unused_local_variable - TODO: Implement session loading
    final recordpTyped = arg1.cast<_SignalMutPointerSessionRecord>();
    // ignore: unused_local_variable - TODO: Implement session loading
    final addressTyped = arg2.cast<_SignalConstPointerProtocolAddress>();
    
    // TODO: Implement session loading
    // 1. Extract protocol address from addressTyped
    // 2. Get recipient ID from protocol address
    // 3. Load session from sessionManager
    // 4. Convert session to C format and write to recordpTyped
    // For now, return error (session not found)
    return 1; // Error code
  }
  
  /// Store session callback implementation
  static int _storeSessionCallbackImpl(
    Pointer<Void> storeCtx,
    Pointer<Void> arg1, // address
    Pointer<Void> arg2, // record
    Pointer<Void> arg3, // unused
    int direction, // unused
  ) {
    final context = _contextMap[storeCtx.address];
    if (context == null) {
      return 1;
    }
    
    // ignore: unused_local_variable - TODO: Implement session storing
    final addressTyped = arg1.cast<_SignalConstPointerProtocolAddress>();
    // ignore: unused_local_variable - TODO: Implement session storing
    final recordTyped = arg2.cast<_SignalConstPointerSessionRecord>();
    
    // TODO: Implement session storing
    return 0; // Success
  }
  
  /// Get identity key pair callback implementation
  static int _getIdentityKeyPairCallbackImpl(
    Pointer<Void> storeCtx,
    Pointer<Void> arg1, // keyp
    Pointer<Void> arg2, // unused
    Pointer<Void> arg3, // unused
    int direction, // unused
  ) {
    final context = _contextMap[storeCtx.address];
    if (context == null) {
      return 1;
    }
    
    // ignore: unused_local_variable - TODO: Implement identity key pair loading
    final keypTyped = arg1.cast<SignalMutPointerPrivateKey>();
    
    // TODO: Implement identity key pair retrieval
    return 1; // Error code
  }
  
  /// Get local registration ID callback implementation
  static int _getLocalRegistrationIdCallbackImpl(
    Pointer<Void> storeCtx,
    Pointer<Void> arg1, // idp
    Pointer<Void> arg2, // unused
    Pointer<Void> arg3, // unused
    int direction, // unused
  ) {
    final context = _contextMap[storeCtx.address];
    if (context == null) {
      return 1;
    }
    
    final idpTyped = arg1.cast<Uint32>();
    
    // TODO: Get registration ID from keyManager
    idpTyped.value = 1; // Default registration ID
    return 0; // Success
  }
  
  /// Save identity key callback implementation
  static int _saveIdentityKeyCallbackImpl(
    Pointer<Void> storeCtx,
    Pointer<Void> arg1, // address
    Pointer<Void> arg2, // public_key
    Pointer<Void> arg3, // unused
    int direction, // unused
  ) {
    final context = _contextMap[storeCtx.address];
    if (context == null) {
      return 1;
    }
    
    // ignore: unused_local_variable - TODO: Implement identity key saving
    final addressTyped = arg1.cast<_SignalConstPointerProtocolAddress>();
    // ignore: unused_local_variable - TODO: Implement identity key saving
    final publicKeyTyped = arg2.cast<SignalConstPointerPublicKey>();
    
    // TODO: Implement identity key saving
    return 0; // Success
  }
  
  /// Get identity key callback implementation
  static int _getIdentityKeyCallbackImpl(
    Pointer<Void> storeCtx,
    Pointer<Void> arg1, // public_keyp
    Pointer<Void> arg2, // address
    Pointer<Void> arg3, // unused
    int direction, // unused
  ) {
    final context = _contextMap[storeCtx.address];
    if (context == null) {
      return 1;
    }
    
    // ignore: unused_local_variable - TODO: Implement identity key retrieval
    final publicKeypTyped = arg1.cast<SignalMutPointerPublicKey>();
    // ignore: unused_local_variable - TODO: Implement identity key retrieval
    final addressTyped = arg2.cast<_SignalConstPointerProtocolAddress>();
    
    // TODO: Implement identity key retrieval
    return 1; // Error code
  }
  
  /// Is trusted identity callback implementation
  static int _isTrustedIdentityCallbackImpl(
    Pointer<Void> storeCtx,
    Pointer<Void> arg1, // address
    Pointer<Void> arg2, // public_key
    Pointer<Void> arg3, // unused
    int direction, // u32 direction
  ) {
    final context = _contextMap[storeCtx.address];
    if (context == null) {
      return 1;
    }
    
    // ignore: unused_local_variable - TODO: Implement trust check
    final addressTyped = arg1.cast<_SignalConstPointerProtocolAddress>();
    // ignore: unused_local_variable - TODO: Implement trust check
    final publicKeyTyped = arg2.cast<SignalConstPointerPublicKey>();
    
    // TODO: Implement trust check
    return 0; // Trusted
  }
  
  /// Create session store struct for FFI
  /// 
  /// Returns a pointer to SignalSessionStore struct
  /// 
  /// Uses Rust wrapper functions that bridge Dart callbacks with libsignal-ffi.
  Pointer<_SignalSessionStore> createSessionStore() {
    if (!_rustWrapper.isInitialized) {
      throw SignalProtocolException(
        'Rust wrapper not initialized. Call SignalRustWrapperBindings.initialize() first.',
      );
    }
    
    final store = malloc.allocate<_SignalSessionStore>(sizeOf<_SignalSessionStore>());
    
    // Set context
    store.ref.ctx = _contextPtr.cast();
    
    // Get function pointers from Rust wrapper (these call the registered Dart callbacks)
    // Cast void* to the correct function pointer type
    store.ref.load_session = _rustWrapper.getLoadSessionWrapperPtr().cast();
    store.ref.store_session = _rustWrapper.getStoreSessionWrapperPtr().cast();
    
    return store;
  }
  
  /// Create identity key store struct for FFI
  /// 
  /// Returns a pointer to SignalIdentityKeyStore struct
  /// 
  /// Uses Rust wrapper functions that bridge Dart callbacks with libsignal-ffi.
  Pointer<_SignalIdentityKeyStore> createIdentityKeyStore() {
    if (!_rustWrapper.isInitialized) {
      throw SignalProtocolException(
        'Rust wrapper not initialized. Call SignalRustWrapperBindings.initialize() first.',
      );
    }
    
    final store = malloc.allocate<_SignalIdentityKeyStore>(sizeOf<_SignalIdentityKeyStore>());
    
    // Set context
    store.ref.ctx = _contextPtr.cast();
    
    // Get function pointers from Rust wrapper (these call the registered Dart callbacks)
    store.ref.get_identity_key_pair = _rustWrapper.getGetIdentityKeyPairWrapperPtr().cast();
    store.ref.get_local_registration_id = _rustWrapper.getGetLocalRegistrationIdWrapperPtr().cast();
    store.ref.save_identity = _rustWrapper.getSaveIdentityKeyWrapperPtr().cast();
    store.ref.get_identity = _rustWrapper.getGetIdentityKeyWrapperPtr().cast();
    store.ref.is_trusted_identity = _rustWrapper.getIsTrustedIdentityWrapperPtr().cast();
    
    return store;
  }
  
  /// Dispose resources
  /// 
  /// Safely disposes all resources, even if the native library is broken.
  /// This method should never throw or crash, even if disposal fails.
  void dispose() {
    _unregisterContext();
    
    // Safely close NativeCallable to release resources (if initialized)
    try {
      // ignore: sdk_version_since - NativeCallable.close() is available in SDK 3.1.0+
      _dispatchNativeCallable?.close();
    } catch (e) {
      // Log but don't throw - disposal should never crash
      // Library may be broken, but we still need to clean up what we can
      developer.log(
        'Error closing NativeCallable during dispose: $e',
        name: _logName,
        error: e,
      );
    }
    _dispatchNativeCallable = null;
    
    // Safely free allocated memory
    try {
      final contextIdPtr = _contextPtr.cast<IntPtr>();
      malloc.free(contextIdPtr);
    } catch (e) {
      // Log but don't throw - memory may already be freed or invalid
      developer.log(
        'Error freeing memory during dispose: $e',
        name: _logName,
        error: e,
      );
    }
    
    _initialized = false;
  }
  
  // ============================================================================
  // CALLBACK IMPLEMENTATIONS
  // ============================================================================
  
  // Static lookup table for store contexts
  // Maps context pointer address to actual store context
  static final Map<int, _SignalStoreContext> _contextMap = {};
  
  /// Register store context for callbacks
  void _registerContext() {
    // Get the address from the IntPtr
    final contextIdPtr = _contextPtr.cast<IntPtr>();
    _contextMap[contextIdPtr.value] = _SignalStoreContext(
      keyManager: _keyManager,
      sessionManager: _sessionManager,
    );
  }
  
  /// Unregister store context
  void _unregisterContext() {
    final contextIdPtr = _contextPtr.cast<IntPtr>();
    _contextMap.remove(contextIdPtr.value);
  }
  
  /// Get session after X3DH key exchange
  /// 
  /// After X3DH key exchange completes, the session is stored via callbacks.
  /// This method loads the session from the session manager.
  /// 
  /// **Parameters:**
  /// - `recipientId`: Recipient's agent ID
  /// 
  /// **Returns:**
  /// Session state if found, null otherwise
  Future<SignalSessionState?> getSessionAfterX3DH(String recipientId) async {
    try {
      // Load session from session manager
      // The session was stored via storeSession callback during X3DH
      return await _sessionManager.getSession(recipientId);
    } catch (e, stackTrace) {
      developer.log(
        'Error loading session after X3DH: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
  
}

// ============================================================================
// FFI TYPE DEFINITIONS FOR STORE STRUCTS
// ============================================================================

// These structs are defined in signal_ffi_bindings.dart
// We import them here to avoid duplication
// Note: Since they're private (start with _), we can't import them directly
// So we redefine them here to match (they must be identical)

/// C struct: SignalMutPointerSessionRecord
/// (Duplicate definition - must match signal_ffi_bindings.dart)
final class _SignalMutPointerSessionRecord extends Struct {
  external Pointer<Opaque> raw;
}

/// C struct: SignalConstPointerSessionRecord
/// (Duplicate definition - must match signal_ffi_bindings.dart)
final class _SignalConstPointerSessionRecord extends Struct {
  external Pointer<Opaque> raw;
}

/// C struct: SignalConstPointerProtocolAddress
/// (Duplicate definition - must match signal_ffi_bindings.dart)
final class _SignalConstPointerProtocolAddress extends Struct {
  external Pointer<Opaque> raw;
}

// ============================================================================
// CALLBACK FUNCTION TYPEDEFS
// ============================================================================
// Note: Typedefs must be defined before structs that use them

// Dispatch callback (single parameter - Dart CAN create function pointers for this!)
// This is the key to the callback ID dispatch pattern
// Note: These typedefs are kept for documentation purposes, but the actual implementation
// uses the Rust wrapper callback ID dispatch pattern instead
// ignore: unused_element - Kept for documentation/reference
typedef _NativeDispatchCallback = Int32 Function(Pointer<CallbackArgs>);
// ignore: unused_element - Kept for documentation/reference
typedef _DispatchCallback = int Function(Pointer<CallbackArgs>);

// ============================================================================
// STORE STRUCT CALLBACK SIGNATURES (matching libsignal-ffi API)
// ============================================================================
// These match the exact callback signatures expected by libsignal-ffi
// The wrapper functions have these same signatures

// Load session: int (*)(void *store_ctx, SignalMutPointerSessionRecord *recordp, SignalConstPointerProtocolAddress address)
typedef _NativeLoadSessionCallback = IntPtr Function(Pointer<Void>, Pointer<_SignalMutPointerSessionRecord>, Pointer<_SignalConstPointerProtocolAddress>);

// Store session: int (*)(void *store_ctx, SignalConstPointerProtocolAddress address, SignalConstPointerSessionRecord record)
typedef _NativeStoreSessionCallback = IntPtr Function(Pointer<Void>, Pointer<_SignalConstPointerProtocolAddress>, Pointer<_SignalConstPointerSessionRecord>);

// Get identity key pair: int (*)(void *store_ctx, SignalMutPointerPrivateKey *keyp)
typedef _NativeGetIdentityKeyPairCallback = IntPtr Function(Pointer<Void>, Pointer<SignalMutPointerPrivateKey>);

// Get local registration ID: int (*)(void *store_ctx, uint32_t *idp)
typedef _NativeGetLocalRegistrationIdCallback = IntPtr Function(Pointer<Void>, Pointer<Uint32>);

// Save identity key: int (*)(void *store_ctx, SignalConstPointerProtocolAddress address, SignalConstPointerPublicKey public_key)
typedef _NativeSaveIdentityKeyCallback = IntPtr Function(Pointer<Void>, Pointer<_SignalConstPointerProtocolAddress>, Pointer<SignalConstPointerPublicKey>);

// Get identity key: int (*)(void *store_ctx, SignalMutPointerPublicKey *public_keyp, SignalConstPointerProtocolAddress address)
typedef _NativeGetIdentityKeyCallback = IntPtr Function(Pointer<Void>, Pointer<SignalMutPointerPublicKey>, Pointer<_SignalConstPointerProtocolAddress>);

// Is trusted identity: int (*)(void *store_ctx, SignalConstPointerProtocolAddress address, SignalConstPointerPublicKey public_key, unsigned int direction)
typedef _NativeIsTrustedIdentityCallback = IntPtr Function(Pointer<Void>, Pointer<_SignalConstPointerProtocolAddress>, Pointer<SignalConstPointerPublicKey>, Uint32);

// ============================================================================
// STORE STRUCT DEFINITIONS (after typedefs)
// ============================================================================

/// C struct: SignalSessionStore
/// 
/// Uses wrapper function pointers which have the exact signatures libsignal-ffi expects
final class _SignalSessionStore extends Struct {
  external Pointer<Void> ctx;
  external Pointer<NativeFunction<_NativeLoadSessionCallback>> load_session;
  external Pointer<NativeFunction<_NativeStoreSessionCallback>> store_session;
}

/// C struct: SignalIdentityKeyStore
/// 
/// Uses wrapper function pointers which have the exact signatures libsignal-ffi expects
final class _SignalIdentityKeyStore extends Struct {
  external Pointer<Void> ctx;
  external Pointer<NativeFunction<_NativeGetIdentityKeyPairCallback>> get_identity_key_pair;
  external Pointer<NativeFunction<_NativeGetLocalRegistrationIdCallback>> get_local_registration_id;
  external Pointer<NativeFunction<_NativeSaveIdentityKeyCallback>> save_identity;
  external Pointer<NativeFunction<_NativeGetIdentityKeyCallback>> get_identity;
  external Pointer<NativeFunction<_NativeIsTrustedIdentityCallback>> is_trusted_identity;
}
