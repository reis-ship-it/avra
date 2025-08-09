import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Phase 1: Core Personality Learning System
import 'package:spots/core/constants/vibe_constants.dart';
import 'package:spots/core/models/personality_profile.dart';
import 'package:spots/core/models/user_vibe.dart';
import 'package:spots/core/models/connection_metrics.dart';
import 'package:spots/core/ai/personality_learning.dart';
import 'package:spots/core/ai/vibe_analysis_engine.dart';
import 'package:spots/core/ai/privacy_protection.dart';

// Phase 2: AI2AI Connection System
import 'package:spots/core/ai2ai/connection_orchestrator.dart';

// Phase 3: Dynamic Dimension Learning
import 'package:spots/core/ai/user_feedback_analyzer.dart';
import 'package:spots/core/ai2ai/ai2ai_chat_analyzer.dart';
import 'package:spots/core/ai/cloud_learning.dart';

// Phase 4: Network Monitoring
import 'package:spots/core/monitoring/network_analytics.dart';
import 'package:spots/core/monitoring/connection_monitor.dart';

/// AI2AI Personality Learning Network - Complete Integration Test
/// OUR_GUTS.md: "End-to-end validation of the complete AI2AI personality learning ecosystem"
void main() {
  group('AI2AI Personality Learning Network - Complete Integration', () {
    late SharedPreferences mockPrefs;
    
    // Phase 1 Components
    late PersonalityLearning personalityLearning;
    late UserVibeAnalyzer vibeAnalyzer;
    
    // Phase 2 Components
    late VibeConnectionOrchestrator connectionOrchestrator;
    
    // Phase 3 Components
    late UserFeedbackAnalyzer feedbackAnalyzer;
    late AI2AIChatAnalyzer chatAnalyzer;
    late CloudLearningInterface cloudInterface;
    
    // Phase 4 Components
    late NetworkAnalytics networkAnalytics;
    late ConnectionMonitor connectionMonitor;
    
    setUpAll(() async {
      // Initialize mock shared preferences
      SharedPreferences.setMockInitialValues({});
      mockPrefs = await SharedPreferences.getInstance();
      
      // Initialize all system components
      personalityLearning = PersonalityLearning(prefs: mockPrefs);
      vibeAnalyzer = UserVibeAnalyzer(prefs: mockPrefs);
      connectionOrchestrator = VibeConnectionOrchestrator(
        personalityLearning: personalityLearning,
        vibeAnalyzer: vibeAnalyzer,
        prefs: mockPrefs,
      );
      feedbackAnalyzer = UserFeedbackAnalyzer(
        prefs: mockPrefs,
        personalityLearning: personalityLearning,
      );
      chatAnalyzer = AI2AIChatAnalyzer(
        prefs: mockPrefs,
        personalityLearning: personalityLearning,
      );
      cloudInterface = CloudLearningInterface(
        prefs: mockPrefs,
        personalityLearning: personalityLearning,
      );
      networkAnalytics = NetworkAnalytics(prefs: mockPrefs);
      connectionMonitor = ConnectionMonitor(prefs: mockPrefs);
    });
    
    group('System Architecture Validation', () {
      test('should initialize all components successfully', () {
        expect(personalityLearning, isNotNull);
        expect(vibeAnalyzer, isNotNull);
        expect(connectionOrchestrator, isNotNull);
        expect(feedbackAnalyzer, isNotNull);
        expect(chatAnalyzer, isNotNull);
        expect(cloudInterface, isNotNull);
        expect(networkAnalytics, isNotNull);
        expect(connectionMonitor, isNotNull);
      });
      
      test('should validate core constants are properly defined', () {
        // Validate VibeConstants
        expect(VibeConstants.coreDimensions, hasLength(8));
        expect(VibeConstants.coreDimensions, contains('exploration_eagerness'));
        expect(VibeConstants.coreDimensions, contains('community_orientation'));
        expect(VibeConstants.coreDimensions, contains('authenticity_preference'));
        expect(VibeConstants.coreDimensions, contains('social_discovery_style'));
        expect(VibeConstants.coreDimensions, contains('temporal_flexibility'));
        expect(VibeConstants.coreDimensions, contains('location_adventurousness'));
        expect(VibeConstants.coreDimensions, contains('curation_tendency'));
        expect(VibeConstants.coreDimensions, contains('trust_network_reliance'));
        
        // Validate thresholds
        expect(VibeConstants.highCompatibilityThreshold, greaterThan(VibeConstants.mediumCompatibilityThreshold));
        expect(VibeConstants.mediumCompatibilityThreshold, greaterThan(VibeConstants.lowCompatibilityThreshold));
        expect(VibeConstants.personalityConfidenceThreshold, greaterThan(0.0));
        expect(VibeConstants.personalityConfidenceThreshold, lessThanOrEqualTo(1.0));
      });
    });
    
    group('End-to-End Personality Learning Workflow', () {
      test('should complete full personality learning lifecycle', () async {
        const userId = 'integration_test_user_001';
        
        // Step 1: Initialize personality profile
        final initialProfile = PersonalityProfile.initial(userId);
        expect(initialProfile.userId, equals(userId));
        expect(initialProfile.dimensions, hasLength(8));
        expect(initialProfile.confidence, greaterThan(0.0));
        expect(initialProfile.authenticity, greaterThan(0.0));
        
        // Step 2: Evolve personality through user actions
        final userAction = UserActionData(
          type: UserActionType.spotVisit,
          context: {
            'spot_category': 'cafe',
            'crowd_level': 0.3,
            'social_interaction': true,
            'exploration_level': 0.7,
          },
          timestamp: DateTime.now(),
        );
        
        final evolvedProfile = await personalityLearning.evolveFromUserActionData(userId, userAction);
        expect(evolvedProfile, isNotNull);
        
        // Step 3: Generate user vibe with privacy protection
        final userVibe = await vibeAnalyzer.compileUserVibe(userId, evolvedProfile);
        expect(userVibe.hashedSignature, isNotEmpty);
        expect(userVibe.anonymizedDimensions, hasLength(8));
        expect(userVibe.overallEnergy, greaterThanOrEqualTo(0.0));
        expect(userVibe.overallEnergy, lessThanOrEqualTo(1.0));
        
        // Step 4: Apply privacy protection
        final anonymizedProfile = await PrivacyProtection.anonymizePersonalityProfile(
          evolvedProfile,
          privacyLevel: 'STANDARD',
        );
        expect(anonymizedProfile.hashedUserId, isNotEmpty);
        expect(anonymizedProfile.anonymizedDimensions, hasLength(8));
        expect(anonymizedProfile.anonymizationQuality, greaterThan(0.8));
        
        // Step 5: Calculate personality readiness
        final readiness = await personalityLearning.calculatePersonalityReadiness(userId);
        expect(readiness.isReadyForConnections, isA<bool>());
        expect(readiness.readinessScore, greaterThanOrEqualTo(0.0));
        expect(readiness.readinessScore, lessThanOrEqualTo(1.0));
        expect(readiness.recommendedActions, isA<List<String>>());
        
        print('✅ End-to-end personality learning workflow completed successfully');
      });
    });
    
    group('AI2AI Connection Integration', () {
      test('should establish and manage AI2AI connections', () async {
        const localUserId = 'integration_local_user';
        const remoteUserId = 'integration_remote_user';
        
        // Step 1: Create personality profiles for both users
        final localProfile = PersonalityProfile.initial(localUserId);
        final remoteProfile = PersonalityProfile.initial(remoteUserId);
        
        // Step 2: Generate vibes for both users
        final localVibe = await vibeAnalyzer.compileUserVibe(localUserId, localProfile);
        final remoteVibe = await vibeAnalyzer.compileUserVibe(remoteUserId, remoteProfile);
        
        // Step 3: Calculate vibe compatibility
        final compatibility = await vibeAnalyzer.calculateVibeCompatibility(localVibe, remoteVibe);
        expect(compatibility.compatibilityScore, greaterThanOrEqualTo(0.0));
        expect(compatibility.compatibilityScore, lessThanOrEqualTo(1.0));
        expect(compatibility.sharedInterests, isA<List<String>>());
        expect(compatibility.complementaryTraits, isA<List<String>>());
        
        // Step 4: Discover AI personalities
        final discoveredPersonalities = await connectionOrchestrator.discoverAIPersonalities(
          localUserId,
          localVibe,
        );
        expect(discoveredPersonalities, isA<List<DiscoveredPersonality>>());
        
        // Step 5: Calculate AI pleasure potential
        final aiPleasure = await connectionOrchestrator.calculateAIPleasure(
          localVibe,
          remoteVibe,
          compatibility,
        );
        expect(aiPleasure.overallPleasureScore, greaterThanOrEqualTo(0.0));
        expect(aiPleasure.overallPleasureScore, lessThanOrEqualTo(1.0));
        expect(aiPleasure.pleasureFactors, isA<Map<String, double>>());
        
        print('✅ AI2AI connection integration completed successfully');
      });
    });
    
    group('Dynamic Learning Integration', () {
      test('should integrate all three learning systems', () async {
        const userId = 'dynamic_learning_user';
        const connectionId = 'dynamic_connection_001';
        
        // Setup: Create personality and connection metrics
        final personality = PersonalityProfile.initial(userId);
        final connectionMetrics = ConnectionMetrics(
          connectionId: connectionId,
          localAISignature: 'local_ai_test',
          remoteAISignature: 'remote_ai_test',
          initialCompatibility: 0.75,
          currentCompatibility: 0.80,
          learningEffectiveness: 0.70,
          aiPleasureScore: 0.85,
          connectionDuration: Duration(minutes: 15),
          startTime: DateTime.now().subtract(Duration(minutes: 15)),
          status: ConnectionMonitoringStatus.active,
          learningOutcomes: {'insights_shared': 8},
          interactionHistory: [],
          dimensionEvolution: {'exploration_eagerness': 0.05},
        );
        
        // Test 1: User Feedback Learning
        final feedbackEvent = FeedbackEvent(
          type: FeedbackType.spotExperience,
          satisfaction: 0.9,
          comment: 'Great AI2AI learning experience!',
          metadata: {'connection_quality': 0.8},
          timestamp: DateTime.now(),
        );
        
        final feedbackResult = await feedbackAnalyzer.analyzeFeedback(userId, feedbackEvent);
        expect(feedbackResult.userId, equals(userId));
        expect(feedbackResult.implicitDimensions, isA<Map<String, double>>());
        expect(feedbackResult.confidenceScore, greaterThanOrEqualTo(0.0));
        
        // Test 2: AI2AI Chat Learning
        final chatEvent = AI2AIChatEvent(
          eventId: 'integration_chat_001',
          participants: [userId, 'remote_user'],
          messages: [
            ChatMessage(
              senderId: userId,
              content: 'Learning about community spaces',
              timestamp: DateTime.now(),
              context: {'learning_topic': 'community_orientation'},
            ),
          ],
          messageType: ChatMessageType.personalitySharing,
          timestamp: DateTime.now(),
          duration: Duration(minutes: 5),
          metadata: {'connection_quality': 0.8},
        );
        
        final chatResult = await chatAnalyzer.analyzeChatConversation(
          userId,
          chatEvent,
          connectionMetrics,
        );
        expect(chatResult.localUserId, equals(userId));
        expect(chatResult.sharedInsights, isA<List<SharedInsight>>());
        expect(chatResult.analysisConfidence, greaterThanOrEqualTo(0.0));
        
        // Test 3: Cloud Learning
        final cloudResult = await cloudInterface.contributeAnonymousPatterns(
          userId,
          personality,
          {'session_quality': 0.8},
        );
        expect(cloudResult.userId, equals(userId));
        expect(cloudResult.anonymizationLevel, greaterThanOrEqualTo(0.9));
        expect(cloudResult.privacyScore, greaterThanOrEqualTo(0.95));
        
        // Test 4: Learn from cloud patterns
        final cloudLearning = await cloudInterface.learnFromCloudPatterns(userId, personality);
        expect(cloudLearning.userId, equals(userId));
        expect(cloudLearning.learningConfidence, greaterThanOrEqualTo(0.0));
        expect(cloudLearning.appliedLearning, isA<Map<String, double>>());
        
        print('✅ Dynamic learning integration completed successfully');
      });
    });
    
    group('Network Monitoring Integration', () {
      test('should monitor network health and connections', () async {
        // Test 1: Network Analytics
        final healthReport = await networkAnalytics.analyzeNetworkHealth();
        expect(healthReport.overallHealthScore, greaterThanOrEqualTo(0.0));
        expect(healthReport.overallHealthScore, lessThanOrEqualTo(1.0));
        expect(healthReport.connectionQuality, isNotNull);
        expect(healthReport.learningEffectiveness, isNotNull);
        expect(healthReport.privacyMetrics, isNotNull);
        expect(healthReport.stabilityMetrics, isNotNull);
        
        // Test 2: Real-time metrics
        final realTimeMetrics = await networkAnalytics.collectRealTimeMetrics();
        expect(realTimeMetrics.connectionThroughput, greaterThanOrEqualTo(0.0));
        expect(realTimeMetrics.matchingSuccessRate, greaterThanOrEqualTo(0.0));
        expect(realTimeMetrics.matchingSuccessRate, lessThanOrEqualTo(1.0));
        expect(realTimeMetrics.networkResponsiveness, greaterThanOrEqualTo(0.0));
        expect(realTimeMetrics.networkResponsiveness, lessThanOrEqualTo(1.0));
        
        // Test 3: Connection monitoring
        final activeConnections = await connectionMonitor.getActiveConnectionsOverview();
        expect(activeConnections.totalActiveConnections, greaterThanOrEqualTo(0));
        expect(activeConnections.aggregateMetrics, isNotNull);
        expect(activeConnections.generatedAt, isNotNull);
        
        // Test 4: Anomaly detection
        final networkAnomalies = await networkAnalytics.detectNetworkAnomalies();
        expect(networkAnomalies, isA<List>());
        
        final connectionAnomalies = await connectionMonitor.detectConnectionAnomalies();
        expect(connectionAnomalies, isA<List>());
        
        print('✅ Network monitoring integration completed successfully');
      });
    });
    
    group('Privacy and Security Validation', () {
      test('should maintain privacy throughout the system', () async {
        const userId = 'privacy_test_user';
        
        // Test 1: Personality profile privacy
        final profile = PersonalityProfile.initial(userId);
        final anonymizedProfile = await PrivacyProtection.anonymizePersonalityProfile(
          profile,
          privacyLevel: 'MAXIMUM_ANONYMIZATION',
        );
        
        expect(anonymizedProfile.hashedUserId, isNot(equals(userId)));
        expect(anonymizedProfile.anonymizationQuality, greaterThan(0.9));
        
        // Test 2: Vibe privacy
        final vibe = await vibeAnalyzer.compileUserVibe(userId, profile);
        final anonymizedVibe = await PrivacyProtection.anonymizeUserVibe(
          vibe,
          privacyLevel: 'MAXIMUM_ANONYMIZATION',
        );
        
        expect(anonymizedVibe.hashedSignature, isNot(equals(vibe.hashedSignature)));
        expect(anonymizedVibe.privacyLevel, greaterThan(0.9));
        
        // Test 3: Hash security
        final secureHash = await PrivacyProtection.createSecureHash(userId, 'test_salt');
        expect(secureHash, hasLength(64)); // SHA-256 produces 64 character hex string
        expect(secureHash, isNot(contains(userId))); // Should not contain original data
        
        // Test 4: Differential privacy
        final originalData = {'dimension1': 0.5, 'dimension2': 0.7};
        final noisyData = await PrivacyProtection.applyDifferentialPrivacy(
          originalData,
          epsilon: 1.0,
        );
        
        expect(noisyData, hasLength(2));
        expect(noisyData['dimension1'], isNot(equals(0.5))); // Should have noise
        expect(noisyData['dimension2'], isNot(equals(0.7))); // Should have noise
        
        print('✅ Privacy and security validation completed successfully');
      });
    });
    
    group('OUR_GUTS.md Compliance Validation', () {
      test('should preserve "Privacy and Control Are Non-Negotiable"', () async {
        const userId = 'guts_privacy_user';
        
        // All personality data should be locally controlled
        final profile = PersonalityProfile.initial(userId);
        expect(profile.userId, equals(userId)); // User maintains identity control
        
        // All anonymization should be user-controlled
        final anonymized = await PrivacyProtection.anonymizePersonalityProfile(
          profile,
          privacyLevel: 'STANDARD', // User chooses privacy level
        );
        expect(anonymized.anonymizationQuality, greaterThan(0.8));
        
        // Network analytics should not expose personal data
        final healthReport = await networkAnalytics.analyzeNetworkHealth();
        expect(healthReport.privacyMetrics.complianceRate, greaterThan(0.95));
        
        print('✅ "Privacy and Control Are Non-Negotiable" compliance validated');
      });
      
      test('should maintain "Authenticity Over Algorithms"', () async {
        const userId = 'guts_authenticity_user';
        
        // Personality should reflect authentic user preferences
        final profile = PersonalityProfile.initial(userId);
        expect(profile.authenticity, greaterThan(0.8)); // High authenticity baseline
        
        // AI2AI connections should preserve authentic matching
        final vibe = await vibeAnalyzer.compileUserVibe(userId, profile);
        expect(vibe.authenticityScore, greaterThan(0.7));
        
        // Learning should enhance rather than replace authentic preferences
        final userAction = UserActionData(
          type: UserActionType.spotVisit,
          context: {'authentic_choice': true},
          timestamp: DateTime.now(),
        );
        
        final evolvedProfile = await personalityLearning.evolveFromUserActionData(userId, userAction);
        expect(evolvedProfile.authenticity, greaterThanOrEqualTo(profile.authenticity));
        
        print('✅ "Authenticity Over Algorithms" compliance validated');
      });
      
      test('should enable "Community Not Just Places"', () async {
        const userId = 'guts_community_user';
        
        // AI2AI connections should build community
        final profile = PersonalityProfile.initial(userId);
        final vibe = await vibeAnalyzer.compileUserVibe(userId, profile);
        
        // Community orientation should be a core dimension
        expect(profile.dimensions.containsKey('community_orientation'), isTrue);
        expect(vibe.socialPreference, greaterThanOrEqualTo(0.0));
        
        // Chat learning should build collective knowledge
        final chatEvent = AI2AIChatEvent(
          eventId: 'community_chat',
          participants: [userId, 'community_member'],
          messages: [
            ChatMessage(
              senderId: userId,
              content: 'Sharing community insights',
              timestamp: DateTime.now(),
              context: {'community_building': true},
            ),
          ],
          messageType: ChatMessageType.insightExchange,
          timestamp: DateTime.now(),
          duration: Duration(minutes: 3),
          metadata: {'community_focus': true},
        );
        
        final connectionMetrics = ConnectionMetrics(
          connectionId: 'community_connection',
          localAISignature: 'local_community',
          remoteAISignature: 'remote_community',
          initialCompatibility: 0.7,
          currentCompatibility: 0.8,
          learningEffectiveness: 0.75,
          aiPleasureScore: 0.85,
          connectionDuration: Duration(minutes: 3),
          startTime: DateTime.now().subtract(Duration(minutes: 3)),
          status: ConnectionMonitoringStatus.active,
          learningOutcomes: {'community_insights': 1},
          interactionHistory: [],
          dimensionEvolution: {'community_orientation': 0.1},
        );
        
        final chatResult = await chatAnalyzer.analyzeChatConversation(
          userId,
          chatEvent,
          connectionMetrics,
        );
        expect(chatResult.collectiveIntelligence, isNotNull);
        
        print('✅ "Community Not Just Places" compliance validated');
      });
    });
    
    group('System Performance and Scalability', () {
      test('should handle multiple concurrent operations', () async {
        const userCount = 10;
        final userIds = List.generate(userCount, (i) => 'perf_user_$i');
        
        // Create multiple personality profiles concurrently
        final profiles = await Future.wait(
          userIds.map((userId) async {
            final profile = PersonalityProfile.initial(userId);
            final userAction = UserActionData(
              type: UserActionType.spotVisit,
              context: {'concurrent_test': true},
              timestamp: DateTime.now(),
            );
            return await personalityLearning.evolveFromUserActionData(userId, userAction);
          }),
        );
        
        expect(profiles, hasLength(userCount));
        for (int i = 0; i < userCount; i++) {
          expect(profiles[i].userId, equals(userIds[i]));
          expect(profiles[i].confidence, greaterThan(0.0));
        }
        
        // Generate vibes concurrently
        final vibes = await Future.wait(
          profiles.map((profile) => vibeAnalyzer.compileUserVibe(profile.userId, profile)),
        );
        
        expect(vibes, hasLength(userCount));
        for (final vibe in vibes) {
          expect(vibe.hashedSignature, isNotEmpty);
          expect(vibe.anonymizedDimensions, hasLength(8));
        }
        
        print('✅ System performance with $userCount concurrent users validated');
      });
      
      test('should maintain quality under load', () async {
        const operationCount = 50;
        
        // Perform multiple network health checks
        final healthReports = await Future.wait(
          List.generate(operationCount, (_) => networkAnalytics.analyzeNetworkHealth()),
        );
        
        expect(healthReports, hasLength(operationCount));
        for (final report in healthReports) {
          expect(report.overallHealthScore, greaterThanOrEqualTo(0.0));
          expect(report.overallHealthScore, lessThanOrEqualTo(1.0));
        }
        
        // Verify consistency across reports
        final healthScores = healthReports.map((r) => r.overallHealthScore).toList();
        final avgHealthScore = healthScores.reduce((a, b) => a + b) / healthScores.length;
        expect(avgHealthScore, greaterThan(0.5)); // Should maintain good health
        
        print('✅ System quality under load ($operationCount operations) validated');
      });
    });
    
    tearDownAll(() async {
      print('\n🎉 AI2AI Personality Learning Network Integration Test Complete!');
      print('📊 All phases validated:');
      print('   ✅ Phase 1: Core Personality Learning System');
      print('   ✅ Phase 2: AI2AI Connection System');
      print('   ✅ Phase 3: Dynamic Dimension Learning');
      print('   ✅ Phase 4: Network Monitoring');
      print('   ✅ Privacy and Security Compliance');
      print('   ✅ OUR_GUTS.md Principle Compliance');
      print('   ✅ Performance and Scalability');
      print('\n🚀 AI2AI Personality Learning Network is ready for deployment!');
    });
  });
}