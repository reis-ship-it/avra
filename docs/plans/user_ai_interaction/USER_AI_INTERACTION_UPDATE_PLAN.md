# User-AI Interaction Update Plan

**Date:** December 16, 2025, 10:42 AM CST  
**Status:** 📋 Ready for Implementation  
**Priority:** HIGH  
**Timeline:** 6-8 weeks  
**Purpose:** Comprehensive plan for implementing layered AI inference, learning loop closure, and user interaction enhancement

---

## 🚪 **DOORS PHILOSOPHY ALIGNMENT**

### **What Doors Does This Help Users Open?**

This update opens doors to:
- **Better AI Understanding:** AI learns from every interaction, showing doors that truly resonate
- **Faster, More Private Responses:** On-device processing means doors appear instantly, even offline
- **Richer Context:** AI understands not just what you do, but when, where, and why
- **Meaningful Connections:** Learning system helps AI2AI connections find people who open similar doors
- **Life Enrichment:** Continuous learning means the AI gets better at showing you doors that lead to meaning, fulfillment, and happiness

### **When Are Users Ready for These Doors?**

- **Immediate:** On-device inference works right away (privacy, speed)
- **Gradual:** Learning system improves over time as it observes patterns
- **Contextual:** Different doors appear based on time, location, social context
- **Receptive Moments:** AI learns when you're open to new doors vs. when you want familiar ones

### **Is This Being a Good Key?**

✅ **Yes** - This update:
- Preserves privacy (on-device processing)
- Works offline (doors appear anywhere)
- Learns authentically (from real actions, not assumptions)
- Adapts to individual usage patterns
- Enhances real-world experiences (not replaces them)

### **Is the AI Learning With the User?**

✅ **Yes** - This update:
- Processes every interaction in real-time
- Updates personality dimensions continuously
- Learns from social and community patterns
- Improves recommendations based on what doors users actually open
- Feeds back into agent generation pipeline

---

## 🎯 **EXECUTIVE SUMMARY**

This plan implements a comprehensive User-AI interaction system that:

1. **Layered Inference Path:** ONNX orchestrator for privacy-sensitive scoring locally, Gemini for higher-level reasoning
2. **Supabase Edge Mesh:** Small, focused edge functions for onboarding aggregation, social enrichment, and LLM generation
3. **Retrieval + LLM Fusion:** Deterministic layer converts interactions into structured facts, feeds distilled context to Gemini
4. **Federated Learning:** AI2AI hooks collect anonymized embedding deltas for on-device personalization
5. **Decision Fabric:** Coordinator service chooses optimal pathway (offline/online, local/cloud) in real-time
6. **Micro Event Instrumentation:** Structured events (list_view_started, respect_tap, scroll_depth) with rich context
7. **Schema Hooks:** Complete Supabase queries for social and community data
8. **Learning Loop Closure:** Real-time model updates from interaction events
9. **Context Enrichment:** Time, location, weather, social context in all events
10. **Learning Quality Monitoring:** Analytics dashboards and feedback loops

**Result:** Fast, private, context-aware AI that learns continuously and opens doors that truly resonate.

---

## 📊 **CURRENT STATE ANALYSIS**

### ✅ **What Exists:**

1. **ContinuousLearningSystem** (`lib/core/ai/continuous_learning_system.dart`)
   - ✅ Framework exists with 10 learning dimensions
   - ✅ Data collection methods (location, weather, time) implemented
   - ❌ `processUserInteraction()`, `trainModel()`, `updateModelRealtime()` are stubs
   - ❌ `_collectSocialData()`, `_collectCommunityData()`, `_collectAppUsageData()` are stubs

2. **Inference Infrastructure**
   - ✅ ConfigService supports `device_first` orchestration strategy
   - ✅ ONNX backend stub exists (`lib/core/ml/onnx_backend_stub.dart`)
   - ✅ Cloud embedding client exists
   - ❌ ONNX currently disabled (cloud-only mode)
   - ❌ No InferenceOrchestrator implementation

3. **Supabase Edge Functions**
   - ✅ Edge function infrastructure exists
   - ✅ Coordinator function exists
   - ✅ Embeddings function exists
   - ❌ No onboarding aggregation function
   - ❌ No social enrichment function
   - ❌ No LLM generation function

4. **OnboardingDataService**
   - ✅ Service exists and saves data to Sembast
   - ✅ Uses agentId for privacy protection
   - ❌ No realtime event triggers to edge functions
   - ❌ No integration with learning system

5. **LLM Service**
   - ✅ LLMService exists (`lib/core/services/llm_service.dart`)
   - ✅ Supabase edge function integration
   - ❌ No structured context preparation
   - ❌ No retrieval-augmented generation

### ❌ **What's Missing:**

1. **Layered Inference Path**
   - No ONNX orchestrator implementation
   - No device-first strategy logic
   - No dimension scoring on-device

2. **Edge Mesh Functions**
   - No onboarding aggregation function
   - No social data enrichment function
   - No LLM generation function with context

3. **Learning Loop**
   - No real-time interaction processing
   - No model training from events
   - No dimension weight updates

4. **Event Instrumentation**
   - No structured event logging
   - No context field enrichment
   - No event persistence

5. **Schema Integration**
   - No Supabase queries for social data
   - No Supabase queries for community data
   - No event storage schema

---

## 🏗️ **ARCHITECTURE OVERVIEW**

### **Layered AI Stack**

```
┌─────────────────────────────────────────────────────────────┐
│                    User Interaction                        │
│  (Respect tap, list view, scroll, dwell time, etc.)       │
└──────────────────────┬────────────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │  Event Instrumentation Layer  │
        │  • Structured events          │
        │  • Context enrichment         │
        │  • Offline queue              │
        └──────────────┬─────────────────┘
                       │
        ┌──────────────┴─────────────────┐
        │                                │
        ▼                                ▼
┌───────────────────┐        ┌──────────────────────┐
│  On-Device Layer  │        │   Edge/Cloud Layer    │
│  (ONNX + Rules)   │        │  (Supabase + Gemini)  │
└─────────┬─────────┘        └──────────┬────────────┘
          │                             │
          ▼                             ▼
┌─────────────────────────┐  ┌──────────────────────────┐
│  ContinuousLearning     │  │  Edge Functions Mesh     │
│  System                 │  │  • Onboarding Agg        │
│  • Dimension scoring    │  │  • Social Enrichment     │
│  • Real-time updates    │  │  • LLM Generation        │
│  • Offline processing   │  └──────────┬───────────────┘
└─────────┬───────────────┘             │
          │                              │
          └──────────────┬───────────────┘
                         │
                         ▼
              ┌──────────────────────┐
              │  Decision Fabric      │
              │  (Pathway Coordinator)│
              └──────────┬────────────┘
                         │
                         ▼
              ┌──────────────────────┐
              │  PersonalityProfile  │
              │  (Updated Dimensions)│
              └──────────────────────┘
```

