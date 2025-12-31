import 'dart:async';
import 'dart:convert';
import 'package:spots_network/spots_network.dart';
import 'package:spots/core/ai2ai/connection_orchestrator.dart';
import 'package:spots/core/services/logger.dart';
import 'package:spots/core/ai2ai/aipersonality_node.dart';

/// Enhanced AI2AI Realtime Service for SPOTS
/// Integrates Supabase Realtime with your existing VibeConnectionOrchestrator
/// OUR_GUTS.md: "Privacy-preserving AI2AI communication with real-time updates"
class AI2AIRealtimeService {
  static const String _logName = 'AI2AIRealtimeService';

  final RealtimeBackend _realtimeBackend;
  final VibeConnectionOrchestrator _orchestrator;
  final AppLogger _logger =
      const AppLogger(defaultTag: 'AI2AI', minimumLevel: LogLevel.debug);

  // Realtime channels for AI2AI communication
  static const String _ai2aiChannel = 'ai2ai-network';
  static const String _personalityDiscoveryChannel = 'personality-discovery';
  static const String _vibeLearningChannel = 'vibe-learning';
  static const String _anonymousCommunicationChannel =
      'anonymous-communication';

  // Active channel ids tracked locally
  final Set<String> _activeChannels = {};

  AI2AIRealtimeService(this._realtimeBackend, this._orchestrator);

  /// Subscribe to AI2AI network updates
  /// Returns StreamSubscription for managing subscription lifecycle
  StreamSubscription<RealtimeEvent>? subscribeToNetwork({
    required String agentId,
    required void Function(Map<String, dynamic> data) onUpdate,
    Function(Object error)? onError,
  }) {
    try {
      _logger.debug('Subscribing to AI2AI network channel for agent: $agentId');

      final channel = _realtimeBackend.subscribe(
        channel: _ai2aiChannel,
        filter: {'agent_id': agentId},
      );

      _activeChannels.add(channel);

      return channel.listen(
        (event) {
          try {
            final data = jsonDecode(event.payload) as Map<String, dynamic>;
            onUpdate(data);
          } catch (e) {
            _logger.warning('Error parsing network update: $e');
            onError?.call(e);
          }
        },
        onError: (error) {
          _logger.error('Error in network subscription: $error');
          onError?.call(error);
        },
      );
    } catch (e, stackTrace) {
      _logger.error(
        'Error subscribing to network: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Subscribe to personality discovery updates
  StreamSubscription<RealtimeEvent>? subscribeToPersonalityDiscovery({
    required String agentId,
    required void Function(Map<String, dynamic> data) onUpdate,
    Function(Object error)? onError,
  }) {
    try {
      _logger.debug(
          'Subscribing to personality discovery channel for agent: $agentId');

      final channel = _realtimeBackend.subscribe(
        channel: _personalityDiscoveryChannel,
        filter: {'agent_id': agentId},
      );

      _activeChannels.add(channel);

      return channel.listen(
        (event) {
          try {
            final data = jsonDecode(event.payload) as Map<String, dynamic>;
            onUpdate(data);
          } catch (e) {
            _logger.warning('Error parsing discovery update: $e');
            onError?.call(e);
          }
        },
        onError: (error) {
          _logger.error('Error in discovery subscription: $error');
          onError?.call(error);
        },
      );
    } catch (e, stackTrace) {
      _logger.error(
        'Error subscribing to personality discovery: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Subscribe to vibe learning updates
  StreamSubscription<RealtimeEvent>? subscribeToVibeLearning({
    required String agentId,
    required void Function(Map<String, dynamic> data) onUpdate,
    Function(Object error)? onError,
  }) {
    try {
      _logger
          .debug('Subscribing to vibe learning channel for agent: $agentId');

      final channel = _realtimeBackend.subscribe(
        channel: _vibeLearningChannel,
        filter: {'agent_id': agentId},
      );

      _activeChannels.add(channel);

      return channel.listen(
        (event) {
          try {
            final data = jsonDecode(event.payload) as Map<String, dynamic>;
            onUpdate(data);
          } catch (e) {
            _logger.warning('Error parsing vibe learning update: $e');
            onError?.call(e);
          }
        },
        onError: (error) {
          _logger.error('Error in vibe learning subscription: $error');
          onError?.call(error);
        },
      );
    } catch (e, stackTrace) {
      _logger.error(
        'Error subscribing to vibe learning: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Broadcast AI2AI network update
  Future<bool> broadcastNetworkUpdate({
    required String agentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      _logger.debug('Broadcasting network update for agent: $agentId');

      final payload = jsonEncode({
        'agent_id': agentId,
        'timestamp': DateTime.now().toIso8601String(),
        ...data,
      });

      await _realtimeBackend.publish(
        channel: _ai2aiChannel,
        event: 'update',
        payload: payload,
      );

      return true;
    } catch (e, stackTrace) {
      _logger.error(
        'Error broadcasting network update: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Broadcast personality discovery update
  Future<bool> broadcastPersonalityDiscovery({
    required String agentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      _logger.debug('Broadcasting personality discovery for agent: $agentId');

      final payload = jsonEncode({
        'agent_id': agentId,
        'timestamp': DateTime.now().toIso8601String(),
        ...data,
      });

      await _realtimeBackend.publish(
        channel: _personalityDiscoveryChannel,
        event: 'discovery',
        payload: payload,
      );

      return true;
    } catch (e, stackTrace) {
      _logger.error(
        'Error broadcasting personality discovery: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Broadcast vibe learning update
  Future<bool> broadcastVibeLearning({
    required String agentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      _logger.debug('Broadcasting vibe learning for agent: $agentId');

      final payload = jsonEncode({
        'agent_id': agentId,
        'timestamp': DateTime.now().toIso8601String(),
        ...data,
      });

      await _realtimeBackend.publish(
        channel: _vibeLearningChannel,
        event: 'learning',
        payload: payload,
      );

      return true;
    } catch (e, stackTrace) {
      _logger.error(
        'Error broadcasting vibe learning: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Unsubscribe from a specific channel
  Future<void> unsubscribe(String channelId) async {
    try {
      _logger.debug('Unsubscribing from channel: $channelId');
      await _realtimeBackend.unsubscribe(channelId);
      _activeChannels.remove(channelId);
    } catch (e, stackTrace) {
      _logger.error(
        'Error unsubscribing from channel: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Unsubscribe from all active channels
  Future<void> unsubscribeAll() async {
    try {
      _logger.debug('Unsubscribing from all channels (${_activeChannels.length})');
      for (final channelId in _activeChannels.toList()) {
        await unsubscribe(channelId);
      }
      _activeChannels.clear();
    } catch (e, stackTrace) {
      _logger.error(
        'Error unsubscribing from all channels: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get list of active channel subscriptions
  List<String> getActiveChannels() {
    return _activeChannels.toList();
  }

  /// Check if service is connected to realtime backend
  bool isConnected() {
    return _realtimeBackend.isConnected();
  }

  /// Reconnect to realtime backend
  Future<bool> reconnect() async {
    try {
      _logger.debug('Reconnecting to realtime backend');
      await _realtimeBackend.reconnect();
      return isConnected();
    } catch (e, stackTrace) {
      _logger.error(
        'Error reconnecting: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Disconnect from realtime backend
  Future<void> disconnect() async {
    try {
      _logger.debug('Disconnecting from realtime backend');
      await unsubscribeAll();
      await _realtimeBackend.disconnect();
    } catch (e, stackTrace) {
      _logger.error(
        'Error disconnecting: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
