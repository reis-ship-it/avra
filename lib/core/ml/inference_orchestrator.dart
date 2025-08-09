import 'dart:typed_data';
import 'package:meta/meta.dart';
import 'inference_backend.dart';

/// Strategy for routing inference requests.
enum OrchestrationStrategy {
  deviceFirst,
  edgePrefetch,
}

/// Simple result wrapper with timing and cache indicators.
@immutable
class InferenceResult {
  final Map<String, Object?> outputs;
  final Duration processingTime;
  final bool cacheHit;
  const InferenceResult({
    required this.outputs,
    required this.processingTime,
    this.cacheHit = false,
  });
}

/// Abstraction over on-device/backend inference with pluggable strategy.
class InferenceOrchestrator {
  final InferenceBackend backend;
  final OrchestrationStrategy strategy;

  // Placeholder cloud function hook. Replace with real implementation.
  final Future<Map<String, Object?>> Function(Map<String, Object?> inputs)? cloudFallback;

  const InferenceOrchestrator({
    required this.backend,
    required this.strategy,
    this.cloudFallback,
  });

  Future<void> initialize({String? assetPath, Uint8List? bytes, ModelMetadata? metadata}) async {
    await backend.initialize();
    if (assetPath != null) {
      await backend.loadModelFromAsset(assetPath, metadata: metadata);
    } else if (bytes != null) {
      await backend.loadModelFromBytes(bytes, metadata: metadata);
    }
  }

  /// Convenience method for a simple smoke test run using a single named input.
  Future<InferenceResult> runSingle(String inputName, Object input) async {
    return run({inputName: input});
  }

  Future<InferenceResult> run(Map<String, Object?> inputs) async {
    final start = DateTime.now();
    try {
      final outputs = await backend.run(inputs);
      return InferenceResult(
        outputs: outputs,
        processingTime: DateTime.now().difference(start),
        cacheHit: false,
      );
    } catch (_) {
      if (cloudFallback != null) {
        final outputs = await cloudFallback!(inputs);
        return InferenceResult(
          outputs: outputs,
          processingTime: DateTime.now().difference(start),
          cacheHit: false,
        );
      }
      rethrow;
    }
  }

  /// For edgePrefetch strategy, call this in background/idle to warm caches.
  Future<void> prefetch(List<Map<String, Object?>> representativeInputs) async {
    if (strategy != OrchestrationStrategy.edgePrefetch) return;
    for (final input in representativeInputs) {
      try { await backend.run(input); } catch (_) { /* ignore */ }
    }
  }
}


