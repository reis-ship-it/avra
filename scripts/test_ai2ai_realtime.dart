import 'dart:developer' as developer;
import 'dart:async';
import 'package:spots/core/services/ai2ai_realtime_service.dart';
import 'package:spots/core/services/supabase_service.dart';
import 'package:spots/core/ai2ai/connection_orchestrator.dart';
import 'package:spots/core/services/business/ai/vibe_analysis_engine.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Test script for AI2AI Realtime Service integration
/// Demonstrates real-time AI2AI communication via Supabase Realtime
void main() async {
  developer.log('🚀 Starting AI2AI Realtime Service Test', name: 'TestAI2AIRealtime');
  
  try {
    // Initialize services
    final supabaseService = SupabaseService();
    final vibeAnalyzer = UserVibeAnalyzer();
    final connectivity = Connectivity();
    
    // Create connection orchestrator
    final orchestrator = VibeConnectionOrchestrator(
      vibeAnalyzer: vibeAnalyzer,
      connectivity: connectivity,
    );
    
    // Create AI2AI realtime service
    final realtimeService = AI2AIRealtimeService(supabaseService, orchestrator);
    
    // Test Supabase connection
    developer.log('🔌 Testing Supabase connection...', name: 'TestAI2AIRealtime');
    final isConnected = await supabaseService.testConnection();
    
    if (!isConnected) {
      developer.log('❌ Supabase connection failed. Please check your configuration.', name: 'TestAI2AIRealtime');
      return;
    }
    
    developer.log('✅ Supabase connection successful', name: 'TestAI2AIRealtime');
    
    // Initialize AI2AI realtime service
    developer.log('🔌 Initializing AI2AI Realtime Service...', name: 'TestAI2AIRealtime');
    final realtimeInitialized = await realtimeService.initialize();
    
    if (!realtimeInitialized) {
      developer.log('❌ AI2AI Realtime Service initialization failed', name: 'TestAI2AIRealtime');
      return;
    }
    
    developer.log('✅ AI2AI Realtime Service initialized successfully', name: 'TestAI2AIRealtime');
    
    // Test realtime functionality
    await _testRealtimeFunctionality(realtimeService);
    
    // Test AI2AI communication
    await _testAI2AICommunication(realtimeService);
    
    // Test presence tracking
    await _testPresenceTracking(realtimeService);
    
    // Clean up
    await realtimeService.disconnect();
    developer.log('🧹 Test completed successfully', name: 'TestAI2AIRealtime');
    
  } catch (e) {
    developer.log('❌ Test failed: $e', name: 'TestAI2AIRealtime');
  }
}

/// Test realtime functionality
Future<void> _testRealtimeFunctionality(AI2AIRealtimeService realtimeService) async {
  developer.log('📡 Testing realtime functionality...', name: 'TestAI2AIRealtime');
  
  try {
    // Test personality discovery broadcasting
    final testNode = AIPersonalityNode(
      nodeId: 'test_node_${DateTime.now().millisecondsSinceEpoch}',
      vibeSignature: 'test_signature_123',
      compatibilityScore: 0.85,
      learningPotential: 0.92,
      lastSeen: DateTime.now(),
      isOnline: true,
    );
    
    await realtimeService.broadcastPersonalityDiscovery(testNode);
    developer.log('✅ Personality discovery broadcast successful', name: 'TestAI2AIRealtime');
    
    // Test vibe learning broadcasting
    final dimensionUpdates = {
      'exploration_eagerness': 0.8,
      'community_orientation': 0.7,
      'authenticity_preference': 0.9,
    };
    
    await realtimeService.broadcastVibeLearning(dimensionUpdates);
    developer.log('✅ Vibe learning broadcast successful', name: 'TestAI2AIRealtime');
    
    // Test anonymous messaging
    await realtimeService.sendAnonymousMessage('test_message', {
      'message_type': 'test',
      'content': 'This is a test message',
      'timestamp': DateTime.now().toIso8601String(),
    });
    developer.log('✅ Anonymous message sent successfully', name: 'TestAI2AIRealtime');
    
  } catch (e) {
    developer.log('❌ Realtime functionality test failed: $e', name: 'TestAI2AIRealtime');
  }
}

/// Test AI2AI communication
Future<void> _testAI2AICommunication(AI2AIRealtimeService realtimeService) async {
  developer.log('💬 Testing AI2AI communication...', name: 'TestAI2AIRealtime');
  
  try {
    // Set up listeners for different message types
    final personalityDiscoveryStream = realtimeService.listenToPersonalityDiscovery();
    final vibeLearningStream = realtimeService.listenToVibeLearning();
    final anonymousCommunicationStream = realtimeService.listenToAnonymousCommunication();
    
    // Listen for personality discovery events
    personalityDiscoveryStream.listen((message) {
      developer.log('🔍 Received personality discovery: ${message.event}', name: 'TestAI2AIRealtime');
      developer.log('  Payload: ${message.payload}', name: 'TestAI2AIRealtime');
    });
    
    // Listen for vibe learning events
    vibeLearningStream.listen((message) {
      developer.log('🧠 Received vibe learning: ${message.event}', name: 'TestAI2AIRealtime');
      developer.log('  Payload: ${message.payload}', name: 'TestAI2AIRealtime');
    });
    
    // Listen for anonymous communication
    anonymousCommunicationStream.listen((message) {
      developer.log('💬 Received anonymous message: ${message.event}', name: 'TestAI2AIRealtime');
      developer.log('  Payload: ${message.payload}', name: 'TestAI2AIRealtime');
    });
    
    // Wait for some events to be received
    await Future.delayed(Duration(seconds: 5));
    
    developer.log('✅ AI2AI communication test completed', name: 'TestAI2AIRealtime');
    
  } catch (e) {
    developer.log('❌ AI2AI communication test failed: $e', name: 'TestAI2AIRealtime');
  }
}

/// Test presence tracking
Future<void> _testPresenceTracking(AI2AIRealtimeService realtimeService) async {
  developer.log('👥 Testing presence tracking...', name: 'TestAI2AIRealtime');
  
  try {
    // Get current presence
    final presence = await realtimeService.getAINetworkPresence();
    developer.log('👥 Current AI network presence: ${presence.length} nodes', name: 'TestAI2AIRealtime');
    
    // Watch for presence changes
    final presenceStream = realtimeService.watchAINetworkPresence();
    presenceStream.listen((presenceList) {
      developer.log('👥 Presence update: ${presenceList.length} nodes online', name: 'TestAI2AIRealtime');
      
      for (final node in presenceList) {
        developer.log('  Node: ${node['user_id']} - ${node['node_type']}', name: 'TestAI2AIRealtime');
      }
    });
    
    // Wait for presence updates
    await Future.delayed(Duration(seconds: 3));
    
    developer.log('✅ Presence tracking test completed', name: 'TestAI2AIRealtime');
    
  } catch (e) {
    developer.log('❌ Presence tracking test failed: $e', name: 'TestAI2AIRealtime');
  }
}

/// Mock AIPersonalityNode for testing
class AIPersonalityNode {
  final String nodeId;
  final String vibeSignature;
  final double compatibilityScore;
  final double learningPotential;
  final DateTime lastSeen;
  final bool isOnline;
  
  AIPersonalityNode({
    required this.nodeId,
    required this.vibeSignature,
    required this.compatibilityScore,
    required this.learningPotential,
    required this.lastSeen,
    required this.isOnline,
  });
}
