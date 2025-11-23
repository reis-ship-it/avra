import 'dart:developer' as developer;
import 'package:spots/core/models/business_account.dart';
import 'package:spots/core/models/business_expert_preferences.dart';
import 'package:spots/core/models/unified_user.dart';
import 'package:spots/core/models/expertise_level.dart';
import 'package:spots/core/models/expertise_community.dart';
import 'package:spots/core/services/expertise_matching_service.dart';
import 'package:spots/core/services/expertise_community_service.dart';
import 'package:spots/core/services/llm_service.dart';
import 'package:spots/core/services/logger.dart';

/// Business Expert Matching Service
/// Matches businesses with experts based on community, expertise, and AI suggestions
class BusinessExpertMatchingService {
  static const String _logName = 'BusinessExpertMatchingService';
  final AppLogger _logger = const AppLogger(defaultTag: 'SPOTS', minimumLevel: LogLevel.debug);
  
  final ExpertiseMatchingService _expertiseMatchingService;
  final ExpertiseCommunityService _communityService;
  final LLMService? _llmService;

  BusinessExpertMatchingService({
    ExpertiseMatchingService? expertiseMatchingService,
    ExpertiseCommunityService? communityService,
    LLMService? llmService,
  }) : _expertiseMatchingService = expertiseMatchingService ?? ExpertiseMatchingService(),
       _communityService = communityService ?? ExpertiseCommunityService(),
       _llmService = llmService;

  /// Find experts for a business account
  /// Uses community membership, expertise matching, and AI suggestions
  /// Applies business expert preferences for filtering and ranking
  Future<List<BusinessExpertMatch>> findExpertsForBusiness(
    BusinessAccount business, {
    int maxResults = 20,
  }) async {
    try {
      _logger.info('Finding experts for business: ${business.id}', tag: _logName);

      final preferences = business.expertPreferences;
      final matches = <BusinessExpertMatch>[];

      // Get expertise categories from preferences or legacy fields
      final requiredCategories = preferences?.requiredExpertiseCategories.isNotEmpty == true
          ? preferences!.requiredExpertiseCategories
          : business.requiredExpertise;
      
      final preferredCategories = preferences?.preferredExpertiseCategories ?? [];

      // STEP 1: Find experts by required expertise categories
      for (final category in requiredCategories) {
        final expertMatches = await _findExpertsByCategory(
          business,
          category,
          maxResults: maxResults ~/ requiredCategories.length,
        );
        matches.addAll(expertMatches);
      }

      // STEP 2: Find experts from preferred communities
      final communities = preferences?.preferredCommunities ?? business.preferredCommunities;
      for (final communityId in communities) {
        final communityMatches = await _findExpertsFromCommunity(
          business,
          communityId,
          maxResults: 5,
        );
        matches.addAll(communityMatches);
      }

      // STEP 3: Use AI to suggest additional experts (with preferences)
      if (_llmService != null) {
        final aiMatches = await _findExpertsWithAI(business, preferences, maxResults: 10);
        matches.addAll(aiMatches);
      }

      // STEP 4: Apply preference filters
      final filteredMatches = _applyPreferenceFilters(matches, business, preferences);

      // STEP 5: Rank matches using preferences
      final rankedMatches = _rankAndDeduplicate(filteredMatches, business, preferences);

      // STEP 6: Apply minimum match score threshold
      final thresholdMatches = preferences?.minMatchScore != null
          ? rankedMatches.where((m) => m.matchScore >= preferences!.minMatchScore!).toList()
          : rankedMatches;

      _logger.info('Found ${thresholdMatches.length} expert matches', tag: _logName);
      return thresholdMatches.take(maxResults).toList();
    } catch (e) {
      _logger.error('Error finding experts for business', error: e, tag: _logName);
      return [];
    }
  }

  /// Find experts by expertise category
  Future<List<BusinessExpertMatch>> _findExpertsByCategory(
    BusinessAccount business,
    String category, {
    int maxResults = 10,
  }) async {
    try {
      // Create a temporary user object for matching
      final tempUser = UnifiedUser(
        id: business.id,
        email: business.email,
        displayName: business.name,
        location: business.preferredLocation ?? business.location,
        createdAt: business.createdAt,
        updatedAt: business.updatedAt,
        expertiseMap: {}, // Business doesn't have expertise, they need it
      );

      // Find similar experts (businesses need experts, so we find experts)
      final expertMatches = await _expertiseMatchingService.findSimilarExperts(
        tempUser,
        category,
        location: business.preferredLocation,
        maxResults: maxResults,
      );

      return expertMatches.map((match) {
        return BusinessExpertMatch(
          expert: match.user,
          business: business,
          matchScore: match.matchScore,
          matchReason: 'Expertise match: $category',
          matchType: MatchType.expertise,
          matchedCategories: [category],
          matchedCommunities: [],
        );
      }).toList();
    } catch (e) {
      _logger.error('Error finding experts by category', error: e, tag: _logName);
      return [];
    }
  }

