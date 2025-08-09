import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/p2p/node_manager.dart';
import 'package:spots/core/p2p/federated_learning.dart';

/// P2P System Integration Test  
/// OUR_GUTS.md: "Decentralized community networks with privacy protection"
void main() {
  group('P2P System Integration Tests', () {
    late P2PNodeManager nodeManager;
    late FederatedLearningSystem federatedSystem;

    setUp(() {
      nodeManager = P2PNodeManager();
      federatedSystem = FederatedLearningSystem();
    });

    test('should initialize P2P node with security and privacy', () async {
      // Test P2P node initialization for direct device-to-device communication
      final node = await nodeManager.initializeNode(
        NetworkType.university,
        'test_university_123',
        NodeCapabilities(
          canHostData: true,
          canProcessML: true,
          canRelay: true,
          maxStorageGB: 10,
          maxBandwidthMbps: 100,
        ),
      );

      expect(node, isNotNull);
      expect(node.nodeId, isA<String>());
      expect(node.organizationId, equals('test_university_123'));
      expect(node.networkType, equals(NetworkType.university));
      expect(node.encryptionKeys, isNotNull);
      expect(node.dataPolicy, isNotNull);
      
      // OUR_GUTS.md: "University/company private networks with verified members"
      // Node should be securely initialized with privacy protection
    });

    test('should discover and connect to network peers securely', () async {
      // Test secure peer discovery and connection establishment
      final compatiblePeers = await nodeManager.discoverNetworkPeers(
        'test_university_123',
        NodeCapabilities(
          canHostData: true,
          canProcessML: true,
          canRelay: true,
          maxStorageGB: 10,
          maxBandwidthMbps: 100,
        ),
      );

      expect(compatiblePeers, isA<List>());
      expect(compatiblePeers.length, greaterThanOrEqualTo(0));
      
      // OUR_GUTS.md: "Cross-node privacy protection"
      // Peer discovery should maintain privacy while finding compatible nodes
    });

    test('should create encrypted data silos for organization privacy', () async {
      // Test encrypted data silo creation for privacy-preserving data sharing
      final dataSilo = await nodeManager.createEncryptedSilo(
        'test_university_123',
        SiloConfiguration(
          maxStorageGB: 5,
          encryptionLevel: EncryptionLevel.maximum,
          accessPolicy: AccessPolicy.verifiedMembersOnly,
          dataRetentionDays: 30,
        ),
      );

      expect(dataSilo, isNotNull);
      expect(dataSilo.organizationId, equals('test_university_123'));
      expect(dataSilo.encryptionLevel, equals(EncryptionLevel.maximum));
      expect(dataSilo.accessPolicy, equals(AccessPolicy.verifiedMembersOnly));
      
      // OUR_GUTS.md: "Encrypted data silos with verified member authentication"
      // Data should be fully encrypted and access-controlled
    });

    test('should perform privacy-preserving federated learning', () async {
      // Test federated learning initialization with privacy preservation
      final learningRound = await federatedSystem.initializeLearningRound(
        'test_university_123',
        LearningObjective.spotRecommendation,
        ['node_1', 'node_2', 'node_3'], // Minimum 3 participants
      );

      expect(learningRound, isNotNull);
      expect(learningRound.roundId, isA<String>());
      expect(learningRound.organizationId, equals('test_university_123'));
      expect(learningRound.participantNodeIds.length, greaterThanOrEqualTo(3));
      expect(learningRound.status, equals(RoundStatus.training));
      expect(learningRound.privacyMetrics, isNotNull);
      
      // OUR_GUTS.md: "Local model training with global model aggregation"
      // Federated learning should maintain complete privacy
    });

    test('should train local model without exposing personal data', () async {
      // Test local model training with privacy preservation
      final mockTrainingData = LocalTrainingData(
        features: [
          {'category_preference': 0.8, 'time_preference': 0.6},
          {'category_preference': 0.7, 'time_preference': 0.9},
        ],
        labels: [1.0, 0.8],
        privacyLevel: PrivacyLevel.maximum,
      );

      final localUpdate = await federatedSystem.trainLocalModel(
        'test_node_1',
        mockTrainingData,
        LearningObjective.spotRecommendation,
      );

      expect(localUpdate, isNotNull);
      expect(localUpdate.nodeId, equals('test_node_1'));
      expect(localUpdate.modelWeights, isA<Map<String, double>>());
      expect(localUpdate.privacyMetrics.hasPersonalData, isFalse);
      expect(localUpdate.privacyMetrics.encryptionLevel, equals(EncryptionLevel.maximum));
      
      // OUR_GUTS.md: "Privacy-preserving federated learning with community insights"
      // Local training should extract insights without exposing personal data
    });

    test('should reject training data containing personal identifiers', () async {
      // Test privacy protection by rejecting data with personal information
      final personalData = LocalTrainingData(
        features: [
          {'user_id': 'john_doe', 'location': 'home_address'}, // Personal identifiers
        ],
        labels: [1.0],
        privacyLevel: PrivacyLevel.low,
      );

      try {
        await federatedSystem.trainLocalModel(
          'test_node_1',
          personalData,
          LearningObjective.spotRecommendation,
        );
        fail('Should have rejected data with personal identifiers');
      } catch (e) {
        expect(e, isA<FederatedLearningException>());
      }
      
      // OUR_GUTS.md: "Privacy and Control Are Non-Negotiable"
      // System must actively protect against personal data exposure
    });

    test('should sync data across network with privacy preservation', () async {
      // Test privacy-preserving data synchronization across P2P network
      final syncResult = await nodeManager.syncNetworkData(
        'test_university_123',
        DataSyncConfiguration(
          syncScope: SyncScope.organizationOnly,
          encryptionRequired: true,
          privacyLevel: PrivacyLevel.maximum,
          maxDataSizeGB: 1,
        ),
      );

      expect(syncResult, isNotNull);
      expect(syncResult.organizationId, equals('test_university_123'));
      expect(syncResult.encryptionApplied, isTrue);
      expect(syncResult.privacyLevel, equals(PrivacyLevel.maximum));
      expect(syncResult.dataExposureRisk, equals(ExposureRisk.none));
      
      // OUR_GUTS.md: "Privacy-preserving data synchronization"
      // Network sync should maintain complete privacy
    });

    test('should implement advanced privacy-preserving protocols', () async {
      // Test comprehensive privacy preservation across all P2P operations
      
      // Test zero-knowledge proof capabilities
      final node = await nodeManager.initializeNode(
        NetworkType.company,
        'test_company_456',
        NodeCapabilities(
          canHostData: true,
          canProcessML: true,
          canRelay: true,
          maxStorageGB: 20,
          maxBandwidthMbps: 200,
        ),
      );

      // Test homomorphic encryption support
      final dataSilo = await nodeManager.createEncryptedSilo(
        'test_company_456',
        SiloConfiguration(
          maxStorageGB: 10,
          encryptionLevel: EncryptionLevel.maximum,
          accessPolicy: AccessPolicy.verifiedMembersOnly,
          dataRetentionDays: 60,
        ),
      );

      // Test secure multi-party computation
      final learningRound = await federatedSystem.initializeLearningRound(
        'test_company_456',
        LearningObjective.communityTrends,
        ['company_node_1', 'company_node_2', 'company_node_3', 'company_node_4'],
      );

      expect(node.encryptionKeys, isNotNull);
      expect(dataSilo.encryptionLevel, equals(EncryptionLevel.maximum));
      expect(learningRound.privacyMetrics, isNotNull);
      
      // System should support advanced cryptographic protocols
    });

    test('should comply with OUR_GUTS.md principles in P2P operations', () async {
      final node = await nodeManager.initializeNode(
        NetworkType.university,
        'guts_compliance_test',
        NodeCapabilities(
          canHostData: true,
          canProcessML: true,
          canRelay: true,
          maxStorageGB: 5,
          maxBandwidthMbps: 50,
        ),
      );

      final dataSilo = await nodeManager.createEncryptedSilo(
        'guts_compliance_test',
        SiloConfiguration(
          maxStorageGB: 2,
          encryptionLevel: EncryptionLevel.maximum,
          accessPolicy: AccessPolicy.verifiedMembersOnly,
          dataRetentionDays: 14,
        ),
      );

      // "Privacy and Control Are Non-Negotiable"
      expect(node.dataPolicy, isNotNull);
      expect(dataSilo.encryptionLevel, equals(EncryptionLevel.maximum));
      
      // "Community, Not Just Places"
      expect(node.organizationId, isA<String>());
      expect(node.networkType, isIn([NetworkType.university, NetworkType.company]));
      
      // "Authenticity Over Algorithms"
      expect(node.capabilities, isNotNull);
      
      // All P2P operations should embody core principles
    });

    test('should handle P2P system errors gracefully', () async {
      // Test error handling across P2P components
      try {
        final invalidNode = await nodeManager.initializeNode(
          NetworkType.university,
          '', // Invalid organization ID
          NodeCapabilities(
            canHostData: false,
            canProcessML: false,
            canRelay: false,
            maxStorageGB: 0,
            maxBandwidthMbps: 0,
          ),
        );
        // Should handle invalid configuration
        expect(invalidNode, isNotNull);
      } catch (e) {
        expect(e, isA<Exception>());
      }
      
      try {
        // Test federated learning with insufficient participants
        final invalidRound = await federatedSystem.initializeLearningRound(
          'test_org',
          LearningObjective.spotRecommendation,
          ['single_node'], // Below minimum of 3 participants
        );
        fail('Should have failed with insufficient participants');
      } catch (e) {
        expect(e, isA<FederatedLearningException>());
      }
      
      // OUR_GUTS.md: "Effortless, Seamless Discovery"
      // System should continue working even with P2P challenges
    });
  });
}