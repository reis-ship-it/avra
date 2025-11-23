import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:spots/core/services/admin_god_mode_service.dart';
import 'package:spots/core/services/admin_auth_service.dart';
import 'package:spots/core/services/admin_communication_service.dart';
import 'package:spots/core/services/business_account_service.dart';
import 'package:spots/core/services/supabase_service.dart';
import 'package:spots/core/services/expertise_service.dart';
import 'package:spots/core/monitoring/connection_monitor.dart';
import 'package:spots/core/ml/predictive_analytics.dart';
import 'package:spots/core/ai/ai2ai_learning.dart';

import 'admin_god_mode_service_test.mocks.dart';

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

    group('isAuthorized', () {
      test('should return false when not authenticated', () {
        when(mockAuthService.isAuthenticated()).thenReturn(false);

        expect(service.isAuthorized, isFalse);
      });

      test('should return false when authenticated but lacks permission', () {
        when(mockAuthService.isAuthenticated()).thenReturn(true);
        when(mockAuthService.hasPermission(AdminPermission.viewRealTimeData))
            .thenReturn(false);

        expect(service.isAuthorized, isFalse);
      });

      test('should return true when authenticated with permission', () {
        when(mockAuthService.isAuthenticated()).thenReturn(true);
        when(mockAuthService.hasPermission(AdminPermission.viewRealTimeData))
            .thenReturn(true);

        expect(service.isAuthorized, isTrue);
      });
    });

    group('watchUserData', () {
      test('should throw exception when not authorized', () {
        when(mockAuthService.isAuthenticated()).thenReturn(false);

        expect(
          () => service.watchUserData('user-123'),
          throwsA(isA<Exception>()),
        );
      });

      test('should return stream when authorized', () {
        when(mockAuthService.isAuthenticated()).thenReturn(true);
        when(mockAuthService.hasPermission(AdminPermission.viewRealTimeData))
            .thenReturn(true);

        final stream = service.watchUserData('user-123');

        expect(stream, isA<Stream<UserDataSnapshot>>());
      });
    });

    group('watchAIData', () {
      test('should throw exception when not authorized', () {
        when(mockAuthService.isAuthenticated()).thenReturn(false);

        expect(
          () => service.watchAIData('ai-signature-123'),
          throwsA(isA<Exception>()),
        );
      });

      test('should return stream when authorized', () {
        when(mockAuthService.isAuthenticated()).thenReturn(true);
        when(mockAuthService.hasPermission(AdminPermission.viewRealTimeData))
            .thenReturn(true);

        final stream = service.watchAIData('ai-signature-123');

        expect(stream, isA<Stream<AIDataSnapshot>>());
      });
    });

    group('watchCommunications', () {
      test('should throw exception when not authorized', () {
        when(mockAuthService.isAuthenticated()).thenReturn(false);

        expect(
          () => service.watchCommunications(),
          throwsA(isA<Exception>()),
        );
      });

      test('should return stream when authorized', () {
        when(mockAuthService.isAuthenticated()).thenReturn(true);
        when(mockAuthService.hasPermission(AdminPermission.viewRealTimeData))
            .thenReturn(true);

        final stream = service.watchCommunications();

        expect(stream, isA<Stream<CommunicationsSnapshot>>());
      });
    });

    group('getUserProgress', () {
      test('should throw exception when not authorized', () async {
        when(mockAuthService.isAuthenticated()).thenReturn(false);

        expect(
          () => service.getUserProgress('user-123'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getDashboardData', () {
      test('should throw exception when not authorized', () async {
        when(mockAuthService.isAuthenticated()).thenReturn(false);

        expect(
          () => service.getDashboardData(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('searchUsers', () {
      test('should throw exception when not authorized', () async {
        when(mockAuthService.isAuthenticated()).thenReturn(false);

        expect(
          () => service.searchUsers(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getUserPredictions', () {
      test('should throw exception when not authorized', () async {
        when(mockAuthService.isAuthenticated()).thenReturn(false);

        expect(
          () => service.getUserPredictions('user-123'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getAllBusinessAccounts', () {
      test('should throw exception when not authorized', () async {
        when(mockAuthService.isAuthenticated()).thenReturn(false);

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
  });
}