  /// Find experts from a specific community
  Future<List<BusinessExpertMatch>> _findExpertsFromCommunity(
    BusinessAccount business,
    String communityId, {
    int maxResults = 5,
  }) async {
    try {
      // Get community
      final communities = await _communityService.searchCommunities();
      final communityMatches = communities.where((c) => c.id == communityId);
      if (communityMatches.isEmpty) {
        _logger.warning('Community not found: $communityId', tag: _logName);
        return [];
      }
      final community = communityMatches.first;

      // Get community members
      final members = await _communityService.getCommunityMembers(community);
      
      // Filter members who match business requirements
      final matches = <BusinessExpertMatch>[];
      
      for (final member in members) {
        // Check if member has required expertise
        bool hasRequiredExpertise = business.requiredExpertise.isEmpty ||
            business.requiredExpertise.any((cat) => member.hasExpertiseIn(cat));

        if (!hasRequiredExpertise) continue;

        // Check location match if specified
        bool locationMatch = business.preferredLocation == null ||
            member.location?.toLowerCase().contains(business.preferredLocation!.toLowerCase()) == true;

        // Check minimum level if specified
        bool levelMatch = business.minExpertLevel == null ||
            business.requiredExpertise.any((cat) {
              final level = member.getExpertiseLevel(cat);
              return level != null && level.index >= business.minExpertLevel!;
            });

        if (hasRequiredExpertise && (locationMatch || business.preferredLocation == null) && levelMatch) {
          final matchedCategories = business.requiredExpertise
              .where((cat) => member.hasExpertiseIn(cat))
              .toList();

          final matchScore = _calculateCommunityMatchScore(
            member,
            business,
            community,
            matchedCategories,
          );

          matches.add(BusinessExpertMatch(
            expert: member,
            business: business,
            matchScore: matchScore,
            matchReason: 'Member of ${community.name}',
            matchType: MatchType.community,
            matchedCategories: matchedCategories,
            matchedCommunities: [community.id],
          ));
        }
      }

      matches.sort((a, b) => b.matchScore.compareTo(a.matchScore));
      return matches.take(maxResults).toList();
    } catch (e) {
      _logger.error('Error finding experts from community', error: e, tag: _logName);
      return [];
    }
  }

  /// Use AI to suggest experts (with preferences)
  Future<List<BusinessExpertMatch>> _findExpertsWithAI(
    BusinessAccount business,
    BusinessExpertPreferences? preferences, {
    int maxResults = 10,
  }) async {
    try {
      if (_llmService == null) return [];

      // Build AI prompt with preferences
      final prompt = _buildAIMatchingPrompt(business, preferences);
      
      // Get AI suggestions
      final aiResponse = await _llmService!.generateRecommendation(
        userQuery: prompt,
      );

      // Parse AI response to extract expert suggestions
      final suggestions = _parseAISuggestions(aiResponse);
      
      // Find actual experts based on AI suggestions
      final matches = <BusinessExpertMatch>[];
      
      for (final suggestion in suggestions) {
        // Find experts matching AI suggestions
        final expertMatches = await _findExpertsByAISuggestion(
          business,
          suggestion,
        );
        matches.addAll(expertMatches);
      }

      matches.sort((a, b) => b.matchScore.compareTo(a.matchScore));
      return matches.take(maxResults).toList();
    } catch (e) {
      _logger.error('Error finding experts with AI', error: e, tag: _logName);
      return [];
    }
  }

