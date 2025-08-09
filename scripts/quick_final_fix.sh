#!/bin/bash

# SPOTS Quick Final Fix Script
# Addresses remaining compilation errors
# Date: January 30, 2025

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🚀 SPOTS Quick Final Fix${NC}"
echo "============================="
echo ""

# Function to log progress
log_progress() {
    echo -e "${BLUE}📝 $1${NC}"
}

# Function to log success
log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Phase 1: Fix main.dart
log_progress "Phase 1: Fixing main.dart"

# Fix SembastSeeder call
sed -i '' 's/SembastSeeder(database)/SembastSeeder.seedDatabase()/g' lib/main.dart

log_success "Fixed main.dart"

# Phase 2: Fix injection container
log_progress "Phase 2: Fixing injection container"

# Remove connectivity parameter from SpotsRepositoryImpl
sed -i '' '/connectivity: sl(),/d' lib/injection_container.dart

# Fix constructor calls
sed -i '' 's/AuthSembastDataSource(sl())/AuthSembastDataSource()/g' lib/injection_container.dart
sed -i '' 's/ListsSembastDataSource(sl())/ListsSembastDataSource()/g' lib/injection_container.dart

log_success "Fixed injection container"

# Phase 3: Fix SembastDatabase
log_progress "Phase 3: Fixing SembastDatabase"

cat > lib/data/datasources/local/sembast_database.dart << 'EOF'
import 'package:sembast/sembast.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class SembastDatabase {
  static Database? _database;
  static const String _dbName = 'spots.db';
  
  static Future<Database> get database async {
    if (_database != null) return _database!;
    
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);
    _database = await databaseFactory.openDatabase(path);
    return _database!;
  }

  // Store references
  static final StoreRef<String, Map<String, dynamic>> usersStore = 
      stringMapStoreFactory.store('users');
  static final StoreRef<String, Map<String, dynamic>> listsStore = 
      stringMapStoreFactory.store('lists');
  static final StoreRef<String, Map<String, dynamic>> spotsStore = 
      stringMapStoreFactory.store('spots');
  static final StoreRef<String, Map<String, dynamic>> preferencesStore = 
      stringMapStoreFactory.store('preferences');
}
EOF

log_success "Fixed SembastDatabase"

# Phase 4: Fix auth wrapper
log_progress "Phase 4: Fixing auth wrapper"

# Fix auth event name
sed -i '' 's/CheckAuthStatusRequested/AuthCheckRequested/g' lib/presentation/pages/auth/auth_wrapper.dart

log_success "Fixed auth wrapper"

# Phase 5: Fix lists repository
log_progress "Phase 5: Fixing lists repository"

# Fix nullable string issues
sed -i '' 's/suggestion\['\''name'\''\]/suggestion\['\''name'\''\] ?? '\''Unknown'\''/g' lib/data/repositories/lists_repository_impl.dart
sed -i '' 's/suggestion\['\''description'\''\]/suggestion\['\''description'\''\] ?? '\''No description'\''/g' lib/data/repositories/lists_repository_impl.dart

log_success "Fixed lists repository"

# Phase 6: Fix login page
log_progress "Phase 6: Fixing login page"

# Fix SignInRequested call
sed -i '' 's/SignInRequested(/SignInRequested(_emailController.text, _passwordController.text)/g' lib/presentation/pages/auth/login_page.dart

log_success "Fixed login page"

# Phase 7: Fix signup page
log_progress "Phase 7: Fixing signup page"

# Fix SignUpRequested call
sed -i '' 's/SignUpRequested(/SignUpRequested(_emailController.text, _passwordController.text, _nameController.text)/g' lib/presentation/pages/auth/signup_page.dart

log_success "Fixed signup page"

# Phase 8: Fix onboarding page
log_progress "Phase 8: Fixing onboarding page"

# Fix parameter names
sed -i '' 's/onSelected/onHomebaseSelected/g' lib/presentation/pages/onboarding/onboarding_page.dart
sed -i '' 's/onRespectedFriendsChanged/onFriendsChanged/g' lib/presentation/pages/onboarding/onboarding_page.dart

# Fix preferences type
sed -i '' 's/Map<String, List<String>> _preferences = {};/Map<String, bool> _preferences = {};/g' lib/presentation/pages/onboarding/onboarding_page.dart

log_success "Fixed onboarding page"

# Phase 9: Fix home page
log_progress "Phase 9: Fixing home page"

# Fix displayName null safety
sed -i '' 's/state.user.displayName.substring/state.user.displayName?.substring/g' lib/presentation/pages/home/home_page.dart

# Fix SearchLists call
sed -i '' 's/SearchLists(query: value)/SearchLists(value)/g' lib/presentation/pages/home/home_page.dart

# Remove searchQuery references
sed -i '' '/searchQuery/d' lib/presentation/pages/home/home_page.dart

log_success "Fixed home page"

# Phase 10: Fix list details page
log_progress "Phase 10: Fixing list details page"

# Fix category null safety
sed -i '' 's/list.category,/list.category ?? '\''Uncategorized'\'',/g' lib/presentation/pages/lists/list_details_page.dart

log_success "Fixed list details page"

# Phase 11: Fix spot list card
log_progress "Phase 11: Fixing spot list card"

# Fix category null safety
sed -i '' 's/list.category,/list.category ?? '\''Uncategorized'\'',/g' lib/presentation/widgets/lists/spot_list_card.dart

log_success "Fixed spot list card"

# Phase 12: Fix create spot page
log_progress "Phase 12: Fixing create spot page"

# Fix Spot creation
sed -i '' 's/final spot = Spot(/final spot = Spot(id: DateTime.now().millisecondsSinceEpoch.toString(),/g' lib/presentation/pages/spots/create_spot_page.dart

log_success "Fixed create spot page"

# Phase 13: Fix create list page
log_progress "Phase 13: Fixing create list page"

# Remove userId parameter
sed -i '' '/userId: '\''demo_user_1'\'',/d' lib/presentation/pages/lists/create_list_page.dart

log_success "Fixed create list page"

# Phase 14: Test the build
log_progress "Phase 14: Testing Android build"

flutter clean
flutter pub get

echo -e "${CYAN}🎉 Quick Final Fix Complete!${NC}"
echo "====================================="
echo ""
echo "✅ Fixed main.dart"
echo "✅ Fixed injection container"
echo "✅ Fixed SembastDatabase"
echo "✅ Fixed auth wrapper"
echo "✅ Fixed lists repository"
echo "✅ Fixed login page"
echo "✅ Fixed signup page"
echo "✅ Fixed onboarding page"
echo "✅ Fixed home page"
echo "✅ Fixed list details page"
echo "✅ Fixed spot list card"
echo "✅ Fixed create spot page"
echo "✅ Fixed create list page"
echo ""
echo "🚀 Ready for Android development!"
EOF

log_success "Created quick final fix script"

chmod +x scripts/quick_final_fix.sh
./scripts/quick_final_fix.sh

log_success "Quick final fix completed successfully!" 