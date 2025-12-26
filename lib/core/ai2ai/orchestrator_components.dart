import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:spots/core/ai/privacy_protection.dart';
import 'package:spots/core/ai/vibe_analysis_engine.dart';
import 'package:spots/core/ai/personality_learning.dart';
import 'package:spots/core/network/ai2ai_protocol.dart';
import 'package:spots/core/constants/vibe_constants.dart';
import 'package:spots/core/models/connection_metrics.dart';
import 'package:spots/core/models/personality_profile.dart';
import 'package:spots/core/models/user_vibe.dart';
import 'package:spots/core/ai2ai/aipersonality_node.dart';
import 'package:spots/core/services/ai2ai_realtime_service.dart';
import 'package:spots_network/spots_network.dart';

/// Supports discovery of nearby AI personalities and prioritization
class DiscoveryManager {
  final Connectivity connectivity;
  final UserVibeAnalyzer vibeAnalyzer;

  DiscoveryManager({required this.connectivity, required this.vibeAnalyzer});

  Future<List<AIPersonalityNode>> discover(
    String userId,
    PersonalityProfile personality,
    Future<List<AIPersonalityNode>> Function(AnonymizedVibeData) performDiscovery,
  ) async {
    final connectivityResult = await connectivity.checkConnectivity();
    final isConnected = connectivityResult.any((c) => c != ConnectivityResult.none);
    if (!isConnected) {
      return [];
    }

    final userVibe = await vibeAnalyzer.compileUserVibe(userId, personality);
    final anonymizedVibe = await PrivacyProtection.anonymizeUserVibe(userVibe);
    final nodes = await performDiscovery(anonymizedVibe);

    final compatibility = await _analyzeCompatibility(userVibe, nodes);
    final prioritized = _prioritize(nodes, compatibility);
    return prioritized;
  }

  Future<Map<String, VibeCompatibilityResult>> _analyzeCompatibility(
    UserVibe localVibe,
    List<AIPersonalityNode> nodes,
  ) async {
    final result = <String, VibeCompatibilityResult>{};
    for (final node in nodes) {
      final c = await vibeAnalyzer.analyzeVibeCompatibility(localVibe, node.vibe);
      result[node.nodeId] = c;
    }
    return result;
  }

  List<AIPersonalityNode> _prioritize(
    List<AIPersonalityNode> nodes,
    Map<String, VibeCompatibilityResult> results,
  ) {
    nodes.sort((a, b) {
      final ar = results[a.nodeId];
      final br = results[b.nodeId];
      if (ar == null || br == null) return 0;
      final ap = (ar.basicCompatibility * 0.4) +
          (ar.aiPleasurePotential * 0.3) +
          (ar.learningOpportunities.length / 8.0 * 0.2) +
          (a.trustScore * 0.1);
      final bp = (br.basicCompatibility * 0.4) +
          (br.aiPleasurePotential * 0.3) +
          (br.learningOpportunities.length / 8.0 * 0.2) +
          (b.trustScore * 0.1);
      return bp.compareTo(ap);
    });
    return nodes.take(5).toList();
  }
}

/// Manages connection establishment and maintenance
/// Philosophy: "Always Learning With You" - AI learns alongside you, online and offline
class ConnectionManager {
  final UserVibeAnalyzer vibeAnalyzer;
  final PersonalityLearning? personalityLearning; // NEW: For offline AI learning
  final AI2AIProtocol? ai2aiProtocol; // NEW: For offline peer exchange

  ConnectionManager({
    required this.vibeAnalyzer,
    this.personalityLearning, // Optional for backward compatibility
    this.ai2aiProtocol, // Optional for backward compatibility
  });

  Future<ConnectionMetrics?> establish(
    String localUserId,
    PersonalityProfile localPersonality,
    AIPersonalityNode remoteNode,
    Future<ConnectionMetrics?> Function(
      UserVibe localVibe,
      AIPersonalityNode remoteNode,
      VibeCompatibilityResult compatibility,
      ConnectionMetrics initialMetrics,
    ) performEstablishment,
  ) async {
    final localVibe = await vibeAnalyzer.compileUserVibe(localUserId, localPersonality);
    final compatibility = await vibeAnalyzer.analyzeVibeCompatibility(localVibe, remoteNode.vibe);

    if (!_isWorthy(compatibility)) return null;

    final anonLocal = await PrivacyProtection.anonymizeUserVibe(localVibe);
    final anonRemote = await PrivacyProtection.anonymizeUserVibe(remoteNode.vibe);

    final metrics = ConnectionMetrics.initial(
      localAISignature: anonLocal.vibeSignature,
      remoteAISignature: anonRemote.vibeSignature,
      compatibility: compatibility.basicCompatibility,
    );

    return performEstablishment(localVibe, remoteNode, compatibility, metrics);
  }

