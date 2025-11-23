import 'dart:developer' as developer;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:spots/core/models/personality_profile.dart';
import 'package:spots/core/models/user_vibe.dart';
import 'package:spots/core/models/connection_metrics.dart';
import 'package:spots/core/ai/personality_learning.dart' as pl;
import 'package:http/http.dart' as http;

/// LLM Service for Google Gemini integration
/// Provides LLM-powered chat and text generation for SPOTS AI features
/// Handles offline scenarios gracefully with connectivity checks
class LLMService {
  static const String _logName = 'LLMService';
  
  final SupabaseClient client;
  final Connectivity connectivity;
  
  LLMService(this.client, {Connectivity? connectivity}) 
      : connectivity = connectivity ?? Connectivity();
  
  /// Check if device is online
  Future<bool> _isOnline() async {
    try {
      final result = await connectivity.checkConnectivity();
      if (result is List) {
        return !result.contains(ConnectivityResult.none);
      }
      return result != ConnectivityResult.none;
    } catch (e) {
      developer.log('Connectivity check failed, assuming offline: $e', name: _logName);
      return false;
    }
  }

  /// Chat with the LLM
  /// 
  /// [messages] - List of chat messages with role and content
  /// [context] - Optional context about user, location, preferences
  /// [temperature] - Controls randomness (0.0-1.0), default 0.7
  /// [maxTokens] - Maximum tokens in response, default 500
  /// 
  /// Throws [OfflineException] if device is offline
  Future<String> chat({
    required List<ChatMessage> messages,
    LLMContext? context,
    double temperature = 0.7,
    int maxTokens = 500,
  }) async {
    // Check connectivity before making request
    final isOnline = await _isOnline();
    if (!isOnline) {
      developer.log('Device is offline, cannot use cloud AI', name: _logName);
      throw OfflineException('Cloud AI requires internet connection. Please check your connection and try again.');
    }

    try {
      developer.log('Sending chat request to LLM: ${messages.length} messages', name: _logName);
      
      final response = await client.functions.invoke(
        'llm-chat',
        body: jsonEncode({
          'messages': messages.map((m) => {
            'role': m.role,
            'content': m.content,
          }).toList(),
          'context': context?.toJson(),
          'temperature': temperature,
          'maxTokens': maxTokens,
        }),
      );
      
      if (response.status != 200) {
        final errorData = response.data is String 
            ? jsonDecode(response.data as String) 
            : response.data;
        throw Exception('LLM request failed: ${response.status} - ${errorData['error'] ?? 'Unknown error'}');
      }
      
      final data = response.data is String 
          ? jsonDecode(response.data as String) 
          : response.data;
      
      final responseText = data['response'] as String?;
      if (responseText == null || responseText.isEmpty) {
        throw Exception('Empty response from LLM');
      }
      
      developer.log('Received LLM response: ${responseText.length} characters', name: _logName);
      return responseText;
    } catch (e) {
      developer.log('LLM service error: $e', name: _logName);
      rethrow;
    }
  }
  
  /// Generate a recommendation or response based on user query
  /// 
  /// [userQuery] - The user's question or request
  /// [userContext] - Context about the user (location, preferences, etc.)
  Future<String> generateRecommendation({
    required String userQuery,
    LLMContext? userContext,
  }) async {
    return chat(
      messages: [
        ChatMessage(
          role: ChatRole.user,
          content: userQuery,
        )
      ],
      context: userContext,
    );
  }
  
  /// Generate a response in a conversation
  /// 
  /// [conversationHistory] - Previous messages in the conversation
  /// [userMessage] - Current user message
  /// [context] - User context
  Future<String> continueConversation({
    required List<ChatMessage> conversationHistory,
    required String userMessage,
    LLMContext? context,
  }) async {
    final messages = [
      ...conversationHistory,
      ChatMessage(role: ChatRole.user, content: userMessage),
    ];
    
    return chat(
      messages: messages,
      context: context,
    );
  }
  
