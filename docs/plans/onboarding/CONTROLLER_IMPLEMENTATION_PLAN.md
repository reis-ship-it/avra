# Controller Implementation Plan - Phase 8.11

**Date:** December 23, 2025  
**Status:** 📋 Ready for Implementation  
**Priority:** P1 - Architecture Improvement  
**Timeline:** 2-3 weeks (13 controllers)  
**Dependencies:** 
- Phase 8 Sections 0-10 (Onboarding Process) ✅ Complete
- All services must be registered in DI ✅

**Related Documents:**
- `docs/plans/onboarding/ONBOARDING_PROCESS_PLAN.md` - Main onboarding plan
- `docs/MASTER_PLAN.md` - Master plan reference
- `.cursorrules` - Development standards

---

## 🎯 **EXECUTIVE SUMMARY**

Create workflow controllers to simplify complex multi-step processes that currently coordinate multiple services directly in UI pages. Controllers will centralize orchestration logic, improve testability, and reduce code duplication.

**Current Problem:**
- Complex workflows scattered across UI pages (150+ lines in `_completeOnboarding()`)
- Multiple services coordinated directly in widgets
- Difficult to test complex workflows
- Code duplication across similar workflows
- Error handling inconsistent

**Solution:**
- Create dedicated controllers for complex workflows
- Controllers orchestrate services, handle errors, manage state
- BLoCs remain for simple state management
- Controllers used by BLoCs for complex operations

---

## 🏗️ **ARCHITECTURE PATTERN**

### **Controller Pattern**

```
UI → BLoC → Controller → Multiple Services/Use Cases → Repository
```

**When to Use Controllers:**
- ✅ Multi-step workflows (3+ steps)
- ✅ Multiple services coordinated
- ✅ Complex validation logic
- ✅ Error handling across services
- ✅ Rollback/compensation needed

**When NOT to Use Controllers:**
- ❌ Simple CRUD operations (use BLoC directly)
- ❌ Single service calls (use BLoC directly)
- ❌ Simple state management (use BLoC directly)

---

## 📋 **CONTROLLER IMPLEMENTATION LIST**

### **Priority 1: Critical Workflows (Implement First)**

#### **1. OnboardingFlowController** ✅ **COMPLETE**
**Location:** `lib/core/controllers/onboarding_flow_controller.dart`  
**Complexity:** ⭐⭐⭐⭐⭐ (Very High)  
**Services Coordinated:** 8+  
**Status:** ✅ Complete - Implemented, tested (unit + integration), integrated into `onboarding_page.dart`, registered in DI  
**Current Location:** `lib/presentation/pages/onboarding/onboarding_page.dart` (lines 447-600)

**Responsibilities:**
- Validate legal document acceptance
- Save onboarding data
- Get agentId for privacy
- Coordinate all onboarding completion steps
- Handle errors gracefully
- Return unified result

**Dependencies:**
- `OnboardingDataService`
- `AgentIdService`
- `LegalDocumentService`
- `AuthBloc` (for user state)

**Interface:**
```dart
class OnboardingFlowController {
  Future<OnboardingFlowResult> completeOnboarding({
    required OnboardingData data,
    required String userId,
    required BuildContext? context, // For legal dialogs
  }) async {
    // 1. Validate legal acceptance
    // 2. Get agentId
    // 3. Save onboarding data
    // 4. Return result
  }
  
  ValidationResult validateOnboardingData(OnboardingData data) { ... }
}
```

**Benefits:**
- Reduces `_completeOnboarding()` from 150+ lines to ~20 lines
- Testable in isolation
- Reusable for onboarding refresh
- Clear error handling

---

#### **2. AgentInitializationController** ✅ **COMPLETE**
**Location:** `lib/core/controllers/agent_initialization_controller.dart`  
**Complexity:** ⭐⭐⭐⭐⭐ (Very High)  
**Services Coordinated:** 6+  
**Status:** ✅ Complete - Implemented, tested (unit + integration), integrated into `ai_loading_page.dart`, registered in DI  
**Current Location:** `lib/presentation/pages/onboarding/ai_loading_page.dart` (lines 300-500)