### **Data Flow**

1. **User Interaction** → Structured event with context
2. **Event Queue** → Local (Sembast/Isar) + Sync to Supabase when online
3. **On-Device Processing** → ONNX dimension scoring → Immediate UI updates
4. **Edge Processing** → Supabase functions → Social/community enrichment
5. **LLM Processing** → Structured facts → Gemini → Rich narrative
6. **Learning Update** → Dimension weights → PersonalityProfile
7. **Feedback Loop** → Updated profile → Better recommendations

---

## 📋 **IMPLEMENTATION PHASES**

### **Phase 1: Event Instrumentation & Schema Hooks (Week 1-2)**

**Goal:** Instrument micro events and complete schema hooks for data collection.

#### **1.1: Structured Event System**

**Files:**
- `lib/core/ai/interaction_events.dart` (NEW)
- `lib/core/ai/event_logger.dart` (NEW)
- `lib/core/ai/event_queue.dart` (NEW)

**Implementation:**

```dart
// lib/core/ai/interaction_events.dart
class InteractionEvent {
  final String eventType; // list_view_started, respect_tap, scroll_depth, etc.
  final Map<String, dynamic> parameters; // list_id, category, dwell_time, etc.
  final InteractionContext context; // time, location, weather, social
  final DateTime timestamp;
  final String? agentId; // Privacy-protected user identifier
}

class InteractionContext {
  final DateTime timeOfDay;
  final LocationData? location;
  final WeatherData? weather;
  final SocialContext? social; // Who's nearby, AI2AI connections
  final AppContext? app; // Current screen, previous actions
}
```

**Events to Instrument:**
- `list_view_started` (list_id, category, source)
- `list_view_duration` (list_id, duration_ms)
- `respect_tap` (target_type, target_id, context)
- `scroll_depth` (list_id, depth_percentage, scroll_velocity)
- `dwell_time` (spot_id, duration_ms, interaction_type)
- `search_performed` (query, results_count, selected_result)
- `spot_visited` (spot_id, visit_duration, check_in)
- `event_attended` (event_id, attendance_duration)

**Integration Points:**
- Add event logging to `ListDetailPage`, `SpotDetailPage`, `SearchPage`
- Add event logging to respect buttons, scroll listeners
- Add event logging to navigation transitions

#### **1.2: Complete Schema Hooks**

**Files:**
- `lib/core/ai/continuous_learning_system.dart` (UPDATE)

**Implementation:**

```dart
// Complete _collectSocialData()
Future<List<dynamic>> _collectSocialData() async {
  try {
    final supabase = Supabase.instance.client;
    final agentId = await _agentIdService.getUserAgentId(userId);
    
    // Query user_respects
    final respects = await supabase
        .from('user_respects')
        .select('*, spots(*), lists(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);
    
    // Query user_follows
    final follows = await supabase
        .from('user_follows')
        .select('*, followed_user:users!user_follows_followed_user_id_fkey(*)')
        .eq('follower_id', userId)
        .limit(50);
    
    // Query comments/shares
    final comments = await supabase
        .from('comments')
        .select('*, spot:spots(*), list:lists(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(20);
    
    final shares = await supabase
        .from('shares')
        .select('*, spot:spots(*), list:lists(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(20);
    
    return [
      ...respects.map((r) => {'type': 'respect', 'data': r}),
      ...follows.map((f) => {'type': 'follow', 'data': f}),
      ...comments.map((c) => {'type': 'comment', 'data': c}),
      ...shares.map((s) => {'type': 'share', 'data': s}),
    ];
  } catch (e) {
    developer.log('Error collecting social data: $e', name: _logName);
    return [];
  }
}

// Complete _collectCommunityData()
Future<List<dynamic>> _collectCommunityData() async {
  try {
    final supabase = Supabase.instance.client;
    
    // Query user_respects aggregated
    final respectedLists = await supabase
        .from('lists')
        .select('*, respects:user_respects(count)')
        .gt('respect_count', 0)
        .order('respect_count', ascending: false)
        .limit(20);
    
    // Query community interactions
    final interactions = await supabase
        .from('community_interactions')
        .select('*, user:users(*), spot:spots(*), list:lists(*)')
        .order('created_at', ascending: false)
        .limit(50);
    
    // Query trending spots/lists
    final trendingSpots = await supabase
        .from('spots')
        .select('*, respects:user_respects(count)')
        .order('respect_count', ascending: false)
        .limit(20);
    
    return [
      ...respectedLists.map((l) => {'type': 'respected_list', 'data': l}),
      ...interactions.map((i) => {'type': 'interaction', 'data': i}),
      ...trendingSpots.map((s) => {'type': 'trending_spot', 'data': s}),
    ];
  } catch (e) {
    developer.log('Error collecting community data: $e', name: _logName);
    return [];
  }
}

// Complete _collectAppUsageData()
Future<List<dynamic>> _collectAppUsageData() async {
  try {
    final supabase = Supabase.instance.client;
    final agentId = await _agentIdService.getUserAgentId(userId);
    
    // Query interaction_events table (created in Phase 1.1)
    final events = await supabase
        .from('interaction_events')
        .select('*')
        .eq('agent_id', agentId)
        .order('timestamp', ascending: false)
        .limit(100);
    
    // Aggregate by event type
    final aggregated = <String, Map<String, dynamic>>{};
    for (final event in events) {
      final type = event['event_type'] as String;
      if (!aggregated.containsKey(type)) {
        aggregated[type] = {
          'event_type': type,
          'count': 0,
          'total_duration': 0,
          'last_occurrence': event['timestamp'],
        };
      }
      aggregated[type]!['count']++;
      if (event['parameters']?['duration_ms'] != null) {
        aggregated[type]!['total_duration'] += event['parameters']['duration_ms'];
      }
    }
    
    return aggregated.values.toList();
  } catch (e) {
    developer.log('Error collecting app usage data: $e', name: _logName);
    return [];
  }
}
```

**Database Schema (Supabase Migration):**

