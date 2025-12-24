# Onboarding Process Plan - Complete Pipeline Fix

**Date:** December 16, 2025  
**Last Updated:** December 22, 2025 (Added patent references and formulas)  
**Status:** 📋 Ready for Implementation  
**Priority:** P1 - Core Functionality  
**Timeline:** 4-6 weeks (9 phases, Phase 0 is critical blocker)

**Patent Integration:**
- **Patent Mapping:** `docs/patents/PATENT_TO_MASTER_PLAN_MAPPING.md` - Complete mapping of all 29 patents
- **Patent #1:** Quantum Compatibility Calculation System ⭐⭐⭐⭐⭐ (Tier 1) - Phase 4 (Quantum Vibe Engine)
- **Patent #3:** Contextual Personality System with Drift Resistance ⭐⭐⭐⭐⭐ (Tier 1) - Phase 3 (PersonalityProfile)
- **Patent #12:** Multi-Path Dynamic Expertise System ⭐⭐⭐⭐⭐ (Tier 1) - Phase 1 (Baseline Lists)

---

## 🎯 **EXECUTIVE SUMMARY**

Fix the complete onboarding → agent generation pipeline to match the architecture specification. Currently, the implementation is a "best-effort approximation" with critical gaps that prevent the system from working as designed. This plan addresses all identified gaps to ensure the product matches the architecture spec.

**Current State:**
- 🔴 **CRITICAL:** Onboarding never reaches AILoadingPage (routed to /home instead)
- ✅ Onboarding flow exists but missing baseline lists step
- ✅ AILoadingPage exists but receives empty social data
- ✅ PersonalityProfile exists but keyed by userId (not agentId)
- ✅ **Quantum Vibe Engine implemented and integrated** (Phase 4 complete)
- ⚠️ Place list generator returns empty results
- ❌ SocialMediaConnectionService doesn't exist
- ❌ Social media connection state never persisted to OnboardingData
- ❌ Duplicate enum causing drift

**Goal:**
- Complete onboarding pipeline matches architecture doc exactly
- All data flows correctly from onboarding → agent generation
- Privacy boundaries respected (agentId throughout)
- Real social data collection and analysis
- Quantum Vibe Engine implemented
- Generated lists contain actual places

---

## 🚪 **DOORS PHILOSOPHY ALIGNMENT**

### **What Doors Does This Help Users Open?**

- **Personalization Door:** Users seed their initial lists, so AI recommendations start from their actual interests
- **Privacy Door:** AgentId-based system protects user privacy throughout the pipeline
- **Social Connection Door:** Real social data helps AI understand user interests and communities
- **Discovery Door:** Generated lists with actual places help users discover spots immediately
- **Authenticity Door:** Quantum Vibe Engine ensures accurate personality representation

### **When Are Users Ready for These Doors?**

- **During Onboarding:** Users are ready to provide baseline lists after expressing preferences
- **After Onboarding:** Users are ready for AI agent that truly understands them
- **With Social Data:** Users are ready to connect social accounts for richer insights

### **Is This Being a Good Key?**

✅ **Yes** - This:
- Respects user privacy (agentId throughout)
- Uses real data (not placeholders)
- Provides accurate personality representation
- Gives users control (baseline lists, social connections)
- Delivers on architecture promises

### **Is the AI Learning With the User?**

✅ **Yes** - The AI:
- Uses real onboarding data (not empty shells)
- Learns from actual social media insights (not placeholders)
- Generates lists with real places (not empty arrays)
- Creates accurate personality profiles (not approximations)

---

## 📊 **CURRENT STATE ANALYSIS**

### **Gap 0: AILoadingPage Never Reached (CRITICAL BLOCKER)**

**Problem:**
- Architecture doc shows "OnboardingPage → AI Loading Page → initializePersonalityFromOnboarding()" (lines 497-512, 621-633)
- `_completeOnboarding()` has "TEMPORARY WORKAROUND" that routes to `/home` directly (lines 558-587)
- Navigation to `/ai-loading` is commented out
- Entire agent-creation pipeline is **skipped**

**Impact:**
- `AILoadingPage` never loads
- `initializePersonalityFromOnboarding()` never called
- Place list generation never happens
- Users land on Home with default/no agent
- **All other fixes are useless until routing is restored**

**Files:**
- `lib/presentation/pages/onboarding/onboarding_page.dart` (lines 558-587)
- `lib/presentation/routes/app_router.dart` (routes definition)

**Priority:** 🔴 **CRITICAL** - Must be fixed first before any other work matters.

---

### **Gap 1: Baseline Lists Never Exist at Runtime**

**Problem:**
- Architecture doc expects users to confirm/tweak baseline lists (lines 1266-1284)
- `OnboardingPage._steps` (lines 70-109) has no `baselineLists` step
- Flow goes straight from `preferences` to `socialMedia`
- `_baselineLists` stays empty `[]` when saved (line 492)
- `AILoadingPage` always generates lists from scratch instead of using seeds

**Impact:**
- Users can't seed their initial lists
- AI always generates from scratch (inefficient)
- Architecture promise not fulfilled

**Files:**
- `lib/presentation/pages/onboarding/onboarding_page.dart`
- `lib/presentation/pages/onboarding/baseline_lists_page.dart` (exists but unused)
- `lib/presentation/pages/onboarding/onboarding_step.dart` (duplicate enum)

---

### **Gap 2: AILoadingPage Feeds Empty Shell to SocialMediaVibeAnalyzer**

**Problem:**
- Architecture doc calls for real social data: "Google: Places/Reviews/Photos... Blend 60/40" (lines 500-509, 622)
- `AILoadingPage` (lines 299-312) just inserts empty placeholder:
  ```dart
  socialMediaData = {
    'profile': {},
    'follows': [],
    'connections': [],
  }
  ```
- `SocialMediaVibeAnalyzer` receives nothing useful
- "Blend 60% onboarding / 40% social" never happens (always 100% onboarding)

**Impact:**
- Social media insights never contribute to personality
- Architecture promise of 60/40 blend not fulfilled
- Users who connect social accounts get no benefit

**Files:**
- `lib/presentation/pages/onboarding/ai_loading_page.dart`
- `lib/core/services/social_media_vibe_analyzer.dart`
- `lib/core/ai/personality_learning.dart` (blending logic exists but gets empty data)

---

### **Gap 3: Personality Profiles Still Keyed by userId**

**Problem:**
- Architecture doc promises agentId-based privacy (lines 1247-1256)
- `initializePersonalityFromOnboarding()` creates `PersonalityProfile(userId: userId, ...)` (line 245)
- Only logs agentId in metadata, doesn't use it as key
- Privacy boundary not respected

**Impact:**
- Personality profiles linked to userId (not agentId)
- Privacy promise not fulfilled
- Migration needed to fix existing profiles

**Files:**
- `lib/core/ai/personality_learning.dart` (lines 214-238)
- `lib/core/models/personality_profile.dart` (needs agentId migration)

---

### **Gap 4: Quantum Vibe Engine is Only a TODO** ✅ **COMPLETE**

**Status:** ✅ **IMPLEMENTED AND INTEGRATED**

**Patent Reference:** Patent #1 - Quantum Compatibility Calculation System ⭐⭐⭐⭐⭐ (Tier 1)

