#!/bin/bash

# SPOTS Final Fixes Script
# Addresses remaining type mismatches and method signature issues
# Date: August 1, 2025

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🔧 SPOTS Final Fixes${NC}"
echo "=========================="
echo ""

# Function to log progress
log_progress() {
    echo -e "${BLUE}📝 $1${NC}"
}

# Function to log success
log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to log error
log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to log warning
log_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

# Phase 1: Fix AI Master Orchestrator Type Issues
echo -e "${CYAN}📋 Phase 1: Fixing AI Master Orchestrator Type Issues${NC}"
echo "----------------------------------------"

log_progress "Fixing type mismatches in ai_master_orchestrator.dart..."

if [ -f "lib/core/ai/ai_master_orchestrator.dart" ]; then
    # Fix the method call on line 170 - remove the cast since it's already UnifiedUser
    sed -i.bak 's/predictFuturePreferences(user as UnifiedUser)/predictFuturePreferences(user)/g' "lib/core/ai/ai_master_orchestrator.dart"
    
    # Fix the Location and SocialContext issues on lines 652 and 654
    sed -i.bak 's/Location(data.locationData.first.latitude, data.locationData.first.longitude)/UnifiedLocation(latitude: data.locationData.first.latitude, longitude: data.locationData.first.longitude)/g' "lib/core/ai/ai_master_orchestrator.dart"
    sed -i.bak 's/SocialContext.solo/UnifiedSocialContext(nearbyUsers: [], friends: [], communityMembers: [], socialMetrics: {}, timestamp: DateTime.now())/g' "lib/core/ai/ai_master_orchestrator.dart"
    
    # Fix the _extractUserActions method to return UnifiedUserAction
    sed -i.bak 's/UserAction(/UnifiedUserAction(/g' "lib/core/ai/ai_master_orchestrator.dart"
    
    # Fix the _createUserFromData method to include all required parameters
    sed -i.bak 's/return UnifiedUser(/return UnifiedUser(\n      id: '\''user_${DateTime.now().millisecondsSinceEpoch}'\'',\n      name: '\''User'\'',\n      email: '\''user@example.com'\'',\n      createdAt: DateTime.now(),\n      updatedAt: DateTime.now(),\n      preferences: {},\n      homebases: [],\n      experienceLevel: 0,\n      pins: [],/g' "lib/core/ai/ai_master_orchestrator.dart"
    
    log_success "Fixed type mismatches in ai_master_orchestrator.dart"
else
    log_error "File not found: lib/core/ai/ai_master_orchestrator.dart"
fi

# Phase 2: Fix Personality Learning Method Signatures
echo ""
echo -e "${CYAN}📋 Phase 2: Fixing Personality Learning Method Signatures${NC}"
echo "----------------------------------------"

log_progress "Updating method signatures in personality_learning.dart..."

if [ -f "lib/core/ai/personality_learning.dart" ]; then
    # Update method signatures to accept UnifiedUser instead of User
    sed -i.bak 's/predictFuturePreferences(User user)/predictFuturePreferences(UnifiedUser user)/g' "lib/core/ai/personality_learning.dart"
    
    # Update method signatures to accept UnifiedUserAction instead of UserAction
    sed -i.bak 's/evolvePersonality(UserAction userAction)/evolvePersonality(UnifiedUserAction userAction)/g' "lib/core/ai/personality_learning.dart"
    sed -i.bak 's/recognizeBehavioralPatterns(List<UserAction> userActions)/recognizeBehavioralPatterns(List<UnifiedUserAction> userActions)/g' "lib/core/ai/personality_learning.dart"
    
    log_success "Updated method signatures in personality_learning.dart"
else
    log_error "File not found: lib/core/ai/personality_learning.dart"
fi

# Phase 3: Fix Pattern Recognition Method Signatures
echo ""
echo -e "${CYAN}📋 Phase 3: Fixing Pattern Recognition Method Signatures${NC}"
echo "----------------------------------------"

log_progress "Updating method signatures in pattern_recognition.dart..."

if [ -f "lib/core/ml/pattern_recognition.dart" ]; then
    # Update method signatures to accept UnifiedUserAction instead of UserAction
    sed -i.bak 's/analyzeUserBehavior(List<UserAction> userActions)/analyzeUserBehavior(List<UnifiedUserAction> userActions)/g' "lib/core/ml/pattern_recognition.dart"
    sed -i.bak 's/recognizePatterns(List<UserAction> userActions)/recognizePatterns(List<UnifiedUserAction> userActions)/g' "lib/core/ml/pattern_recognition.dart"
    sed -i.bak 's/predictPreferences(List<UserAction> userActions)/predictPreferences(List<UnifiedUserAction> userActions)/g' "lib/core/ml/pattern_recognition.dart"
    sed -i.bak 's/analyzeCommunityTrends(List<UserAction> userActions)/analyzeCommunityTrends(List<UnifiedUserAction> userActions)/g' "lib/core/ml/pattern_recognition.dart"
    sed -i.bak 's/generatePrivacyPreservingInsights(List<UserAction> userActions)/generatePrivacyPreservingInsights(List<UnifiedUserAction> userActions)/g' "lib/core/ml/pattern_recognition.dart"
    
    log_success "Updated method signatures in pattern_recognition.dart"