  /// Generate list name suggestions based on user intent
  Future<List<String>> suggestListNames({
    required String userIntent,
    LLMContext? context,
  }) async {
    try {
      final prompt = 'Based on this user request: "$userIntent", suggest 3-5 creative list names for a location discovery app. Return only the list names, one per line, no numbering or bullets.';
      
      final response = await chat(
        messages: [
          ChatMessage(role: ChatRole.user, content: prompt),
        ],
        context: context,
        maxTokens: 200,
      );
      
      // Parse response into list names
      final names = response
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty && !line.startsWith(RegExp(r'[0-9\-•]')))
          .take(5)
          .toList();
      
      return names.isEmpty ? ['New List'] : names;
    } catch (e) {
      developer.log('Error generating list names: $e', name: _logName);
      return ['New List'];
    }
  }
  
  /// Generate spot recommendations based on query
  Future<String> generateSpotRecommendations({
    required String query,
    LLMContext? context,
  }) async {
    final prompt = 'User is looking for: "$query". Provide helpful, concise recommendations for places to visit. Focus on authentic local spots.';
    
    return chat(
      messages: [
        ChatMessage(role: ChatRole.user, content: prompt),
      ],
      context: context,
      maxTokens: 300,
    );
  }
  
  /// Chat with the LLM using streaming for real-time response display
  /// 
  /// [messages] - List of chat messages with role and content
  /// [context] - Optional context about user, location, preferences
  /// [temperature] - Controls randomness (0.0-1.0), default 0.7
  /// [maxTokens] - Maximum tokens in response, default 500
  /// 
  /// Returns a Stream<String> that emits chunks of text as they arrive
  /// Throws [OfflineException] if device is offline
  /// 
  /// Note: Streaming support depends on Edge Function configuration
  /// Falls back to non-streaming if streaming not available
  /// Chat with the LLM using streaming responses
  /// Returns a stream of progressive text chunks for real-time display
  /// 
  /// Optional Enhancement: Real SSE Streaming
  /// Set useRealSSE=true to use actual Server-Sent Events from Gemini API
  /// Set useRealSSE=false to use simulated streaming (faster to implement, still smooth UX)
  Stream<String> chatStream({
    required List<ChatMessage> messages,
    LLMContext? context,
    double temperature = 0.7,
    int maxTokens = 500,
    bool useRealSSE = true, // Toggle between real and simulated streaming
  }) async* {
    // Check connectivity before making request
    final isOnline = await _isOnline();
    if (!isOnline) {
      developer.log('Device is offline, cannot use cloud AI', name: _logName);
      throw OfflineException('Cloud AI requires internet connection. Please check your connection and try again.');
    }

    try {
      developer.log('Sending streaming chat request to LLM: ${messages.length} messages (realSSE: $useRealSSE)', name: _logName);
      
      if (useRealSSE) {
        // Use real SSE streaming from Edge Function
        yield* _chatStreamSSE(messages, context, temperature, maxTokens);
      } else {
        // Use simulated streaming (fallback)
        yield* _chatStreamSimulated(messages, context, temperature, maxTokens);
      }
      
      developer.log('Completed streaming response', name: _logName);
    } catch (e) {
      developer.log('LLM streaming error: $e', name: _logName);
      rethrow;
    }
  }
  
  /// Real SSE streaming from Edge Function
  Stream<String> _chatStreamSSE(
    List<ChatMessage> messages,
    LLMContext? context,
    double temperature,
    int maxTokens,
  ) async* {
    final url = '${client.supabaseUrl}/functions/v1/llm-chat-stream';
    
    final request = http.Request('POST', Uri.parse(url));
    request.headers.addAll({
      'Authorization': 'Bearer ${client.supabaseKey}',
      'Content-Type': 'application/json',
    });
    request.body = jsonEncode({
      'messages': messages.map((m) => m.toJson()).toList(),
      if (context != null) 'context': context.toJson(),
      'temperature': temperature,
      'maxTokens': maxTokens,
    });
    
    final streamedResponse = await request.send();
    
    if (streamedResponse.statusCode != 200) {
      final error = await streamedResponse.stream.bytesToString();
      throw Exception('SSE stream error: ${streamedResponse.statusCode} - $error');
    }
    
    String accumulatedText = '';
    
    await for (final chunk in streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      // Parse SSE events
      if (chunk.startsWith('data: ')) {
        final data = chunk.substring(6);
        
        try {
          final event = jsonDecode(data) as Map<String, dynamic>;
          
          // Check for completion
          if (event['done'] == true) {
            break;
          }
          
          // Check for error
          if (event['error'] != null) {
            throw Exception('SSE error: ${event['error']}');
          }
          
          // Extract text chunk
          if (event['text'] != null) {
            final text = event['text'] as String;
            accumulatedText += text;
            yield accumulatedText; // Yield cumulative text
          }
        } catch (e) {
          developer.log('Error parsing SSE event: $e', name: _logName);
          // Continue processing other events
        }
      }
    }
    
    // Ensure final text is yielded
    if (accumulatedText.isNotEmpty) {
      yield accumulatedText;
    }
  }
  
  /// Simulated streaming (fallback for offline or testing)
  Stream<String> _chatStreamSimulated(
    List<ChatMessage> messages,
    LLMContext? context,
    double temperature,
    int maxTokens,
  ) async* {
    // Use regular chat and simulate streaming
    final response = await chat(
      messages: messages,
      context: context,
      temperature: temperature,
      maxTokens: maxTokens,
    );
    
    // Simulate streaming by yielding chunks
    const chunkSize = 5; // Characters per chunk
    for (int i = 0; i < response.length; i += chunkSize) {
      final end = (i + chunkSize < response.length) ? i + chunkSize : response.length;
      yield response.substring(0, end); // Yield cumulative text
      
      // Small delay to simulate streaming
      await Future.delayed(const Duration(milliseconds: 20));
    }
  }
}

