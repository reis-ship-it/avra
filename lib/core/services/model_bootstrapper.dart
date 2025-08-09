import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:spots/core/ml/inference_orchestrator.dart';
import 'package:spots/core/services/config_service.dart';

class ModelBootstrapper {
  final http.Client httpClient;
  const ModelBootstrapper({required this.httpClient});

  Future<void> ensureModelInitialized({
    required InferenceOrchestrator orchestrator,
    required ConfigService config,
  }) async {
    // Try asset first
    try {
      await rootBundle.load(config.modelAssetPath);
      await orchestrator.initialize(assetPath: config.modelAssetPath);
      return;
    } catch (_) {
      // fall through to download
    }

    // Try download if URL provided
    if (config.modelDownloadUrl.isNotEmpty) {
      final bytes = await _tryDownload(config.modelDownloadUrl);
      if (bytes != null) {
        await orchestrator.initialize(bytes: bytes);
      }
    }
  }

  Future<Uint8List?> _tryDownload(String url) async {
    try {
      final resp = await httpClient.get(Uri.parse(url));
      if (resp.statusCode == 200) {
        return Uint8List.fromList(resp.bodyBytes);
      }
    } catch (_) {
      // ignore network errors
    }
    return null;
  }
}