```sql
-- Create interaction_events table
CREATE TABLE interaction_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id TEXT NOT NULL, -- Privacy-protected identifier
  event_type TEXT NOT NULL, -- list_view_started, respect_tap, etc.
  parameters JSONB NOT NULL, -- Flexible event parameters
  context JSONB, -- time, location, weather, social context
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for efficient queries
CREATE INDEX idx_interaction_events_agent_id ON interaction_events(agent_id);
CREATE INDEX idx_interaction_events_timestamp ON interaction_events(timestamp DESC);
CREATE INDEX idx_interaction_events_type ON interaction_events(event_type);

-- Enable RLS (Row Level Security)
ALTER TABLE interaction_events ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own events (via agentId)
CREATE POLICY "Users can view own events"
  ON interaction_events
  FOR SELECT
  USING (agent_id = current_setting('app.current_agent_id', true));
```

**Deliverables:**
- ✅ Structured event system with context enrichment
- ✅ Event queue with offline support
- ✅ Complete schema hooks for social/community/app usage data
- ✅ Database migration for interaction_events table
- ✅ Integration with UI components

---

### **Phase 2: Learning Loop Closure (Week 2-3)**

**Goal:** Implement real-time learning from interactions, closing the loop from events to dimension updates.

#### **2.1: Implement processUserInteraction()**

**Files:**
- `lib/core/ai/continuous_learning_system.dart` (UPDATE)

**Implementation:**

```dart
Future<void> processUserInteraction(Map<String, dynamic> payload) async {
  try {
    final eventType = payload['event_type'] as String;
    final parameters = payload['parameters'] as Map<String, dynamic>? ?? {};
    final context = payload['context'] as Map<String, dynamic>? ?? {};
    
    // Map event to learning dimensions
    final dimensionUpdates = <String, double>{};
    
    switch (eventType) {
      case 'respect_tap':
        // Respecting a "coffee spots" list bumps community_evolution and personalization_depth
        final targetType = parameters['target_type'] as String?;
        if (targetType == 'list') {
          final category = parameters['category'] as String?;
          dimensionUpdates['community_evolution'] = 0.05;
          dimensionUpdates['personalization_depth'] = 0.03;
          
          // Category-specific learning
          if (category != null) {
            dimensionUpdates['user_preference_understanding'] = 0.02;
          }
        }
        break;
        
      case 'list_view_duration':
        // Longer dwell time indicates interest
        final duration = parameters['duration_ms'] as int? ?? 0;
        if (duration > 30000) { // 30 seconds
          dimensionUpdates['user_preference_understanding'] = 0.04;
          dimensionUpdates['recommendation_accuracy'] = 0.02;
        }
        break;
        
      case 'scroll_depth':
        // Deep scrolling indicates engagement
        final depth = parameters['depth_percentage'] as double? ?? 0.0;
        if (depth > 0.8) {
          dimensionUpdates['user_preference_understanding'] = 0.03;
        }
        break;
        
      case 'spot_visited':
        // Visiting a spot indicates recommendation success
        dimensionUpdates['recommendation_accuracy'] = 0.05;
        dimensionUpdates['location_intelligence'] = 0.03;
        break;
        
      case 'event_attended':
        // Attending events indicates community engagement
        dimensionUpdates['community_evolution'] = 0.08;
        dimensionUpdates['social_dynamics'] = 0.05;
        break;
    }
    
    // Apply context modifiers
    final timeOfDay = context['time_of_day'] as String?;
    final location = context['location'] as Map<String, dynamic>?;
    final weather = context['weather'] as Map<String, dynamic>?;
    
    // Time-based learning (e.g., morning coffee preferences)
    if (timeOfDay == 'morning' && eventType == 'spot_visited') {
      dimensionUpdates['temporal_patterns'] = 0.02;
    }
    
    // Location-based learning
    if (location != null) {
      dimensionUpdates['location_intelligence'] = 
          (dimensionUpdates['location_intelligence'] ?? 0.0) + 0.01;
    }
    
    // Weather-based learning
    if (weather != null) {
      final conditions = weather['conditions'] as String?;
      if (conditions == 'Rain' && eventType == 'spot_visited') {
        dimensionUpdates['temporal_patterns'] = 0.01;
      }
    }
    
    // Update dimension weights
    for (final entry in dimensionUpdates.entries) {
      final current = _currentLearningState[entry.key] ?? 0.5;
      final learningRate = _learningRates[entry.key] ?? 0.1;
      final newValue = (current + (entry.value * learningRate)).clamp(0.0, 1.0);
      _currentLearningState[entry.key] = newValue;
      
      // Record learning event
      _recordLearningEvent(
        entry.key,
        entry.value,
        LearningData.empty(), // Will be enriched in next cycle
      );
    }
    
    // Trigger real-time model update
    await updateModelRealtime(payload);
    
    developer.log(
      'Processed interaction: $eventType → ${dimensionUpdates.length} dimension updates',
      name: _logName,
    );
  } catch (e) {
    developer.log('Error processing user interaction: $e', name: _logName);
  }
}
```

#### **2.2: Implement trainModel()**

**Files:**
- `lib/core/ai/continuous_learning_system.dart` (UPDATE)

**Implementation:**

```dart
Future<void> trainModel(dynamic data) async {
  try {
    // Collect recent interaction history
    final recentEvents = await _collectRecentInteractions(limit: 100);
    
    // Group by dimension
    final dimensionData = <String, List<Map<String, dynamic>>>{};
    for (final event in recentEvents) {
      final updates = await _calculateDimensionUpdates(event);
      for (final entry in updates.entries) {
        if (!dimensionData.containsKey(entry.key)) {
          dimensionData[entry.key] = [];
        }
        dimensionData[entry.key]!.add({
          'event': event,
          'update': entry.value,
        });
      }
    }
    
    // Train each dimension
    for (final entry in dimensionData.entries) {
      final dimension = entry.key;
      final trainingData = entry.value;
      
      // Calculate average improvement
      final avgImprovement = trainingData
          .map((d) => d['update'] as double)
          .reduce((a, b) => a + b) / trainingData.length;
      
      // Update dimension weight
      final current = _currentLearningState[dimension] ?? 0.5;
      final learningRate = _learningRates[dimension] ?? 0.1;
      final newValue = (current + (avgImprovement * learningRate)).clamp(0.0, 1.0);
      _currentLearningState[dimension] = newValue;
      
      // Update improvement metrics
      _improvementMetrics[dimension] = avgImprovement;
      
      developer.log(
        'Trained dimension $dimension: $current → $newValue (improvement: $avgImprovement)',
        name: _logName,
      );
    }
    
    // Save updated state
    await _saveLearningState();
  } catch (e) {
    developer.log('Error training model: $e', name: _logName);
  }
}

Future<List<Map<String, dynamic>>> _collectRecentInteractions({int limit = 100}) async {
  try {
    final supabase = Supabase.instance.client;
    final agentId = await _agentIdService.getUserAgentId(userId);
    
    final events = await supabase
        .from('interaction_events')
        .select('*')
        .eq('agent_id', agentId)
        .order('timestamp', ascending: false)
        .limit(limit);
    
    return List<Map<String, dynamic>>.from(events);
  } catch (e) {
    developer.log('Error collecting recent interactions: $e', name: _logName);
    return [];
  }
}

Future<Map<String, double>> _calculateDimensionUpdates(Map<String, dynamic> event) async {
  // Reuse logic from processUserInteraction()
  // This is a helper to calculate updates without applying them
  final payload = {
    'event_type': event['event_type'],
    'parameters': event['parameters'] ?? {},
    'context': event['context'] ?? {},
  };
  
  // Calculate updates (same logic as processUserInteraction)
  // Return map of dimension → update value
  return {}; // Simplified - full implementation in processUserInteraction
}
```

