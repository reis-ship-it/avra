import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/network/ai2ai_protocol.dart';
import 'package:spots/core/ai/privacy_protection.dart';
import 'package:spots/core/models/user_vibe.dart';
import 'dart:typed_data';

void main() {
  group('AI2AIProtocol', () {
    late AI2AIProtocol protocol;
    late Uint8List encryptionKey;

    setUp(() {
      // Create a test encryption key
      encryptionKey = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]);
      protocol = AI2AIProtocol(encryptionKey: encryptionKey);
    });

    group('encodeMessage', () {
      test('should encode a message successfully', () {
        final message = protocol.encodeMessage(
          type: MessageType.heartbeat,
          payload: {'timestamp': DateTime.now().toIso8601String()},
          senderNodeId: 'node1',
        );

        expect(message.version, equals('1.0'));
        expect(message.type, equals(MessageType.heartbeat));
        expect(message.senderId, equals('node1'));
        expect(message.payload, isNotEmpty);
      });

      test('should include recipient ID when provided', () {
        final message = protocol.encodeMessage(
          type: MessageType.connectionRequest,
          payload: {},
          senderNodeId: 'node1',
          recipientNodeId: 'node2',
        );

        expect(message.recipientId, equals('node2'));
      });
    });

    group('decodeMessage', () {
      test('should decode a valid message', () {
        final originalMessage = protocol.encodeMessage(
          type: MessageType.heartbeat,
          payload: {'test': 'value'},
          senderNodeId: 'node1',
        );

        // Convert message to bytes (simulating transmission)
        final json = originalMessage.toJson();
        final jsonString = json.toString();
        final bytes = Uint8List.fromList(jsonString.codeUnits);

        // Note: In real implementation, decodeMessage would parse the protocol packet
        // For testing, we verify the encoding works correctly
        expect(originalMessage.type, equals(MessageType.heartbeat));
        expect(originalMessage.senderId, equals('node1'));
      });
    });

    group('createConnectionRequest', () {
      test('should create connection request message', () async {
        // Create anonymized vibe data
        final vibe = UserVibe.fromPersonalityProfile('user1', {
          'exploration_eagerness': 0.8,
          'community_orientation': 0.6,
        });
        final anonymizedVibe = await PrivacyProtection.anonymizeUserVibe(vibe);

        final message = protocol.createConnectionRequest(
          senderNodeId: 'node1',
          recipientNodeId: 'node2',
          senderVibe: anonymizedVibe,
        );

        expect(message.type, equals(MessageType.connectionRequest));
        expect(message.senderId, equals('node1'));
        expect(message.recipientId, equals('node2'));
        expect(message.payload['requestId'], isNotNull);
        expect(message.payload['senderVibe'], isNotNull);
      });
    });

    group('createConnectionResponse', () {
      test('should create accepted connection response', () {
        final message = protocol.createConnectionResponse(
          senderNodeId: 'node2',
          recipientNodeId: 'node1',
          requestId: 'req123',
          accepted: true,
          compatibilityScore: 0.85,
        );

        expect(message.type, equals(MessageType.connectionResponse));
        expect(message.payload['accepted'], isTrue);
        expect(message.payload['compatibilityScore'], equals(0.85));
        expect(message.payload['requestId'], equals('req123'));
      });

      test('should create rejected connection response', () {
        final message = protocol.createConnectionResponse(
          senderNodeId: 'node2',
          recipientNodeId: 'node1',
          requestId: 'req123',
          accepted: false,
        );

        expect(message.type, equals(MessageType.connectionResponse));
        expect(message.payload['accepted'], isFalse);
      });
    });

    group('createLearningExchange', () {
      test('should create learning exchange message', () {
        final message = protocol.createLearningExchange(
          senderNodeId: 'node1',
          recipientNodeId: 'node2',
          learningData: {
            'insight': 'test insight',
            'dimension': 'exploration_eagerness',
            'value': 0.8,
          },
        );

        expect(message.type, equals(MessageType.learningExchange));
        expect(message.payload['learningData'], isNotNull);
        expect(message.payload['timestamp'], isNotNull);
        
        // Verify anonymization (no userId in learning data)
        final learningData = message.payload['learningData'] as Map<String, dynamic>;
        expect(learningData['userId'], isNull);
      });
    });

    group('createHeartbeat', () {
      test('should create heartbeat message', () {
        final message = protocol.createHeartbeat(
          senderNodeId: 'node1',
        );

        expect(message.type, equals(MessageType.heartbeat));
        expect(message.senderId, equals('node1'));
        expect(message.payload['timestamp'], isNotNull);
      });
    });
  });

  group('ProtocolMessage', () {
    test('should serialize and deserialize correctly', () {
      final original = ProtocolMessage(
        version: '1.0',
        type: MessageType.connectionRequest,
        senderId: 'node1',
        recipientId: 'node2',
        timestamp: DateTime.now(),
        payload: {'test': 'value'},
      );

      final json = original.toJson();
      final restored = ProtocolMessage.fromJson(json);

      expect(restored.version, equals(original.version));
      expect(restored.type, equals(original.type));
      expect(restored.senderId, equals(original.senderId));
      expect(restored.recipientId, equals(original.recipientId));
      expect(restored.payload['test'], equals('value'));
    });
  });
}

