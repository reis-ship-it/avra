import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/models/expertise_level.dart';

/// Comprehensive tests for ExpertiseLevel enum
/// Tests enum values, display names, descriptions, emojis, parsing, and level comparisons
void main() {
  group('ExpertiseLevel Enum Tests', () {
    group('Enum Values', () {
      test('should have all 6 expertise levels', () {
        expect(ExpertiseLevel.values, hasLength(6));
        expect(ExpertiseLevel.values, contains(ExpertiseLevel.local));
        expect(ExpertiseLevel.values, contains(ExpertiseLevel.city));
        expect(ExpertiseLevel.values, contains(ExpertiseLevel.regional));
        expect(ExpertiseLevel.values, contains(ExpertiseLevel.national));
        expect(ExpertiseLevel.values, contains(ExpertiseLevel.global));
        expect(ExpertiseLevel.values, contains(ExpertiseLevel.universal));
      });

      test('should have correct order (local to universal)', () {
        expect(ExpertiseLevel.local.index, equals(0));
        expect(ExpertiseLevel.city.index, equals(1));
        expect(ExpertiseLevel.regional.index, equals(2));
        expect(ExpertiseLevel.national.index, equals(3));
        expect(ExpertiseLevel.global.index, equals(4));
        expect(ExpertiseLevel.universal.index, equals(5));
      });
    });

    group('Display Names', () {
      test('should have correct display names', () {
        expect(ExpertiseLevel.local.displayName, equals('Local'));
        expect(ExpertiseLevel.city.displayName, equals('City'));
        expect(ExpertiseLevel.regional.displayName, equals('Regional'));
        expect(ExpertiseLevel.national.displayName, equals('National'));
        expect(ExpertiseLevel.global.displayName, equals('Global'));
        expect(ExpertiseLevel.universal.displayName, equals('Universal'));
      });
    });

    group('Descriptions', () {
      test('should have correct descriptions', () {
        expect(ExpertiseLevel.local.description, equals('Neighborhood-level expertise'));
        expect(ExpertiseLevel.city.description, equals('City-level expertise'));
        expect(ExpertiseLevel.regional.description, equals('Regional-level expertise'));
        expect(ExpertiseLevel.national.description, equals('National-level expertise'));
        expect(ExpertiseLevel.global.description, equals('Global-level expertise'));
        expect(ExpertiseLevel.universal.description, equals('Universal recognition'));
      });
    });

    group('Emojis', () {
      test('should have correct emoji representations', () {
        expect(ExpertiseLevel.local.emoji, equals('🏘️'));
        expect(ExpertiseLevel.city.emoji, equals('🏙️'));
        expect(ExpertiseLevel.regional.emoji, equals('🗺️'));
        expect(ExpertiseLevel.national.emoji, equals('🌎'));
        expect(ExpertiseLevel.global.emoji, equals('🌍'));
        expect(ExpertiseLevel.universal.emoji, equals('✨'));
      });
    });

    group('Parsing from String', () {
      test('should parse valid level strings', () {
        expect(ExpertiseLevel.fromString('local'), equals(ExpertiseLevel.local));
        expect(ExpertiseLevel.fromString('city'), equals(ExpertiseLevel.city));
        expect(ExpertiseLevel.fromString('regional'), equals(ExpertiseLevel.regional));
        expect(ExpertiseLevel.fromString('national'), equals(ExpertiseLevel.national));
        expect(ExpertiseLevel.fromString('global'), equals(ExpertiseLevel.global));
        expect(ExpertiseLevel.fromString('universal'), equals(ExpertiseLevel.universal));
      });

      test('should handle case insensitive parsing', () {
        expect(ExpertiseLevel.fromString('LOCAL'), equals(ExpertiseLevel.local));
        expect(ExpertiseLevel.fromString('City'), equals(ExpertiseLevel.city));
        expect(ExpertiseLevel.fromString('REGIONAL'), equals(ExpertiseLevel.regional));
      });

      test('should return null for invalid strings', () {
        expect(ExpertiseLevel.fromString('invalid'), isNull);
        expect(ExpertiseLevel.fromString(''), isNull);
        expect(ExpertiseLevel.fromString('unknown'), isNull);
      });

      test('should return null for null input', () {
        expect(ExpertiseLevel.fromString(null), isNull);
      });
    });

    group('Next Level', () {
      test('should return correct next level for each level', () {
        expect(ExpertiseLevel.local.nextLevel, equals(ExpertiseLevel.city));
        expect(ExpertiseLevel.city.nextLevel, equals(ExpertiseLevel.regional));
        expect(ExpertiseLevel.regional.nextLevel, equals(ExpertiseLevel.national));
        expect(ExpertiseLevel.national.nextLevel, equals(ExpertiseLevel.global));
        expect(ExpertiseLevel.global.nextLevel, equals(ExpertiseLevel.universal));
        expect(ExpertiseLevel.universal.nextLevel, isNull); // Highest level
      });
    });

    group('Level Comparisons', () {
      test('isHigherThan should return true for higher levels', () {
        expect(ExpertiseLevel.city.isHigherThan(ExpertiseLevel.local), isTrue);
        expect(ExpertiseLevel.regional.isHigherThan(ExpertiseLevel.city), isTrue);
        expect(ExpertiseLevel.national.isHigherThan(ExpertiseLevel.regional), isTrue);
        expect(ExpertiseLevel.global.isHigherThan(ExpertiseLevel.national), isTrue);
        expect(ExpertiseLevel.universal.isHigherThan(ExpertiseLevel.global), isTrue);
      });

      test('isHigherThan should return false for same or lower levels', () {
        expect(ExpertiseLevel.local.isHigherThan(ExpertiseLevel.local), isFalse);
        expect(ExpertiseLevel.local.isHigherThan(ExpertiseLevel.city), isFalse);
        expect(ExpertiseLevel.city.isHigherThan(ExpertiseLevel.regional), isFalse);
      });

      test('isLowerThan should return true for lower levels', () {
        expect(ExpertiseLevel.local.isLowerThan(ExpertiseLevel.city), isTrue);
        expect(ExpertiseLevel.city.isLowerThan(ExpertiseLevel.regional), isTrue);
        expect(ExpertiseLevel.regional.isLowerThan(ExpertiseLevel.national), isTrue);
        expect(ExpertiseLevel.national.isLowerThan(ExpertiseLevel.global), isTrue);
        expect(ExpertiseLevel.global.isLowerThan(ExpertiseLevel.universal), isTrue);
      });

      test('isLowerThan should return false for same or higher levels', () {
        expect(ExpertiseLevel.local.isLowerThan(ExpertiseLevel.local), isFalse);
        expect(ExpertiseLevel.city.isLowerThan(ExpertiseLevel.local), isFalse);
        expect(ExpertiseLevel.regional.isLowerThan(ExpertiseLevel.city), isFalse);
      });
    });

    group('Level Progression', () {
      test('should progress from local to universal', () {
        var current = ExpertiseLevel.local;
        final progression = <ExpertiseLevel>[current];

        while (current.nextLevel != null) {
          current = current.nextLevel!;
          progression.add(current);
        }

        expect(progression, hasLength(6));
        expect(progression[0], equals(ExpertiseLevel.local));
        expect(progression[5], equals(ExpertiseLevel.universal));
      });

      test('should have correct index progression', () {
        var current = ExpertiseLevel.local;
        var expectedIndex = 0;

        while (current.nextLevel != null) {
          expect(current.index, equals(expectedIndex));
          current = current.nextLevel!;
          expectedIndex++;
        }
        expect(current.index, equals(5)); // universal
      });
    });
  });
}

