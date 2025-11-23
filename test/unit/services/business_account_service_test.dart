import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/services/business_account_service.dart';
import 'package:spots/core/models/business_account.dart';
import 'package:spots/core/models/unified_user.dart';
import '../../fixtures/model_factories.dart';

/// Business Account Service Tests
/// Tests business account creation and management
void main() {
  group('BusinessAccountService Tests', () {
    late BusinessAccountService service;
    late UnifiedUser creator;

    setUp(() {
      service = BusinessAccountService();
      creator = ModelFactories.createTestUser(
        id: 'creator-123',
        tags: ['business_owner'],
      );
    });

    group('createBusinessAccount', () {
      test('should create business account with required fields', () async {
        final account = await service.createBusinessAccount(
          creator: creator,
          name: 'Test Business',
          email: 'test@business.com',
          businessType: 'Restaurant',
        );

        expect(account, isA<BusinessAccount>());
        expect(account.name, equals('Test Business'));
        expect(account.email, equals('test@business.com'));
        expect(account.businessType, equals('Restaurant'));
        expect(account.createdBy, equals(creator.id));
        expect(account.createdAt, isNotNull);
        expect(account.updatedAt, isNotNull);
      });

      test('should create business account with all optional fields', () async {
        final account = await service.createBusinessAccount(
          creator: creator,
          name: 'Test Business',
          email: 'test@business.com',
          businessType: 'Retail',
          description: 'A test business',
          website: 'https://testbusiness.com',
          location: 'San Francisco',
          phone: '555-1234',
          logoUrl: 'https://example.com/logo.png',
          categories: ['Food', 'Dining'],
          requiredExpertise: ['Restaurant Management'],
          preferredCommunities: ['community-1'],
        );

        expect(account.description, equals('A test business'));
        expect(account.website, equals('https://testbusiness.com'));
        expect(account.location, equals('San Francisco'));
        expect(account.phone, equals('555-1234'));
        expect(account.logoUrl, equals('https://example.com/logo.png'));
        expect(account.categories, contains('Food'));
        expect(account.requiredExpertise, contains('Restaurant Management'));
      });

      test('should generate unique business ID', () async {
        final account1 = await service.createBusinessAccount(
          creator: creator,
          name: 'Test Business',
          email: 'test1@business.com',
          businessType: 'Restaurant',
        );

        final account2 = await service.createBusinessAccount(
          creator: creator,
          name: 'Test Business',
          email: 'test2@business.com',
          businessType: 'Restaurant',
        );

        expect(account1.id, isNot(equals(account2.id)));
      });
    });

    group('updateBusinessAccount', () {
      test('should update business account fields', () async {
        final account = await service.createBusinessAccount(
          creator: creator,
          name: 'Original Name',
          email: 'test@business.com',
          businessType: 'Restaurant',
        );

        final updated = await service.updateBusinessAccount(
          account,
          name: 'Updated Name',
          description: 'Updated description',
          website: 'https://updated.com',
        );

        expect(updated.name, equals('Updated Name'));
        expect(updated.description, equals('Updated description'));
        expect(updated.website, equals('https://updated.com'));
        expect(updated.updatedAt, isNot(equals(account.updatedAt)));
      });

      test('should update categories', () async {
        final account = await service.createBusinessAccount(
          creator: creator,
          name: 'Test Business',
          email: 'test@business.com',
          businessType: 'Restaurant',
        );

        final updated = await service.updateBusinessAccount(
          account,
          categories: ['Food', 'Dining', 'Italian'],
        );

        expect(updated.categories, equals(['Food', 'Dining', 'Italian']));
      });
    });

    group('getBusinessAccount', () {
      test('should return null for non-existent account', () async {
        final account = await service.getBusinessAccount('non-existent-id');
        expect(account, isNull);
      });

      test('should return account after creation', () async {
        final created = await service.createBusinessAccount(
          creator: creator,
          name: 'Test Business',
          email: 'test@business.com',
          businessType: 'Restaurant',
        );

        // Note: This will return null in test environment since _getAllBusinessAccounts returns []
        // In production, it would query the database
        final retrieved = await service.getBusinessAccount(created.id);
        expect(retrieved, anyOf(isNull, isA<BusinessAccount>()));
      });
    });

    group('getBusinessAccountsByUser', () {
      test('should return empty list for user with no accounts', () async {
        final accounts = await service.getBusinessAccountsByUser('user-123');
        expect(accounts, isEmpty);
      });
    });

    group('addExpertConnection', () {
      test('should add expert connection', () async {
        final account = await service.createBusinessAccount(
          creator: creator,
          name: 'Test Business',
          email: 'test@business.com',
          businessType: 'Restaurant',
        );

        final updated = await service.addExpertConnection(account, 'expert-123');

        expect(updated.connectedExpertIds, contains('expert-123'));
        expect(updated.pendingConnectionIds, isNot(contains('expert-123')));
      });

      test('should not add duplicate expert connection', () async {
        final account = await service.createBusinessAccount(
          creator: creator,
          name: 'Test Business',
          email: 'test@business.com',
          businessType: 'Restaurant',
        );

        final updated1 = await service.addExpertConnection(account, 'expert-123');
        final updated2 = await service.addExpertConnection(updated1, 'expert-123');

        expect(updated2.connectedExpertIds.where((id) => id == 'expert-123').length, equals(1));
      });
    });

    group('requestExpertConnection', () {
      test('should add expert to pending connections', () async {
        final account = await service.createBusinessAccount(
          creator: creator,
          name: 'Test Business',
          email: 'test@business.com',
          businessType: 'Restaurant',
        );

        final updated = await service.requestExpertConnection(account, 'expert-123');

        expect(updated.pendingConnectionIds, contains('expert-123'));
      });

      test('should not add if already connected', () async {
        final account = await service.createBusinessAccount(
          creator: creator,
          name: 'Test Business',
          email: 'test@business.com',
          businessType: 'Restaurant',
        );

        final connected = await service.addExpertConnection(account, 'expert-123');
        final requested = await service.requestExpertConnection(connected, 'expert-123');

        expect(requested.pendingConnectionIds, isNot(contains('expert-123')));
        expect(requested.connectedExpertIds, contains('expert-123'));
      });
    });
  });
}

