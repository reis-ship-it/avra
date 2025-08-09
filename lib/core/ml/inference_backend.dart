import 'dart:developer' as developer;
import 'dart:typed_data';

/// Represents the type of inference backend used by the app.
enum InferenceBackendType {
  onnx,
  tflite,
  coreml,
}

/// Metadata describing a model and its expected I/O shapes.
class ModelMetadata {
  final String modelId;
  final String version;
  final Map<String, List<int>> inputShapes; // tensor name -> shape
  final Map<String, List<int>> outputShapes; // tensor name -> shape
  final String dtype; // e.g., float32, int8

  const ModelMetadata({
    required this.modelId,
    required this.version,
    this.inputShapes = const {},
    this.outputShapes = const {},
    this.dtype = 'float32',
  });
}

/// Input and output payloads for inference calls.
typedef InferenceInputs = Map<String, Object?>;
typedef InferenceOutputs = Map<String, Object?>;

/// Abstract interface for inference backends. Implementations should be
/// platform-agnostic and hide runtime specifics behind this API.
abstract class InferenceBackend {
  InferenceBackendType get type;

  /// Perform any one-time initialization (e.g., runtime/session creation).
  Future<void> initialize();

  /// Load a model from app assets.
  Future<void> loadModelFromAsset(String assetPath, {ModelMetadata? metadata});

  /// Load a model from raw bytes (e.g., downloaded from remote storage).
  Future<void> loadModelFromBytes(Uint8List modelBytes, {ModelMetadata? metadata});

  /// Run inference with named inputs and return named outputs.
  Future<InferenceOutputs> run(InferenceInputs inputs);

  /// Free any native resources held by the backend.
  Future<void> dispose();

  /// Simple logger helper for implementations.
  void log(String message) {
    developer.log(message, name: runtimeType.toString());
  }
}


