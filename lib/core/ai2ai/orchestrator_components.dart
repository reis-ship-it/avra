import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:spots/core/ai/privacy_protection.dart';
import 'package:spots/core/ai/vibe_analysis_engine.dart';
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
class ConnectionManager {
  final UserVibeAnalyzer vibeAnalyzer;

  ConnectionManager({required this.vibeAnalyzer});

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