  /// Find experts based on AI suggestion
  Future<List<BusinessExpertMatch>> _findExpertsByAISuggestion(
    BusinessAccount business,
    AISuggestion suggestion,
  ) async {
    try {
      final matches = <BusinessExpertMatch>[];

      // Find experts in suggested category
      if (suggestion.category != null) {
        final categoryMatches = await _findExpertsByCategory(
          business,
          suggestion.category!,
          maxResults: 3,
        );
        matches.addAll(categoryMatches);
      }

      // Find experts from suggested community
      if (suggestion.communityId != null) {
        final communityMatches = await _findExpertsFromCommunity(
          business,
          suggestion.communityId!,
          maxResults: 3,
        );
        matches.addAll(communityMatches);
      }

      // Boost match score for AI-suggested matches
      return matches.map((match) {
        return BusinessExpertMatch(
          expert: match.expert,
          business: match.business,
          matchScore: match.matchScore * 1.2, // Boost AI suggestions
          matchReason: 'AI suggested: ${suggestion.reason}',
          matchType: MatchType.aiSuggestion,
          matchedCategories: match.matchedCategories,
          matchedCommunities: match.matchedCommunities,
        );
      }).toList();
    } catch (e) {
      _logger.error('Error finding experts by AI suggestion', error: e, tag: _logName);
      return [];
    }
  }

  /// Build AI prompt for expert matching (with preferences)
  String _buildAIMatchingPrompt(BusinessAccount business, BusinessExpertPreferences? preferences) {
    final buffer = StringBuffer();
    
    buffer.writeln('A business "${business.name}" (${business.businessType}) is looking for experts to connect with.');
    buffer.writeln('');
    buffer.writeln('Business Details:');
    buffer.writeln('- Type: ${business.businessType}');
    buffer.writeln('- Categories: ${business.categories.join(', ')}');
    buffer.writeln('- Location: ${business.location ?? 'Not specified'}');
    buffer.writeln('- Description: ${business.description ?? 'No description'}');
    buffer.writeln('');
    
    if (preferences != null) {
      buffer.writeln('EXPERT PREFERENCES (CRITICAL - Use these to filter and rank matches):');
      
      if (preferences.requiredExpertiseCategories.isNotEmpty) {
        buffer.writeln('- REQUIRED Expertise: ${preferences.requiredExpertiseCategories.join(', ')}');
      }
      if (preferences.preferredExpertiseCategories.isNotEmpty) {
        buffer.writeln('- PREFERRED Expertise: ${preferences.preferredExpertiseCategories.join(', ')}');
      }
      if (preferences.minExpertLevel != null) {
        buffer.writeln('- Minimum Expertise Level: ${preferences.minExpertLevel}');
      }
      if (preferences.preferredLocation != null) {
        buffer.writeln('- Preferred Location: ${preferences.preferredLocation}');
      }
      if (preferences.maxDistanceKm != null) {
        buffer.writeln('- Maximum Distance: ${preferences.maxDistanceKm}km');
      }
      if (preferences.preferredAgeRange != null) {
        buffer.writeln('- Preferred Age Range: ${preferences.preferredAgeRange!.displayText}');
      }
      if (preferences.preferredPersonalityTraits?.isNotEmpty == true) {
        buffer.writeln('- Preferred Personality: ${preferences.preferredPersonalityTraits!.join(', ')}');
      }
      if (preferences.preferredWorkStyles?.isNotEmpty == true) {
        buffer.writeln('- Preferred Work Styles: ${preferences.preferredWorkStyles!.join(', ')}');
      }
      if (preferences.preferredCommunicationStyles?.isNotEmpty == true) {
        buffer.writeln('- Preferred Communication: ${preferences.preferredCommunicationStyles!.join(', ')}');
      }
      if (preferences.preferredAvailability?.isNotEmpty == true) {
        buffer.writeln('- Preferred Availability: ${preferences.preferredAvailability!.join(', ')}');
      }
      if (preferences.preferredEngagementTypes?.isNotEmpty == true) {
        buffer.writeln('- Preferred Engagement: ${preferences.preferredEngagementTypes!.join(', ')}');
      }
      if (preferences.aiKeywords?.isNotEmpty == true) {
        buffer.writeln('- AI Keywords: ${preferences.aiKeywords!.join(', ')}');
      }
      if (preferences.aiMatchingPrompt != null) {
        buffer.writeln('- Custom Matching Criteria: ${preferences.aiMatchingPrompt}');
      }
      if (preferences.excludedExpertise?.isNotEmpty == true) {
        buffer.writeln('- EXCLUDE Expertise: ${preferences.excludedExpertise!.join(', ')}');
      }
      if (preferences.excludedLocations?.isNotEmpty == true) {
        buffer.writeln('- EXCLUDE Locations: ${preferences.excludedLocations!.join(', ')}');
      }
      buffer.writeln('');
    } else {
      buffer.writeln('Required Expertise: ${business.requiredExpertise.join(', ')}');
      buffer.writeln('');
    }
    
    buffer.writeln('Based on this information, suggest:');
    buffer.writeln('1. What expertise categories would be most valuable for this business?');
    buffer.writeln('2. What communities should this business connect with?');
    buffer.writeln('3. What specific expert profiles would be ideal matches?');
    buffer.writeln('');
    buffer.writeln('Provide specific, actionable suggestions for expert matching.');
    
    return buffer.toString();
  }

