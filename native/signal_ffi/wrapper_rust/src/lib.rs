// Signal Protocol FFI Wrapper (Rust)
// Phase 14: Signal Protocol Implementation - Option 1
//
// This Rust wrapper bridges Dart FFI callbacks with libsignal-ffi's store interface.
// Uses Callback ID Dispatch Pattern to work around Dart FFI limitations.
//
// Architecture:
//   Dart → C FFI → Rust Wrapper (callback ID dispatch) → libsignal-ffi (C library) → Signal Protocol
//
// The Rust wrapper uses callback IDs instead of function pointers:
// 1. Dart registers callbacks with unique IDs (no function pointers needed!)
// 2. Rust wrapper stores callback IDs in a registry
// 3. Single dispatch function (Dart CAN create this - it has only one parameter!)
// 4. Dispatch function receives callback ID + parameters, looks up callback, and invokes it

use std::ffi::{c_int, c_void};
use std::sync::Mutex;

// ============================================================================
// CALLBACK ID DISPATCH SYSTEM
// ============================================================================
// Uses single-parameter struct pattern to work around Dart FFI limitations

// Callback ID type
type CallbackId = u64;

// Callback ID constants (must match Dart callback IDs)
const CALLBACK_ID_LOAD_SESSION: CallbackId = 1;
const CALLBACK_ID_STORE_SESSION: CallbackId = 2;
const CALLBACK_ID_GET_IDENTITY_KEY_PAIR: CallbackId = 3;
const CALLBACK_ID_GET_LOCAL_REGISTRATION_ID: CallbackId = 4;
const CALLBACK_ID_SAVE_IDENTITY_KEY: CallbackId = 5;
const CALLBACK_ID_GET_IDENTITY_KEY: CallbackId = 6;
const CALLBACK_ID_IS_TRUSTED_IDENTITY: CallbackId = 7;

// Callback args struct (single parameter for dispatch function)
#[repr(C)]
pub struct CallbackArgs {
    pub callback_id: u64,
    pub store_ctx: *mut c_void,
    pub arg1: *mut c_void,
    pub arg2: *mut c_void,
    pub arg3: *mut c_void,
    pub direction: u32,
}

// Dispatch function type
// NOTE: Dart FFI cannot create function pointers for struct pointers!
// We'll use int Function(int) where int is the pointer address
type DispatchCallback = extern "C" fn(u64) -> c_int; // u64 = pointer address

struct CallbackRegistry {
    dispatch: Option<DispatchCallback>,
}

// Global callback registry (thread-safe)
static CALLBACK_REGISTRY: Mutex<CallbackRegistry> = Mutex::new(CallbackRegistry {
    dispatch: None,
});

// ============================================================================
// CALLBACK REGISTRATION FUNCTIONS (CALLED FROM DART)
// ============================================================================
// Dart registers a single dispatch function that handles all callbacks.

#[no_mangle]
pub extern "C" fn spots_rust_register_dispatch_callback(callback: *mut c_void) {
    let callback_fn: DispatchCallback = unsafe { std::mem::transmute(callback) };
    let mut registry = CALLBACK_REGISTRY.lock().unwrap();
    registry.dispatch = Some(callback_fn);
}

// ============================================================================
// FORWARD DECLARATIONS FOR LIBSIGNAL-FFI TYPES
// ============================================================================

#[repr(C)]
pub struct SignalSessionRecord {
    _private: [u8; 0],
}

#[repr(C)]
pub struct SignalProtocolAddress {
    _private: [u8; 0],
}

#[repr(C)]
pub struct SignalPrivateKey {
    _private: [u8; 0],
}

#[repr(C)]
pub struct SignalPublicKey {
    _private: [u8; 0],
}

// Wrapper structs matching libsignal-ffi
#[repr(C)]
pub struct SignalMutPointerSessionRecord {
    pub raw: *mut SignalSessionRecord,
}

#[repr(C)]
pub struct SignalConstPointerSessionRecord {
    pub raw: *const SignalSessionRecord,
}

#[repr(C)]
pub struct SignalConstPointerProtocolAddress {
    pub raw: *const SignalProtocolAddress,
}

