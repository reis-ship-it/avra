import 'dart:developer' as developer;
import 'package:get_it/get_it.dart';
import 'package:spots/injection_container.dart' as di;
import 'package:spots/core/models/onboarding_data.dart';
import 'package:spots/core/services/edge_function_service.dart';
import 'package:spots/core/services/agent_id_service.dart';

/// Service for aggregating onboarding data via edge function
/// Phase 11 Section 4: Edge Mesh Functions
class OnboardingAggregationService {
  static const String _logName = 'OnboardingAggregationService';
  
  final EdgeFunctionService _edgeFunctionService;
  final AgentIdService _agentIdService;
  
  OnboardingAggregationService({
    EdgeFunctionService? edgeFunctionService,
    AgentIdService? agentIdService,
  }) : _edgeFunctionService = edgeFunctionService ?? GetIt.instance<EdgeFunctionService>(),
       _agentIdService = agentIdService ?? di.sl<AgentIdService>();
  
  /// Aggregate onboarding data via edge function
  /// 
  /// [userId] - Authenticated user ID
  /// [onboardingData] - OnboardingData to aggregate
  /// 
  /// Returns the mapped personality dimensions
  Future<Map<String, double>> aggregateOnboardingData({
    required String userId,
    required OnboardingData onboardingData,
  }) async {
    try {
      developer.log('Aggregating onboarding data via edge function', name: _logName);
      
      // Convert userId → agentId
      final agentId = await _agentIdService.getUserAgentId(userId);
      
      // Call edge function
      final response = await _edgeFunctionService.invokeFunction(
        functionName: 'onboarding-aggregation',
        body: {
          'agentId': agentId,
          'onboardingData': onboardingData.toJson(),
        },
      );
      
      if (response['success'] != true) {
        throw Exception('Onboarding aggregation failed');
      }
      
      // Extract dimensions (convert JSON numbers to doubles)
      final dimensionsJson = response['dimensions'] as Map<String, dynamic>? ?? {};
      final dimensions = <String, double>{};
      
      dimensionsJson.forEach((key, value) {
        if (value is num) {
          dimensions[key] = value.toDouble();
        }
      });
      
      developer.log(
        'Onboarding aggregation complete: ${dimensions.length} dimensions',
        name: _logName,
      );
      
      return dimensions;
    } catch (e, stackTrace) {
      developer.log(
        'Error aggregating onboarding data: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      // Return empty dimensions on error (don't fail onboarding)
      return {};
    }
  }
}