/// Chat message with role and content
class ChatMessage {
  final ChatRole role;
  final String content;
  
  ChatMessage({
    required this.role,
    required this.content,
  });
  
  Map<String, String> toJson() => {
    'role': role.name,
    'content': content,
  };
}

/// Chat message roles
enum ChatRole {
  user,
  assistant,
  system,
}

/// Context for LLM requests with full AI/ML system integration
class LLMContext {
  final String? userId;
  final Position? location;
  final Map<String, dynamic>? preferences;
  final List<Map<String, dynamic>>? recentSpots;
  
  // AI/ML System Integration
  final PersonalityProfile? personality;
  final UserVibe? vibe;
  final List<pl.AI2AILearningInsight>? ai2aiInsights;
  final ConnectionMetrics? connectionMetrics;
  
  LLMContext({
    this.userId,
    this.location,
    this.preferences,
    this.recentSpots,
    // AI/ML Integration
    this.personality,
    this.vibe,
    this.ai2aiInsights,
    this.connectionMetrics,
  });
  
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (userId != null) json['userId'] = userId;
    if (location != null) {
      json['location'] = {
        'lat': location!.latitude,
        'lng': location!.longitude,
      };
    }
    if (preferences != null) json['preferences'] = preferences;
    if (recentSpots != null) json['recentSpots'] = recentSpots;
    
    // Personality integration
    if (personality != null) {
      json['personality'] = {
        'archetype': personality!.archetype,
        'dimensions': personality!.dimensions,
        'dimensionConfidence': personality!.dimensionConfidence,
        'authenticity': personality!.authenticity,
        'evolutionGeneration': personality!.evolutionGeneration,
        'dominantTraits': personality!.getDominantTraits(),
      };
    }
    
    // Vibe integration
    if (vibe != null) {
      json['vibe'] = {
        'archetype': vibe!.getVibeArchetype(),
        'overallEnergy': vibe!.overallEnergy,
        'socialPreference': vibe!.socialPreference,
        'explorationTendency': vibe!.explorationTendency,
        'anonymizedDimensions': vibe!.anonymizedDimensions,
        'temporalContext': vibe!.temporalContext,
      };
    }
    
    // AI2AI insights integration
    if (ai2aiInsights != null && ai2aiInsights!.isNotEmpty) {
      json['ai2aiInsights'] = ai2aiInsights!.map((insight) => {
        'type': insight.type.toString(),
        'dimensionInsights': insight.dimensionInsights,
        'learningQuality': insight.learningQuality,
        'timestamp': insight.timestamp.toIso8601String(),
      }).toList();
    }
    
    // Connection metrics integration
    if (connectionMetrics != null) {
      json['connectionMetrics'] = {
        'initialCompatibility': connectionMetrics!.initialCompatibility,
        'currentCompatibility': connectionMetrics!.currentCompatibility,
        'learningEffectiveness': connectionMetrics!.learningEffectiveness,
        'aiPleasureScore': connectionMetrics!.aiPleasureScore,
        'status': connectionMetrics!.status.toString(),
        'learningOutcomes': connectionMetrics!.learningOutcomes,
      };
    }
    
    return json;
  }
}

/// Exception thrown when cloud AI is requested but device is offline
class OfflineException implements Exception {
  final String message;
  
  OfflineException(this.message);
  
  @override
  String toString() => 'OfflineException: $message';
}

