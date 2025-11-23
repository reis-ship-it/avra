# Admin Backend Connections Test

This test script verifies all backend integrations for the god-mode admin system.

## Prerequisites

1. **Supabase Configuration**: Ensure your Supabase credentials are configured in `lib/supabase_config.dart`
2. **Dependencies**: All required packages should be installed (`flutter pub get`)

## Running the Test

### Option 1: Standalone Dart Script

```bash
# From project root
dart run scripts/test_admin_backend_connections.dart
```

### Option 2: Flutter Test (Recommended)

```bash
# From project root
flutter test test/integration/admin_backend_connections_test.dart
```

### Option 3: Run from Flutter App

You can also run the test from within the Flutter app by navigating to the admin dashboard and checking the console output.

## What Gets Tested

### 1. Supabase Initialization ✅
- Verifies Supabase client can be initialized
- Checks connection to Supabase backend

### 2. Supabase Service ✅
- Tests `SupabaseService` connection
- Verifies client access

### 3. Admin Services Initialization ✅
- `ConnectionMonitor`
- `AdminAuthService`
- `AdminCommunicationService`
- `BusinessAccountService`
- `PredictiveAnalytics`
- `AdminGodModeService`

### 4. Database Queries ✅
- Users table
- Spots table
- Spot lists table
- User respects table
- Business accounts table (if exists)

### 5. Admin God-Mode Service Methods ✅
- Authorization checks
- Dashboard data retrieval
- User search
- Business accounts retrieval

### 6. Privacy Filtering ✅
- Verifies user search returns only ID and AI signature
- Ensures no personal data leaks

### 7. AI Data Streams ✅
- Reverse index functionality
- AI signature lookups
- Session retrieval

## Expected Output

```
🧪 Admin Backend Connections Test
==================================================

📡 Testing Supabase Initialization...
  ✓ Supabase already initialized

🔌 Testing Supabase Service...
  ✓ Supabase connection test passed
  ✓ Supabase client accessible

⚙️  Testing Admin Services Initialization...
  ✓ SharedPreferences initialized
  ✓ ConnectionMonitor initialized
  ✓ AdminAuthService initialized
  ✓ AdminCommunicationService initialized
  ✓ BusinessAccountService initialized
  ✓ PredictiveAnalytics initialized
  ✓ AdminGodModeService initialized

🗄️  Testing Database Queries...
  ✓ Users table accessible (found X users)
  ✓ Spots table accessible (found X spots)
  ✓ Spot lists table accessible (found X lists)
  ✓ User respects table accessible (found X respects)
  ⚠️  Business accounts table not found (expected if not created yet)

👑 Testing Admin God-Mode Service Methods...
  ✓ Authorization check works (authorized: false)
  ✓ Dashboard data correctly requires authorization
  ✓ User search correctly requires authorization
  ✓ Business accounts correctly requires authorization

🔒 Testing Privacy Filtering...
  ✓ Privacy filtering structure verified

🤖 Testing AI Data Streams...
  ✓ AI signature reverse index works (found 0 connections)
  ✓ AI signature session lookup works (found 0 sessions)
  ✓ Reverse index correctly returns empty set for non-existent signature
  ✓ AI data streams infrastructure ready

✅ All backend connection tests passed!
```

## Troubleshooting

### "Supabase URL or Anon Key not configured"
- Check `lib/supabase_config.dart` has valid credentials
- Ensure environment variables are set if using them

### "Unauthorized" errors
- This is expected if you haven't logged in as an admin
- The tests verify that authorization is properly enforced
- To test with authorization, log in first using `AdminAuthService`

### "Table not found" warnings
- Some tables may not exist yet (e.g., `business_accounts`)
- This is normal and the tests handle it gracefully
- Create the tables in Supabase if you need them

### Connection timeouts
- Check your internet connection
- Verify Supabase project is active
- Check Supabase dashboard for any service issues

## Integration with CI/CD

You can integrate this test into your CI/CD pipeline:

```yaml
# Example GitHub Actions
- name: Test Admin Backend Connections
  run: dart run scripts/test_admin_backend_connections.dart
  env:
    SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
    SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
```

## Next Steps

After running the tests successfully:

1. **Test with Real Data**: Log in as admin and test with actual user data
2. **Monitor Performance**: Check query performance with large datasets
3. **Security Audit**: Verify privacy filtering with real user data
4. **Load Testing**: Test with multiple concurrent admin users

