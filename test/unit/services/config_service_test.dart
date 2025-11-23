import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/services/config_service.dart';

/// Config Service Tests
/// Tests configuration service for app settings
void main() {
  group('ConfigService', () {
    group('Constructor', () {
      test('should create config with required fields', () {
        const config = ConfigService(
          environment: 'development',
          supabaseUrl: 'https://test.supabase.co',
          supabaseAnonKey: 'test_anon_key',
        );

        expect(config.environment, equals('development'));
        expect(config.supabaseUrl, equals('https://test.supabase.co'));
        expect(config.supabaseAnonKey, equals('test_anon_key'));
      });

      test('should use default values for optional fields', () {
        const config = ConfigService(
          environment: 'production',
          supabaseUrl: 'https://prod.supabase.co',
          supabaseAnonKey: 'prod_anon_key',
        );

        expect(config.googlePlacesApiKey, isEmpty);
        expect(config.debug, isFalse);
        expect(config.inferenceBackend, equals('onnx'));
        expect(config.orchestrationStrategy, equals('device_first'));
        expect(config.modelAssetPath, equals('assets/models/default.onnx'));
        expect(config.modelInputName, equals('input'));
        expect(config.modelOutputName, equals('output'));
        expect(config.modelInputShape, equals([1]));
        expect(config.modelDownloadUrl, isEmpty);
      });

      test('should accept custom optional values', () {
        const config = ConfigService(
          environment: 'staging',
          supabaseUrl: 'https://staging.supabase.co',
          supabaseAnonKey: 'staging_anon_key',
          googlePlacesApiKey: 'test_places_key',
          debug: true,
          inferenceBackend: 'tflite',
          orchestrationStrategy: 'edge_prefetch',
          modelAssetPath: 'assets/models/custom.onnx',
          modelInputName: 'custom_input',
          modelOutputName: 'custom_output',
          modelInputShape: [1, 2, 3],
          modelDownloadUrl: 'https://example.com/model.onnx',
        );

        expect(config.googlePlacesApiKey, equals('test_places_key'));
        expect(config.debug, isTrue);
        expect(config.inferenceBackend, equals('tflite'));
        expect(config.orchestrationStrategy, equals('edge_prefetch'));
        expect(config.modelAssetPath, equals('assets/models/custom.onnx'));
        expect(config.modelInputName, equals('custom_input'));
        expect(config.modelOutputName, equals('custom_output'));
        expect(config.modelInputShape, equals([1, 2, 3]));
        expect(config.modelDownloadUrl, equals('https://example.com/model.onnx'));
      });

      test('should accept NLP configuration defaults', () {
        const config = ConfigService(
          environment: 'development',
          supabaseUrl: 'https://test.supabase.co',
          supabaseAnonKey: 'test_anon_key',
        );

        expect(config.nlpMaxSeqLen, equals(128));
        expect(config.nlpHiddenSize, equals(768));
        expect(config.nlpInputIdsName, equals('input_ids'));
        expect(config.nlpAttentionMaskName, equals('attention_mask'));
        expect(config.nlpTokenTypeIdsName, equals('token_type_ids'));
        expect(config.nlpOutputName, equals('last_hidden_state'));
        expect(config.nlpDoLowerCase, isFalse);
      });

      test('should accept custom NLP configuration', () {
        const config = ConfigService(
          environment: 'development',
          supabaseUrl: 'https://test.supabase.co',
          supabaseAnonKey: 'test_anon_key',
          nlpMaxSeqLen: 256,
          nlpHiddenSize: 1024,
          nlpInputIdsName: 'custom_input_ids',
          nlpAttentionMaskName: 'custom_attention',
          nlpTokenTypeIdsName: 'custom_token_type',
          nlpOutputName: 'pooled_output',
          nlpDoLowerCase: true,
        );

        expect(config.nlpMaxSeqLen, equals(256));
        expect(config.nlpHiddenSize, equals(1024));
        expect(config.nlpInputIdsName, equals('custom_input_ids'));
        expect(config.nlpAttentionMaskName, equals('custom_attention'));
        expect(config.nlpTokenTypeIdsName, equals('custom_token_type'));
        expect(config.nlpOutputName, equals('pooled_output'));
        expect(config.nlpDoLowerCase, isTrue);
      });
    });

    group('Environment Checks', () {
      test('isProd should return true for production', () {
        const config = ConfigService(
          environment: 'production',
          supabaseUrl: 'https://prod.supabase.co',
          supabaseAnonKey: 'prod_key',
        );

        expect(config.isProd, isTrue);
        expect(config.isDev, isFalse);
      });

      test('isProd should return true for PRODUCTION (case insensitive)', () {
        const config = ConfigService(
          environment: 'PRODUCTION',
          supabaseUrl: 'https://prod.supabase.co',
          supabaseAnonKey: 'prod_key',
        );

        expect(config.isProd, isTrue);
      });

      test('isDev should return true for development', () {
        const config = ConfigService(
          environment: 'development',
          supabaseUrl: 'https://dev.supabase.co',
          supabaseAnonKey: 'dev_key',
        );

        expect(config.isDev, isTrue);
        expect(config.isProd, isFalse);
      });

      test('isDev should return true for DEVELOPMENT (case insensitive)', () {
        const config = ConfigService(
          environment: 'DEVELOPMENT',
          supabaseUrl: 'https://dev.supabase.co',
          supabaseAnonKey: 'dev_key',
        );

        expect(config.isDev, isTrue);
      });

      test('should return false for staging environment', () {
        const config = ConfigService(
          environment: 'staging',
          supabaseUrl: 'https://staging.supabase.co',
          supabaseAnonKey: 'staging_key',
        );

        expect(config.isProd, isFalse);
        expect(config.isDev, isFalse);
      });
    });

    group('Configuration Scenarios', () {
      test('should create production config', () {
        const config = ConfigService(
          environment: 'production',
          supabaseUrl: 'https://prod.supabase.co',
          supabaseAnonKey: 'prod_anon_key',
          debug: false,
        );

        expect(config.isProd, isTrue);
        expect(config.debug, isFalse);
      });

      test('should create development config', () {
        const config = ConfigService(
          environment: 'development',
          supabaseUrl: 'https://dev.supabase.co',
          supabaseAnonKey: 'dev_anon_key',
          debug: true,
        );

        expect(config.isDev, isTrue);
        expect(config.debug, isTrue);
      });

      test('should create config with ONNX backend', () {
        const config = ConfigService(
          environment: 'development',
          supabaseUrl: 'https://test.supabase.co',
          supabaseAnonKey: 'test_key',
          inferenceBackend: 'onnx',
        );

        expect(config.inferenceBackend, equals('onnx'));
      });

      test('should create config with TFLite backend', () {
        const config = ConfigService(
          environment: 'development',
          supabaseUrl: 'https://test.supabase.co',
          supabaseAnonKey: 'test_key',
          inferenceBackend: 'tflite',
        );

        expect(config.inferenceBackend, equals('tflite'));
      });

      test('should create config with CoreML backend', () {
        const config = ConfigService(
          environment: 'development',
          supabaseUrl: 'https://test.supabase.co',
          supabaseAnonKey: 'test_key',
          inferenceBackend: 'coreml',
        );

        expect(config.inferenceBackend, equals('coreml'));
      });
    });
  });
}