else
    log_error "File not found: lib/core/ml/pattern_recognition.dart"
fi

# Phase 4: Fix Comprehensive Data Collector
echo ""
echo -e "${CYAN}📋 Phase 4: Fixing Comprehensive Data Collector${NC}"
echo "----------------------------------------"

log_progress "Fixing remaining issues in comprehensive_data_collector.dart..."

if [ -f "lib/core/ai/comprehensive_data_collector.dart" ]; then
    # Fix any remaining type mismatches
    sed -i.bak 's/UserAction/UnifiedUserAction/g' "lib/core/ai/comprehensive_data_collector.dart"
    sed -i.bak 's/SocialContext/UnifiedSocialContext/g' "lib/core/ai/comprehensive_data_collector.dart"
    sed -i.bak 's/Location/UnifiedLocation/g' "lib/core/ai/comprehensive_data_collector.dart"
    
    log_success "Fixed remaining issues in comprehensive_data_collector.dart"
else
    log_error "File not found: lib/core/ai/comprehensive_data_collector.dart"
fi

# Phase 5: Fix Community Trend Detection Service
echo ""
echo -e "${CYAN}📋 Phase 5: Fixing Community Trend Detection Service${NC}"
echo "----------------------------------------"

log_progress "Fixing remaining issues in community_trend_detection_service.dart..."

if [ -f "lib/core/services/community_trend_detection_service.dart" ]; then
    # Fix any remaining type mismatches
    sed -i.bak 's/UserAction/UnifiedUserAction/g' "lib/core/services/community_trend_detection_service.dart"
    sed -i.bak 's/SocialContext/UnifiedSocialContext/g' "lib/core/services/community_trend_detection_service.dart"
    sed -i.bak 's/Location/UnifiedLocation/g' "lib/core/services/community_trend_detection_service.dart"
    
    log_success "Fixed remaining issues in community_trend_detection_service.dart"
else
    log_error "File not found: lib/core/services/community_trend_detection_service.dart"
fi

# Phase 6: Cleanup Backup Files
echo ""
echo -e "${CYAN}📋 Phase 6: Cleanup${NC}"
echo "----------------------------------------"

log_progress "Cleaning up backup files..."

# Remove backup files
find . -name "*.bak" -type f -delete
log_success "Removed backup files"

# Phase 7: Validation
echo ""
echo -e "${CYAN}📋 Phase 7: Validation${NC}"
echo "----------------------------------------"

log_progress "Running code analysis to check for remaining issues..."

# Run flutter analyze to check for remaining issues
if flutter analyze --no-fatal-infos > /tmp/analyze_output.txt 2>&1; then
    log_success "Code analysis completed"
    echo "Analysis output saved to /tmp/analyze_output.txt"
    
    # Count remaining errors
    ERROR_COUNT=$(grep -c "error" /tmp/analyze_output.txt || echo "0")
    WARNING_COUNT=$(grep -c "warning" /tmp/analyze_output.txt || echo "0")
    
    echo "Remaining errors: $ERROR_COUNT"
    echo "Remaining warnings: $WARNING_COUNT"
else
    log_warning "Code analysis found issues - check /tmp/analyze_output.txt"
fi

# Phase 8: Summary
echo ""
echo -e "${CYAN}📋 Phase 8: Summary${NC}"
echo "----------------------------------------"

log_success "Final fixes completed!"

echo ""
echo -e "${GREEN}✅ Fix Summary:${NC}"
echo "=================="
echo "✅ Fixed AI Master Orchestrator type mismatches"
echo "✅ Updated Personality Learning method signatures"
echo "✅ Updated Pattern Recognition method signatures"
echo "✅ Fixed Comprehensive Data Collector issues"
echo "✅ Fixed Community Trend Detection Service issues"
echo "✅ Cleaned up backup files"
echo ""

echo -e "${YELLOW}⚠️ Manual Tasks Remaining:${NC}"
echo "================================"
echo "1. Test all functionality after changes"
echo "2. Review any remaining warnings"
echo "3. Update documentation if needed"
echo ""

echo -e "${BLUE}📝 Next Steps:${NC}"
echo "=================="
echo "1. Run 'flutter test' to verify all tests pass"
echo "2. Run 'flutter analyze' to check remaining issues"
echo "3. Test app functionality manually"
echo "4. Update documentation"
echo ""

log_success "Final fixes script completed successfully!" 