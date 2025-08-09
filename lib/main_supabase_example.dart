// Moved to examples/supabase/main_supabase_example.dart

/// Example of how to use Supabase in your actual app
class SupabaseUsageExample {
  static final _supabase = SupabaseInitializer.client;
  
  /// Sign in a user
  static Future<void> signInUser(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print('✅ User signed in: ${response.user?.email}');
    } catch (e) {
      print('❌ Sign in failed: $e');
      rethrow;
    }
  }
  
  /// Create a new spot
  static Future<void> createSpot(String name, double lat, double lng) async {
    try {
      final spotData = {
        'name': name,
        'latitude': lat,
        'longitude': lng,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      await _supabase.from('spots').insert(spotData);
      print('✅ Spot created: $name');
    } catch (e) {
      print('❌ Failed to create spot: $e');
      rethrow;
    }
  }
  
  /// Get all spots
  static Future<List<Map<String, dynamic>>> getSpots() async {
    try {
      final response = await _supabase.from('spots').select('*');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Failed to get spots: $e');
      return [];
    }
  }
  
  /// Subscribe to real-time updates
  static Stream<List<Map<String, dynamic>>> getSpotsStream() {
    return _supabase
        .from('spots')
        .stream(primaryKey: ['id'])
        .map((event) => List<Map<String, dynamic>>.from(event));
  }
}
