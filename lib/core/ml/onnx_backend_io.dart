import 'dart:io' show File, Directory;
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:onnxruntime/onnxruntime.dart' as ort;
import 'inference_backend.dart';

class OnnxRuntimeBackend implements InferenceBackend {
  bool _initialized = false;
  ModelMetadata? _metadata;
  ort.OrtSession? _session;

  @override
  InferenceBackendType get type => InferenceBackendType.onnx;

  @override
  Future<void> initialize() async { _initialized = true; }

  @override
  Future<void> loadModelFromAsset(String assetPath, {ModelMetadata? metadata}) async {
    if (!_initialized) await initialize();
    _metadata = metadata;
    final bytes = (await rootBundle.load(assetPath)).buffer.asUint8List();
    await loadModelFromBytes(bytes, metadata: metadata);
  }

  @override
  Future<void> loadModelFromBytes(Uint8List modelBytes, {ModelMetadata? metadata}) async {
    if (!_initialized) await initialize();
    _metadata = metadata;
    try {
      final options = ort.OrtSessionOptions();
      options.setIntraOpNumThreads(1);
      options.appendCPUProvider(ort.CPUFlags.useNone);
      _session = ort.OrtSession.fromBuffer(modelBytes, options);
    } catch (_) {
      final file = await _writeTemp(modelBytes);
      final options = ort.OrtSessionOptions();
      options.setIntraOpNumThreads(1);
      options.appendCPUProvider(ort.CPUFlags.useNone);
      _session = ort.OrtSession.fromFile(file, options);
    }
  }

  @override
  Future<Map<String, Object?>> run(Map<String, Object?> inputs) async {
    if (!_initialized || _session == null) {
      throw StateError('ONNX backend not initialized');
    }
    final mapped = <String, ort.OrtValue>{};
    try {
      for (final e in inputs.entries) {
        mapped[e.key] = _toOrtValue(e.value, _metadata?.inputShapes[e.key]);
      }
      final runOptions = ort.OrtRunOptions();
      final outputNames = _session!.outputNames;
      final outputs = _session!.run(runOptions, mapped, outputNames);
      final result = <String, Object?>{};
      for (int i = 0; i < outputNames.length; i++) {
        final name = outputNames[i];
        final val = outputs[i];
        if (val != null) {
          result[name] = await _fromOrtValue(val);
          val.release();
        }
      }
      runOptions.release();
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
  }

  @override
  void log(String message) {
    developer.log(message, name: runtimeType.toString());
  }

  Future<File> _writeTemp(Uint8List bytes) async {
    final f = File('${Directory.systemTemp.path}/model_${DateTime.now().microsecondsSinceEpoch}.onnx');
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }

  ort.OrtValue _toOrtValue(Object? value, List<int>? shape) {
    final inferredShape = shape ?? _inferShape(value);
    if (value is Int64List) return ort.OrtValueTensor.createTensorWithDataList(value.toList(), inferredShape);
    if (value is Int32List) return ort.OrtValueTensor.createTensorWithDataList(value.toList(), inferredShape);
    if (value is List<int>) return ort.OrtValueTensor.createTensorWithDataList(value, inferredShape);
    if (value is Float32List) return ort.OrtValueTensor.createTensorWithDataList(value, inferredShape);
    if (value is List<double>) return ort.OrtValueTensor.createTensorWithDataList(value, inferredShape);
    if (value is Uint8List) return ort.OrtValueTensor.createTensorWithDataList(value, inferredShape);
    throw ArgumentError('Unsupported input type: ${value.runtimeType}');
  }

  List<int> _inferShape(Object? value) {
    if (value is List) return [value.length];
    if (value is Uint8List) return [value.length];
    if (value is Int32List) return [value.length];
    if (value is Int64List) return [value.length];
    if (value is Float32List) return [value.length];
    return [1];
  }

  Future<Object?> _fromOrtValue(ort.OrtValue v) async {
    if (v is ort.OrtValueTensor) {
      return v.value;
    }
    return null;
  }
  // Helpers retained for native implementation
}


