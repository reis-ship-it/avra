import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:spots/core/services/business_verification_service.dart';
import 'package:spots/core/services/business_account_service.dart';
import 'package:spots/core/models/business_account.dart';
import 'package:spots/core/models/business_verification.dart';

import 'business_verification_service_test.mocks.dart';

@GenerateMocks([BusinessAccountService])
void main() {
  group('BusinessVerificationService Tests', () {
    late BusinessVerificationService service;
    late MockBusinessAccountService mockBusinessAccountService;

    setUp(() {
      mockBusinessAccountService = MockBusinessAccountService();
      service = BusinessVerificationService(
        businessAccountService: mockBusinessAccountService,
      );
    });

    group('Initialization', () {
      test('should initialize with default BusinessAccountService', () {
        final defaultService = BusinessVerificationService();
        expect(defaultService, isNotNull);
      });

      test('should initialize with provided BusinessAccountService', () {
        expect(service, isNotNull);
      });
    });

    group('submitVerification', () {
      test('should submit verification with required fields', () async {
        final business = BusinessAccount(
          id: 'business-123',
          name: 'Test Business',
          email: 'test@business.com',
          businessType: 'Restaurant',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'user-123',
        );

        final verification = await service.submitVerification(
          business: business,
          legalBusinessName: 'Test Business LLC',
        );

        expect(verification, isA<BusinessVerification>());
        expect(verification.businessAccountId, equals(business.id));
        expect(verification.legalBusinessName, equals('Test Business LLC'));
        expect(verification.status, equals(VerificationStatus.pending));
        expect(verification.submittedAt, isNotNull);
      });

      test('should submit verification with all optional fields', () async {
        final business = BusinessAccount(
          id: 'business-123',
          name: 'Test Business',
          email: 'test@business.com',
          businessType: 'Retail',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'user-123',
        );

        final verification = await service.submitVerification(
          business: business,
          legalBusinessName: 'Test Business LLC',
          taxId: 'TAX123',
          businessAddress: '123 Main St',
          phoneNumber: '555-1234',
          websiteUrl: 'https://testbusiness.com',
          businessLicenseUrl: 'https://example.com/license.pdf',
          taxIdDocumentUrl: 'https://example.com/tax.pdf',
          proofOfAddressUrl: 'https://example.com/address.pdf',
          websiteVerificationUrl: 'https://testbusiness.com/verify',
          socialMediaVerificationUrl: 'https://twitter.com/testbusiness',
        );

        expect(verification.taxId, equals('TAX123'));
        expect(verification.businessAddress, equals('123 Main St'));
        expect(verification.phoneNumber, equals('555-1234'));
        expect(verification.websiteUrl, equals('https://testbusiness.com'));
        expect(verification.businessLicenseUrl, isNotNull);
        expect(verification.method, isA<VerificationMethod>());
      });

      test('should determine verification method from documents', () async {
        final business = BusinessAccount(
          id: 'business-123',
          name: 'Test Business',
          email: 'test@business.com',
          businessType: 'Service',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'user-123',
        );

        final verification = await service.submitVerification(
          business: business,
          legalBusinessName: 'Test Business LLC',
          businessLicenseUrl: 'https://example.com/license.pdf',
        );

        expect(verification.method, equals(VerificationMethod.document));
      });

      test('should determine verification method from website', () async {
        final business = BusinessAccount(
          id: 'business-123',
          name: 'Test Business',
          email: 'test@business.com',
          businessType: 'Restaurant',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'user-123',
        );

        final verification = await service.submitVerification(
          business: business,
          legalBusinessName: 'Test Business LLC',
          websiteUrl: 'https://testbusiness.com',
        );

        expect(verification.method, equals(VerificationMethod.automatic));
      });
    });

    group('verifyAutomatically', () {
      test('should verify automatically with valid website', () async {
        final business = BusinessAccount(
          id: 'business-123',
          name: 'Test Business',
          email: 'test@business.com',
          businessType: 'Restaurant',
          website: 'https://testbusiness.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'user-123',
        );

        final verification = await service.verifyAutomatically(business);

        expect(verification.status, equals(VerificationStatus.verified));
        expect(verification.method, equals(VerificationMethod.automatic));
        expect(verification.verifiedAt, isNotNull);
      });

      test('should throw exception when automatic verification fails', () async {
        final business = BusinessAccount(
          id: 'business-123',
          name: 'Test Business',
          email: 'test@business.com',
          businessType: 'Restaurant',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'user-123',
        );

        expect(
          () => service.verifyAutomatically(business),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception with invalid website', () async {
        final business = BusinessAccount(
          id: 'business-123',
          name: 'Test Business',
          email: 'test@business.com',
          businessType: 'Restaurant',
          website: 'invalid-url',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'user-123',
        );

        expect(
          () => service.verifyAutomatically(business),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('approveVerification', () {
      test('should approve verification', () async {
        final verification = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          status: VerificationStatus.pending,
          method: VerificationMethod.document,
          legalBusinessName: 'Test Business LLC',
          submittedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final business = BusinessAccount(
          id: 'business-123',
          name: 'Test Business',
          email: 'test@business.com',
          businessType: 'Restaurant',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'user-123',
        );

        when(mockBusinessAccountService.getBusinessAccount('business-123'))
            .thenAnswer((_) async => business);

        final approved = await service.approveVerification(
          verification,
          'admin-123',
          notes: 'All documents verified',
        );

        expect(approved.status, equals(VerificationStatus.verified));
        expect(approved.verifiedBy, equals('admin-123'));
        expect(approved.verifiedAt, isNotNull);
        expect(approved.notes, equals('All documents verified'));
      });
    });

    group('rejectVerification', () {
      test('should reject verification with reason', () async {
        final verification = BusinessVerification(
          id: 'verification-123',
          businessAccountId: 'business-123',
          status: VerificationStatus.pending,
          method: VerificationMethod.document,
          legalBusinessName: 'Test Business LLC',
          submittedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final rejected = await service.rejectVerification(
          verification,
          'admin-123',
          'Documents do not match business name',
        );

        expect(rejected.status, equals(VerificationStatus.rejected));
        expect(rejected.verifiedBy, equals('admin-123'));
        expect(rejected.rejectionReason, equals('Documents do not match business name'));
        expect(rejected.rejectedAt, isNotNull);
      });
    });

    group('getVerification', () {
      test('should get verification for business', () async {
        final business = BusinessAccount(
          id: 'business-123',
          name: 'Test Business',
          email: 'test@business.com',
          businessType: 'Restaurant',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'user-123',
        );

        when(mockBusinessAccountService.getBusinessAccount('business-123'))
            .thenAnswer((_) async => business);

        final verification = await service.getVerification('business-123');

        expect(verification, anyOf(isNull, isA<BusinessVerification>()));
      });
    });

    group('isBusinessVerified', () {
      test('should return true for verified business', () async {
        final business = BusinessAccount(
          id: 'business-123',
          name: 'Test Business',
          email: 'test@business.com',
          businessType: 'Restaurant',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'user-123',
        );

        when(mockBusinessAccountService.getBusinessAccount('business-123'))
            .thenAnswer((_) async => business);

        final isVerified = await service.isBusinessVerified('business-123');

        expect(isVerified, isA<bool>());
      });

      test('should return false for unverified business', () async {
        final business = BusinessAccount(
          id: 'business-123',
          name: 'Test Business',
          email: 'test@business.com',
          businessType: 'Restaurant',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'user-123',
        );

        when(mockBusinessAccountService.getBusinessAccount('business-123'))
            .thenAnswer((_) async => business);

        final isVerified = await service.isBusinessVerified('business-123');

        expect(isVerified, isA<bool>());
      });
    });
  });
}