**Current State:**
- ✅ `QuantumVibeEngine` class exists and is fully implemented (`lib/core/ai/quantum/quantum_vibe_engine.dart`)
- ✅ Integrated into `initializePersonalityFromOnboarding()` (`lib/core/ai/personality_learning.dart` lines 232-301)
- ✅ Registered in dependency injection (`lib/injection_container.dart` line 389)
- ✅ Uses quantum mathematics: superposition, interference, entanglement, decoherence
- ✅ Blends quantum dimensions (70%) with onboarding dimensions (30%)
- ✅ Archetype and authenticity calculated from quantum-compiled dimensions

**Key Formulas (Patent #1):**
- **Compatibility Formula:** `C = |⟨ψ_A|ψ_B⟩|²`
  - `C` = Compatibility score (0.0 to 1.0)
  - `|ψ_A⟩` = Quantum state vector for personality A
  - `|ψ_B⟩` = Quantum state vector for personality B
  - `⟨ψ_A|ψ_B⟩` = Quantum inner product (bra-ket notation)
- **Bures Distance:** `D_B = √[2(1 - |⟨ψ_A|ψ_B⟩|)]` (quantum distance metric)
- **Entanglement:** `|ψ_entangled⟩ = |ψ_energy⟩ ⊗ |ψ_exploration⟩` (entangled dimensions)

**Mathematical Proofs (Patent #1):**
- ✅ **3 theorems + 1 corollary** (documented in patent)
- Theorem 1: Quantum Inner Product Properties
- Theorem 2: Bures Distance Metric Properties
- Theorem 3: Entanglement Impact on Compatibility
- Corollary 1: Quantum Regularization Effectiveness

**Implementation Details:**
- Quantum compilation uses multiple insight sources (personality, behavioral, social, relationship, temporal)
- Applies quantum superposition to combine insights
- Uses quantum interference patterns for dimension refinement
- Implements entanglement network for correlated dimensions
- Applies decoherence for temporal effects
- Collapses quantum states to classical probabilities for final dimensions

**Files:**
- ✅ `lib/core/ai/quantum/quantum_vibe_engine.dart` (IMPLEMENTED)
- ✅ `lib/core/ai/personality_learning.dart` (INTEGRATED at lines 232-301)
- ✅ `lib/core/ai/quantum/quantum_vibe_state.dart` (SUPPORTING CLASS)
- ✅ `lib/core/ai/quantum/quantum_vibe_dimension.dart` (SUPPORTING CLASS)

---

### **Gap 5: Generated Lists Never Contain Spots**

**Problem:**
- Architecture doc promises "Google Maps-generated personalized lists"
- `OnboardingPlaceListGenerator.searchPlacesForCategory()` always returns `[]` (lines 108-141)
- `AILoadingPage` can't create lists with actual places
- Even if baseline lists step is added, generated lists will be empty

**Impact:**
- Users get empty lists (no spots)
- Architecture promise not fulfilled
- Poor user experience

**Files:**
- `lib/core/services/onboarding_place_list_generator.dart` (lines 108-141)
- Need: Google Maps Places API integration

---

### **Gap 6: SocialMediaConnectionService Doesn't Exist**

**Problem:**
- Architecture doc calls for `SocialMediaConnectionService` to pull Google/Instagram/Facebook data (lines 500-513, 1303-1314)
- Service doesn't exist
- `AILoadingPage` can't collect real social data
- References in code are TODOs

**Impact:**
- No way to collect social media data
- Architecture promise not fulfilled
- Social insights never available

**Files:**
- Need: `lib/core/services/social_media_connection_service.dart` (NEW)
- `lib/presentation/pages/onboarding/ai_loading_page.dart` (needs integration)

---

### **Gap 7: Duplicate OnboardingStepType Enum**

**Problem:**
- `onboarding_step.dart` has orphaned enum (lines 777-798) that includes `baselineLists`
- `onboarding_page.dart` defines its own enum without `baselineLists`
- Two enums have drifted apart
- Will cause errors when adding baseline lists step

**Impact:**
- Code/doc divergence
- Future updates error-prone
- Confusion about which enum is correct

**Files:**
- `lib/presentation/pages/onboarding/onboarding_step.dart` (lines 777-798)
- `lib/presentation/pages/onboarding/onboarding_page.dart` (lines 26-35)

---

### **Gap 8: Social Media Connection State Never Persisted**

**Problem:**
- `OnboardingPage` initializes `_connectedSocialPlatforms` but never updates it (line 67)
- `SocialMediaConnectionPage` keeps its own private `_connectedPlatforms` map (line 17)
- No callback provided to report changes back to parent
- Never persists to a service
- `OnboardingData.socialMediaConnected` is always `{}` (line 494)

**Additional Problem:**
- `SocialMediaConnectionPage._connectPlatform()` is just a placeholder (lines 132-173)
- TODO comment says "Implement actual OAuth connection when Phase 12 backend is ready" (line 139)
- Boolean toggles never create real OAuth connections, store tokens, or persist credentials
- Even with callback fix, there's no `SocialMediaConnectionService` to read connections from
- Phase 2's data collection can't work without real connections and tokens

**Impact:**
- User connections never saved to `OnboardingData`
- No real OAuth flow, no tokens stored
- Even if Phase 2 adds real connection service, `AILoadingPage` will think no platforms linked
- Social media data collection will never trigger (no tokens to fetch data)
- Architecture promise not fulfilled

**Files:**
- `lib/presentation/pages/onboarding/social_media_connection_page.dart` (lines 16-201, especially 132-173)
- `lib/presentation/pages/onboarding/onboarding_page.dart` (lines 67, 278-279, 494)

---

## 📋 **IMPLEMENTATION PHASES**

### **Phase 0: Restore AILoadingPage Navigation (CRITICAL BLOCKER - Week 1, Day 1)**

**Goal:** Fix the routing blocker so onboarding actually reaches `AILoadingPage` and the agent-creation pipeline runs.

**Priority:** 🔴 **CRITICAL** - Nothing else matters if onboarding never reaches `AILoadingPage`.

#### **0.1: The Problem**

**Current state:**
- `_completeOnboarding()` has a "TEMPORARY WORKAROUND" that routes directly to `/home` (line 574)
- Actual navigation to `/ai-loading` is commented out (lines 577-585)
- This means the entire agent-creation pipeline is **skipped**
- `AILoadingPage` never runs
- `initializePersonalityFromOnboarding()` never called
- Place list generation never happens
- All future fixes are useless until routing is restored

**Impact:**
- Users land on Home with default/no agent
- Onboarding → Agent creation pipeline is disabled
- Architecture doc flow is completely bypassed

---

#### **0.2: Restore Original Navigation**

**Files:**
- `lib/presentation/pages/onboarding/onboarding_page.dart`

**Current code (lines 569-585):**
```dart
// TEMPORARY WORKAROUND: Navigate directly to home to avoid graphics crash
_logger.info('⚠️ [ONBOARDING_PAGE] Using workaround: navigating directly to /home to avoid crash',
    tag: 'Onboarding');
router.go('/home');

// Original navigation (commented out until crash is fixed):
// router.go('/ai-loading', extra: {
//   'userName': "User",
//   'birthday': _selectedBirthday?.toIso8601String(),
//   'age': age,
//   'homebase': _selectedHomebase,
//   'favoritePlaces': _favoritePlaces,
//   'preferences': _preferences,
//   'baselineLists': _baselineLists,
// });
```

**Action:** Restore navigation to `/ai-loading` with all required data:

```dart
// Get user name from auth state
final authState = context.read<AuthBloc>().state;
final userName = authState is Authenticated 
    ? (authState.user.name ?? 'User')
    : 'User';

// Navigate to AI loading page with all onboarding data
router.go('/ai-loading', extra: {
  'userName': userName,
  'birthday': _selectedBirthday?.toIso8601String(),
  'age': age,
  'homebase': _selectedHomebase,
  'favoritePlaces': _favoritePlaces,
  'preferences': _preferences,
  'baselineLists': _baselineLists,
  'respectedFriends': _respectedFriends,
  'socialMediaConnected': _connectedSocialPlatforms,
});
```

**Remove:** The workaround code (lines 569-574) and comments.

---

#### **0.3: Address Original Crash Cause**

**Problem:** The workaround was added due to a graphics-thread crash during transition.

**Root Cause Analysis:**
1. **Disposed Controller:** `_pageController` may be disposed before navigation completes
2. **Null Safety:** `AILoadingPage` widgets may assume non-null values
3. **Missing Scaffold:** `AILoadingPage` may need Material/Scaffold wrapper

**Fix Strategy:**

**Option 1: Don't dispose controller until after navigation**
```dart
// In _completeOnboarding():
// DO NOT dispose _pageController here
// Let dispose() handle it in normal widget lifecycle

// Navigate first
router.go('/ai-loading', extra: { ... });

// Controller will be disposed in dispose() method after navigation completes
```

**Option 2: Ensure AILoadingPage handles nullables**
```dart
// In AILoadingPage, ensure all parameters handle nulls:
final userName = widget.userName ?? 'User';
final age = widget.age;
final homebase = widget.homebase;
// etc.
```

**Option 3: Wrap in Scaffold if needed**
```dart
// In app_router.dart, ensure AILoadingPage route returns Scaffold:
GoRoute(
  path: '/ai-loading',
  builder: (context, state) {
    return Scaffold(
      body: AILoadingPage(...),
    );
  },
);
```

**Debug Steps:**
1. Reproduce the crash (remove workaround temporarily)
2. Check crash logs (likely in `logs/Crash...`)
3. Get stack trace
4. Identify root cause (disposed controller, null reference, etc.)
5. Apply appropriate fix

---

#### **0.4: Guard Onboarding Completion**

**Problem:** `markOnboardingCompleted()` is called before navigation (line 438), so crashes leave users stuck.

**Current flow:**
1. Save onboarding data ✅
2. Mark onboarding complete ✅ (before navigation)
3. Navigate to `/ai-loading` ❌ (crashes)
4. User stuck (onboarding marked complete, but no agent created)

**Solution:** Remove early mark from `onboarding_page.dart` - `AILoadingPage` already handles it.

**Current State:**
- `onboarding_page.dart` calls `markOnboardingCompleted()` at line 438 (before navigation)
- `AILoadingPage` already has `_markOnboardingCompleted()` method (line 777) that marks complete after agent creation succeeds

**Action:**
```dart
// In _completeOnboarding():
// REMOVE the markOnboardingCompleted call (currently at lines 438-459)
// Just save data and navigate

// AILoadingPage already handles completion marking:
// - Called after agent creation succeeds (line 491)
// - Has retry logic and error handling
// - Only marks complete when agent is actually created
```

**Why this is better:**
- Onboarding only marked complete when agent actually created
- If navigation or agent creation fails, user can retry onboarding
- Retry logic in `AILoadingPage` handles failures gracefully

---

#### **0.5: Verify AILoadingPage Wiring**

**Files:**
- `lib/presentation/routes/app_router.dart` (lines 618-646)
- `lib/presentation/pages/onboarding/ai_loading_page.dart`

**Verify:**
1. ✅ GoRoute accepts extras correctly
2. ✅ `AILoadingPage` receives data via extras
3. ✅ `AILoadingPage` loads saved data via `OnboardingDataService`
4. ✅ Generates lists (or uses baseline lists)
5. ✅ Fetches social data (when Phase 2 is complete)
6. ✅ Calls `initializePersonalityFromOnboarding()`
7. ✅ Navigates to `/home` after completion

**Check app_router.dart:** Already correctly configured (lines 590-626)

---

#### **0.6: Add Regression Coverage**

**Files:**
- `integration_test/onboarding_flow_complete_integration_test.dart` (UPDATE or CREATE)

**Test:**
```dart
testWidgets('onboarding flow reaches AILoadingPage before home', (tester) async {
  // Complete onboarding flow
  // ... fill out forms ...
  
  // Tap complete button
  await tester.tap(find.text('Complete'));
  await tester.pumpAndSettle();
  
  // Verify we're on AILoadingPage (not home)
  expect(find.text('Creating your AI agent...'), findsOneWidget);
  
  // Wait for agent creation to complete
  await tester.pumpAndSettle(const Duration(seconds: 5));
  
  // Now verify we're on home
  expect(find.byType(HomePage), findsOneWidget);
});
```

**Purpose:** Prevent future "temporary" bypasses from slipping in unnoticed.

---

### **Phase 1: Baseline Lists Integration (Week 1)**

**Goal:** Wire `BaselineListsPage` into onboarding flow so users can seed their initial lists.

**Patent Reference:** Patent #12 - Multi-Path Dynamic Expertise System with Economic Enablement ⭐⭐⭐⭐⭐ (Tier 1)
- Baseline lists seed expertise paths (Exploration, Credentials, Influence, Professional, Community, Local)
- Multi-path expertise system enables economic opportunities

#### **1.1: Add baselineLists Step to Onboarding Flow**

**Files:**
- `lib/presentation/pages/onboarding/onboarding_page.dart`

**Actions:**
1. Add `baselineLists` to `OnboardingStepType` enum (after `preferences`, before `socialMedia`)
2. Add step to `_steps` list
3. Add case in `_buildStepContent` switch to render `BaselineListsPage`
4. Import `BaselineListsPage`
5. Add case in `_canProceedToNextStep` (optional, always true)

**Code:**
```dart
enum OnboardingStepType {
  welcome,
  homebase,
  favoritePlaces,
  preferences,
  baselineLists, // ← ADD THIS
  friends,
  permissions,
  socialMedia,
  connectAndDiscover,
}

// In _steps list:
OnboardingStep(
  page: OnboardingStepType.baselineLists,
  title: 'Your Lists',
  description: 'Create your starting lists (optional)',
),

// In _buildStepContent switch:
case OnboardingStepType.baselineLists:
  return BaselineListsPage(
    baselineLists: _baselineLists,
    onBaselineListsChanged: (lists) {
      setState(() {
        _baselineLists = lists;
      });
    },
    userName: "User",
    userPreferences: _preferences,
    userFavoritePlaces: _favoritePlaces,
  );
```

**Verification:**
- ✅ Step appears in onboarding flow
- ✅ Users can edit baseline lists
- ✅ `_baselineLists` gets populated
- ✅ Saved to `OnboardingData` (already works)

---

#### **1.2: Wire Social Media Connection State**

**Files:**
- `lib/presentation/pages/onboarding/social_media_connection_page.dart`
- `lib/presentation/pages/onboarding/onboarding_page.dart`

**Problem:**
- `SocialMediaConnectionPage` maintains private `_connectedPlatforms` but never reports to parent
- `OnboardingPage._connectedSocialPlatforms` stays empty
- Never saved to `OnboardingData`

**Solution:** Add callback pattern (same as other onboarding pages)

**Update SocialMediaConnectionPage:**

**Current (no callback):**
```dart
class SocialMediaConnectionPage extends StatefulWidget {
  const SocialMediaConnectionPage({super.key});
  // No callback to report changes
}
```

**Change to:**
```dart
class SocialMediaConnectionPage extends StatefulWidget {
  final Map<String, bool> connectedPlatforms;
  final Function(Map<String, bool>) onConnectionsChanged;
  
  const SocialMediaConnectionPage({
    super.key,
    required this.connectedPlatforms,
    required this.onConnectionsChanged,
  });
}
```

**Update state initialization:**
```dart
class _SocialMediaConnectionPageState extends State<SocialMediaConnectionPage> {
  late Map<String, bool> _connectedPlatforms;
  
  @override
  void initState() {
    super.initState();
    // Initialize from parent
    _connectedPlatforms = Map<String, bool>.from(widget.connectedPlatforms);
  }
```

**Update connect/disconnect methods:**
```dart
Future<void> _connectPlatform(String platform) async {
  // ... existing connection logic ...
  
  if (mounted) {
    setState(() {
      _connectedPlatforms[platform] = true;
      _isConnecting = false;
      _connectingPlatform = null;
    });
    
    // Report changes to parent
    widget.onConnectionsChanged(Map<String, bool>.from(_connectedPlatforms));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$platform connected successfully'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

Future<void> _disconnectPlatform(String platform) async {
  // ... existing disconnect logic ...
  
  if (confirmed == true && mounted) {
    setState(() {
      _connectedPlatforms[platform] = false;
    });
    
    // Report changes to parent
    widget.onConnectionsChanged(Map<String, bool>.from(_connectedPlatforms));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$platform disconnected'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
```

**Update OnboardingPage usage:**

**Current (line 278-279):**
```dart
case OnboardingStepType.socialMedia:
  return const SocialMediaConnectionPage();
```

**Change to:**
```dart
case OnboardingStepType.socialMedia:
  return SocialMediaConnectionPage(
    connectedPlatforms: _connectedSocialPlatforms,
    onConnectionsChanged: (connections) {
      setState(() {
        _connectedSocialPlatforms = connections;
      });
    },
  );
```

**Verification:**
- ✅ User connections update `_connectedSocialPlatforms` in parent
- ✅ Saved to `OnboardingData.socialMediaConnected` (line 494)
- ✅ `AILoadingPage` receives non-empty social media flags
- ✅ Phase 2 social data collection can trigger correctly

---

#### **1.3: Remove Duplicate Enum**

**Files:**
- `lib/presentation/pages/onboarding/onboarding_step.dart`

**Actions:**
1. Check if enum is actually used (grep for references)
2. Delete duplicate enum (lines 777-798)
3. If needed, move to shared file for reuse

**Verification:**
- ✅ No duplicate enum conflicts
- ✅ Single source of truth for step types

---

### **Phase 2: Social Media Data Collection (Week 1-2)**

**Goal:** Implement `SocialMediaConnectionService` and wire it into `AILoadingPage` to collect real social data.

#### **2.1: Create SocialMediaConnectionService**

**Files:**
- `lib/core/services/social_media_connection_service.dart` (NEW)

**Implementation:**
```dart
class SocialMediaConnectionService {
  /// Connect a social media platform (runs OAuth flow and stores tokens)
  /// 
  /// [platform] - Platform name ('instagram', 'facebook', 'google', etc.)
  /// [agentId] - Privacy-protected agent identifier
  /// [userId] - User identifier for service lookup
  /// 
  /// Returns connection record after successful OAuth
  Future<SocialMediaConnection> connectPlatform({
    required String platform,
    required String agentId,
    required String userId,
  }) async {
    // Run OAuth flow for the platform
    // Store access token, refresh token (encrypted)
    // Create SocialMediaConnection record
    // Save to database
    // Return connection record
  }
  
  /// Disconnect a social media platform (removes tokens and connection)
  /// 
  /// [platform] - Platform name
  /// [agentId] - Privacy-protected agent identifier
  Future<void> disconnectPlatform({
    required String platform,
    required String agentId,
  }) async {
    // Remove connection from database
    // Clear tokens (encrypted storage)
    // Mark connection as inactive
  }
  
  /// Get active social media connections for a user
  Future<List<SocialMediaConnection>> getActiveConnections(String userId) async {
    // Query database for active connections
    // Return connections with valid tokens
  }
  
  /// Fetch profile data from platform
  Future<Map<String, dynamic>> fetchProfileData(
    SocialMediaConnection connection,
  ) async {
    // Google: Fetch profile, places, reviews, photos
    // Instagram: Fetch profile, follows, posts
    // Facebook: Fetch profile, friends, pages
    // Return structured data
  }
  
  /// Fetch follows/connections from platform
  Future<List<Map<String, dynamic>>> fetchFollows(
    SocialMediaConnection connection,
  ) async {
    // Fetch user's follows/connections
    // Return list of connection data
  }
  
  /// Fetch places/reviews/photos (Google-specific)
  Future<Map<String, dynamic>> fetchGooglePlacesData(
    SocialMediaConnection connection,
  ) async {
    // Fetch Google Places API data
    // Return places, reviews, photos
  }
}
```

**Dependencies:**
- Google Places API integration
- Instagram Graph API integration
- Facebook Graph API integration
- OAuth token management

---

#### **2.2: Replace Placeholder Logic in SocialMediaConnectionPage**

**Files:**
- `lib/presentation/pages/onboarding/social_media_connection_page.dart`
- `lib/presentation/pages/onboarding/onboarding_page.dart`

**Problem:**
- Current `_connectPlatform()` method is just a placeholder (line 132-173)
- TODO comment says OAuth flow is missing (line 139)
- Boolean toggles don't create real connections or store tokens
- No service calls to persist credentials

**Solution:** Replace placeholder with real service calls.

**Update SocialMediaConnectionPage to use service:**

**Current (placeholder):**
```dart
Future<void> _connectPlatform(String platform) async {
  // TODO: Implement actual OAuth connection when Phase 12 backend is ready
  // For now, this is a placeholder UI
  await Future.delayed(const Duration(seconds: 1));
  
  if (mounted) {
    setState(() {
      _connectedPlatforms[platform] = true;
    });
  }
}
```

**Replace with:**
```dart
Future<void> _connectPlatform(String platform) async {
  setState(() {
    _isConnecting = true;
    _connectingPlatform = platform;
  });

  try {
    // Get current user
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;
    if (authState is! Authenticated) {
      throw Exception('User not authenticated');
    }
    
    final userId = authState.user.id;
    
    // Get agentId for privacy
    final agentIdService = di.sl<AgentIdService>();
    final agentId = await agentIdService.getUserAgentId(userId);
    
    // Call service to run OAuth flow and store tokens
    final socialMediaService = di.sl<SocialMediaConnectionService>();
    final connection = await socialMediaService.connectPlatform(
      platform: platform.toLowerCase(), // 'instagram', 'facebook', etc.
      agentId: agentId, // Use agentId for privacy
      userId: userId, // For service lookup
    );
    
    if (mounted) {
      setState(() {
        _connectedPlatforms[platform] = true;
        _isConnecting = false;
        _connectingPlatform = null;
      });
      
      // Report changes to parent with real connection status
      widget.onConnectionsChanged(Map<String, bool>.from(_connectedPlatforms));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$platform connected successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _isConnecting = false;
        _connectingPlatform = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect $platform: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}

Future<void> _disconnectPlatform(String platform) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Disconnect $platform?'),
      content: Text(
        'Disconnecting $platform will stop using your social data to enhance your AI personality. You can reconnect anytime in settings.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Disconnect'),
        ),
      ],
    ),
  );

  if (confirmed == true && mounted) {
    try {
      // Get current user
      final authBloc = context.read<AuthBloc>();
      final authState = authBloc.state;
      if (authState is! Authenticated) {
        throw Exception('User not authenticated');
      }
      
      final userId = authState.user.id;
      
      // Get agentId for privacy
      final agentIdService = di.sl<AgentIdService>();
      final agentId = await agentIdService.getUserAgentId(userId);
      
      // Call service to disconnect and remove tokens
      final socialMediaService = di.sl<SocialMediaConnectionService>();
      await socialMediaService.disconnectPlatform(
        platform: platform.toLowerCase(),
        agentId: agentId,
      );
      
      setState(() {
        _connectedPlatforms[platform] = false;
      });
      
      // Report changes to parent
      widget.onConnectionsChanged(Map<String, bool>.from(_connectedPlatforms));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$platform disconnected'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to disconnect $platform: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}
```

**Add imports:**
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';
import 'package:spots/core/services/agent_id_service.dart';
import 'package:spots/core/services/social_media_connection_service.dart';
import 'package:spots/injection_container.dart' as di;
```

**Update OnboardingPage to load existing connections:**

**In _buildStepContent, initialize from service:**
```dart
case OnboardingStepType.socialMedia:
  return SocialMediaConnectionPage(
    connectedPlatforms: _connectedSocialPlatforms,
    onConnectionsChanged: (connections) async {
      setState(() {
        _connectedSocialPlatforms = connections;
      });
      
      // Optionally: Verify connections exist in service
      // This ensures OnboardingData reflects real connections
      try {
        final authBloc = context.read<AuthBloc>();
        final authState = authBloc.state;
        if (authState is Authenticated) {
          final userId = authState.user.id;
          final socialMediaService = di.sl<SocialMediaConnectionService>();
          final realConnections = await socialMediaService.getActiveConnections(userId);
          
          // Update map to reflect only real connections
          final realPlatforms = <String, bool>{};
          for (final conn in realConnections) {
            // Map platform names: 'instagram' -> 'Instagram'
            final displayName = conn.platform[0].toUpperCase() + conn.platform.substring(1);
            realPlatforms[displayName] = true;
          }
          
          setState(() {
            _connectedSocialPlatforms = realPlatforms;
          });
        }
      } catch (e) {
        // Continue with UI state if service check fails
      }
    },
  );
```

**Note:** The service should already be created in Phase 2.1. This section replaces the placeholder UI logic with real service calls.

**Verification:**
- ✅ OAuth flow runs when user connects platform
- ✅ Tokens stored in service/database
- ✅ Connection records persist
- ✅ `OnboardingData.socialMediaConnected` reflects real connections
- ✅ Phase 2.3 data collection can read connections and fetch data

---

#### **2.3: Integrate into AILoadingPage**

**Files:**
- `lib/presentation/pages/onboarding/ai_loading_page.dart`

**Current code (lines 299-312):**
```dart
// TODO: Phase 12 - Implement actual social media data collection
socialMediaData = {
  'profile': {},
  'follows': [],
  'connections': [],
};
```

**Replace with:**
```dart
// Collect real social media data if connected
Map<String, dynamic>? socialMediaData;
try {
  final socialMediaService = di.sl<SocialMediaConnectionService>();
  final connections = await socialMediaService.getActiveConnections(userId);
  
  if (connections.isNotEmpty) {
    _logger.info('📱 Found ${connections.length} social media connections', 
        tag: 'AILoadingPage');
    
    // Fetch data from each platform
    final allProfileData = <String, dynamic>{};
    final allFollows = <Map<String, dynamic>>[];
    final allConnections = <Map<String, dynamic>>[];
    String? primaryPlatform;
    
    for (final connection in connections) {
      // Fetch profile
      final profile = await socialMediaService.fetchProfileData(connection);
      allProfileData[connection.platform] = profile;
      
      // Fetch follows
      final follows = await socialMediaService.fetchFollows(connection);
      allFollows.addAll(follows);
      
      // Google-specific: Fetch places/reviews/photos
      if (connection.platform == 'google') {
        final placesData = await socialMediaService.fetchGooglePlacesData(connection);
        allProfileData['google_places'] = placesData;
      }
      
      if (primaryPlatform == null) {
        primaryPlatform = connection.platform;
      }
    }
    
    socialMediaData = {
      'profile': allProfileData,
      'follows': allFollows,
      'connections': allConnections,
      'platform': primaryPlatform ?? 'unknown',
    };
    
    _logger.info('✅ Collected social media data from ${connections.length} platforms', 
        tag: 'AILoadingPage');
  }
} catch (e) {
  _logger.warn('⚠️ Could not collect social media data: $e', tag: 'AILoadingPage');
  // Continue without social data
}
```

**Verification:**
- ✅ Real social data collected
- ✅ Passed to `SocialMediaVibeAnalyzer`
- ✅ 60/40 blend actually happens

---

### **Phase 3: PersonalityProfile agentId Migration (Week 2)**

**Goal:** Migrate `PersonalityProfile` to use `agentId` as primary key instead of `userId`.

**Patent Reference:** Patent #3 - Contextual Personality System with Drift Resistance ⭐⭐⭐⭐⭐ (Tier 1)

**Key Innovation:** Three-layered personality architecture preventing AI homogenization:
- **Core Personality:** Stable baseline with max 18.36% drift limit (`maxDrift = 0.1836`)
- **Contextual Adaptation Layers:** Context-specific personality adaptations (work, social, location)
- **Evolution Timeline:** Preserved history of all life phases forever

**Drift Resistance Formulas (Patent #3):**
- **Drift Limit:** `maxDrift = 0.1836` (18.36% absolute change limit)
- **Surface Drift Resistance:** `resistedInsight = insight * 0.1` (10% of original change)
- **Adaptive Influence Reduction:** `influence = baseInfluence * (1 - homogenizationRate)`

**Mathematical Proofs (Patent #3):**
- ✅ **3 theorems** (documented in patent)
- Theorem 1: Homogenization Convergence Without Drift Resistance
- Theorem 2: Drift Resistance Prevents Convergence
- Theorem 3: 18.36% Threshold Optimality Analysis

#### **3.1: Update PersonalityProfile Model**

**Files:**
- `lib/core/models/personality_profile.dart`

**Current:**
```dart
class PersonalityProfile {
  final String userId; // ← Change to agentId
  // ...
}
```

**Change to:**
```dart
class PersonalityProfile {
  final String agentId; // ← Privacy-protected identifier
  final String? userId; // ← Optional, for backward compatibility during migration
  // ...
}
```

---

#### **3.2: Update initializePersonalityFromOnboarding**

**Files:**
- `lib/core/ai/personality_learning.dart`

**Current (lines 245-246):**
```dart
final newProfile = PersonalityProfile(
  userId: userId, // TODO: Change to agentId after Phase 7.3 migration
  // ...
);
```

**Change to:**
```dart
// Get agentId (already available from onboardingData)
final agentId = onboardingData.agentId;

final newProfile = PersonalityProfile(
  agentId: agentId, // ✅ Use agentId for privacy
  userId: userId, // Keep for backward compatibility during migration
  // ...
);
```

---

#### **3.3: Update Persistence Layer**

**Files:**
- `lib/core/ai/personality_learning.dart` (storage methods)
- Database/storage schema

**Actions:**
1. Update storage to use `agentId` as key
2. Create migration for existing profiles
3. Update all queries to use `agentId`

**Migration:**
```dart
// Migration: Convert existing userId-based profiles to agentId-based
Future<void> migrateProfilesToAgentId() async {
  final allProfiles = await getAllProfiles(); // Get all existing profiles
  
  for (final profile in allProfiles) {
    // Get agentId for this userId
    final agentIdService = di.sl<AgentIdService>();
    final agentId = await agentIdService.getUserAgentId(profile.userId);
    
    // Create new profile with agentId
    final migratedProfile = profile.copyWith(
      agentId: agentId,
      userId: profile.userId, // Keep for reference
    );
    
    // Save with agentId as key
    await saveProfile(agentId, migratedProfile);
  }
}
```

**Verification:**
- ✅ All new profiles use `agentId`
- ✅ Existing profiles migrated
- ✅ All queries use `agentId`
- ✅ Privacy boundary respected

---

### **Phase 4: Quantum Vibe Engine Implementation (Week 3)** ✅ **COMPLETE**

**Status:** ✅ **IMPLEMENTED AND VERIFIED**

**Patent Reference:** Patent #1 - Quantum Compatibility Calculation System ⭐⭐⭐⭐⭐ (Tier 1)

**Goal:** Implement the Quantum Vibe Engine calculation as described in architecture doc.

**Key Formulas (Patent #1):**
- **Compatibility Formula:** `C = |⟨ψ_A|ψ_B⟩|²`
  - `C` = Compatibility score (0.0 to 1.0)
  - `|ψ_A⟩` = Quantum state vector for personality A
  - `|ψ_B⟩` = Quantum state vector for personality B
  - `⟨ψ_A|ψ_B⟩` = Quantum inner product (bra-ket notation)
- **Bures Distance:** `D_B = √[2(1 - |⟨ψ_A|ψ_B⟩|)]` (quantum distance metric)
- **Entanglement:** `|ψ_entangled⟩ = |ψ_energy⟩ ⊗ |ψ_exploration⟩` (entangled dimensions)

**Mathematical Proofs (Patent #1):**
- ✅ **3 theorems + 1 corollary** (documented in patent)
- Theorem 1: Quantum Inner Product Properties
- Theorem 2: Bures Distance Metric Properties
- Theorem 3: Entanglement Impact on Compatibility
- Corollary 1: Quantum Regularization Effectiveness

**Completion Status:**
- ✅ Quantum Vibe Engine class created and fully implemented
- ✅ Integrated into `initializePersonalityFromOnboarding()`
- ✅ Uses quantum mathematics (superposition, interference, entanglement, decoherence)
- ✅ Blends quantum dimensions (70%) with onboarding dimensions (30%)
- ✅ Architecture promise fulfilled

#### **4.1: Create QuantumVibeEngine** ✅ **COMPLETE**

**Files:**
- ✅ `lib/core/ai/quantum/quantum_vibe_engine.dart` (IMPLEMENTED)
- ✅ `lib/core/ai/quantum/quantum_vibe_state.dart` (SUPPORTING CLASS)
- ✅ `lib/core/ai/quantum/quantum_vibe_dimension.dart` (SUPPORTING CLASS)

**Implementation:**
```dart
class QuantumVibeEngine {
  /// Calculate personality dimensions using quantum-inspired math
  /// 
  /// Uses quantum superposition principles to blend multiple data sources
  /// into coherent personality dimensions with confidence scores.
  Future<QuantumVibeResult> calculateVibe({
    required Map<String, double> onboardingDimensions,
    required Map<String, double>? socialDimensions,
    required OnboardingData onboardingData,
  }) async {
    // Quantum-inspired calculation:
    // 1. Treat each dimension as a quantum state (superposition)
    // 2. Blend onboarding (60%) and social (40%) as quantum interference
    // 3. Calculate confidence as quantum measurement probability
    // 4. Determine archetype as collapsed quantum state
    // 5. Calculate authenticity as quantum coherence
    
    final blendedDimensions = <String, double>{};
    final confidenceScores = <String, double>{};
    
    // Quantum superposition: Blend onboarding and social
    for (final entry in onboardingDimensions.entries) {
      final dimension = entry.key;
      final onboardingValue = entry.value;
      final socialValue = socialDimensions?[dimension] ?? onboardingValue;
      
      // Quantum interference: 60% onboarding, 40% social
      final blended = (onboardingValue * 0.6 + socialValue * 0.4);
      
      // Quantum measurement probability (confidence)
      final confidence = _calculateConfidence(
        onboardingValue,
        socialValue,
        onboardingData,
      );
      
      blendedDimensions[dimension] = blended.clamp(0.0, 1.0);
      confidenceScores[dimension] = confidence;
    }
    
    // Quantum state collapse: Determine archetype
    final archetype = _collapseToArchetype(blendedDimensions);
    
    // Quantum coherence: Calculate authenticity
    final authenticity = _calculateAuthenticity(
      blendedDimensions,
      confidenceScores,
      onboardingData,
    );
    
    return QuantumVibeResult(
      dimensions: blendedDimensions,
      confidenceScores: confidenceScores,
      archetype: archetype,
      authenticity: authenticity,
    );
  }
  
  double _calculateConfidence(
    double onboardingValue,
    double socialValue,
    OnboardingData data,
  ) {
    // Quantum measurement probability
    // Higher confidence when:
    // - Onboarding and social agree
    // - More data sources available
    // - User provided detailed preferences
    
    double confidence = 0.3; // Base confidence
    
    // Agreement bonus
    final agreement = 1.0 - (onboardingValue - socialValue).abs();
    confidence += agreement * 0.2;
    
    // Data richness bonus
    if (data.preferences.isNotEmpty) confidence += 0.2;
    if (data.favoritePlaces.isNotEmpty) confidence += 0.1;
    if (data.baselineLists.isNotEmpty) confidence += 0.1;
    if (data.socialMediaConnected.values.any((v) => v)) confidence += 0.1;
    
    return confidence.clamp(0.0, 1.0);
  }
  
  String _collapseToArchetype(Map<String, double> dimensions) {
    // Quantum state collapse: Determine most likely archetype
    // Based on dimension patterns
    
    // Calculate archetype scores
    final archetypeScores = <String, double>{};
    
    // Example archetypes (expand based on your system):
    archetypeScores['adventurous_explorer'] = 
        (dimensions['exploration_eagerness'] ?? 0.0) * 0.4 +
        (dimensions['location_adventurousness'] ?? 0.0) * 0.3 +
        (dimensions['temporal_flexibility'] ?? 0.0) * 0.3;
    
    archetypeScores['community_builder'] = 
        (dimensions['community_orientation'] ?? 0.0) * 0.5 +
        (dimensions['social_discovery_style'] ?? 0.0) * 0.3 +
        (dimensions['trust_network_reliance'] ?? 0.0) * 0.2;
    
    // ... more archetypes
    
    // Return highest scoring archetype
    final maxScore = archetypeScores.values.reduce((a, b) => a > b ? a : b);
    return archetypeScores.entries
        .firstWhere((e) => e.value == maxScore)
        .key;
  }
  
  double _calculateAuthenticity(
    Map<String, double> dimensions,
    Map<String, double> confidenceScores,
    OnboardingData data,
  ) {
    // Quantum coherence: Measure how "authentic" the profile is
    // Higher authenticity when:
    // - Dimensions are internally consistent
    // - Confidence scores are high
    // - Data sources are diverse
    
    // Average confidence
    final avgConfidence = confidenceScores.values.reduce((a, b) => a + b) / 
        confidenceScores.length;
    
    // Dimension consistency (low variance = high coherence)
    final dimensionValues = dimensions.values.toList();
    final mean = dimensionValues.reduce((a, b) => a + b) / dimensionValues.length;
    final variance = dimensionValues
        .map((v) => (v - mean) * (v - mean))
        .reduce((a, b) => a + b) / dimensionValues.length;
    final consistency = 1.0 - (variance / 0.25).clamp(0.0, 1.0); // Normalize
    
    // Data diversity bonus
    double diversity = 0.0;
    if (data.preferences.isNotEmpty) diversity += 0.2;
    if (data.favoritePlaces.isNotEmpty) diversity += 0.2;
    if (data.baselineLists.isNotEmpty) diversity += 0.2;
    if (data.socialMediaConnected.values.any((v) => v)) diversity += 0.2;
    if (data.respectedFriends.isNotEmpty) diversity += 0.2;
    
    // Authenticity = weighted combination
    return (avgConfidence * 0.4 + consistency * 0.3 + diversity * 0.3)
        .clamp(0.0, 1.0);
  }
}

class QuantumVibeResult {
  final Map<String, double> dimensions;
  final Map<String, double> confidenceScores;
  final String archetype;
  final double authenticity;
  
  QuantumVibeResult({
    required this.dimensions,
    required this.confidenceScores,
    required this.archetype,
    required this.authenticity,
  });
}
```

---

#### **4.2: Integrate into PersonalityLearning** ✅ **COMPLETE**

**Files:**
- `lib/core/ai/personality_learning.dart`

**Current Implementation (lines 232-301):** ✅ **ALREADY INTEGRATED**
```dart
// 3. Use quantum engine for final dimension calculation ✅ IMPLEMENTED
final quantumEngine = di.sl<QuantumVibeEngine>();

// Convert insights to quantum-compatible format
final personalityInsights = PersonalityVibeInsights(...);
final behavioralInsights = BehavioralVibeInsights(...);
final socialInsights = SocialVibeInsights(...);
final relationshipInsights = RelationshipVibeInsights(...);
final temporalInsights = TemporalVibeInsights(...);

// Use quantum engine to compile final dimensions
final quantumDimensions = await quantumEngine.compileVibeDimensionsQuantum(
  personalityInsights,
  behavioralInsights,
  socialInsights,
  relationshipInsights,
  temporalInsights,
);

// Blend quantum dimensions with onboarding dimensions (70% quantum, 30% onboarding)
quantumDimensions.forEach((dimension, quantumValue) {
  final onboardingValue = initialDimensions[dimension] ?? 0.5;
  initialDimensions[dimension] = 
      (onboardingValue * 0.3 + quantumValue * 0.7).clamp(0.0, 1.0);
  initialConfidence[dimension] = 
      (initialConfidence[dimension] ?? 0.0) + 0.1;
});
```

**Verification:** ✅ **COMPLETE**
- ✅ Quantum Vibe Engine implemented and integrated
- ✅ Integrated into `initializePersonalityFromOnboarding()` (lines 232-301)
- ✅ Uses quantum mathematics (superposition, interference, entanglement, decoherence)
- ✅ Blends quantum dimensions (70%) with onboarding dimensions (30%)
- ✅ Registered in dependency injection (`lib/injection_container.dart`)
- ✅ Architecture promise fulfilled

---

### **Phase 5: Place List Generator Integration (Week 3-4)**

**Goal:** Integrate Google Maps Places API so generated lists contain actual places.

#### **5.1: Implement Google Maps Places API Integration**

**Files:**
- `lib/core/services/onboarding_place_list_generator.dart`

**Current (lines 108-141):**
```dart
// Search places (placeholder - can integrate Google Maps API later)
final places = await searchPlacesForCategory(...);
// Always returns []
```

**Implementation:**
```dart
Future<List<Place>> searchPlacesForCategory({
  required String category,
  required String query,
  double? latitude,
  double? longitude,
  String? type,
}) async {
  try {
    // Use Google Places API
    final placesService = di.sl<GooglePlacesService>();
    
    // Build search request
    final request = PlacesSearchRequest(
      query: query,
      location: latitude != null && longitude != null
          ? LatLng(latitude: latitude, longitude: longitude)
          : null,
      type: type,
      radius: 5000, // 5km radius
    );
    
    // Search places
    final results = await placesService.searchNearby(request);
    
    // Convert to Place models
    return results.map((result) => Place(
      id: result.placeId,
      name: result.name,
      address: result.formattedAddress,
      location: result.geometry?.location,
      rating: result.rating,
      types: result.types,
      // ... more fields
    )).toList();
  } catch (e) {
    developer.log('Error searching places: $e', name: _logName);
    return [];
  }
}
```

**Dependencies:**
- Google Places API client
- API key configuration
- Place model definition

---

#### **5.2: Update AILoadingPage to Use Real Places**

**Files:**
- `lib/presentation/pages/onboarding/ai_loading_page.dart`

**Current:** Uses `OnboardingPlaceListGenerator` but it returns empty lists.

**Action:** Verify integration works end-to-end:
1. `OnboardingPlaceListGenerator` calls Google Places API
2. Returns actual places
3. `AILoadingPage` creates lists with real spots

**Verification:**
- ✅ Generated lists contain actual places
- ✅ Places have real data (name, address, rating, etc.)
- ✅ Lists are useful to users immediately

---

### **Phase 6: Testing & Validation (Week 4)**

**Goal:** Ensure all gaps are fixed and pipeline works end-to-end.

#### **6.1: Integration Tests**

**Test:** Complete onboarding → agent generation flow
1. User completes onboarding with baseline lists
2. User connects social media
3. AILoadingPage collects real social data
4. PersonalityProfile created with agentId
5. Quantum Vibe Engine calculates dimensions
6. Generated lists contain real places

**Files:**
- `test/integration/onboarding_to_agent_flow_test.dart` (NEW)

---

#### **6.2: Contract Tests**

**Test:** Verify architecture promises are fulfilled
1. Baseline lists persist correctly
2. Social data collected and blended 60/40
3. PersonalityProfile uses agentId
4. Quantum Vibe Engine produces results
5. Generated lists have places

**Files:**
- `test/contract/onboarding_pipeline_contract_test.dart` (NEW)

---

#### **6.3: Migration Tests**

**Test:** Verify PersonalityProfile migration works
1. Existing profiles migrate to agentId
2. New profiles use agentId
3. Queries work with agentId

**Files:**
- `test/migration/personality_profile_agentid_migration_test.dart` (NEW)

---

### **Phase 7: Documentation Updates (Week 4-5)**

**Goal:** Update architecture doc to reflect implementation.

#### **7.1: Update Architecture Doc**

**Files:**
- `docs/architecture/ONBOARDING_TO_AGENT_GENERATION_FLOW.md`

**Actions:**
1. Mark implemented sections as ✅
2. Update code examples to match implementation
3. Remove TODO comments
4. Add implementation notes

---

### **Phase 8: Future-Proofing (Ongoing)**

**Goal:** Prepare for future enhancements.

#### **8.1: Richer Baseline List Metadata**

**Future:** Extend `OnboardingData.baselineLists` to store:
- Audience (personal, shared, public)
- Tags
- Initial spot IDs
- Source (onboarding, ai_generated, user_created)

**Files:**
- `lib/core/models/onboarding_data.dart`
- Migration needed

---

#### **8.2: Async Refresh Pipeline**

**Future:** Build `BaselineListGenerator` service that:
- Re-runs generation after onboarding
- Stores generation metadata
- Decides when to refresh

**Files:**
- `lib/core/services/baseline_list_generator.dart` (NEW)

---

#### **8.3: Lifecycle Tracking**

**Future:** Track list evolution:
- Origin (onboarding_seed, user_curated, ai_suggested)
- Edit history
- Active status

**Files:**
- `lib/core/models/baseline_list_metadata.dart` (NEW)

---

## ✅ **IMPLEMENTATION CHECKLIST**

### **Phase 0: Restore AILoadingPage Navigation (CRITICAL)**
- [ ] Remove workaround code (router.go('/home') at line 574)
- [ ] Restore navigation to `/ai-loading` with all data (uncomment lines 577-585, update with complete data including respectedFriends and socialMediaConnected)
- [ ] Remove early markOnboardingCompleted call from onboarding_page.dart (line 438) - let AILoadingPage handle it (already implemented at line 777)
- [ ] Reproduce and fix graphics crash (check logs, identify root cause)
- [ ] Fix crash root cause (disposed controller, null safety, missing Scaffold)
- [ ] Verify AILoadingPage receives data correctly via extras
- [ ] Add integration test to prevent regression
- [ ] Test: Complete onboarding → AILoadingPage → Agent creation → Home flow works end-to-end

### **Phase 1: Baseline Lists Integration**
- [ ] Add `baselineLists` to `OnboardingStepType` enum
- [ ] Add step to `_steps` list
- [ ] Add case in `_buildStepContent` switch
- [ ] Import `BaselineListsPage`
- [ ] Wire SocialMediaConnectionPage with callback (Gap 8)
- [ ] Remove duplicate enum from `onboarding_step.dart`
- [ ] Test: Step appears in flow
- [ ] Test: Lists persist correctly
- [ ] Test: Social media connections persist correctly

### **Phase 2: Social Media Data Collection**
- [ ] Create `SocialMediaConnectionService`
- [ ] Implement Google Places API integration
- [ ] Implement Instagram Graph API integration
- [ ] Implement Facebook Graph API integration
- [ ] Replace placeholder logic in `SocialMediaConnectionPage` with real service calls
- [ ] Implement OAuth flows in service (`connectPlatform`, `disconnectPlatform`)
- [ ] Update `SocialMediaConnectionPage` to call service methods
- [ ] Update `OnboardingPage` to load existing connections from service
- [ ] Integrate into `AILoadingPage`
- [ ] Test: Real OAuth connections work
- [ ] Test: Tokens stored correctly
- [ ] Test: Real social data collected
- [ ] Test: 60/40 blend works

### **Phase 3: PersonalityProfile agentId Migration**
- [ ] Update `PersonalityProfile` model to use `agentId`
- [ ] Update `initializePersonalityFromOnboarding` to use `agentId`
- [ ] Update persistence layer
- [ ] Create migration for existing profiles
- [ ] Test: New profiles use `agentId`
- [ ] Test: Existing profiles migrated

### **Phase 4: Quantum Vibe Engine** ✅ **COMPLETE**
- [x] Create `QuantumVibeEngine` class ✅
- [x] Implement quantum-inspired calculation ✅
- [x] Implement quantum superposition, interference, entanglement, decoherence ✅
- [x] Integrate into `PersonalityLearning` ✅
- [x] Blends quantum (70%) with onboarding (30%) ✅
- [x] Verified: Quantum calculation produces results ✅
- [x] Verified: Integrated and working in `initializePersonalityFromOnboarding()` ✅

### **Phase 5: Place List Generator**
- [ ] Integrate Google Maps Places API
- [ ] Implement `searchPlacesForCategory` with real API
- [ ] Update `AILoadingPage` to use real places
- [ ] Test: Generated lists contain places
- [ ] Test: Places have real data

### **Phase 6: Testing & Validation**
- [ ] Write integration tests
- [ ] Write contract tests
- [ ] Write migration tests
- [ ] Run all tests
- [ ] Fix any issues

### **Phase 7: Documentation**
- [ ] Update architecture doc
- [ ] Mark implemented sections
- [ ] Update code examples
- [ ] Remove TODOs

### **Phase 8: Future-Proofing**
- [ ] Design richer metadata structure
- [ ] Plan async refresh pipeline
- [ ] Design lifecycle tracking
- [ ] Create future enhancement docs

---

## 📊 **SUCCESS CRITERIA**

### **Functional:**
- ✅ Baseline lists step appears in onboarding flow
- ✅ Users can edit baseline lists
- ✅ Real social media data collected
- ✅ 60/40 blend actually happens
- ✅ PersonalityProfile uses `agentId` as key
- ✅ Quantum Vibe Engine calculates dimensions
- ✅ Generated lists contain actual places
- ✅ All architecture promises fulfilled

### **Quality:**
- ✅ Zero linter errors
- ✅ All tests passing
- ✅ Migration successful
- ✅ Documentation updated

### **Privacy:**
- ✅ All data uses `agentId` (not `userId`)
- ✅ Privacy boundaries respected
- ✅ Social data handled securely

---

## 🚨 **RISKS & MITIGATION**

### **Risk 1: Google Places API Costs**
**Risk:** API calls may be expensive at scale  
**Mitigation:** Implement caching, rate limiting, batch requests

### **Risk 2: Social Media API Rate Limits**
**Risk:** Instagram/Facebook APIs have strict rate limits  
**Mitigation:** Implement rate limiting, caching, background sync

### **Risk 3: Migration Complexity**
**Risk:** Migrating existing profiles to `agentId` may be complex  
**Mitigation:** Test migration thoroughly, support rollback

### **Risk 4: Quantum Engine Accuracy**
**Risk:** Quantum-inspired math may not be more accurate than simple blending  
**Mitigation:** A/B test, validate results, iterate

---

## 📚 **RELATED DOCUMENTATION**

- `docs/architecture/ONBOARDING_TO_AGENT_GENERATION_FLOW.md` - Architecture specification
- `lib/presentation/pages/onboarding/onboarding_page.dart` - Onboarding flow
- `lib/presentation/pages/onboarding/ai_loading_page.dart` - AI loading page
- `lib/core/ai/personality_learning.dart` - Personality learning
- `docs/plans/social_media_integration/SOCIAL_MEDIA_INTEGRATION_PLAN.md` - Social media plan

---

**Status:** 📋 Ready for Implementation  
**Last Updated:** December 22, 2025 (Added patent references, formulas, and mathematical proofs)  
**Next Steps:** Begin Phase 0: Restore AILoadingPage Navigation (CRITICAL BLOCKER)