**Responsibilities:**
- Collect social media data from all platforms
- Initialize PersonalityProfile from onboarding
- Initialize PreferencesProfile from onboarding
- Generate place lists (optional, non-blocking)
- Get recommendations (optional, non-blocking)
- Attempt cloud sync (optional, non-blocking)
- Handle errors per step (continue on failure)
- Return unified initialization result

**Dependencies:**
- `SocialMediaConnectionService`
- `PersonalityLearning`
- `PreferencesProfileService`
- `OnboardingPlaceListGenerator`
- `OnboardingRecommendationService`
- `PersonalitySyncService`
- `AgentIdService`

**Interface:**
```dart
class AgentInitializationController {
  Future<AgentInitializationResult> initializeAgent({
    required String userId,
    required Map<String, dynamic> onboardingData,
    bool generatePlaceLists = true,
    bool getRecommendations = true,
    bool attemptCloudSync = true,
  }) async {
    // 1. Collect social media data
    // 2. Initialize PersonalityProfile
    // 3. Initialize PreferencesProfile
    // 4. Optional: Generate place lists
    // 5. Optional: Get recommendations
    // 6. Optional: Attempt cloud sync
    // 7. Return unified result
  }
  
  Future<SocialMediaDataResult> collectSocialMediaData(String userId) async { ... }
  Future<PersonalityProfile> initializePersonality(...) async { ... }
  Future<PreferencesProfile> initializePreferences(...) async { ... }
}
```

**Benefits:**
- Separates orchestration from UI
- Handles optional steps gracefully
- Clear progress tracking
- Testable initialization flow

---

#### **3. EventCreationController** ✅ **COMPLETE**
**Location:** `lib/core/controllers/event_creation_controller.dart`  
**Complexity:** ⭐⭐⭐⭐ (High)  
**Services Coordinated:** 4+  
**Status:** ✅ Complete - Implemented, tested (unit + integration), integrated into `event_review_page.dart`, registered in DI  
**Current Location:** `lib/presentation/pages/events/create_event_page.dart` (lines 78-446)

**Responsibilities:**
- Validate form data
- Verify user expertise (Local level+)
- Validate geographic scope
- Validate dates/times
- Create event via service
- Handle payment setup (if paid event)
- Return unified result with validation errors

**Dependencies:**
- `ExpertiseEventService`
- `GeographicScopeService`
- `ExpertiseService` (for expertise verification)
- `PaymentService` (for paid events)

**Interface:**
```dart
class EventCreationController {
  Future<EventCreationResult> createEvent({
    required EventFormData formData,
    required UnifiedUser host,
  }) async {
    // 1. Validate form
    // 2. Check expertise
    // 3. Validate geographic scope
    // 4. Validate dates
    // 5. Create event
    // 6. Setup payment (if paid)
    // 7. Return result
  }
  
  ValidationResult validateForm(EventFormData data) { ... }
  ExpertiseValidationResult validateExpertise(UnifiedUser user, String category) { ... }
  GeographicScopeResult validateGeographicScope(...) { ... }
  DateTimeValidationResult validateDates(DateTime start, DateTime end) { ... }
}
```

**Benefits:**
- Centralizes validation logic
- Reusable across event creation pages
- Clear validation error messages
- Easier to test validation rules

---

### **Priority 2: High-Value Workflows**

#### **4. SocialMediaDataCollectionController** ✅ **COMPLETE**
**Location:** `lib/core/controllers/social_media_data_collection_controller.dart`  
**Complexity:** ⭐⭐⭐⭐ (High)  
**Services Coordinated:** 1 (but complex multi-platform logic)  
**Status:** ✅ Complete - Implemented, tested (unit + integration), integrated into `AgentInitializationController`, registered in DI  
**Current Location:** `lib/presentation/pages/onboarding/ai_loading_page.dart` (lines 310-360)