#### **2.3: Implement updateModelRealtime()**

**Files:**
- `lib/core/ai/continuous_learning_system.dart` (UPDATE)
- `lib/core/ai/personality_learning.dart` (UPDATE - feed back to PersonalityProfile)

**Implementation:**

```dart
Future<void> updateModelRealtime(Map<String, dynamic> payload) async {
  try {
    // Get current PersonalityProfile
    final personalityService = GetIt.instance<PersonalityLearning>();
    final currentProfile = await personalityService.getPersonalityProfile(agentId);
    
    if (currentProfile == null) {
      developer.log('No personality profile found for realtime update', name: _logName);
      return;
    }
    
    // Map learning state to personality dimensions
    final dimensionMap = {
      'user_preference_understanding': 'exploration_eagerness',
      'location_intelligence': 'location_adventurousness',
      'temporal_patterns': 'temporal_flexibility',
      'social_dynamics': 'community_orientation',
      'community_evolution': 'community_orientation',
      'recommendation_accuracy': 'trust_network_reliance',
      'personalization_depth': 'authenticity_preference',
    };
    
    // Update personality dimensions based on learning state
    final updatedDimensions = Map<String, double>.from(currentProfile.dimensions);
    for (final entry in _currentLearningState.entries) {
      final personalityDim = dimensionMap[entry.key];
      if (personalityDim != null) {
        // Blend: 70% current, 30% learning update
        final current = updatedDimensions[personalityDim] ?? 0.5;
        final learning = entry.value;
        final blended = (current * 0.7) + (learning * 0.3);
        updatedDimensions[personalityDim] = blended.clamp(0.0, 1.0);
      }
    }
    
    // Update PersonalityProfile
    final updatedProfile = PersonalityProfile(
      agentId: currentProfile.agentId,
      dimensions: updatedDimensions,
      archetype: currentProfile.archetype, // May update based on dimension changes
      authenticity: currentProfile.authenticity,
      createdAt: currentProfile.createdAt,
      updatedAt: DateTime.now(),
    );
    
    // Save updated profile
    await personalityService.updatePersonalityProfile(updatedProfile);
    
    developer.log(
      'Updated PersonalityProfile with ${_currentLearningState.length} learning dimensions',
      name: _logName,
    );
  } catch (e) {
    developer.log('Error updating model realtime: $e', name: _logName);
  }
}
```

**Deliverables:**
- ✅ `processUserInteraction()` fully implemented
- ✅ `trainModel()` fully implemented
- ✅ `updateModelRealtime()` fully implemented
- ✅ Integration with PersonalityProfile
- ✅ Real-time dimension updates from interactions

---

### **Phase 3: Layered Inference Path (Week 3-4)**

**Goal:** Implement ONNX orchestrator for device-first inference, with Gemini fallback for complex reasoning.

#### **3.1: InferenceOrchestrator Implementation**

**Files:**
- `lib/core/ml/inference_orchestrator.dart` (NEW)
- `lib/core/ml/onnx_dimension_scorer.dart` (NEW)
- `lib/injection_container.dart` (UPDATE - re-enable ONNX)

**Implementation:**

