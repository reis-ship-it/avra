import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/models/business_verification.dart';
import '../../helpers/test_helpers.dart';

/// Comprehensive tests for BusinessVerification model
/// Tests verification status, methods, progress calculation, and JSON serialization
void main() {
  group('BusinessVerification Model Tests', () {
    late DateTime testDate;

    setUp(() {
      TestHelpers.setupTestEnvironment();
      testDate = TestHelpers.createTestDateTime();
    });

    tearDown(() {
      TestHelpers.teardownTestEnvironment();
    });

    group('Constructor and Properties', () {
      test('should create verification with required fields', () {
        final verification = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          submittedAt: testDate,
          updatedAt: testDate,
        );

        expect(verification.id, equals('verification-123'));
        expect(verification.businessAccountId, equals('business-123'));
        expect(verification.status, equals(VerificationStatus.pending));
        expect(verification.method, equals(VerificationMethod.automatic));
        expect(verification.submittedAt, equals(testDate));
        expect(verification.updatedAt, equals(testDate));
        
        // Test default values
        expect(verification.businessLicenseUrl, isNull);
        expect(verification.taxIdDocumentUrl, isNull);
        expect(verification.proofOfAddressUrl, isNull);
        expect(verification.websiteVerificationUrl, isNull);
        expect(verification.socialMediaVerificationUrl, isNull);
        expect(verification.legalBusinessName, isNull);
        expect(verification.taxId, isNull);
        expect(verification.businessAddress, isNull);
        expect(verification.phoneNumber, isNull);
        expect(verification.websiteUrl, isNull);
        expect(verification.verifiedBy, isNull);
        expect(verification.verifiedAt, isNull);
        expect(verification.rejectionReason, isNull);
        expect(verification.rejectedAt, isNull);
        expect(verification.notes, isNull);
      });

      test('should create verification with all fields', () {
        final verifiedAt = testDate.add(Duration(days: 1));
        final verification = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          status: VerificationStatus.verified,
          method: VerificationMethod.manual,
          businessLicenseUrl: 'https://example.com/license.pdf',
          taxIdDocumentUrl: 'https://example.com/tax.pdf',
          proofOfAddressUrl: 'https://example.com/address.pdf',
          websiteVerificationUrl: 'https://example.com/website.png',
          socialMediaVerificationUrl: 'https://example.com/social.png',
          legalBusinessName: 'Legal Business Name Inc.',
          taxId: '12-3456789',
          businessAddress: '123 Main St, NYC, NY 10001',
          phoneNumber: '+1-555-0123',
          websiteUrl: 'https://example.com',
          verifiedBy: 'admin-123',
          verifiedAt: verifiedAt,
          notes: 'All documents verified',
          submittedAt: testDate,
          updatedAt: verifiedAt,
        );

        expect(verification.status, equals(VerificationStatus.verified));
        expect(verification.method, equals(VerificationMethod.manual));
        expect(verification.businessLicenseUrl, equals('https://example.com/license.pdf'));
        expect(verification.legalBusinessName, equals('Legal Business Name Inc.'));
        expect(verification.taxId, equals('12-3456789'));
        expect(verification.verifiedBy, equals('admin-123'));
        expect(verification.verifiedAt, equals(verifiedAt));
        expect(verification.notes, equals('All documents verified'));
      });
    });

    group('Verification Status Enum', () {
      test('should have all status values', () {
        expect(VerificationStatus.values, hasLength(5));
        expect(VerificationStatus.values, contains(VerificationStatus.pending));
        expect(VerificationStatus.values, contains(VerificationStatus.inReview));
        expect(VerificationStatus.values, contains(VerificationStatus.verified));
        expect(VerificationStatus.values, contains(VerificationStatus.rejected));
        expect(VerificationStatus.values, contains(VerificationStatus.expired));
      });

      test('should have correct display names', () {
        expect(VerificationStatus.pending.displayName, equals('Pending'));
        expect(VerificationStatus.inReview.displayName, equals('In Review'));
        expect(VerificationStatus.verified.displayName, equals('Verified'));
        expect(VerificationStatus.rejected.displayName, equals('Rejected'));
        expect(VerificationStatus.expired.displayName, equals('Expired'));
      });

      test('should parse status from string correctly', () {
        expect(VerificationStatusExtension.fromString('pending'), equals(VerificationStatus.pending));
        expect(VerificationStatusExtension.fromString('inreview'), equals(VerificationStatus.inReview));
        expect(VerificationStatusExtension.fromString('in_review'), equals(VerificationStatus.inReview));
        expect(VerificationStatusExtension.fromString('verified'), equals(VerificationStatus.verified));
        expect(VerificationStatusExtension.fromString('rejected'), equals(VerificationStatus.rejected));
        expect(VerificationStatusExtension.fromString('expired'), equals(VerificationStatus.expired));
        expect(VerificationStatusExtension.fromString('unknown'), equals(VerificationStatus.pending));
        expect(VerificationStatusExtension.fromString(null), equals(VerificationStatus.pending));
      });
    });

    group('Verification Method Enum', () {
      test('should have all method values', () {
        expect(VerificationMethod.values, hasLength(4));
        expect(VerificationMethod.values, contains(VerificationMethod.automatic));
        expect(VerificationMethod.values, contains(VerificationMethod.manual));
        expect(VerificationMethod.values, contains(VerificationMethod.document));
        expect(VerificationMethod.values, contains(VerificationMethod.hybrid));
      });

      test('should have correct display names', () {
        expect(VerificationMethod.automatic.displayName, equals('Automatic'));
        expect(VerificationMethod.manual.displayName, equals('Manual Review'));
        expect(VerificationMethod.document.displayName, equals('Document Verification'));
        expect(VerificationMethod.hybrid.displayName, equals('Hybrid'));
      });

      test('should parse method from string correctly', () {
        expect(VerificationMethodExtension.fromString('automatic'), equals(VerificationMethod.automatic));
        expect(VerificationMethodExtension.fromString('manual'), equals(VerificationMethod.manual));
        expect(VerificationMethodExtension.fromString('document'), equals(VerificationMethod.document));
        expect(VerificationMethodExtension.fromString('hybrid'), equals(VerificationMethod.hybrid));
        expect(VerificationMethodExtension.fromString('unknown'), equals(VerificationMethod.automatic));
        expect(VerificationMethodExtension.fromString(null), equals(VerificationMethod.automatic));
      });
    });

    group('Status Checkers', () {
      test('isComplete should return true for verified status', () {
        final verification = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          status: VerificationStatus.verified,
          submittedAt: testDate,
          updatedAt: testDate,
        );

        expect(verification.isComplete, isTrue);
      });

      test('isComplete should return false for non-verified status', () {
        final verification = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          status: VerificationStatus.pending,
          submittedAt: testDate,
          updatedAt: testDate,
        );

        expect(verification.isComplete, isFalse);
      });

      test('isPending should return true for pending status', () {
        final verification = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          status: VerificationStatus.pending,
          submittedAt: testDate,
          updatedAt: testDate,
        );

        expect(verification.isPending, isTrue);
      });

      test('isRejected should return true for rejected status', () {
        final verification = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          status: VerificationStatus.rejected,
          submittedAt: testDate,
          updatedAt: testDate,
        );

        expect(verification.isRejected, isTrue);
      });
    });

    group('Progress Calculation', () {
      test('should calculate 0.0 progress with no fields filled', () {
        final verification = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          submittedAt: testDate,
          updatedAt: testDate,
        );

        expect(verification.progress, equals(0.0));
      });

      test('should calculate 0.25 progress with legal business name only', () {
        final verification = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          legalBusinessName: 'Legal Name',
          submittedAt: testDate,
          updatedAt: testDate,
        );

        expect(verification.progress, equals(0.25));
      });

      test('should calculate 0.5 progress with name and address', () {
        final verification = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          legalBusinessName: 'Legal Name',
          businessAddress: '123 Main St',
          submittedAt: testDate,
          updatedAt: testDate,
        );

        expect(verification.progress, equals(0.5));
      });

      test('should calculate 0.75 progress with name, address, and phone', () {
        final verification = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          legalBusinessName: 'Legal Name',
          businessAddress: '123 Main St',
          phoneNumber: '+1-555-0123',
          submittedAt: testDate,
          updatedAt: testDate,
        );

        expect(verification.progress, equals(0.75));
      });

      test('should calculate 1.0 progress with all required fields', () {
        final verification = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          legalBusinessName: 'Legal Name',
          businessAddress: '123 Main St',
          phoneNumber: '+1-555-0123',
          businessLicenseUrl: 'https://example.com/license.pdf',
          submittedAt: testDate,
          updatedAt: testDate,
        );

        expect(verification.progress, equals(1.0));
      });

      test('should calculate 1.0 progress with taxIdDocumentUrl instead of businessLicenseUrl', () {
        final verification = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          legalBusinessName: 'Legal Name',
          businessAddress: '123 Main St',
          phoneNumber: '+1-555-0123',
          taxIdDocumentUrl: 'https://example.com/tax.pdf',
          submittedAt: testDate,
          updatedAt: testDate,
        );

        expect(verification.progress, equals(1.0));
      });

      test('should calculate 1.0 progress with proofOfAddressUrl instead of businessLicenseUrl', () {
        final verification = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          legalBusinessName: 'Legal Name',
          businessAddress: '123 Main St',
          phoneNumber: '+1-555-0123',
          proofOfAddressUrl: 'https://example.com/address.pdf',
          submittedAt: testDate,
          updatedAt: testDate,
        );

        expect(verification.progress, equals(1.0));
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final verifiedAt = testDate.add(Duration(days: 1));
        final verification = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          status: VerificationStatus.verified,
          method: VerificationMethod.manual,
          legalBusinessName: 'Legal Name',
          businessAddress: '123 Main St',
          phoneNumber: '+1-555-0123',
          verifiedBy: 'admin-123',
          verifiedAt: verifiedAt,
          submittedAt: testDate,
          updatedAt: verifiedAt,
        );

        final json = verification.toJson();

        expect(json['id'], equals('verification-123'));
        expect(json['businessAccountId'], equals('business-123'));
        expect(json['status'], equals('verified'));
        expect(json['method'], equals('manual'));
        expect(json['legalBusinessName'], equals('Legal Name'));
        expect(json['businessAddress'], equals('123 Main St'));
        expect(json['phoneNumber'], equals('+1-555-0123'));
        expect(json['verifiedBy'], equals('admin-123'));
        expect(json['verifiedAt'], equals(verifiedAt.toIso8601String()));
        expect(json['submittedAt'], equals(testDate.toIso8601String()));
        expect(json['updatedAt'], equals(verifiedAt.toIso8601String()));
      });

      test('should deserialize from JSON correctly', () {
        final verifiedAt = testDate.add(Duration(days: 1));
        final json = {
          'id': 'verification-123',
          'businessAccountId': 'business-123',
          'status': 'verified',
          'method': 'manual',
          'legalBusinessName': 'Legal Name',
          'businessAddress': '123 Main St',
          'phoneNumber': '+1-555-0123',
          'websiteUrl': 'https://example.com',
          'verifiedBy': 'admin-123',
          'verifiedAt': verifiedAt.toIso8601String(),
          'rejectionReason': null,
          'rejectedAt': null,
          'notes': 'Verified',
          'submittedAt': testDate.toIso8601String(),
          'updatedAt': verifiedAt.toIso8601String(),
        };

        final verification = BusinessVerification.fromJson(json);

        expect(verification.id, equals('verification-123'));
        expect(verification.businessAccountId, equals('business-123'));
        expect(verification.status, equals(VerificationStatus.verified));
        expect(verification.method, equals(VerificationMethod.manual));
        expect(verification.legalBusinessName, equals('Legal Name'));
        expect(verification.businessAddress, equals('123 Main St'));
        expect(verification.phoneNumber, equals('+1-555-0123'));
        expect(verification.websiteUrl, equals('https://example.com'));
        expect(verification.verifiedBy, equals('admin-123'));
        expect(verification.verifiedAt, equals(verifiedAt));
        expect(verification.notes, equals('Verified'));
        expect(verification.submittedAt, equals(testDate));
        expect(verification.updatedAt, equals(verifiedAt));
      });

      test('should handle null optional fields in JSON', () {
        final json = {
          'id': 'verification-123',
          'businessAccountId': 'business-123',
          'submittedAt': testDate.toIso8601String(),
          'updatedAt': testDate.toIso8601String(),
        };

        final verification = BusinessVerification.fromJson(json);

        expect(verification.status, equals(VerificationStatus.pending));
        expect(verification.method, equals(VerificationMethod.automatic));
        expect(verification.legalBusinessName, isNull);
        expect(verification.businessAddress, isNull);
        expect(verification.phoneNumber, isNull);
        expect(verification.verifiedBy, isNull);
        expect(verification.verifiedAt, isNull);
        expect(verification.rejectionReason, isNull);
        expect(verification.rejectedAt, isNull);
      });

      test('should handle rejected verification in JSON', () {
        final rejectedAt = testDate.add(Duration(days: 1));
        final json = {
          'id': 'verification-123',
          'businessAccountId': 'business-123',
          'status': 'rejected',
          'rejectionReason': 'Incomplete documentation',
          'rejectedAt': rejectedAt.toIso8601String(),
          'submittedAt': testDate.toIso8601String(),
          'updatedAt': rejectedAt.toIso8601String(),
        };

        final verification = BusinessVerification.fromJson(json);

        expect(verification.status, equals(VerificationStatus.rejected));
        expect(verification.rejectionReason, equals('Incomplete documentation'));
        expect(verification.rejectedAt, equals(rejectedAt));
      });
    });

    group('copyWith', () {
      test('should create copy with modified fields', () {
        final original = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          status: VerificationStatus.pending,
          submittedAt: testDate,
          updatedAt: testDate,
        );

        final updated = original.copyWith(
          status: VerificationStatus.verified,
          verifiedBy: 'admin-123',
          verifiedAt: testDate.add(Duration(days: 1)),
        );

        expect(updated.id, equals('verification-123')); // Unchanged
        expect(updated.status, equals(VerificationStatus.verified)); // Changed
        expect(updated.verifiedBy, equals('admin-123')); // Changed
        expect(updated.verifiedAt, isNotNull); // Changed
        expect(updated.submittedAt, equals(testDate)); // Unchanged
      });

      test('should create copy with null fields', () {
        final original = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          legalBusinessName: 'Original Name',
          submittedAt: testDate,
          updatedAt: testDate,
        );

        final updated = original.copyWith(legalBusinessName: null);

        expect(updated.legalBusinessName, isNull);
        expect(updated.id, equals('verification-123')); // Unchanged
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        final verification1 = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          status: VerificationStatus.verified,
          submittedAt: testDate,
          updatedAt: testDate,
        );

        final verification2 = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          status: VerificationStatus.verified,
          submittedAt: testDate,
          updatedAt: testDate,
        );

        expect(verification1, equals(verification2));
      });

      test('should not be equal when properties differ', () {
        final verification1 = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          status: VerificationStatus.pending,
          submittedAt: testDate,
          updatedAt: testDate,
        );

        final verification2 = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          status: VerificationStatus.verified, // Different status
          submittedAt: testDate,
          updatedAt: testDate,
        );

        expect(verification1, isNot(equals(verification2)));
      });
    });

    group('Edge Cases', () {
      test('should handle empty strings', () {
        final verification = BusinessVerification(
          id: '',
          businessAccountId: '',
          legalBusinessName: '',
          businessAddress: '',
          phoneNumber: '',
          submittedAt: testDate,
          updatedAt: testDate,
        );

        expect(verification.id, isEmpty);
        expect(verification.businessAccountId, isEmpty);
        expect(verification.legalBusinessName, isEmpty);
        expect(verification.businessAddress, isEmpty);
        expect(verification.phoneNumber, isEmpty);
      });

      test('should handle very long strings', () {
        final longName = 'A' * 1000;
        final longAddress = 'B' * 2000;
        final longReason = 'C' * 5000;

        final verification = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          legalBusinessName: longName,
          businessAddress: longAddress,
          rejectionReason: longReason,
          submittedAt: testDate,
          updatedAt: testDate,
        );

        expect(verification.legalBusinessName, equals(longName));
        expect(verification.businessAddress, equals(longAddress));
        expect(verification.rejectionReason, equals(longReason));
      });

      test('should handle special characters in strings', () {
        final verification = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          legalBusinessName: r'Business @#$%^&*()_+ Name',
          businessAddress: r'Address !@#$%^&*()_+ Street',
          rejectionReason: r'Reason with !@#$%^&*()_+ chars',
          submittedAt: testDate,
          updatedAt: testDate,
        );

        expect(verification.legalBusinessName, contains(r'@#$%^&*()_+'));
        expect(verification.businessAddress, contains(r'!@#$%^&*()_+'));
        expect(verification.rejectionReason, contains(r'!@#$%^&*()_+'));
      });
    });
  });
}