**Responsibilities:**
- Fetch profile data from all connected platforms
- Fetch follows from all platforms
- Fetch platform-specific data (Google Places, etc.)
- Merge and structure data consistently
- Handle errors per platform (continue on failure)
- Return unified data structure

**Dependencies:**
- `SocialMediaConnectionService`

**Interface:**
```dart
class SocialMediaDataCollectionController {
  Future<SocialMediaDataResult> collectAllData({
    required String userId,
    required List<SocialMediaConnection> connections,
  }) async {
    // 1. Fetch profiles from all platforms
    // 2. Fetch follows from all platforms
    // 3. Fetch platform-specific data
    // 4. Merge and structure
    // 5. Return unified result
  }
  
  Future<Map<String, dynamic>> fetchPlatformProfile(SocialMediaConnection connection) async { ... }
  Future<List<Map<String, dynamic>>> fetchPlatformFollows(SocialMediaConnection connection) async { ... }
  Future<Map<String, dynamic>> fetchPlatformSpecificData(SocialMediaConnection connection) async { ... }
}
```

**Benefits:**
- Handles multi-platform complexity
- Graceful error handling (continue on failure)
- Reusable for refresh operations
- Testable per platform

---

#### **5. PaymentProcessingController** ✅ **COMPLETE**
**Location:** `lib/core/controllers/payment_processing_controller.dart`  
**Complexity:** ⭐⭐⭐⭐⭐ (Very High)  
**Services Coordinated:** 5+  
**Status:** ✅ Complete - Implemented, tested (unit + integration), integrated into `PaymentFormWidget` and `CheckoutPage`, registered in DI  
**Current Location:** `lib/presentation/widgets/payment/payment_form_widget.dart` and `lib/presentation/pages/payment/checkout_page.dart`

**Responsibilities:**
- Validate payment data
- Calculate sales tax
- Calculate revenue split
- Process Stripe payment
- Update event (add attendee)
- Generate receipt
- Handle refunds if needed
- Return unified payment result

**Dependencies:**
- `PaymentService`
- `StripeService`
- `SalesTaxService`
- `RevenueSplitService`
- `ExpertiseEventService`
- `ReceiptService`

**Interface:**
```dart
class PaymentProcessingController {
  Future<PaymentResult> processEventPayment({
    required PaymentData payment,
    required ExpertiseEvent event,
    required UnifiedUser buyer,
  }) async {
    // 1. Validate payment
    // 2. Calculate tax
    // 3. Calculate revenue split
    // 4. Process payment
    // 5. Update event
    // 6. Generate receipt
    // 7. Return result
  }
  
  Future<PaymentResult> processRefund({
    required String paymentId,
    required String reason,
  }) async { ... }
  
  PaymentValidationResult validatePayment(PaymentData data) { ... }
}
```

**Benefits:**
- Coordinates multiple payment services
- Handles complex business logic
- Clear transaction flow
- Easier to test payment scenarios

---

### **Priority 3: Medium-Value Workflows**

#### **6. AIRecommendationController** ✅ **COMPLETE**
**Location:** `lib/core/controllers/ai_recommendation_controller.dart`  
**Complexity:** ⭐⭐⭐⭐ (High)  
**Services Coordinated:** 4+  
**Current Location:** AI recommendation features

**Responsibilities:**
- Load PersonalityProfile
- Load PreferencesProfile
- Calculate quantum compatibility
- Get event recommendations
- Get spot recommendations
- Get list recommendations
- Rank and filter results
- Return unified recommendations

**Dependencies:**
- `PersonalityLearning`
- `PreferencesProfileService`
- `EventRecommendationService`
- `SpotRecommendationService`
- `ListRecommendationService`
- `QuantumVibeEngine`