```dart
// lib/core/ml/inference_orchestrator.dart
class InferenceOrchestrator {
  final OnnxDimensionScorer? onnxScorer;
  final LLMService llmService;
  final ConfigService config;
  
  InferenceOrchestrator({
    this.onnxScorer,
    required this.llmService,
    required this.config,
  });
  
  /// Orchestrates inference based on strategy
  Future<InferenceResult> infer({
    required Map<String, dynamic> input,
    required InferenceStrategy strategy,
  }) async {
    switch (strategy) {
      case InferenceStrategy.deviceFirst:
        return await _deviceFirstInference(input);
      case InferenceStrategy.edgePrefetch:
        return await _edgePrefetchInference(input);
      case InferenceStrategy.cloudOnly:
        return await _cloudOnlyInference(input);
    }
  }
  
  /// Device-first: ONNX for dimension math, Gemini for reasoning
  Future<InferenceResult> _deviceFirstInference(Map<String, dynamic> input) async {
    try {
      // Step 1: ONNX dimension scoring (privacy-sensitive, fast)
      Map<String, double> dimensionScores = {};
      if (onnxScorer != null) {
        dimensionScores = await onnxScorer!.scoreDimensions(input);
      } else {
        // Fallback to rule-based scoring
        dimensionScores = _ruleBasedDimensionScoring(input);
      }
      
      // Step 2: Check if Gemini expansion needed
      final needsExpansion = _needsGeminiExpansion(input, dimensionScores);
      
      if (needsExpansion) {
        // Step 3: Prepare structured context for Gemini
        final structuredContext = _prepareStructuredContext(input, dimensionScores);
        
        // Step 4: Call Gemini with distilled context
        final geminiResponse = await llmService.chat(
          messages: [
            {
              'role': 'system',
              'content': 'You are a helpful assistant for SPOTS. Use the provided dimension scores and context to provide recommendations.',
            },
            {
              'role': 'user',
              'content': _buildPrompt(input, structuredContext),
            },
          ],
          context: structuredContext,
        );
        
        return InferenceResult(
          dimensionScores: dimensionScores,
          reasoning: geminiResponse,
          source: InferenceSource.hybrid, // ONNX + Gemini
        );
      } else {
        // ONNX-only result
        return InferenceResult(
          dimensionScores: dimensionScores,
          reasoning: null,
          source: InferenceSource.device, // ONNX only
        );
      }
    } catch (e) {
      // Fallback to cloud-only
      return await _cloudOnlyInference(input);
    }
  }
  
  bool _needsGeminiExpansion(Map<String, dynamic> input, Map<String, double> scores) {
    // Heuristics for when to use Gemini:
    // 1. Complex query (natural language, multiple intents)
    // 2. Low confidence scores (need reasoning)
    // 3. User explicitly requests narrative/explanation
    // 4. Context requires social/community insights
    
    final query = input['query'] as String? ?? '';
    final hasComplexQuery = query.length > 50 || query.contains('?');
    final hasLowConfidence = scores.values.any((s) => s < 0.3);
    final needsNarrative = input['needs_narrative'] as bool? ?? false;
    
    return hasComplexQuery || hasLowConfidence || needsNarrative;
  }
  
  Map<String, dynamic> _prepareStructuredContext(
    Map<String, dynamic> input,
    Map<String, double> scores,
  ) {
    // Convert to structured facts for Gemini
    return {
      'dimension_scores': scores,
      'traits': _scoresToTraits(scores),
      'places': input['places'] ?? [],
      'social_graph': input['social_graph'] ?? [],
      'onboarding_data': input['onboarding_data'] ?? {},
    };
  }
  
  List<String> _scoresToTraits(Map<String, double> scores) {
    final traits = <String>[];
    if (scores['exploration_eagerness'] ?? 0.0 > 0.7) traits.add('explorer');
    if (scores['community_orientation'] ?? 0.0 > 0.7) traits.add('community-focused');
    if (scores['location_adventurousness'] ?? 0.0 > 0.7) traits.add('adventurous');
    // ... more trait mappings
    return traits;
  }
  
  String _buildPrompt(Map<String, dynamic> input, Map<String, dynamic> context) {
    final query = input['query'] as String? ?? '';
    final traits = (context['traits'] as List?)?.join(', ') ?? '';
    
    return '''
User query: $query
User traits: $traits
Dimension scores: ${context['dimension_scores']}
Context: ${context}

Provide a helpful recommendation based on this context.
''';
  }
  
  Map<String, double> _ruleBasedDimensionScoring(Map<String, dynamic> input) {
    // Fallback rule-based scoring when ONNX unavailable
    // This is the existing logic from PersonalityLearning
    return {};
  }
  
  Future<InferenceResult> _edgePrefetchInference(Map<String, dynamic> input) async {
    // Similar to device-first but prefetches from edge
    // Implementation similar to device-first
    return await _deviceFirstInference(input);
  }
  
  Future<InferenceResult> _cloudOnlyInference(Map<String, dynamic> input) async {
    // Pure cloud inference (current implementation)
    final response = await llmService.chat(
      messages: [
        {
          'role': 'user',
          'content': input['query'] as String? ?? '',
        },
      ],
    );
    
    return InferenceResult(
      dimensionScores: {},
      reasoning: response,
      source: InferenceSource.cloud,
    );
  }
}

enum InferenceStrategy {
  deviceFirst, // ONNX for math, Gemini for reasoning
  edgePrefetch, // Edge cache + device
  cloudOnly, // Pure cloud (fallback)
}

enum InferenceSource {
  device, // ONNX only
  hybrid, // ONNX + Gemini
  cloud, // Cloud only
}

class InferenceResult {
  final Map<String, double> dimensionScores;
  final String? reasoning;
  final InferenceSource source;
  
  InferenceResult({
    required this.dimensionScores,
    this.reasoning,
    required this.source,
  });
}
```

#### **3.2: ONNX Dimension Scorer**

**Files:**
- `lib/core/ml/onnx_dimension_scorer.dart` (NEW)

**Implementation:**

```dart
// lib/core/ml/onnx_dimension_scorer.dart
class OnnxDimensionScorer {
  // ONNX runtime instance
  // Model loading
  // Dimension scoring logic
  
  /// Scores personality dimensions from onboarding inputs
  Future<Map<String, double>> scoreDimensions(Map<String, dynamic> input) async {
    // Map onboarding inputs → dimension scores
    // Use ONNX model for fast, privacy-sensitive scoring
    // Returns dimension scores (0.0-1.0)
    return {};
  }
  
  /// Enforces safety heuristics
  bool validateScores(Map<String, double> scores) {
    // Check for extreme values
    // Validate dimension ranges
    // Return true if safe
    return true;
  }
}
```

**Deliverables:**
- ✅ InferenceOrchestrator implementation
- ✅ ONNX dimension scorer
- ✅ Device-first strategy logic
- ✅ Integration with LLMService
- ✅ Re-enable ONNX in injection_container.dart

---

### **Phase 4: Supabase Edge Mesh (Week 4-5)**

**Goal:** Create small, focused edge functions for onboarding aggregation, social enrichment, and LLM generation.

#### **4.1: Onboarding Aggregation Function**

**Files:**
- `supabase/functions/onboarding-aggregation/index.ts` (NEW)

**Implementation:**

```typescript
// supabase/functions/onboarding-aggregation/index.ts
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const { agentId, onboardingData } = await req.json()
    
    // Aggregate onboarding data
    const aggregated = {
      age: onboardingData.age,
      homebase: onboardingData.homebase,
      favoritePlaces: onboardingData.favoritePlaces?.length ?? 0,
      preferences: onboardingData.preferences,
      baselineLists: onboardingData.baselineLists?.length ?? 0,
      respectedFriends: onboardingData.respectedFriends?.length ?? 0,
      socialMediaConnected: onboardingData.socialMediaConnected || [],
    }
    
    // Map to dimensions (rule-based)
    const dimensions = mapOnboardingToDimensions(aggregated)
    
    // Store aggregated data
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )
    
    await supabase
      .from('onboarding_aggregations')
      .upsert({
        agent_id: agentId,
        aggregated_data: aggregated,
        dimensions: dimensions,
        updated_at: new Date().toISOString(),
      })
    
    return new Response(JSON.stringify({ success: true, dimensions }), {
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 })
  }
})

function mapOnboardingToDimensions(aggregated: any) {
  // Rule-based mapping: onboarding → dimensions
  // Similar to PersonalityLearning logic
  return {}
}
```

#### **4.2: Social Data Enrichment Function**

**Files:**
- `supabase/functions/social-enrichment/index.ts` (NEW)

**Implementation:**