  bool _isWorthy(VibeCompatibilityResult c) {
    return c.basicCompatibility >= VibeConstants.minimumCompatibilityThreshold &&
        c.aiPleasurePotential >= VibeConstants.minAIPleasureScore &&
        c.learningOpportunities.isNotEmpty;
  }
  
  // ========================================================================
  // OFFLINE PEER CONNECTION (Philosophy Implementation - Phase 1)
  // OUR_GUTS.md: "Always Learning With You"
  // Philosophy: The key works everywhere - offline AI2AI connections via Bluetooth
  // ========================================================================
  
  /// Establish offline peer-to-peer connection (no internet required)
  /// 
  /// Philosophy: "Doors appear everywhere (subway, park, street). 
  /// The key should work anywhere, not just when online."
  /// 
  /// Flow:
  /// 1. Exchange personality profiles via Bluetooth/NSD
  /// 2. Calculate compatibility locally
  /// 3. Generate learning insights locally
  /// 4. Update both AIs immediately (on-device)
  /// 5. Queue connection log for cloud sync (optional, when online)
  Future<ConnectionMetrics?> establishOfflinePeerConnection(
    String localUserId,
    PersonalityProfile localPersonality,
    String remoteDeviceId,
  ) async {
    // Verify we have the required dependencies
    if (personalityLearning == null || ai2aiProtocol == null) {
      throw Exception(
        'Offline AI2AI requires PersonalityLearning and AI2AIProtocol dependencies'
      );
    }
    
    try {
      // Step 1: Exchange personality profiles peer-to-peer
      final remoteProfile = await ai2aiProtocol!.exchangePersonalityProfile(
        remoteDeviceId,
        localPersonality,
      );
      
      if (remoteProfile == null) {
        // Exchange failed (timeout, connection lost, etc.)
        return null;
      }
      
      // Step 2: Calculate compatibility locally (no cloud needed)
      final compatibility = await ai2aiProtocol!.calculateLocalCompatibility(
        localPersonality,
        remoteProfile,
        vibeAnalyzer,
      );
      
      // Check if connection is worthy
      if (!_isWorthy(compatibility)) {
        return null;
      }
      
      // Step 3: Generate learning insights locally
      final learningInsight = await ai2aiProtocol!.generateLocalLearningInsights(
        localPersonality,
        remoteProfile,
        compatibility,
      );
      
      // Step 4: Apply learning to local AI immediately (offline learning)
      await personalityLearning!.evolveFromAI2AILearning(
        localUserId,
        learningInsight,
      );
      
      // Step 5: Create connection metrics
      final localVibe = await vibeAnalyzer.compileUserVibe(localUserId, localPersonality);
      final remoteVibe = await vibeAnalyzer.compileUserVibe(remoteProfile.agentId, remoteProfile);
      
      final anonLocal = await PrivacyProtection.anonymizeUserVibe(localVibe);
      final anonRemote = await PrivacyProtection.anonymizeUserVibe(remoteVibe);
      
      final metrics = ConnectionMetrics.initial(
        localAISignature: anonLocal.vibeSignature,
        remoteAISignature: anonRemote.vibeSignature,
        compatibility: compatibility.basicCompatibility,
      );
      
      // TODO: Queue connection log for cloud sync when online
      // This is optional - the AI has already learned offline
      
      return metrics;
      
    } catch (e) {
      // Log error but don't throw - offline connections can fail gracefully
      return null;
    }
  }
}

/// Bundles realtime listener wiring and disposables
class RealtimeCoordinator {
  final AI2AIRealtimeService realtime;
  StreamSubscription? personalitySub;
  StreamSubscription? learningSub;
  StreamSubscription? anonymousSub;

  RealtimeCoordinator(this.realtime);

  void setup({
    required void Function(RealtimeMessage) onPersonality,
    required void Function(RealtimeMessage) onLearning,
    required void Function(RealtimeMessage) onAnonymous,
  }) {
    dispose();
    personalitySub = realtime.listenToPersonalityDiscovery().listen(onPersonality);
    learningSub = realtime.listenToVibeLearning().listen(onLearning);
    anonymousSub = realtime.listenToAnonymousCommunication().listen(onAnonymous);
  }

  void dispose() {
    personalitySub?.cancel();
    learningSub?.cancel();
    anonymousSub?.cancel();
  }
}


