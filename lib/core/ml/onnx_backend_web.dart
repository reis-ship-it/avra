import 'dart:typed_data';
import 'inference_backend.dart';

/// Web stub: ONNX Runtime native plugin isn’t available on Flutter Web.
/// We keep the interface but throw a clear error so callers can fallback.
class OnnxRuntimeBackend implements InferenceBackend {
  @override
  InferenceBackendType get type => InferenceBackendType.onnx;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> loadModelFromAsset(String assetPath, {ModelMetadata? metadata}) async {}

  @override
  Future<void> loadModelFromBytes(Uint8List modelBytes, {ModelMetadata? metadata}) async {}

  @override
  Future<Map<String, Object?>> run(Map<String, Object?> inputs) async {
    throw UnsupportedError('ONNX Runtime not supported on Flutter Web. Use cloud fallback.');
  }

  @override
  Future<void> dispose() async {}

  @override
  void log(String message) {
    // no-op on web
  }
}