**Interface:**
```dart
class AIRecommendationController {
  Future<RecommendationResult> generateRecommendations({
    required String userId,
    required RecommendationContext context,
  }) async {
    // 1. Load profiles
    // 2. Calculate quantum compatibility
    // 3. Get recommendations
    // 4. Rank and filter
    // 5. Return unified result
  }
  
  Future<List<EventRecommendation>> getEventRecommendations(...) async { ... }
  Future<List<SpotRecommendation>> getSpotRecommendations(...) async { ... }
  Future<List<ListRecommendation>> getListRecommendations(...) async { ... }
}
```

**Benefits:**
- Coordinates multiple AI systems
- Handles quantum calculations
- Unified recommendation interface
- Testable AI workflows

---

#### **7. SyncController** ✅ **COMPLETE**
**Location:** `lib/core/controllers/sync_controller.dart`  
**Complexity:** ⭐⭐⭐⭐ (High)  
**Services Coordinated:** 3+  
**Status:** ✅ Complete - Implemented, tested (unit + integration), registered in DI  
**Current Location:** Ready for integration into sync pages

**Responsibilities:**
- Check connectivity
- Load local changes
- Fetch remote changes
- Detect conflicts
- Apply merge strategy
- Sync changes
- Update local cache
- Return sync result

**Dependencies:**
- `ConnectivityService`
- `StorageService`
- `PersonalitySyncService`
- `DataSyncService`

**Interface:**
```dart
class SyncController {
  Future<SyncResult> syncUserData({
    required String userId,
    required SyncScope scope,
  }) async {
    // 1. Check connectivity
    // 2. Load local changes
    // 3. Fetch remote changes
    // 4. Detect conflicts
    // 5. Apply merge strategy
    // 6. Sync changes
    // 7. Return result
  }
  
  Future<ConflictResolution> resolveConflict(Conflict conflict) async { ... }
  Future<void> syncPersonalityProfile(String userId) async { ... }
  Future<void> syncPreferencesProfile(String userId) async { ... }
}
```

**Benefits:**
- Centralizes sync logic
- Handles conflicts consistently
- Testable sync scenarios
- Reusable across data types

---

### **Priority 4: Additional Workflows**

#### **8. BusinessOnboardingController** ✅ **COMPLETE**
**Location:** `lib/core/controllers/business_onboarding_controller.dart`  
**Complexity:** ⭐⭐⭐ (Medium)  
**Services Coordinated:** 2  
**Current Location:** `lib/presentation/pages/business/business_onboarding_page.dart` ✅ **Integrated**

**Responsibilities:**
- Validate business information
- Verify business credentials
- Create business account
- Setup payment processing
- Initialize business profile
- Return unified result

**Dependencies:**
- `BusinessAuthService`
- `BusinessService`
- `PaymentService`
- `BusinessVerificationService`

**Interface:**
```dart
class BusinessOnboardingController {
  Future<BusinessOnboardingResult> completeBusinessOnboarding({
    required BusinessOnboardingData data,
    required String userId,
  }) async {
    // 1. Validate business info
    // 2. Verify credentials
    // 3. Create business account
    // 4. Setup payment
    // 5. Initialize profile
    // 6. Return result
  }
}
```

---

#### **9. EventAttendanceController** ✅ **COMPLETE**
**Location:** `lib/core/controllers/event_attendance_controller.dart`  
**Complexity:** ⭐⭐⭐ (Medium)  
**Services Coordinated:** 3  
**Current Location:** `lib/presentation/pages/events/event_details_page.dart` ✅ **Integrated**

**Responsibilities:**
- Check event availability
- Process payment (if paid)
- Register attendee
- Update event capacity
- Send confirmation
- Update user preferences
- Return attendance result

**Dependencies:**
- `ExpertiseEventService`
- `PaymentProcessingController`
- `NotificationService`
- `PreferencesProfileService`

