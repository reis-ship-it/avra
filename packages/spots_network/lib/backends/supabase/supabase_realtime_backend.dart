import 'package:supabase_flutter/supabase_flutter.dart';
import '../../interfaces/realtime_backend.dart';
import '../../models/api_response.dart';

/// Supabase realtime backend implementation
class SupabaseRealtimeBackend implements RealtimeBackend {
  final SupabaseClient _client;
  Map<String, dynamic> _config = {};
  bool _isInitialized = false;
  final Map<String, RealtimeChannel> _activeChannels = {};
  
  SupabaseRealtimeBackend(this._client);
  
  @override
  bool get isInitialized => _isInitialized;
  
  @override
  Future<void> initialize(Map<String, dynamic> config) async {
    _config = Map.unmodifiable(config);
    _isInitialized = true;
  }
  
  @override
  Future<void> dispose() async {
    // Unsubscribe from all active channels
    for (final channel in _activeChannels.values) {
      await channel.unsubscribe();
    }
    _activeChannels.clear();
    _isInitialized = false;
  }
  
  @override
  Future<ApiResponse<RealtimeChannel>> subscribeToChannel(
    String channelName,
    {Map<String, dynamic>? parameters}
  ) async {
    try {
      final channel = _client.channel(channelName);
      
      // Add parameters if provided
      if (parameters != null) {
        for (final entry in parameters.entries) {
          channel = channel.addParameter(entry.key, entry.value);
        }
      }
      
      // Subscribe to the channel
      await channel.subscribe();
      
      _activeChannels[channelName] = channel;
      
      return ApiResponse.success(channel);
      
    } catch (e) {
      return ApiResponse.error('Subscribe to channel failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<void>> unsubscribeFromChannel(String channelName) async {
    try {
      final channel = _activeChannels[channelName];
      if (channel != null) {
        await channel.unsubscribe();
        _activeChannels.remove(channelName);
      }
      
      return ApiResponse.success(null);
      
    } catch (e) {
      return ApiResponse.error('Unsubscribe from channel failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<void>> broadcastMessage(
    String channelName,
    String event,
    Map<String, dynamic> payload,
  ) async {
    try {
      final channel = _activeChannels[channelName];
      if (channel != null) {
        await channel.send(
          type: RealtimeListenTypes.broadcast,
          event: event,
          payload: payload,
        );
      }
      
      return ApiResponse.success(null);
      
    } catch (e) {
      return ApiResponse.error('Broadcast message failed: $e');
    }
  }
  
  @override
  Stream<RealtimeMessage> getChannelMessages(String channelName) {
    final channel = _activeChannels[channelName];
    if (channel == null) {
      return Stream.empty();
    }
    
    return channel.on().map((event) {
      return RealtimeMessage(
        channel: channelName,
        event: event.event,
        payload: event.payload,
        timestamp: DateTime.now(),
      );
    });
  }
  
  @override
  Future<ApiResponse<void>> setPresence(
    String channelName,
    Map<String, dynamic> presence,
  ) async {
    try {
      final channel = _activeChannels[channelName];
      if (channel != null) {
        await channel.track(presence);
      }
      
      return ApiResponse.success(null);
      
    } catch (e) {
      return ApiResponse.error('Set presence failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getPresence(
    String channelName,
  ) async {
    try {
      final channel = _activeChannels[channelName];
      if (channel != null) {
        final presence = await channel.presence();
        return ApiResponse.success(presence);
      }
      
      return ApiResponse.success([]);
      
    } catch (e) {
      return ApiResponse.error('Get presence failed: $e');
    }
  }
  
  @override
  Stream<Map<String, dynamic>> watchPresence(String channelName) {
    final channel = _activeChannels[channelName];
    if (channel == null) {
      return Stream.empty();
    }
    
    return channel.onPresenceChange().map((event) {
      return event.payload as Map<String, dynamic>;
    });
  }
  
  @override
  Future<ApiResponse<void>> sendDirectMessage(
    String userId,
    Map<String, dynamic> message,
  ) async {
    try {
      // Send direct message via private channel
      final channelName = 'private:${userId}';
      final channel = _activeChannels[channelName];
      
      if (channel != null) {
        await channel.send(
          type: RealtimeListenTypes.broadcast,
          event: 'direct_message',
          payload: message,
        );
      }
      
      return ApiResponse.success(null);
      
    } catch (e) {
      return ApiResponse.error('Send direct message failed: $e');
    }
  }
  
  @override
  Stream<Map<String, dynamic>> watchDirectMessages() {
    // Watch for direct messages on user's private channel
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return Stream.empty();
    }
    
    final channelName = 'private:${userId}';
    final channel = _activeChannels[channelName];
    
    if (channel == null) {
      return Stream.empty();
    }
    
    return channel.on().where((event) => event.event == 'direct_message').map((event) {
      return event.payload as Map<String, dynamic>;
    });
  }
  
  @override
  Future<ApiResponse<void>> joinRoom(
    String roomId,
    Map<String, dynamic>? metadata,
  ) async {
    try {
      final channelName = 'room:${roomId}';
      final channel = _client.channel(channelName);
      
      if (metadata != null) {
        for (final entry in metadata.entries) {
          channel = channel.addParameter(entry.key, entry.value);
        }
      }
      
      await channel.subscribe();
      _activeChannels[channelName] = channel;
      
      return ApiResponse.success(null);
      
    } catch (e) {
      return ApiResponse.error('Join room failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<void>> leaveRoom(String roomId) async {
    try {
      final channelName = 'room:${roomId}';
      await unsubscribeFromChannel(channelName);
      
      return ApiResponse.success(null);
      
    } catch (e) {
      return ApiResponse.error('Leave room failed: $e');
    }
  }
  
  @override
  Stream<Map<String, dynamic>> watchRoomMessages(String roomId) {
    final channelName = 'room:${roomId}';
    return getChannelMessages(channelName).map((message) {
      return {
        'roomId': roomId,
        'event': message.event,
        'payload': message.payload,
        'timestamp': message.timestamp.toIso8601String(),
      };
    });
  }
  
  @override
  Future<ApiResponse<void>> startTyping(
    String channelName,
    Map<String, dynamic>? userInfo,
  ) async {
    try {
      final channel = _activeChannels[channelName];
      if (channel != null) {
        await channel.send(
          type: RealtimeListenTypes.broadcast,
          event: 'typing_start',
          payload: userInfo ?? {},
        );
      }
      
      return ApiResponse.success(null);
      
    } catch (e) {
      return ApiResponse.error('Start typing failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<void>> stopTyping(
    String channelName,
    Map<String, dynamic>? userInfo,
  ) async {
    try {
      final channel = _activeChannels[channelName];
      if (channel != null) {
        await channel.send(
          type: RealtimeListenTypes.broadcast,
          event: 'typing_stop',
          payload: userInfo ?? {},
        );
      }
      
      return ApiResponse.success(null);
      
    } catch (e) {
      return ApiResponse.error('Stop typing failed: $e');
    }
  }
  
  @override
  Stream<Map<String, dynamic>> watchTyping(String channelName) {
    final channel = _activeChannels[channelName];
    if (channel == null) {
      return Stream.empty();
    }
    
    return channel.on().where((event) => 
      event.event == 'typing_start' || event.event == 'typing_stop'
    ).map((event) {
      return {
        'event': event.event,
        'payload': event.payload,
        'timestamp': DateTime.now().toIso8601String(),
      };
    });
  }
  
  @override
  List<String> get activeChannels => _activeChannels.keys.toList();
  
  @override
  bool isSubscribedToChannel(String channelName) {
    return _activeChannels.containsKey(channelName);
  }
}

/// Realtime message model
class RealtimeMessage {
  final String channel;
  final String event;
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  
  const RealtimeMessage({
    required this.channel,
    required this.event,
    required this.payload,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'channel': channel,
      'event': event,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory RealtimeMessage.fromJson(Map<String, dynamic> json) {
    return RealtimeMessage(
      channel: json['channel'] as String,
      event: json['event'] as String,
      payload: json['payload'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