```typescript
// supabase/functions/social-enrichment/index.ts
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const { agentId } = await req.json()
    
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )
    
    // Query social data
    const respects = await supabase
      .from('user_respects')
      .select('*, spots(*), lists(*)')
      .eq('user_id', userId)
      .limit(50)
    
    const follows = await supabase
      .from('user_follows')
      .select('*, followed_user:users(*)')
      .eq('follower_id', userId)
      .limit(50)
    
    // Enrich with insights
    const insights = {
      respectPatterns: analyzeRespectPatterns(respects.data),
      followNetwork: analyzeFollowNetwork(follows.data),
      socialInfluence: calculateSocialInfluence(respects.data, follows.data),
    }
    
    return new Response(JSON.stringify({ insights }), {
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 })
  }
})

function analyzeRespectPatterns(respects: any[]) {
  // Analyze what user respects (categories, types, etc.)
  return {}
}

function analyzeFollowNetwork(follows: any[]) {
  // Analyze follow network structure
  return {}
}

function calculateSocialInfluence(respects: any[], follows: any[]) {
  // Calculate social influence metrics
  return {}
}
```

#### **4.3: LLM Generation Function with Context**

**Files:**
- `supabase/functions/llm-generation/index.ts` (NEW - or update existing)

**Implementation:**

```typescript
// supabase/functions/llm-generation/index.ts
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'

serve(async (req) => {
  try {
    const { 
      query, 
      structuredContext, // From retrieval layer
      dimensionScores, // From ONNX/device
      personalityProfile, // From PersonalityProfile
    } = await req.json()
    
    // Call Gemini with distilled context
    const response = await fetch('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': Deno.env.get('GEMINI_API_KEY')!,
      },
      body: JSON.stringify({
        contents: [{
          parts: [{
            text: buildPrompt(query, structuredContext, dimensionScores, personalityProfile),
          }],
        }],
      }),
    })
    
    const data = await response.json()
    const generatedText = data.candidates[0].content.parts[0].text
    
    // Publish back to client via Supabase Realtime
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )
    
    await supabase
      .from('llm_responses')
      .insert({
        agent_id: structuredContext.agentId,
        query: query,
        response: generatedText,
        created_at: new Date().toISOString(),
      })
    
    return new Response(JSON.stringify({ response: generatedText }), {
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 })
  }
})

function buildPrompt(
  query: string,
  structuredContext: any,
  dimensionScores: any,
  personalityProfile: any,
) {
  return `
User query: ${query}

Structured context:
- Traits: ${structuredContext.traits?.join(', ')}
- Places: ${structuredContext.places?.length || 0} places
- Social graph: ${structuredContext.social_graph?.length || 0} connections

Dimension scores: ${JSON.stringify(dimensionScores)}
Personality profile: ${JSON.stringify(personalityProfile)}

Provide a helpful recommendation based on this context.
`
}
```

#### **4.4: Realtime Event Triggers**

**Files:**
- `supabase/functions/onboarding-aggregation/index.ts` (UPDATE - add trigger)
- Database triggers (NEW)

**Implementation:**

```sql
-- Trigger: When OnboardingDataService saves, trigger edge function
CREATE OR REPLACE FUNCTION trigger_onboarding_aggregation()
RETURNS TRIGGER AS $$
BEGIN
  -- Call edge function via HTTP (or use pg_net extension)
  PERFORM net.http_post(
    url := current_setting('app.edge_function_url') || '/onboarding-aggregation',
    body := jsonb_build_object(
      'agent_id', NEW.agent_id,
      'onboarding_data', NEW.data
    )
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER onboarding_saved_trigger
  AFTER INSERT OR UPDATE ON onboarding_data
  FOR EACH ROW
  EXECUTE FUNCTION trigger_onboarding_aggregation();
```

**Deliverables:**
- ✅ Onboarding aggregation edge function
- ✅ Social enrichment edge function
- ✅ LLM generation function with structured context
- ✅ Realtime event triggers
- ✅ Integration with OnboardingDataService

---

### **Phase 5: Retrieval + LLM Fusion (Week 5-6)**

**Goal:** Build deterministic layer that converts interactions into structured facts, indexes them, and feeds distilled context to Gemini.

#### **5.1: Structured Facts Layer**

**Files:**
- `lib/core/ai/structured_facts_extractor.dart` (NEW)
- `lib/core/ai/facts_index.dart` (NEW)

**Implementation:**

```dart
// lib/core/ai/structured_facts_extractor.dart
class StructuredFactsExtractor {
  /// Extracts structured facts from interactions
  Future<StructuredFacts> extractFacts(List<InteractionEvent> events) async {
    final traits = <String>[];
    final places = <String>[];
    final socialGraph = <String>[];
    
    for (final event in events) {
      switch (event.eventType) {
        case 'respect_tap':
          final targetType = event.parameters['target_type'];
          if (targetType == 'list') {
            final category = event.parameters['category'];
            if (category != null) traits.add('prefers_$category');
          }
          break;
          
        case 'spot_visited':
          final spotId = event.parameters['spot_id'];
          if (spotId != null) places.add(spotId);
          break;
          
        case 'event_attended':
          final eventId = event.parameters['event_id'];
          if (eventId != null) socialGraph.add('attended_$eventId');
          break;
      }
    }
    
    return StructuredFacts(
      traits: traits,
      places: places,
      socialGraph: socialGraph,
      timestamp: DateTime.now(),
    );
  }
}

class StructuredFacts {
  final List<String> traits;
  final List<String> places;
  final List<String> socialGraph;
  final DateTime timestamp;
  
  StructuredFacts({
    required this.traits,
    required this.places,
    required this.socialGraph,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() => {
    'traits': traits,
    'places': places,
    'social_graph': socialGraph,
    'timestamp': timestamp.toIso8601String(),
  };
}
```

#### **5.2: Facts Indexing**

**Files:**
- `lib/core/ai/facts_index.dart` (NEW)

**Implementation:**

```dart
// lib/core/ai/facts_index.dart
class FactsIndex {
  final SupabaseClient supabase;
  
  /// Index structured facts in Supabase/Postgres
  Future<void> indexFacts(String agentId, StructuredFacts facts) async {
    await supabase
        .from('structured_facts')
        .upsert({
          'agent_id': agentId,
          'traits': facts.traits,
          'places': facts.places,
          'social_graph': facts.socialGraph,
          'timestamp': facts.timestamp.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
  }
  
  /// Retrieve indexed facts for LLM context
  Future<StructuredFacts> retrieveFacts(String agentId) async {
    final result = await supabase
        .from('structured_facts')
        .select('*')
        .eq('agent_id', agentId)
        .order('updated_at', ascending: false)
        .limit(1)
        .single();
    
    return StructuredFacts(
      traits: List<String>.from(result['traits'] ?? []),
      places: List<String>.from(result['places'] ?? []),
      socialGraph: List<String>.from(result['social_graph'] ?? []),
      timestamp: DateTime.parse(result['timestamp']),
    );
  }
}
```