**Interface:**
```dart
class EventAttendanceController {
  Future<AttendanceResult> registerForEvent({
    required String eventId,
    required String userId,
    PaymentData? payment,
  }) async {
    // 1. Check availability
    // 2. Process payment
    // 3. Register attendee
    // 4. Update capacity
    // 5. Send confirmation
    // 6. Update preferences
    // 7. Return result
  }
}
```

---

#### **10. ListCreationController** ✅ **COMPLETE**
**Location:** `lib/core/controllers/list_creation_controller.dart`  
**Complexity:** ⭐⭐⭐ (Medium)  
**Services Coordinated:** 2  
**Current Location:** `lib/presentation/pages/lists/create_list_page.dart` ✅ **Integrated**

**Responsibilities:**
- Validate list data
- Check user permissions
- Create list
- Add initial spots (if provided)
- Generate AI suggestions (optional)
- Return creation result

**Dependencies:**
- `ListsService`
- `SpotsService`
- `AIListGeneratorService`
- `PermissionService`

**Interface:**
```dart
class ListCreationController {
  Future<ListCreationResult> createList({
    required ListFormData data,
    required String userId,
    List<String>? initialSpotIds,
    bool generateAISuggestions = false,
  }) async {
    // 1. Validate data
    // 2. Check permissions
    // 3. Create list
    // 4. Add spots
    // 5. Generate AI suggestions
    // 6. Return result
  }
}
```

---

#### **11. ProfileUpdateController** ✅ **COMPLETE**
**Location:** `lib/core/controllers/profile_update_controller.dart`  
**Complexity:** ⭐⭐⭐ (Medium)  
**Services Coordinated:** 3+  
**Current Location:** `lib/presentation/pages/profile/edit_profile_page.dart` ✅ **Integrated**

**Responsibilities:**
- Validate profile changes
- Update user profile
- Update PersonalityProfile (if needed)
- Update PreferencesProfile (if needed)
- Sync to cloud
- Return update result

**Dependencies:**
- `UserService`
- `PersonalityLearning`
- `PreferencesProfileService`
- `PersonalitySyncService`

**Interface:**
```dart
class ProfileUpdateController {
  Future<ProfileUpdateResult> updateProfile({
    required String userId,
    required ProfileUpdateData data,
  }) async {
    // 1. Validate changes
    // 2. Update user profile
    // 3. Update personality (if needed)
    // 4. Update preferences (if needed)
    // 5. Sync to cloud
    // 6. Return result
  }
}
```

---

#### **12. EventCancellationController** ✅ **COMPLETE**
**Location:** `lib/core/controllers/event_cancellation_controller.dart`  
**Complexity:** ⭐⭐⭐⭐ (High)  
**Services Coordinated:** 3  
**Current Location:** `lib/presentation/pages/events/cancellation_flow_page.dart` ✅ **Integrated**

**Responsibilities:**
- Validate cancellation reason
- Calculate refund amount (if applicable)
- Check cancellation policy
- Process cancellation
- Process refunds (if applicable)
- Notify attendees
- Update event status
- Return cancellation result

**Dependencies:**
- `ExpertiseEventService`
- `CancellationService`
- `RefundService`
- `NotificationService`
- `PaymentService`

**Interface:**
```dart
class EventCancellationController {
  Future<CancellationResult> cancelEvent({
    required String eventId,
    required String userId,
    required CancellationReason reason,
    bool isHost = false,
  }) async {
    // 1. Validate cancellation
    // 2. Calculate refund
    // 3. Check policy
    // 4. Process cancellation
    // 5. Process refunds
    // 6. Notify attendees
    // 7. Update event
    // 8. Return result
  }
  
  Future<RefundCalculation> calculateRefund(String eventId, String userId) async { ... }
}
```

---

#### **13. PartnershipProposalController** ✅ **COMPLETE**
**Location:** `lib/core/controllers/partnership_proposal_controller.dart`  
**Complexity:** ⭐⭐⭐⭐ (High)  
**Services Coordinated:** 2  
**Current Location:** `lib/presentation/pages/partnerships/partnership_proposal_page.dart` ✅ **Integrated**