  /// Parse AI response into structured suggestions
  List<AISuggestion> _parseAISuggestions(String aiResponse) {
    final suggestions = <AISuggestion>[];

    // Simple parsing - in production, use structured output or JSON parsing
    // For now, extract categories and communities mentioned
    final lines = aiResponse.split('\n');
    
    for (final line in lines) {
      final lowerLine = line.toLowerCase();
      
      // Look for category mentions
      final commonCategories = ['coffee', 'restaurant', 'food', 'bar', 'cafe', 'retail', 'service'];
      for (final category in commonCategories) {
        if (lowerLine.contains(category)) {
          suggestions.add(AISuggestion(
            category: category,
            reason: 'AI identified $category as relevant',
          ));
        }
      }
    }

    return suggestions;
  }

  /// Calculate match score for community-based matches
  double _calculateCommunityMatchScore(
    UnifiedUser expert,
    BusinessAccount business,
    ExpertiseCommunity community,
    List<String> matchedCategories,
  ) {
    double score = 0.5; // Base score for community membership

    // Expertise match bonus
    score += matchedCategories.length * 0.2;

    // Location match bonus
    if (business.preferredLocation != null && expert.location != null) {
      if (expert.location!.toLowerCase().contains(business.preferredLocation!.toLowerCase())) {
        score += 0.2;
      }
    }

    // Level match bonus
    if (business.minExpertLevel != null) {
      for (final category in matchedCategories) {
        final level = expert.getExpertiseLevel(category);
        if (level != null && level.index >= business.minExpertLevel!) {
          score += 0.1;
        }
      }
    }

    return score.clamp(0.0, 1.0);
  }

  /// Apply preference filters to matches
  List<BusinessExpertMatch> _applyPreferenceFilters(
    List<BusinessExpertMatch> matches,
    BusinessAccount business,
    BusinessExpertPreferences? preferences,
  ) {
    if (preferences == null) return matches;
    
    return matches.where((match) {
      final expert = match.expert;
      
      // Check excluded expertise
      if (preferences.excludedExpertise?.isNotEmpty == true) {
        final hasExcludedExpertise = preferences.excludedExpertise!.any(
          (cat) => expert.hasExpertiseIn(cat),
        );
        if (hasExcludedExpertise) return false;
      }
      
      // Check excluded locations
      if (preferences.excludedLocations?.isNotEmpty == true && expert.location != null) {
        final isExcludedLocation = preferences.excludedLocations!.any(
          (loc) => expert.location!.toLowerCase().contains(loc.toLowerCase()),
        );
        if (isExcludedLocation) return false;
      }
      
      // Check age range if specified
      // Note: Age data would need to be available in UnifiedUser model
      // For now, we'll skip this check
      
      // Check location distance if specified
      if (preferences.maxDistanceKm != null && 
          preferences.preferredLocation != null &&
          expert.location != null) {
        // In production, calculate actual distance
        // For now, just check if location matches
        if (!expert.location!.toLowerCase().contains(
              preferences.preferredLocation!.toLowerCase(),
            )) {
          // Could be filtered out, but we'll keep for now
        }
      }
      
      return true;
    }).toList();
  }