#[repr(C)]
pub struct SignalMutPointerPrivateKey {
    pub raw: *mut SignalPrivateKey,
}

#[repr(C)]
pub struct SignalConstPointerPublicKey {
    pub raw: *const SignalPublicKey,
}

#[repr(C)]
pub struct SignalMutPointerPublicKey {
    pub raw: *mut SignalPublicKey,
}

// ============================================================================
// WRAPPER FUNCTIONS (CALLED BY LIBSIGNAL-FFI)
// ============================================================================
// These functions match libsignal-ffi's expected callback signatures.
// They retrieve the Dart callback from the registry and invoke it with the callback ID.

// Load session wrapper
#[no_mangle]
pub extern "C" fn spots_rust_load_session_wrapper(
    store_ctx: *mut c_void,
    recordp: *mut SignalMutPointerSessionRecord,
    address: *const SignalConstPointerProtocolAddress,
) -> c_int {
    let registry = CALLBACK_REGISTRY.lock().unwrap();
    if let Some(dispatch) = registry.dispatch {
        // Use hardcoded callback ID for this wrapper function
        let callback_id = CALLBACK_ID_LOAD_SESSION;
        
        // Pack parameters into struct
        let args = CallbackArgs {
            callback_id,
            store_ctx,
            arg1: recordp as *mut c_void,
            arg2: address as *mut c_void,
            arg3: std::ptr::null_mut(),
            direction: 0,
        };
        
        // Allocate struct on heap and pass address as u64
        let args_box = Box::new(args);
        let args_ptr = Box::into_raw(args_box);
        let args_address = args_ptr as u64;
        
        // Call dispatch function with pointer address
        let result = dispatch(args_address);
        
        // Free the struct
        let _ = Box::from_raw(args_ptr);
        
        result
    } else {
        1 // Error: dispatch callback not registered
    }
}

// Store session wrapper
#[no_mangle]
pub extern "C" fn spots_rust_store_session_wrapper(
    store_ctx: *mut c_void,
    address: *const SignalConstPointerProtocolAddress,
    record: *const SignalConstPointerSessionRecord,
) -> c_int {
    let registry = CALLBACK_REGISTRY.lock().unwrap();
    if let Some(dispatch) = registry.dispatch {
        let callback_id = CALLBACK_ID_STORE_SESSION;
        let args = CallbackArgs {
            callback_id,
            store_ctx,
            arg1: address as *mut c_void,
            arg2: record as *mut c_void,
            arg3: std::ptr::null_mut(),
            direction: 0,
        };
        dispatch(&args)
    } else {
        1
    }
}

// Get identity key pair wrapper
#[no_mangle]
pub extern "C" fn spots_rust_get_identity_key_pair_wrapper(
    store_ctx: *mut c_void,
    keyp: *mut SignalMutPointerPrivateKey,
) -> c_int {
    let registry = CALLBACK_REGISTRY.lock().unwrap();
    if let Some(dispatch) = registry.dispatch {
        let callback_id = CALLBACK_ID_GET_IDENTITY_KEY_PAIR;
        let args = CallbackArgs {
            callback_id,
            store_ctx,
            arg1: keyp as *mut c_void,
            arg2: std::ptr::null_mut(),
            arg3: std::ptr::null_mut(),
            direction: 0,
        };
        dispatch(&args)
    } else {
        1
    }
}

// Get local registration ID wrapper
#[no_mangle]
pub extern "C" fn spots_rust_get_local_registration_id_wrapper(
    store_ctx: *mut c_void,
    idp: *mut u32,
) -> c_int {
    let registry = CALLBACK_REGISTRY.lock().unwrap();
    if let Some(dispatch) = registry.dispatch {
        let callback_id = CALLBACK_ID_GET_LOCAL_REGISTRATION_ID;
        let args = CallbackArgs {
            callback_id,
            store_ctx,
            arg1: idp as *mut c_void,
            arg2: std::ptr::null_mut(),
            arg3: std::ptr::null_mut(),
            direction: 0,
        };
        dispatch(&args)
    } else {
        1
    }
}

