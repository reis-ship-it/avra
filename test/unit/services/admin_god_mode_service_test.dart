import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:avrai/core/services/admin_god_mode_service.dart';
import 'package:avrai/core/services/admin_auth_service.dart';
import 'package:avrai/core/services/admin_communication_service.dart';
import 'package:avrai/core/services/business_account_service.dart';
import 'package:avrai/core/services/supabase_service.dart';
import 'package:avrai/core/services/expertise_service.dart';
import 'package:avrai/core/monitoring/connection_monitor.dart';
import 'package:avrai/core/ml/predictive_analytics.dart';
import 'package:avrai/core/ai/ai2ai_learning.dart';

import 'admin_god_mode_service_test.mocks.dart';
import '../../helpers/platform_channel_helper.dart';

@GenerateMocks([
  AdminAuthService,
  AdminCommunicationService,
  BusinessAccountService,
  PredictiveAnalytics,
  ConnectionMonitor,
  AI2AIChatAnalyzer,
  SupabaseService,
  ExpertiseService,
])
void main() {
  group('AdminGodModeService Tests', () {
    late AdminGodModeService service;
    late MockAdminAuthService mockAuthService;
    late MockAdminCommunicationService mockCommunicationService;
    late MockBusinessAccountService mockBusinessService;
    late MockPredictiveAnalytics mockPredictiveAnalytics;
    late MockConnectionMonitor mockConnectionMonitor;
    late MockSupabaseService mockSupabaseService;
    late MockExpertiseService mockExpertiseService;

    setUp(() {
      mockAuthService = MockAdminAuthService();
      mockCommunicationService = MockAdminCommunicationService();
      mockBusinessService = MockBusinessAccountService();
      mockPredictiveAnalytics = MockPredictiveAnalytics();
      mockConnectionMonitor = MockConnectionMonitor();
      mockSupabaseService = MockSupabaseService();
      mockExpertiseService = MockExpertiseService();

      service = AdminGodModeService(
        authService: mockAuthService,
        communicationService: mockCommunicationService,
        businessService: mockBusinessService,
        predictiveAnalytics: mockPredictiveAnalytics,
        connectionMonitor: mockConnectionMonitor,
        supabaseService: mockSupabaseService,
        expertiseService: mockExpertiseService,
      );
    });

    // Removed: Property assignment tests
    // Admin god mode service tests focus on business logic (authorization, data watching, retrieval), not property assignment

    group('isAuthorized', () {
      test(
          'should return false when not authenticated or when authenticated but lacks permission, or true when authenticated with permission',
          () {
        // Test business logic: authorization checking
        when(mockAuthService.isAuthenticated()).thenReturn(false);
        expect(service.isAuthorized, isFalse);

        when(mockAuthService.isAuthenticated()).thenReturn(true);
        when(mockAuthService.hasPermission(AdminPermission.viewRealTimeData))
            .thenReturn(false);
        expect(service.isAuthorized, isFalse);

        when(mockAuthService.isAuthenticated()).thenReturn(true);
        when(mockAuthService.hasPermission(AdminPermission.viewRealTimeData))
            .thenReturn(true);
        expect(service.isAuthorized, isTrue);
      });
    });

    group('watchUserData', () {
      test(
          'should throw exception when not authorized, or return stream when authorized',
          () {
        // Test business logic: user data watching with authorization
        when(mockAuthService.isAuthenticated()).thenReturn(false);
        expect(
          () => service.watchUserData('user-123'),
          throwsA(isA<Exception>()),
        );

        when(mockAuthService.isAuthenticated()).thenReturn(true);
        when(mockAuthService.hasPermission(AdminPermission.viewRealTimeData))
            .thenReturn(true);
        final stream = service.watchUserData('user-123');
        expect(stream, isA<Stream<UserDataSnapshot>>());
      });
    });

    group('watchAIData', () {
      test(
          'should throw exception when not authorized, or return stream when authorized',
          () {
        // Test business logic: AI data watching with authorization
        when(mockAuthService.isAuthenticated()).thenReturn(false);
        expect(
          () => service.watchAIData('ai-signature-123'),
          throwsA(isA<Exception>()),
        );

        when(mockAuthService.isAuthenticated()).thenReturn(true);
        when(mockAuthService.hasPermission(AdminPermission.viewRealTimeData))
            .thenReturn(true);
        final stream = service.watchAIData('ai-signature-123');
        expect(stream, isA<Stream<AIDataSnapshot>>());
      });
    });

    group('watchCommunications', () {
      test(
          'should throw exception when not authorized, or return stream when authorized',
          () {
        // Test business logic: communications watching with authorization
        when(mockAuthService.isAuthenticated()).thenReturn(false);
        expect(
          () => service.watchCommunications(),
          throwsA(isA<Exception>()),
        );

        when(mockAuthService.isAuthenticated()).thenReturn(true);
        when(mockAuthService.hasPermission(AdminPermission.viewRealTimeData))
            .thenReturn(true);
        final stream = service.watchCommunications();
        expect(stream, isA<Stream<CommunicationsSnapshot>>());
      });
    });

    group('Data Retrieval Methods', () {
      test(
          'should throw exception when not authorized for getUserProgress, getDashboardData, searchUsers, getUserPredictions, and getAllBusinessAccounts',
          () async {
        // Test business logic: authorization enforcement for all data retrieval methods
        when(mockAuthService.isAuthenticated()).thenReturn(false);

        expect(
          () => service.getUserProgress('user-123'),
          throwsA(isA<Exception>()),
        );

        expect(
          () => service.getDashboardData(),
          throwsA(isA<Exception>()),
        );

        expect(
          () => service.searchUsers(),
          throwsA(isA<Exception>()),
        );

        expect(
          () => service.getUserPredictions('user-123'),
          throwsA(isA<Exception>()),
        );

        expect(
          () => service.getAllBusinessAccounts(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('dispose', () {
      test('should cleanup streams and cache', () {
        when(mockAuthService.isAuthenticated()).thenReturn(true);
        when(mockAuthService.hasPermission(AdminPermission.viewRealTimeData))
            .thenReturn(true);

        // Create a stream to test disposal
        final stream = service.watchUserData('user-123');
        expect(stream, isA<Stream<UserDataSnapshot>>());

        // Dispose should not throw
        expect(() => service.dispose(), returnsNormally);
      });
    });

    tearDownAll(() async {
      await cleanupTestStorage();
    });
  });
}