**Responsibilities:**
- Validate partnership proposal
- Check business compatibility
- Calculate revenue split
- Create partnership proposal
- Send proposal to business
- Handle proposal acceptance/rejection
- Return proposal result

**Dependencies:**
- `PartnershipService`
- `BusinessService`
- `RevenueSplitService`
- `NotificationService`
- `BusinessExpertMatchingService`

**Interface:**
```dart
class PartnershipProposalController {
  Future<PartnershipProposalResult> createProposal({
    required PartnershipProposalData data,
    required String proposerId,
    required String businessId,
  }) async {
    // 1. Validate proposal
    // 2. Check compatibility
    // 3. Calculate revenue split
    // 4. Create proposal
    // 5. Send to business
    // 6. Return result
  }
  
  Future<PartnershipProposalResult> acceptProposal(String proposalId) async { ... }
  Future<PartnershipProposalResult> rejectProposal(String proposalId, String reason) async { ... }
}
```

---

#### **14. CheckoutController** ✅ **COMPLETE**
**Location:** `lib/core/controllers/checkout_controller.dart`  
**Complexity:** ⭐⭐⭐⭐ (High)  
**Services Coordinated:** 4  
**Current Location:** `lib/presentation/pages/payment/checkout_page.dart` ✅ **Integrated**

**Responsibilities:**
- Validate checkout data
- Calculate totals (price + tax)
- Process payment
- Create order/transaction
- Update event/spot/list (if applicable)
- Generate receipt
- Send confirmation
- Return checkout result

**Dependencies:**
- `PaymentService`
- `StripeService`
- `SalesTaxService`
- `ExpertiseEventService` (for event purchases)
- `ReceiptService`
- `NotificationService`

**Interface:**
```dart
class CheckoutController {
  Future<CheckoutResult> processCheckout({
    required CheckoutData data,
    required String userId,
  }) async {
    // 1. Validate checkout
    // 2. Calculate totals
    // 3. Process payment
    // 4. Create transaction
    // 5. Update related entities
    // 6. Generate receipt
    // 7. Send confirmation
    // 8. Return result
  }
  
  Future<CheckoutTotals> calculateTotals(CheckoutData data) async { ... }
}
```

---

#### **15. PartnershipCheckoutController** ✅ **COMPLETE**
**Location:** `lib/core/controllers/partnership_checkout_controller.dart`  
**Complexity:** ⭐⭐⭐⭐ (High)  
**Services Coordinated:** 4  
**Current Location:** `lib/presentation/pages/partnerships/partnership_checkout_page.dart` ✅ **Integrated**

**Responsibilities:**
- Validate partnership checkout data (quantity, availability, partnership status)
- Calculate revenue split for partnership events
- Validate partnership exists and is active
- Process payment with multi-party revenue split
- Update event attendance
- Create payment transaction with partnership metadata
- Handle payment failures with rollback
- Return unified checkout result

**Dependencies:**
- `PaymentService`
- `PaymentEventService`
- `RevenueSplitService`
- `PartnershipService`
- `ExpertiseEventService`

**Interface:**
```dart
class PartnershipCheckoutController {
  Future<PartnershipCheckoutResult> processCheckout({
    required String eventId,
    required String userId,
    required int quantity,
    EventPartnership? partnership,
  }) async {
    // 1. Validate checkout data
    // 2. Validate partnership (if provided)
    // 3. Calculate revenue split
    // 4. Validate event availability
    // 5. Process payment
    // 6. Update event attendance
    // 7. Create transaction
    // 8. Return result
  }
  
  Future<RevenueSplit?> calculateRevenueSplit({
    required String eventId,
    required double totalAmount,
    required int quantity,
    EventPartnership? partnership,
  }) async { ... }
  
  ValidationResult validateCheckout({
    required ExpertiseEvent event,
    required int quantity,
    EventPartnership? partnership,
  }) { ... }
}
```

