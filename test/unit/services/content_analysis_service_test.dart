import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/services/content_analysis_service.dart';

/// Content Analysis Service Tests
/// Tests content analysis functionality
void main() {
  group('ContentAnalysisService Tests', () {
    group('analyzeContent', () {
      test('should analyze content and return analysis map', () {
        const content = 'This is a test content string.';

        final analysis = ContentAnalysisService.analyzeContent(content);

        expect(analysis, isA<Map<String, dynamic>>());
        expect(analysis['length'], equals(content.length));
        expect(analysis['sentiment'], isA<String>());
        expect(analysis['topics'], isA<List<String>>());
        expect(analysis['quality'], isA<double>());
      });

      test('should return correct length for content', () {
        const content = 'Short';
        final analysis = ContentAnalysisService.analyzeContent(content);
        expect(analysis['length'], equals(5));
      });

      test('should return correct length for long content', () {
        const content = 'A' * 1000;
        final analysis = ContentAnalysisService.analyzeContent(content);
        expect(analysis['length'], equals(1000));
      });

      test('should return empty string analysis', () {
        const content = '';
        final analysis = ContentAnalysisService.analyzeContent(content);
        expect(analysis['length'], equals(0));
      });

      test('should return sentiment value', () {
        const content = 'This is neutral content.';
        final analysis = ContentAnalysisService.analyzeContent(content);
        expect(analysis['sentiment'], isNotEmpty);
      });

      test('should return topics list', () {
        const content = 'This is test content.';
        final analysis = ContentAnalysisService.analyzeContent(content);
        expect(analysis['topics'], isA<List<String>>());
      });

      test('should return quality score', () {
        const content = 'This is test content.';
        final analysis = ContentAnalysisService.analyzeContent(content);
        expect(analysis['quality'], isA<double>());
        expect(analysis['quality'], greaterThanOrEqualTo(0.0));
        expect(analysis['quality'], lessThanOrEqualTo(1.0));
      });

      test('should handle special characters', () {
        const content = r'Café Münchën 北京烤鸭 🍜 @#$%';
        final analysis = ContentAnalysisService.analyzeContent(content);
        expect(analysis['length'], equals(content.length));
      });

      test('should handle multiline content', () {
        const content = 'Line 1\nLine 2\nLine 3';
        final analysis = ContentAnalysisService.analyzeContent(content);
        expect(analysis['length'], equals(content.length));
      });
    });
  });
}

