import 'dart:io' show File, Directory;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:onnxruntime/onnxruntime.dart' as ort;
import 'inference_backend.dart';

/// Real ONNX Runtime backend implementation.
class OnnxRuntimeBackend implements InferenceBackend {
  bool _initialized = false;
  ModelMetadata? _metadata;
  ort.OrtSession? _session;

  @override
  InferenceBackendType get type => InferenceBackendType.onnx;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
  }

  @override
  Future<void> loadModelFromAsset(String assetPath, {ModelMetadata? metadata}) async {
    if (!_initialized) await initialize();
    _metadata = metadata;
    final data = await rootBundle.load(assetPath);
    await loadModelFromBytes(data.buffer.asUint8List(), metadata: metadata);
  }

  @override
  Future<void> loadModelFromBytes(Uint8List modelBytes, {ModelMetadata? metadata}) async {
    if (!_initialized) await initialize();
    _metadata = metadata;
    try {
      // Some platforms expose fromBytes, others only fromPath; guard via try/catch
      _session = await ort.OrtSession.fromBytes(modelBytes);
    } catch (_) {
      // Fallback: write to a temp file if fromBytes is not supported on a platform
      final file = await _writeTemp(modelBytes);
      _session = await ort.OrtSession.fromPath(file.path);
    }
  }

  @override
  Future<InferenceOutputs> run(InferenceInputs inputs) async {
    final session = _session;
    if (!_initialized || session == null) {
      throw StateError('ONNX backend not ready. Call initialize() and loadModel*() first.');
    }

    final mapped = <String, ort.OrtValue>{};
    try {
      for (final e in inputs.entries) {
        mapped[e.key] = _toOrtValue(e.value, _metadata?.inputShapes[e.key]);
      }
      final outputs = await session.run(mapped);
      final result = <String, Object?>{};
      for (final e in outputs.entries) {
        result[e.key] = await _fromOrtValue(e.value);
      }
      return result;
    } finally {
      for (final v in mapped.values) {
        v.release();
      }
    }
  }

  @override
  Future<void> dispose() async {
    _session?.release();
    _session = null;
    _metadata = null;
    _initialized = false;
  }

  @override
  void log(String message) {
    // Simple passthrough; in tests we do not need verbose logging
  }

  Future<File> _writeTemp(Uint8List bytes) async {
    final dir = Directory.systemTemp;
    final path = '${dir.path}/model_${DateTime.now().microsecondsSinceEpoch}.onnx';
    final f = File(path);
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }

  ort.OrtValue _toOrtValue(Object? value, List<int>? shape) {
    // Common integer types (IDs/masks)
    if (value is Int64List) {
      return ort.OrtValueTensor.createTensorWithShapeInt64(value.toList(), shape ?? [value.length]);
    }
    if (value is Int32List) {
      return ort.OrtValueTensor.createTensorWithShapeInt64(value.toList(), shape ?? [value.length]);
    }
    if (value is List<int>) {
      return ort.OrtValueTensor.createTensorWithShapeInt64(value.map((e) => e.toInt()).toList(), shape ?? [value.length]);
    }
    // Floating point tensors
    if (value is Float32List) {
      return ort.OrtValueTensor.createTensorWithShapeFloat32(value, shape ?? [value.length]);
    }
    if (value is List<double>) {
      return ort.OrtValueTensor.createTensorWithShapeFloat32(Float32List.fromList(value), shape ?? [value.length]);
    }
    if (value is Uint8List) {
      return ort.OrtValueTensor.createTensorWithShapeUInt8(value, shape ?? [value.length]);
    }
    throw ArgumentError('Unsupported input type for ONNX: ${value.runtimeType}');
  }

  Future<Object?> _fromOrtValue(ort.OrtValue v) async {
    if (v is ort.OrtValueTensor) {
      try { return v.toFloat32List(); } catch (_) {}
      try { return v.toInt64List(); } catch (_) {}
      try { return v.toUint8List(); } catch (_) {}
    }
    return null;
  }
}