**Benefits:**
- Handles partnership-specific checkout logic
- Coordinates revenue split calculation with payment
- Validates partnership status before checkout
- Consistent error handling and rollback
- Testable partnership checkout workflow

---

#### **16. SponsorshipCheckoutController** ✅ **COMPLETE**
**Location:** `lib/core/controllers/sponsorship_checkout_controller.dart`  
**Complexity:** ⭐⭐⭐⭐ (High)  
**Services Coordinated:** 4  
**Current Location:** `lib/presentation/pages/brand/sponsorship_checkout_page.dart` ✅ **Integrated**

**Responsibilities:**
- Validate sponsorship contribution (financial, product, or hybrid)
- Calculate revenue split including sponsorship contribution
- Process financial payment (if applicable)
- Track product contributions
- Create or update sponsorship record
- Handle multi-party revenue split with sponsors
- Process payment with sponsorship metadata
- Handle payment failures with rollback
- Return unified sponsorship checkout result

**Dependencies:**
- `PaymentService`
- `SponsorshipService`
- `RevenueSplitService`
- `ExpertiseEventService`
- `BrandAccountService` (for brand verification)

**Interface:**
```dart
class SponsorshipCheckoutController {
  Future<SponsorshipCheckoutResult> processSponsorshipCheckout({
    required String eventId,
    required String userId,
    required SponsorshipType type,
    double? cashAmount,
    double? productValue,
    String? productName,
    int? productQuantity,
    Sponsorship? existingSponsorship,
  }) async {
    // 1. Validate contribution data
    // 2. Verify brand account (when available)
    // 3. Calculate revenue split with sponsorship
    // 4. Process financial payment (if applicable)
    // 5. Create/update sponsorship
    // 6. Track product contribution (if applicable)
    // 7. Update event revenue split
    // 8. Return result
  }
  
  Future<RevenueSplit?> calculateSponsorshipRevenueSplit({
    required String eventId,
    required double totalContribution,
    RevenueSplit? existingSplit,
  }) async { ... }
  
  ValidationResult validateContribution({
    required SponsorshipType type,
    double? cashAmount,
    double? productValue,
  }) { ... }
  
  Future<SponsorshipCheckoutResult> updateSponsorship({
    required String sponsorshipId,
    double? cashAmount,
    double? productValue,
  }) async { ... }
}
```

**Benefits:**
- Handles complex sponsorship contribution types
- Coordinates financial and product contributions
- Integrates sponsorship into event revenue splits
- Consistent error handling for sponsorship flows
- Testable sponsorship checkout workflow

---

## 🏗️ **IMPLEMENTATION STRUCTURE**

### **Directory Structure**

```
lib/core/controllers/
├── base/
│   ├── workflow_controller.dart          # Base interface
│   └── controller_result.dart           # Result models
├── onboarding_flow_controller.dart
├── agent_initialization_controller.dart
├── event_creation_controller.dart
├── social_media_data_collection_controller.dart
├── payment_processing_controller.dart
├── ai_recommendation_controller.dart
├── sync_controller.dart
├── business_onboarding_controller.dart
├── event_attendance_controller.dart
├── list_creation_controller.dart
├── profile_update_controller.dart
├── event_cancellation_controller.dart
├── partnership_proposal_controller.dart
├── checkout_controller.dart
├── partnership_checkout_controller.dart
└── sponsorship_checkout_controller.dart
```

### **Base Controller Interface**

```dart
/// Base interface for all workflow controllers
abstract class WorkflowController<TInput, TResult> {
  /// Execute the workflow
  Future<TResult> execute(TInput input);
  
  /// Validate input before execution
  ValidationResult validate(TInput input);
  
  /// Rollback changes if workflow fails (optional)
  Future<void> rollback(TResult result);
}

/// Base result class for all controller results
abstract class ControllerResult {
  final bool success;
  final String? error;
  final Map<String, dynamic>? metadata;
  
  const ControllerResult({
    required this.success,
    this.error,
    this.metadata,
  });
}
```

