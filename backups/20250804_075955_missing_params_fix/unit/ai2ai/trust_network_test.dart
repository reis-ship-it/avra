import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/ai2ai/trust_network.dart';

void main() {
  group('TrustNetworkManager', () {
    late TrustNetworkManager manager;
    
    setUp(() {
      manager = TrustNetworkManager();
    });
    
    test('establishTrust creates anonymous trust relationship', () async {
      // OUR_GUTS.md: "Building trust without exposing user identity"
      final context = TrustContext(
        hasUserData: false, // Critical: no user data
        hasValidatedBehavior: true,
        hasCommunityEndorsement: true,
        hasRecentActivity: true,
        behaviorSignature: 'pattern_abc123',
        activityLevel: 0.8,
        communityScore: 0.7,
      );
      
      final relationship = await manager.establishTrust('agent-789', context);
      
      expect(relationship.trustScore, greaterThan(0.0));
      expect(relationship.trustScore, lessThanOrEqualTo(1.0));
      expect(relationship.agentId, equals('agent-789'));
    });
    
    test('rejects trust context with user data', () async {
      // OUR_GUTS.md: "Privacy and Control Are Non-Negotiable"
      final contextWithUserData = TrustContext(
        hasUserData: true, // This should trigger rejection
        hasValidatedBehavior: true,
        hasCommunityEndorsement: false,
        hasRecentActivity: true,
        behaviorSignature: 'pattern_def456',
        activityLevel: 0.6,
        communityScore: 0.5,
      );
      
      expect(
        () => manager.establishTrust('agent-999', contextWithUserData),
        throwsA(isA<TrustNetworkException>()),
      );
    });
    
    test('verifyAgentReputation maintains anonymity', () async {
      // OUR_GUTS.md: "Reputation system without identity exposure"
      final reputation = await manager.verifyAgentReputation('agent-456');
      
      expect(reputation.agentId, equals('agent-456'));
      expect(reputation.overallScore, inInclusiveRange(0.0, 1.0));
      expect(reputation.reputationLevel, isA<ReputationLevel>());
    });
  });
}