#### **5.3: LLM Context Preparation**

**Files:**
- `lib/core/services/llm_service.dart` (UPDATE)

**Implementation:**

```dart
// Update LLMService to use structured facts
Future<String> generateWithContext({
  required String query,
  required String agentId,
}) async {
  // Step 1: Retrieve structured facts
  final factsIndex = FactsIndex(supabase);
  final facts = await factsIndex.retrieveFacts(agentId);
  
  // Step 2: Get dimension scores (from ONNX or PersonalityProfile)
  final personalityService = GetIt.instance<PersonalityLearning>();
  final profile = await personalityService.getPersonalityProfile(agentId);
  final dimensionScores = profile?.dimensions ?? {};
  
  // Step 3: Prepare distilled context
  final context = {
    'traits': facts.traits,
    'places': facts.places,
    'social_graph': facts.socialGraph,
    'dimension_scores': dimensionScores,
  };
  
  // Step 4: Call Gemini with distilled context
  return await chat(
    messages: [
      {
        'role': 'user',
        'content': query,
      },
    ],
    context: context,
  );
}
```

**Deliverables:**
- ✅ Structured facts extractor
- ✅ Facts indexing system
- ✅ LLM context preparation
- ✅ Integration with LLMService
- ✅ Database schema for structured_facts

---

### **Phase 6: Federated Learning Enhancements (Week 6-7)**

**Goal:** Use AI2AI hooks to collect anonymized embedding deltas for on-device personalization.

#### **6.1: AI2AI Embedding Delta Collection**

**Files:**
- `lib/core/ai2ai/embedding_delta_collector.dart` (NEW)
- `lib/core/ai2ai/federated_learning_hooks.dart` (NEW)

**Implementation:**

```dart
// lib/core/ai2ai/embedding_delta_collector.dart
class EmbeddingDeltaCollector {
  /// Collects anonymized embedding deltas from AI2AI connections
  Future<List<EmbeddingDelta>> collectDeltas() async {
    // Get recent AI2AI connections
    final connections = await _getRecentAI2AIConnections();
    
    final deltas = <EmbeddingDelta>[];
    for (final connection in connections) {
      // Calculate embedding delta (anonymized)
      final delta = await _calculateDelta(connection);
      if (delta != null) {
        deltas.add(delta);
      }
    }
    
    return deltas;
  }
  
  Future<EmbeddingDelta?> _calculateDelta(AI2AIConnection connection) async {
    // Calculate difference between personalities
    // Anonymize (remove personal identifiers)
    // Return delta if significant
    return null; // Simplified
  }
}

class EmbeddingDelta {
  final List<double> delta; // Anonymized embedding difference
  final DateTime timestamp;
  final String? category; // Optional category (e.g., "coffee_preference")
  
  EmbeddingDelta({
    required this.delta,
    required this.timestamp,
    this.category,
  });
}
```

#### **6.2: On-Device Model Updates**

**Files:**
- `lib/core/ml/onnx_dimension_scorer.dart` (UPDATE)

**Implementation:**

```dart
// Update ONNX model with federated deltas
Future<void> updateWithDeltas(List<EmbeddingDelta> deltas) async {
  // Apply deltas to on-device model
  // Keep personalization fresh even offline
  // Lightweight update (not full retraining)
}
```

#### **6.3: Edge Sync**

**Files:**
- `supabase/functions/federated-sync/index.ts` (NEW)

**Implementation:**

```typescript
// Sync federated updates to edge functions
// Aggregate deltas from multiple agents
// Update cloud models
```

**Deliverables:**
- ✅ Embedding delta collector
- ✅ AI2AI hooks integration
- ✅ On-device model updates
- ✅ Edge sync function
- ✅ Privacy-preserving anonymization

---

### **Phase 7: Decision Fabric (Week 7-8)**

**Goal:** Coordinator service that chooses optimal pathway in real-time.

#### **7.1: Decision Coordinator**

**Files:**
- `lib/core/ai/decision_coordinator.dart` (NEW)

**Implementation:**

```dart
// lib/core/ai/decision_coordinator.dart
class DecisionCoordinator {
  final InferenceOrchestrator orchestrator;
  final ConnectivityService connectivity;
  final ConfigService config;
  
  /// Chooses optimal inference pathway
  Future<InferenceResult> coordinate({
    required Map<String, dynamic> input,
    required InferenceContext context,
  }) async {
    // Decision logic:
    // 1. Offline? → ONNX + Rules
    // 2. Online but latency critical? → Local scores + Cached recommendations
    // 3. Need rich narrative? → Gemini through LLM service
    // 4. Need social/community insights? → Edge functions
    
    final isOffline = !await connectivity.isConnected();
    final needsNarrative = context.needsNarrative;
    final latencyCritical = context.latencyCritical;
    final needsSocialInsights = context.needsSocialInsights;
    
    if (isOffline) {
      // Offline: Stick to ONNX + rules
      return await orchestrator.infer(
        input: input,
        strategy: InferenceStrategy.deviceFirst,
      );
    } else if (latencyCritical) {
      // Latency critical: Local scores + cached
      return await _getCachedRecommendations(input);
    } else if (needsNarrative || needsSocialInsights) {
      // Rich narrative or social insights: Gemini/Edge
      return await orchestrator.infer(
        input: input,
        strategy: InferenceStrategy.edgePrefetch,
      );
    } else {
      // Default: Device-first with Gemini fallback
      return await orchestrator.infer(
        input: input,
        strategy: InferenceStrategy.deviceFirst,
      );
    }
  }
  
  Future<InferenceResult> _getCachedRecommendations(Map<String, dynamic> input) async {
    // Get cached recommendations from local storage
    // Return immediately for low latency
    return InferenceResult(
      dimensionScores: {},
      reasoning: null,
      source: InferenceSource.device,
    );
  }
}

class InferenceContext {
  final bool needsNarrative;
  final bool latencyCritical;
  final bool needsSocialInsights;
  final Map<String, dynamic>? userContext;
  
  InferenceContext({
    this.needsNarrative = false,
    this.latencyCritical = false,
    this.needsSocialInsights = false,
    this.userContext,
  });
}
```

**Deliverables:**
- ✅ Decision coordinator implementation
- ✅ Pathway selection logic
- ✅ Integration with all inference layers
- ✅ Caching strategy
- ✅ Context-aware routing

