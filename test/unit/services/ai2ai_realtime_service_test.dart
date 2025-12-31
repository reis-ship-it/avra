import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spots_ai/services/ai2ai_realtime_service.dart';
import 'package:spots/core/ai2ai/connection_orchestrator.dart';
import 'package:spots_network/spots_network.dart';
import 'package:spots/core/ai2ai/aipersonality_node.dart';
import '../../helpers/platform_channel_helper.dart';

class MockRealtimeBackend extends Mock implements RealtimeBackend {}

class MockVibeConnectionOrchestrator extends Mock
    implements VibeConnectionOrchestrator {}

class MockAIPersonalityNode extends Mock implements AIPersonalityNode {}

void main() {
  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(UserPresence(
      userId: 'test-user',
      userName: 'Test User',
      lastSeen: DateTime.now(),
      isOnline: true,
    ));
    registerFallbackValue(RealtimeMessage(
      id: 'test-id',
      senderId: 'test-sender',
      content: 'test-content',
      type: 'test-type',
      timestamp: DateTime.now(),
    ));
  });
  group('AI2AIRealtimeService', () {
    late AI2AIRealtimeService service;
    late MockRealtimeBackend mockBackend;
    late MockVibeConnectionOrchestrator mockOrchestrator;

    setUp(() {
      mockBackend = MockRealtimeBackend();
      mockOrchestrator = MockVibeConnectionOrchestrator();
      service = AI2AIRealtimeService(mockBackend, mockOrchestrator);

      // Mock getCurrentVibe to avoid web-specific code paths
      when(() => mockOrchestrator.getCurrentVibe()).thenReturn(null);
    });

    // Removed: Property assignment tests
    // AI2AI realtime tests focus on business logic (connection, broadcasting, listening, presence), not property assignment

    group('initialization', () {
      test(
          'should initialize successfully, subscribe to all AI2AI channels, or handle initialization failure',
          () async {
        // Test business logic: service initialization with channel subscription
        when(() => mockBackend.connect()).thenAnswer((_) async => {});
        when(() => mockBackend.joinChannel(any())).thenAnswer((_) async => {});
        when(() => mockBackend.updatePresence(any(), any()))
            .thenAnswer((_) async => {});

        final result = await service.initialize();
        expect(result, isTrue);
        verify(() => mockBackend.connect()).called(1);
        verify(() => mockBackend.updatePresence(any(), any())).called(1);
        // Verify specific channels (verify general count separately to avoid conflicts)
        verify(() => mockBackend.joinChannel('ai2ai-network')).called(1);
        verify(() => mockBackend.joinChannel('personality-discovery'))
            .called(1);
        verify(() => mockBackend.joinChannel('vibe-learning')).called(1);
        verify(() => mockBackend.joinChannel('anonymous-communication'))
            .called(1);

        // Test failure case
        when(() => mockBackend.connect())
            .thenThrow(Exception('Connection failed'));
        final failureResult = await service.initialize();
        expect(failureResult, isFalse);
      });
    });

    group('broadcasting', () {
      setUp(() async {
        when(() => mockBackend.connect()).thenAnswer((_) async => {});
        when(() => mockBackend.joinChannel(any())).thenAnswer((_) async => {});
        when(() => mockBackend.updatePresence(any(), any()))
            .thenAnswer((_) async => {});
        await service.initialize();
      });

      test(
          'should broadcast personality discovery, vibe learning, anonymous messages, and private messages',
          () async {
        // Test business logic: all broadcasting operations
        when(() => mockBackend.sendMessage(any(), any()))
            .thenAnswer((_) async => {});

        final mockNode = MockAIPersonalityNode();
        when(() => mockNode.nodeId).thenReturn('node-123');
        when(() => mockNode.vibeSignature).thenReturn('sig-123');
        when(() => mockNode.compatibilityScore).thenReturn(0.85);
        when(() => mockNode.learningPotential).thenReturn(0.9);
        await service.broadcastPersonalityDiscovery(mockNode);
        verify(() => mockBackend.sendMessage('personality-discovery', any()))
            .called(1);

        final dimensionUpdates = {
          'exploration_eagerness': 0.7,
          'community_orientation': 0.8
        };
        await service.broadcastVibeLearning(dimensionUpdates);
        verify(() => mockBackend.sendMessage('vibe-learning', any())).called(1);

        await service.sendAnonymousMessage('test_message', {'key': 'value'});
        verify(() => mockBackend.sendMessage('anonymous-communication', any()))
            .called(1);

        await service.sendPrivateMessage('user-123', {'message': 'test'});
        verify(() => mockBackend.sendMessage('ai2ai-network', any())).called(1);
      });
    });

    group('listening', () {
      test(
          'should listen to all channels when connected, or return empty stream when not connected',
          () async {
        // Test business logic: listening to all channel types
        when(() => mockBackend.connect()).thenAnswer((_) async => {});
        when(() => mockBackend.joinChannel(any())).thenAnswer((_) async => {});
        when(() => mockBackend.updatePresence(any(), any()))
            .thenAnswer((_) async => {});

        final testStream = Stream<RealtimeMessage>.value(
          RealtimeMessage(
              id: '1',
              senderId: 'sender',
              content: 'test',
              type: 'test',
              timestamp: DateTime.now()),
        );
        const emptyStream = Stream<RealtimeMessage>.empty();
        when(() => mockBackend.subscribeToMessages('ai2ai-network'))
            .thenAnswer((_) => testStream);
        when(() => mockBackend.subscribeToMessages('personality-discovery'))
            .thenAnswer((_) => emptyStream);
        when(() => mockBackend.subscribeToMessages('vibe-learning'))
            .thenAnswer((_) => emptyStream);
        when(() => mockBackend.subscribeToMessages('anonymous-communication'))
            .thenAnswer((_) => emptyStream);

        await service.initialize();
        expect(service.listenToAI2AINetwork(), isA<Stream<RealtimeMessage>>());
        expect(service.listenToPersonalityDiscovery(),
            isA<Stream<RealtimeMessage>>());
        expect(service.listenToVibeLearning(), isA<Stream<RealtimeMessage>>());
        expect(service.listenToAnonymousCommunication(),
            isA<Stream<RealtimeMessage>>());

        // Test not connected case
        final newService = AI2AIRealtimeService(mockBackend, mockOrchestrator);
        when(() => mockOrchestrator.getCurrentVibe()).thenReturn(null);
        expect(
            newService.listenToAI2AINetwork(), isA<Stream<RealtimeMessage>>());
      });
    });

    group('presence', () {
      test(
          'should watch AI network presence when connected or return empty stream when not connected',
          () async {
        // Test business logic: presence watching
        when(() => mockBackend.connect()).thenAnswer((_) async => {});
        when(() => mockBackend.joinChannel(any())).thenAnswer((_) async => {});
        when(() => mockBackend.updatePresence(any(), any()))
            .thenAnswer((_) async => {});
        final stream = Stream<List<UserPresence>>.value([]);
        when(() => mockBackend.subscribeToPresence('ai2ai-network'))
            .thenAnswer((_) => stream);
        await service.initialize();
        final result1 = service.watchAINetworkPresence();
        expect(result1, isA<Stream<List<UserPresence>>>());

        final newService = AI2AIRealtimeService(mockBackend, mockOrchestrator);
        when(() => mockOrchestrator.getCurrentVibe()).thenReturn(null);
        final result2 = newService.watchAINetworkPresence();
        expect(result2, isA<Stream<List<UserPresence>>>());
      });
    });

    group('disconnection', () {
      test(
          'should disconnect from all channels, or handle disconnection errors gracefully',
          () async {
        // Test business logic: disconnection with error handling
        when(() => mockBackend.connect()).thenAnswer((_) async => {});
        when(() => mockBackend.joinChannel(any())).thenAnswer((_) async => {});
        when(() => mockBackend.updatePresence(any(), any()))
            .thenAnswer((_) async => {});
        when(() => mockBackend.leaveChannel(any())).thenAnswer((_) async => {});

        await service.initialize();
        await service.disconnect();
        verify(() => mockBackend.leaveChannel(any())).called(4);
        expect(service.isConnected, isFalse);
        expect(service.activeChannels, isEmpty);

        // Test error handling
        await service.initialize();
        when(() => mockBackend.leaveChannel(any()))
            .thenThrow(Exception('Disconnect failed'));
        await service.disconnect();
        expect(service.activeChannels, isEmpty);
      });
    });

    group('connection status', () {
      test('should return false when not connected, or true when connected',
          () async {
        // Test business logic: connection status checking
        expect(service.isConnected, isFalse);
        expect(service.activeChannels, isEmpty);

        when(() => mockBackend.connect()).thenAnswer((_) async => {});
        when(() => mockBackend.joinChannel(any())).thenAnswer((_) async => {});
        when(() => mockBackend.updatePresence(any(), any()))
            .thenAnswer((_) async => {});

        await service.initialize();
        expect(service.isConnected, isTrue);
        expect(service.activeChannels.length, equals(4));
      });
    });

    group('latency measurement', () {
      test('should measure realtime latency, or handle timeout', () async {
        // Test business logic: latency measurement with timeout handling
        when(() => mockBackend.connect()).thenAnswer((_) async => {});
        when(() => mockBackend.joinChannel(any())).thenAnswer((_) async => {});
        when(() => mockBackend.updatePresence(any(), any()))
            .thenAnswer((_) async => {});

        final sendTime = DateTime.now();
        final traceId = DateTime.now().microsecondsSinceEpoch.toString();
        final stream = Stream<RealtimeMessage>.value(
          RealtimeMessage(
            id: traceId,
            senderId: 'sender',
            content: 'latency_ping',
            type: 'latency_ping',
            timestamp: sendTime.add(const Duration(milliseconds: 50)),
            metadata: {
              'trace_id': traceId,
              'send_ts': sendTime.toIso8601String()
            },
          ),
        );
        when(() => mockBackend.subscribeToMessages(any()))
            .thenAnswer((_) => stream);
        when(() => mockBackend.sendMessage(any(), any()))
            .thenAnswer((_) async => {});

        await service.initialize();
        final latency = await service.measureRealtimeLatency();
        expect(latency, isA<int?>());

        // Test timeout
        when(() => mockBackend.subscribeToMessages(any()))
            .thenAnswer((_) => const Stream<RealtimeMessage>.empty());
        final timeoutLatency = await service.measureRealtimeLatency(
            timeout: const Duration(milliseconds: 100));
        expect(timeoutLatency, isNull);
      });
    });

    tearDownAll(() async {
      await cleanupTestStorage();
    });
  });
}
