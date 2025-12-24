import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:spots/core/services/legal_document_service.dart';
import 'package:spots/core/services/expertise_event_service.dart';
import 'package:spots/core/models/expertise_event.dart';
import 'package:spots/core/models/user_agreement.dart';
import 'package:spots/core/models/unified_user.dart';

import 'legal_document_service_test.mocks.dart';
import '../../helpers/platform_channel_helper.dart';

@GenerateMocks([ExpertiseEventService])
void main() {
  group('LegalDocumentService', () {
    late LegalDocumentService service;
    late MockExpertiseEventService mockEventService;

    late ExpertiseEvent testEvent;

    setUp(() {
      mockEventService = MockExpertiseEventService();
      service = LegalDocumentService(eventService: mockEventService);

      testEvent = ExpertiseEvent(
        id: 'event-123',
        host: UnifiedUser(
          id: 'host-123',
          displayName: 'Test Host',
          email: 'test@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        title: 'Test Event',
        category: 'General',
        description: 'Test Description',
        startTime: DateTime.now().add(const Duration(days: 5)),
        endTime: DateTime.now().add(const Duration(days: 5, hours: 2)),
        maxAttendees: 50,
        attendeeCount: 10,
        eventType: ExpertiseEventType.workshop,
        isPaid: true,
        price: 25.00,
        location: 'Test Location',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    // Removed: Property assignment tests
    // Legal document service tests focus on business logic (agreement creation, validation, revocation), not property assignment

    group('acceptTermsOfService', () {
      test(
          'should create and save Terms of Service agreement, and revoke old agreement when accepting new',
          () async {
        // Test business logic: terms acceptance with revocation of old agreements
        final agreement1 = await service.acceptTermsOfService(
          userId: 'user-123',
          ipAddress: '192.168.1.1',
          userAgent: 'Test Agent',
        );
        expect(agreement1, isA<UserAgreement>());
        expect(agreement1.userId, equals('user-123'));
        expect(agreement1.documentType, equals('terms_of_service'));
        expect(agreement1.version, equals('1.0.0'));
        expect(agreement1.isActive, isTrue);
        expect(agreement1.ipAddress, equals('192.168.1.1'));

        await service.acceptTermsOfService(
          userId: 'user-123',
          ipAddress: '192.168.1.2',
        );
        final agreements = await service.getUserAgreements('user-123');
        final activeAgreements = agreements.where((a) => a.isActive).toList();
        expect(activeAgreements.length, equals(1));
        expect(activeAgreements.first.ipAddress, equals('192.168.1.2'));
      });
    });

    group('acceptPrivacyPolicy', () {
      test('should create and save Privacy Policy agreement', () async {
        // Test business logic: privacy policy acceptance
        final agreement = await service.acceptPrivacyPolicy(
          userId: 'user-123',
          ipAddress: '192.168.1.1',
        );
        expect(agreement, isA<UserAgreement>());
        expect(agreement.documentType, equals('privacy_policy'));
        expect(agreement.version, equals('1.0.0'));
        expect(agreement.isActive, isTrue);
      });
    });

    group('acceptEventWaiver', () {
      test(
          'should create and save event waiver agreement, or throw exception if event not found',
          () async {
        // Test business logic: event waiver acceptance with validation
        when(mockEventService.getEventById('event-123'))
            .thenAnswer((_) async => testEvent);

        final agreement = await service.acceptEventWaiver(
          userId: 'user-123',
          eventId: 'event-123',
          ipAddress: '192.168.1.1',
        );
        expect(agreement, isA<UserAgreement>());
        expect(agreement.documentType, equals('event_waiver'));
        expect(agreement.eventId, equals('event-123'));
        expect(agreement.isActive, isTrue);
        verify(mockEventService.getEventById('event-123')).called(1);

        when(mockEventService.getEventById('event-123'))
            .thenAnswer((_) async => null);
        expect(
          () => service.acceptEventWaiver(
            userId: 'user-123',
            eventId: 'event-123',
          ),
          throwsException,
        );
      });
    });

    group('hasAcceptedTerms', () {
      test(
          'should return false if user has not accepted Terms, or true if user has accepted current version',
          () async {
        // Test business logic: terms acceptance checking
        final hasAccepted1 = await service.hasAcceptedTerms('user-123');
        expect(hasAccepted1, isFalse);
        await service.acceptTermsOfService(
          userId: 'user-123',
          ipAddress: '192.168.1.1',
        );
        final hasAccepted2 = await service.hasAcceptedTerms('user-123');
        expect(hasAccepted2, isTrue);
      });
    });

    group('hasAcceptedPrivacyPolicy', () {
      test(
          'should return false if user has not accepted Privacy Policy, or true if user has accepted current version',
          () async {
        // Test business logic: privacy policy acceptance checking
        final hasAccepted1 = await service.hasAcceptedPrivacyPolicy('user-123');
        expect(hasAccepted1, isFalse);
        await service.acceptPrivacyPolicy(
          userId: 'user-123',
          ipAddress: '192.168.1.1',
        );
        final hasAccepted2 = await service.hasAcceptedPrivacyPolicy('user-123');
        expect(hasAccepted2, isTrue);
      });
    });

    group('hasAcceptedEventWaiver', () {
      test(
          'should return false if user has not accepted waiver, or true if user has accepted waiver',
          () async {
        // Test business logic: event waiver acceptance checking
        final hasAccepted1 =
            await service.hasAcceptedEventWaiver('user-123', 'event-123');
        expect(hasAccepted1, isFalse);
        when(mockEventService.getEventById('event-123'))
            .thenAnswer((_) async => testEvent);
        await service.acceptEventWaiver(
          userId: 'user-123',
          eventId: 'event-123',
        );
        final hasAccepted2 =
            await service.hasAcceptedEventWaiver('user-123', 'event-123');
        expect(hasAccepted2, isTrue);
      });
    });

    group('generateEventWaiver', () {
      test('should generate waiver text for event', () async {
        // Test business logic: event waiver generation
        when(mockEventService.getEventById('event-123'))
            .thenAnswer((_) async => testEvent);
        final waiver = await service.generateEventWaiver('event-123');
        expect(waiver, isNotEmpty);
        expect(waiver, contains('Test Event'));
        verify(mockEventService.getEventById('event-123')).called(1);
      });
    });

    group('needsTermsUpdate', () {
      test(
          'should return true if user has not accepted Terms, or false if user has accepted current version',
          () async {
        // Test business logic: terms update requirement checking
        final needsUpdate1 = await service.needsTermsUpdate('user-123');
        expect(needsUpdate1, isTrue);
        await service.acceptTermsOfService(
          userId: 'user-123',
          ipAddress: '192.168.1.1',
        );
        final needsUpdate2 = await service.needsTermsUpdate('user-123');
        expect(needsUpdate2, isFalse);
      });
    });

    group('revokeAgreement', () {
      test('should revoke an agreement', () async {
        // Test business logic: agreement revocation
        final agreement = await service.acceptTermsOfService(
          userId: 'user-123',
          ipAddress: '192.168.1.1',
        );
        final revoked = await service.revokeAgreement(
          agreementId: agreement.id,
          reason: 'User requested',
        );
        expect(revoked.isActive, isFalse);
        expect(revoked.revokedAt, isNotNull);
        expect(revoked.revocationReason, equals('User requested'));
      });
    });

    tearDownAll(() async {
      await cleanupTestStorage();
    });
  });
}
