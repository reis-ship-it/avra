import 'dart:typed_data';
import 'package:spots/core/ml/inference_backend.dart';
import 'package:spots/core/ml/inference_orchestrator.dart';
import 'package:spots/core/ml/tokenization/wordpiece_tokenizer.dart';
import 'package:spots/core/services/config_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'embedding_cloud_client.dart';

class EmbeddingService {
  final InferenceOrchestrator orchestrator;
  final WordPieceTokenizer tokenizer;
  final ConfigService config;
  final EmbeddingCloudClient? cloudClient;

  const EmbeddingService({
    required this.orchestrator,
    required this.tokenizer,
    required this.config,
    this.cloudClient,
  });

  Future<Float32List> embed(String text) async {
    final ids = tokenizer.tokenizeToIds(text, config.nlpMaxSeqLen);
    final mask = tokenizer.attentionMaskFor(ids);
    final tokenTypes = List<int>.filled(config.nlpMaxSeqLen, 0);

    final inputs = <String, Object?>{
      config.nlpInputIdsName: Int64List.fromList(ids.map((e) => e.toInt()).toList()),
      config.nlpAttentionMaskName: Int64List.fromList(mask.map((e) => e.toInt()).toList()),
      config.nlpTokenTypeIdsName: Int64List.fromList(tokenTypes.map((e) => e.toInt()).toList()),
    };

    Map<String, Object?> outputs;
    try {
      final result = await orchestrator.run(inputs);
      outputs = result.outputs;
    } catch (e) {
      // On web, backend may not be available. Try cloud if configured.
      if (cloudClient != null) {
        final vec = await cloudClient!.embedOne(text);
        return Float32List.fromList(vec);
      }
      rethrow;
    }
    final output = outputs[config.nlpOutputName];
    // Expect last_hidden_state [1, L, H]; mean-pool across tokens where mask==1
    final hidden = _toFloat32List(output);
    final length = config.nlpMaxSeqLen * config.nlpHiddenSize;
    if (hidden.length < length) {
      throw StateError('Unexpected hidden size');
    }
    final pooled = Float32List(config.nlpHiddenSize);
    var count = 0;
    for (var t = 0; t < config.nlpMaxSeqLen; t++) {
      if (mask[t] == 0) continue;
      final base = t * config.nlpHiddenSize;
      for (var h = 0; h < config.nlpHiddenSize; h++) {
        pooled[h] += hidden[base + h];
      }
      count += 1;
    }
    if (count == 0) return pooled; // all pads
    for (var h = 0; h < config.nlpHiddenSize; h++) {
      pooled[h] /= count;
    }
    return pooled;
  }

  Float32List _toFloat32List(Object? value) {
    if (value is Float32List) return value;
    if (value is List) return Float32List.fromList(value.cast<num>().map((e) => e.toDouble()).toList());
    throw ArgumentError('Unsupported tensor type: ${value.runtimeType}');
  }
}