---

### **Phase 8: Learning Quality Monitoring (Week 8)**

**Goal:** Implement learning history persistence and analytics dashboards.

#### **8.1: Learning History Persistence**

**Files:**
- `lib/core/ai/continuous_learning_system.dart` (UPDATE - _learningHistory)

**Implementation:**

```dart
// Persist learning history to Supabase
Future<void> _persistLearningHistory() async {
  final supabase = Supabase.instance.client;
  final agentId = await _agentIdService.getUserAgentId(userId);
  
  for (final entry in _learningHistory.entries) {
    final dimension = entry.key;
    final events = entry.value;
    
    // Store recent events
    for (final event in events.take(10)) {
      await supabase.from('learning_history').insert({
        'agent_id': agentId,
        'dimension': dimension,
        'improvement': event.improvement,
        'data_source': event.dataSource,
        'timestamp': event.timestamp.toIso8601String(),
      });
    }
  }
}
```

#### **8.2: Analytics Dashboard**

**Files:**
- `lib/presentation/pages/admin/learning_analytics_page.dart` (NEW)

**Implementation:**

```dart
// Dashboard to visualize learning quality
// Show dimension improvements over time
// Detect when interactions fail to improve metrics
// Suggest which signals to capture next
```

**Deliverables:**
- ✅ Learning history persistence
- ✅ Analytics dashboard
- ✅ Quality metrics tracking
- ✅ Feedback loop for signal optimization

---

## 🔄 **INTEGRATION POINTS**

### **1. OnboardingDataService → Edge Functions**

When `OnboardingDataService.saveOnboardingData()` is called:
1. Save to Sembast (existing)
2. Trigger Supabase Realtime event
3. Edge function `onboarding-aggregation` processes data
4. Publishes aggregated dimensions back to client

### **2. Interaction Events → Learning System**

When user interacts (respect tap, list view, etc.):
1. Log structured event with context
2. Queue locally (Sembast/Isar)
3. Process via `ContinuousLearningSystem.processUserInteraction()`
4. Update dimensions in real-time
5. Sync to Supabase when online

### **3. Learning System → PersonalityProfile**

When dimensions update:
1. `updateModelRealtime()` called
2. Map learning dimensions → personality dimensions
3. Update PersonalityProfile
4. Feed back into agent generation pipeline

### **4. Inference Orchestrator → All Layers**

When inference needed:
1. DecisionCoordinator chooses pathway
2. InferenceOrchestrator routes to appropriate layer
3. ONNX for dimension math (device)
4. Gemini for reasoning (cloud)
5. Edge functions for social/community enrichment

---

## 📊 **SUCCESS METRICS**

### **Technical Metrics:**
- ✅ Zero linter errors
- ✅ All tests passing
- ✅ <100ms on-device inference latency
- ✅ <2s cloud inference latency (with Gemini)
- ✅ 100% offline functionality for dimension scoring

### **Learning Metrics:**
- ✅ Dimension weights update within 1 second of interaction
- ✅ PersonalityProfile reflects learning updates within 5 seconds
- ✅ Learning history persisted for all dimensions
- ✅ Analytics dashboard shows improvement trends

### **User Experience Metrics:**
- ✅ Recommendations improve over time (measured by user feedback)
- ✅ Doors shown match user preferences (measured by respect/visit rates)
- ✅ AI2AI connections improve (measured by connection success rate)
- ✅ Context-aware suggestions (measured by engagement)

---

## 🚨 **RISKS & MITIGATION**

### **Risk 1: ONNX Model Complexity**
**Risk:** ONNX model may be too complex for on-device inference  
**Mitigation:** Start with simple rule-based scoring, add ONNX incrementally

### **Risk 2: Edge Function Latency**
**Risk:** Edge functions may add latency  
**Mitigation:** Use caching, prefetching, and async processing

### **Risk 3: Learning Loop Overfitting**
**Risk:** Model may overfit to recent interactions  
**Mitigation:** Use learning rates, decay factors, and validation

### **Risk 4: Privacy Concerns**
**Risk:** User data may be exposed  
**Mitigation:** Use agentId (not userId), anonymize deltas, on-device processing

---

## 📅 **TIMELINE SUMMARY**

| Phase | Duration | Key Deliverables |
|-------|----------|------------------|
| Phase 1: Event Instrumentation | Week 1-2 | Structured events, schema hooks |
| Phase 2: Learning Loop Closure | Week 2-3 | processUserInteraction, trainModel, updateModelRealtime |
| Phase 3: Layered Inference | Week 3-4 | InferenceOrchestrator, ONNX scorer |
| Phase 4: Edge Mesh | Week 4-5 | Onboarding, social, LLM edge functions |
| Phase 5: Retrieval + LLM Fusion | Week 5-6 | Structured facts, facts index |
| Phase 6: Federated Learning | Week 6-7 | Embedding deltas, on-device updates |
| Phase 7: Decision Fabric | Week 7-8 | Decision coordinator |
| Phase 8: Quality Monitoring | Week 8 | Learning history, analytics dashboard |

**Total:** 6-8 weeks

---

## ✅ **COMPLETION CRITERIA**

- [ ] All event types instrumented with context
- [ ] All schema hooks implemented (social, community, app usage)
- [ ] Learning loop fully closed (events → dimensions → PersonalityProfile)
- [ ] ONNX orchestrator working (device-first strategy)
- [ ] All edge functions deployed and tested
- [ ] Structured facts extraction and indexing working
- [ ] Federated learning hooks integrated
- [ ] Decision coordinator routing correctly
- [ ] Learning history persisted and visualized
- [ ] Zero linter errors
- [ ] All tests passing
- [ ] Documentation complete

---

## 📚 **RELATED DOCUMENTATION**

- `docs/plans/data_sources/DATA_SOURCES_IMPLEMENTATION_COMPLETE.md` - Data source connections
- `docs/plans/llm_integration/LLM_INTEGRATION_ASSESSMENT.md` - LLM integration guide
- `docs/architecture/ONBOARDING_TO_AGENT_GENERATION_FLOW.md` - Onboarding pipeline
- `lib/core/ai/continuous_learning_system.dart` - Current implementation
- `docs/plans/philosophy_implementation/SPOTS_PHILOSOPHY_AND_ARCHITECTURE.md` - Philosophy alignment

---

**Status:** 📋 Ready for Implementation  
**Last Updated:** December 16, 2025, 10:42 AM CST  
**Next Steps:** Begin Phase 1: Event Instrumentation & Schema Hooks