  /// Rank and deduplicate matches (with preferences)
  List<BusinessExpertMatch> _rankAndDeduplicate(
    List<BusinessExpertMatch> matches,
    BusinessAccount business,
    BusinessExpertPreferences? preferences,
  ) {
    // Group by expert ID
    final Map<String, BusinessExpertMatch> uniqueMatches = {};

    for (final match in matches) {
      final expertId = match.expert.id;
      
      if (uniqueMatches.containsKey(expertId)) {
        // Combine match scores and reasons
        final existing = uniqueMatches[expertId]!;
        final combinedScore = (existing.matchScore + match.matchScore) / 2;
        final combinedReason = '${existing.matchReason}; ${match.matchReason}';
        final combinedCategories = {...existing.matchedCategories, ...match.matchedCategories}.toList();
        final combinedCommunities = {...existing.matchedCommunities, ...match.matchedCommunities}.toList();
        
        // Apply preference-based score adjustments
        final adjustedScore = _applyPreferenceScoring(
          combinedScore,
          match.expert,
          business,
          preferences,
        );
        
        uniqueMatches[expertId] = BusinessExpertMatch(
          expert: match.expert,
          business: match.business,
          matchScore: adjustedScore,
          matchReason: combinedReason,
          matchType: _combineMatchTypes(existing.matchType, match.matchType),
          matchedCategories: combinedCategories,
          matchedCommunities: combinedCommunities,
        );
      } else {
        // Apply preference-based score adjustments to new match
        final adjustedScore = _applyPreferenceScoring(
          match.matchScore,
          match.expert,
          business,
          preferences,
        );
        uniqueMatches[expertId] = BusinessExpertMatch(
          expert: match.expert,
          business: match.business,
          matchScore: adjustedScore,
          matchReason: match.matchReason,
          matchType: match.matchType,
          matchedCategories: match.matchedCategories,
          matchedCommunities: match.matchedCommunities,
        );
      }
    }

    // Sort by match score
    final ranked = uniqueMatches.values.toList();
    ranked.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    return ranked;
  }

  MatchType _combineMatchTypes(MatchType type1, MatchType type2) {
    // Prefer AI suggestions, then community, then expertise
    if (type1 == MatchType.aiSuggestion || type2 == MatchType.aiSuggestion) {
      return MatchType.aiSuggestion;
    }
    if (type1 == MatchType.community || type2 == MatchType.community) {
      return MatchType.community;
    }
    return MatchType.expertise;
  }

  /// Apply preference-based scoring adjustments
  double _applyPreferenceScoring(
    double baseScore,
    UnifiedUser expert,
    BusinessAccount business,
    BusinessExpertPreferences? preferences,
  ) {
    if (preferences == null) return baseScore;
    
    double adjustedScore = baseScore;
    
    // Boost for preferred expertise categories
    if (preferences.preferredExpertiseCategories.isNotEmpty) {
      final preferredMatches = preferences.preferredExpertiseCategories
          .where((cat) => expert.hasExpertiseIn(cat))
          .length;
      if (preferredMatches > 0) {
        adjustedScore += (preferredMatches / preferences.preferredExpertiseCategories.length) * 0.2;
      }
    }
    
    // Boost for preferred location match
    if (preferences.preferredLocation != null && expert.location != null) {
      if (expert.location!.toLowerCase().contains(
            preferences.preferredLocation!.toLowerCase(),
          )) {
        adjustedScore += 0.15;
      }
    }
    
    // Boost for preferred expert level
    if (preferences.preferredExpertLevel != null) {
      final hasPreferredLevel = preferences.requiredExpertiseCategories.any((cat) {
        final level = expert.getExpertiseLevel(cat);
        return level != null && level.index == preferences.preferredExpertLevel!;
      });
      if (hasPreferredLevel) {
        adjustedScore += 0.1;
      }
    }
    
    // Boost for community leaders if preferred
    if (preferences.preferCommunityLeaders) {
      // Check if expert is a community leader (would need additional data)
      // For now, skip this boost
    }
    
    return adjustedScore.clamp(0.0, 1.0);
  }
}

/// Business Expert Match Result
class BusinessExpertMatch {
  final UnifiedUser expert;
  final BusinessAccount business;
  final double matchScore; // 0.0 to 1.0
  final String matchReason;
  final MatchType matchType;
  final List<String> matchedCategories;
  final List<String> matchedCommunities;

  const BusinessExpertMatch({
    required this.expert,
    required this.business,
    required this.matchScore,
    required this.matchReason,
    required this.matchType,
    required this.matchedCategories,
    required this.matchedCommunities,
  });
}

/// Match Type
enum MatchType {
  expertise,      // Matched by expertise category
  community,       // Matched by community membership
  aiSuggestion,    // Suggested by AI
}

/// AI Suggestion
class AISuggestion {
  final String? category;
  final String? communityId;
  final String reason;

  const AISuggestion({
    this.category,
    this.communityId,
    required this.reason,
  });
}