---

## 📝 **IMPLEMENTATION PHASES**

### **Phase 1: Foundation (Days 1-2)**
- [ ] Create base controller interface
- [ ] Create result models
- [ ] Set up controller directory structure
- [ ] Register controllers in DI
- [ ] Create controller tests structure

### **Phase 2: Priority 1 Controllers (Days 3-7)**
- [x] OnboardingFlowController ✅ Complete
- [x] AgentInitializationController ✅ Complete
- [x] EventCreationController ✅ Complete
- [ ] Update pages to use controllers
- [ ] Write comprehensive tests

### **Phase 3: Priority 2 Controllers (Days 8-10)**
- [x] SocialMediaDataCollectionController ✅ Complete
- [x] PaymentProcessingController ✅ Complete
- [ ] Update pages to use controllers
- [ ] Write comprehensive tests

### **Phase 4: Priority 3 Controllers (Days 11-13)**
- [x] AIRecommendationController ✅
- [x] SyncController ✅
- [ ] Update pages to use controllers
- [ ] Write comprehensive tests

### **Phase 5: Priority 4 Controllers (Days 14-15)**
- [x] BusinessOnboardingController ✅
- [x] EventAttendanceController ✅
- [x] ListCreationController ✅
- [x] ProfileUpdateController ✅
- [x] EventCancellationController ✅
- [x] PartnershipProposalController ✅
- [ ] Update pages to use controllers
- [ ] Write comprehensive tests

### **Phase 6: Checkout Controllers (Days 16-17)**
- [ ] CheckoutController
- [ ] PartnershipCheckoutController
- [ ] SponsorshipCheckoutController
- [ ] Update checkout pages to use controllers
- [ ] Write comprehensive tests

---

## ✅ **SUCCESS CRITERIA**

### **Code Quality:**
- ✅ All controllers follow base interface
- ✅ All controllers have comprehensive tests (90%+ coverage)
- ✅ All controllers registered in DI
- ✅ All controllers handle errors gracefully
- ✅ All controllers return unified result types

### **Architecture:**
- ✅ Complex workflows moved from UI to controllers
- ✅ BLoCs use controllers for complex operations
- ✅ Simple operations still use BLoCs directly
- ✅ No code duplication across similar workflows
- ✅ Clear separation of concerns

### **Testing:**
- ✅ Unit tests for all controllers
- ✅ Integration tests for controller workflows
- ✅ Error handling tests
- ✅ Rollback tests (where applicable)

### **Documentation:**
- ✅ All controllers documented
- ✅ Usage examples provided
- ✅ Architecture diagram updated
- ✅ Migration guide for existing code

---

## 🔄 **MIGRATION STRATEGY**

### **Step 1: Create Controller**
- Create controller with same logic as current implementation
- Write tests for controller
- Register in DI

### **Step 2: Update BLoC/Page**
- Replace inline logic with controller call
- Update error handling to use controller result
- Keep UI logic in page/widget

### **Step 3: Test & Verify**
- Run existing tests (should still pass)
- Run new controller tests
- Manual testing of workflow

### **Step 4: Cleanup**
- Remove old inline logic
- Update documentation
- Mark migration complete

---

## 📚 **RELATED DOCUMENTATION**

- `docs/plans/onboarding/ONBOARDING_PROCESS_PLAN.md` - Main onboarding plan
- `docs/MASTER_PLAN.md` - Master plan reference
- `docs/architecture/ONBOARDING_TO_AGENT_GENERATION_FLOW.md` - Architecture flow
- `.cursorrules` - Development standards

---

**Status:** 📋 Ready for Implementation  
**Last Updated:** December 23, 2025  
**Next Steps:** Begin Phase 1: Foundation

