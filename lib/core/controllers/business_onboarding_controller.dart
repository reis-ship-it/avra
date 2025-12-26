import 'dart:developer' as developer;

import 'package:get_it/get_it.dart';

import 'package:spots/core/controllers/base/workflow_controller.dart';
import 'package:spots/core/controllers/base/controller_result.dart';
import 'package:spots/core/models/business_account.dart';
import 'package:spots/core/models/business_expert_preferences.dart';
import 'package:spots/core/models/business_patron_preferences.dart';
import 'package:spots/core/services/business_account_service.dart';
import 'package:spots/core/services/business_shared_agent_service.dart';

/// Business Onboarding Controller
/// 
/// Orchestrates the completion of business onboarding workflow. Coordinates
/// validation, preference updates, shared AI agent initialization, and profile setup.
/// 
/// **Responsibilities:**
/// - Validate onboarding data (preferences, team members)
/// - Update business account with preferences
/// - Initialize shared AI agent (if enabled)
/// - Setup payment processing (if applicable)
/// - Return unified result with errors
/// 
/// **Dependencies:**
/// - `BusinessAccountService` - Update business account
/// - `BusinessSharedAgentService` - Initialize shared AI agent
/// 
/// **Usage:**
/// ```dart
/// final controller = BusinessOnboardingController();
/// final result = await controller.completeBusinessOnboarding(
///   businessId: 'business_123',
///   data: BusinessOnboardingData(
///     expertPreferences: expertPrefs,
///     patronPreferences: patronPrefs,
///     teamMembers: ['user_1', 'user_2'],
///     setupSharedAgent: true,
///   ),
/// );
/// 
/// if (result.isSuccess) {
///   // Onboarding completed
/// } else {
///   // Handle errors
/// }
/// ```
class BusinessOnboardingController
    implements WorkflowController<BusinessOnboardingData, BusinessOnboardingResult> {
  static const String _logName = 'BusinessOnboardingController';

  final BusinessAccountService _businessAccountService;
  final BusinessSharedAgentService? _sharedAgentService;

  BusinessOnboardingController({
    BusinessAccountService? businessAccountService,
    BusinessSharedAgentService? sharedAgentService,
  })  : _businessAccountService =
            businessAccountService ?? GetIt.instance<BusinessAccountService>(),
        _sharedAgentService =
            sharedAgentService ?? GetIt.instance<BusinessSharedAgentService>();

  /// Complete business onboarding
  /// 
  /// Orchestrates the complete onboarding workflow:
  /// 1. Validate onboarding data
  /// 2. Get business account
  /// 3. Update business account with preferences
  /// 4. Initialize shared AI agent (if enabled)
  /// 5. Return unified result
  /// 
  /// **Parameters:**
  /// - `businessId`: Business account ID
  /// - `data`: Onboarding data (preferences, team members, etc.)
  /// 
  /// **Returns:**
  /// `BusinessOnboardingResult` with success/failure and error details
  Future<BusinessOnboardingResult> completeBusinessOnboarding({
    required String businessId,
    required BusinessOnboardingData data,
  }) async {
    try {
      developer.log('Starting business onboarding for: $businessId', name: _logName);

      // Step 1: Validate input
      final validationResult = validate(data);
      if (!validationResult.isValid) {
        return BusinessOnboardingResult.failure(
          error: validationResult.allErrors.join(', '),
          errorCode: 'VALIDATION_ERROR',
        );
      }

      // Step 2: Get business account
      final businessAccount = await _businessAccountService.getBusinessAccount(businessId);
      if (businessAccount == null) {
        return BusinessOnboardingResult.failure(
          error: 'Business account not found: $businessId',
          errorCode: 'BUSINESS_NOT_FOUND',
        );
      }

      // Step 3: Update business account with preferences
      BusinessAccount updatedAccount = businessAccount;
      try {
        updatedAccount = await _businessAccountService.updateBusinessAccount(
          businessAccount,
          expertPreferences: data.expertPreferences,
          patronPreferences: data.patronPreferences,
          requiredExpertise: data.requiredExpertise,
          preferredCommunities: data.preferredCommunities,
        );
        developer.log('Updated business account with preferences', name: _logName);
      } catch (e) {
        developer.log('Error updating business account: $e', name: _logName);
        return BusinessOnboardingResult.failure(
          error: 'Failed to update business account: $e',
          errorCode: 'UPDATE_FAILED',
        );
      }

      // Step 4: Initialize shared AI agent (if enabled)
      String? sharedAgentId;
      if (data.setupSharedAgent && _sharedAgentService != null) {
        try {
          sharedAgentId = await _sharedAgentService!.initializeSharedAgent(businessId);
          developer.log('Initialized shared agent: $sharedAgentId', name: _logName);
        } catch (e) {
          developer.log('Error initializing shared agent: $e', name: _logName);
          // Don't fail onboarding if shared agent setup fails
          // Return partial success with warning
          return BusinessOnboardingResult.partialSuccess(
            businessAccount: updatedAccount,
            sharedAgentId: null,
            warning: 'Business onboarding completed, but shared AI agent setup failed: $e',
          );
        }
      }

      // Step 5: Setup payment processing (if applicable)
      // TODO(Phase 8.12): Implement Stripe Connect account setup
      // For now, this is a placeholder

      developer.log('Business onboarding completed successfully', name: _logName);
      return BusinessOnboardingResult.success(
        businessAccount: updatedAccount,
        sharedAgentId: sharedAgentId,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error completing business onboarding: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return BusinessOnboardingResult.failure(
        error: 'Unexpected error: $e',
        errorCode: 'UNEXPECTED_ERROR',
      );
    }
  }

  @override
  Future<BusinessOnboardingResult> execute(BusinessOnboardingData input) async {
    // Extract businessId from input (must be provided)
    if (input.businessId == null) {
      return BusinessOnboardingResult.failure(
        error: 'Business ID is required',
        errorCode: 'VALIDATION_ERROR',
      );
    }

    return completeBusinessOnboarding(
      businessId: input.businessId!,
      data: input,
    );
  }

  @override
  ValidationResult validate(BusinessOnboardingData input) {
    final generalErrors = <String>[];
    final warnings = <String>[];

    // Business ID validation
    // Business ID is required if not already set in data
    // (It can be set via completeBusinessOnboarding parameter or in data)
    // For validation, we only check if data itself is valid

    // Expert preferences validation (if provided)
    // Preferences can be null (optional)

    // Patron preferences validation (if provided)
    // Preferences can be null (optional)

    // Team members validation (if provided)
    if (input.teamMembers != null && input.teamMembers!.isEmpty && input.setupSharedAgent) {
      // Empty list with shared agent setup - warn but don't error
      warnings.add('Shared agent enabled but no team members added');
    }

    if (generalErrors.isEmpty) {
      return ValidationResult.valid(warnings: warnings);
    } else {
      return ValidationResult.invalid(generalErrors: generalErrors);
    }
  }

  @override
  Future<void> rollback(BusinessOnboardingResult result) async {
    // Onboarding operations are generally idempotent
    // No explicit rollback needed
    // If needed in the future, can delete shared agent or revert preferences
    
    // If shared agent was created, could delete it here
    // If preferences were updated, could revert them here
    // For now, no rollback needed
  }
}

/// Business Onboarding Data
/// 
/// Input data for business onboarding completion
class BusinessOnboardingData {
  /// Business account ID (optional if provided via method parameter)
  final String? businessId;

  /// Expert preferences (optional)
  final BusinessExpertPreferences? expertPreferences;

  /// Patron preferences (optional)
  final BusinessPatronPreferences? patronPreferences;

  /// Required expertise categories (optional)
  final List<String>? requiredExpertise;

  /// Preferred communities (optional)
  final List<String>? preferredCommunities;

  /// Team member user IDs (optional)
  final List<String>? teamMembers;

  /// Whether to setup shared AI agent
  final bool setupSharedAgent;

  BusinessOnboardingData({
    this.businessId,
    this.expertPreferences,
    this.patronPreferences,
    this.requiredExpertise,
    this.preferredCommunities,
    this.teamMembers,
    this.setupSharedAgent = false,
  });
}

/// Business Onboarding Result
/// 
/// Unified result for business onboarding operations
class BusinessOnboardingResult extends ControllerResult {
  final BusinessAccount? businessAccount;
  final String? sharedAgentId;
  final String? warning;

  BusinessOnboardingResult._({
    required super.success,
    required super.error,
    required super.errorCode,
    this.businessAccount,
    this.sharedAgentId,
    this.warning,
  });

  factory BusinessOnboardingResult.success({
    required BusinessAccount businessAccount,
    String? sharedAgentId,
  }) {
    return BusinessOnboardingResult._(
      success: true,
      error: null,
      errorCode: null,
      businessAccount: businessAccount,
      sharedAgentId: sharedAgentId,
    );
  }

  factory BusinessOnboardingResult.partialSuccess({
    required BusinessAccount businessAccount,
    String? sharedAgentId,
    String? warning,
  }) {
    return BusinessOnboardingResult._(
      success: true, // Still considered success, but with warning
      error: null,
      errorCode: null,
      businessAccount: businessAccount,
      sharedAgentId: sharedAgentId,
      warning: warning,
    );
  }

  factory BusinessOnboardingResult.failure({
    required String error,
    required String errorCode,
  }) {
    return BusinessOnboardingResult._(
      success: false,
      error: error,
      errorCode: errorCode,
      businessAccount: null,
      sharedAgentId: null,
    );
  }
}