// Save identity key wrapper
#[no_mangle]
pub extern "C" fn spots_rust_save_identity_key_wrapper(
    store_ctx: *mut c_void,
    address: *const SignalConstPointerProtocolAddress,
    public_key: *const SignalConstPointerPublicKey,
) -> c_int {
    let registry = CALLBACK_REGISTRY.lock().unwrap();
    if let Some(dispatch) = registry.dispatch {
        let callback_id = CALLBACK_ID_SAVE_IDENTITY_KEY;
        let args = CallbackArgs {
            callback_id,
            store_ctx,
            arg1: address as *mut c_void,
            arg2: public_key as *mut c_void,
            arg3: std::ptr::null_mut(),
            direction: 0,
        };
        dispatch(&args)
    } else {
        1
    }
}

// Get identity key wrapper
#[no_mangle]
pub extern "C" fn spots_rust_get_identity_key_wrapper(
    store_ctx: *mut c_void,
    public_keyp: *mut SignalMutPointerPublicKey,
    address: *const SignalConstPointerProtocolAddress,
) -> c_int {
    let registry = CALLBACK_REGISTRY.lock().unwrap();
    if let Some(dispatch) = registry.dispatch {
        let callback_id = CALLBACK_ID_GET_IDENTITY_KEY;
        let args = CallbackArgs {
            callback_id,
            store_ctx,
            arg1: public_keyp as *mut c_void,
            arg2: address as *mut c_void,
            arg3: std::ptr::null_mut(),
            direction: 0,
        };
        dispatch(&args)
    } else {
        1
    }
}

// Is trusted identity wrapper
#[no_mangle]
pub extern "C" fn spots_rust_is_trusted_identity_wrapper(
    store_ctx: *mut c_void,
    address: *const SignalConstPointerProtocolAddress,
    public_key: *const SignalConstPointerPublicKey,
    direction: u32,
) -> c_int {
    let registry = CALLBACK_REGISTRY.lock().unwrap();
    if let Some(dispatch) = registry.dispatch {
        let callback_id = CALLBACK_ID_IS_TRUSTED_IDENTITY;
        let args = CallbackArgs {
            callback_id,
            store_ctx,
            arg1: address as *mut c_void,
            arg2: public_key as *mut c_void,
            arg3: std::ptr::null_mut(),
            direction,
        };
        dispatch(&args)
    } else {
        1
    }
}

// ============================================================================
// FUNCTION POINTER GETTERS (FOR DART)
// ============================================================================
// These functions return the addresses of the wrapper functions.
// Dart can look up these functions and get their addresses to pass to libsignal-ffi.

#[no_mangle]
pub extern "C" fn spots_rust_get_load_session_wrapper_ptr() -> *mut c_void {
    spots_rust_load_session_wrapper as *mut c_void
}

#[no_mangle]
pub extern "C" fn spots_rust_get_store_session_wrapper_ptr() -> *mut c_void {
    spots_rust_store_session_wrapper as *mut c_void
}

#[no_mangle]
pub extern "C" fn spots_rust_get_get_identity_key_pair_wrapper_ptr() -> *mut c_void {
    spots_rust_get_identity_key_pair_wrapper as *mut c_void
}

#[no_mangle]
pub extern "C" fn spots_rust_get_get_local_registration_id_wrapper_ptr() -> *mut c_void {
    spots_rust_get_local_registration_id_wrapper as *mut c_void
}

#[no_mangle]
pub extern "C" fn spots_rust_get_save_identity_key_wrapper_ptr() -> *mut c_void {
    spots_rust_save_identity_key_wrapper as *mut c_void
}

#[no_mangle]
pub extern "C" fn spots_rust_get_get_identity_key_wrapper_ptr() -> *mut c_void {
    spots_rust_get_identity_key_wrapper as *mut c_void
}

#[no_mangle]
pub extern "C" fn spots_rust_get_is_trusted_identity_wrapper_ptr() -> *mut c_void {
    spots_rust_is_trusted_identity_wrapper as *mut c_void
}
