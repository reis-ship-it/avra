import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Env-driven Supabase readiness verification for CI and local use.
// Env vars:
// - SUPABASE_URL (required)
// - SUPABASE_ANON_KEY (required)
// - BUCKETS (csv; default: user-avatars,spot-images,list-images)
// - REQUIRE_CANARY (true/false; default: false)
// - CANARY_PATH (default: health/_canary.txt)
// - CANARY_BUCKETS (csv; default: BUCKETS)

void main() async {
  print('🔍 Verifying Supabase Setup');
  print('==========================');

  final env = Platform.environment;
  final String? url = env['SUPABASE_URL'];
  final String? anonKey = env['SUPABASE_ANON_KEY'];
  if (url == null || anonKey == null || url.isEmpty || anonKey.isEmpty) {
    stderr.writeln('❌ Missing SUPABASE_URL or SUPABASE_ANON_KEY');
    exit(1);
  }

  final String bucketsCsv = env['BUCKETS'] ?? 'user-avatars,spot-images,list-images';
  final List<String> requiredBuckets = bucketsCsv
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  final bool requireCanary = (env['REQUIRE_CANARY'] ?? 'false').toLowerCase() == 'true';
  final String canaryPath = env['CANARY_PATH'] ?? 'health/_canary.txt';
  final String canaryBucketsCsv = env['CANARY_BUCKETS'] ?? '';
  final List<String> canaryBuckets = (canaryBucketsCsv.isEmpty
      ? requiredBuckets
      : canaryBucketsCsv
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList());

  try {
    var failed = false;

    final tablesOk = await _checkTables(url, anonKey);
    failed = failed || !tablesOk;

    final bucketsOk = await _checkStorageBuckets(url, anonKey, requiredBuckets);
    failed = failed || !bucketsOk;

    if (requireCanary) {
      final canaryOk = await _checkCanaries(url, anonKey, canaryBuckets, canaryPath);
      failed = failed || !canaryOk;
    }

    final policiesOk = await _checkPolicies(url, anonKey);
    failed = failed || !policiesOk;

    if (failed) {
      stderr.writeln('\n❌ Verification failed');
      exit(1);
    }

    print('\n✅ Verification passed');
  } catch (e) {
    stderr.writeln('❌ Verification error: $e');
    exit(1);
  }
}

Future<bool> _checkTables(String url, String anonKey) async {
  print('\n🗄️  Checking database tables...');
  final tables = ['users', 'spots', 'spot_lists', 'spot_list_items', 'user_respects', 'user_follows'];
  var ok = true;
  for (final table in tables) {
    try {
      final response = await http.get(
        Uri.parse('$url/rest/v1/$table?select=count'),
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
        },
      );
      if (response.statusCode == 200) {
        print('✅ Table "$table" exists');
      } else {
        print('❌ Table "$table" not found (${response.statusCode})');
        ok = false;
      }
    } catch (e) {
      print('❌ Error checking table "$table": $e');
      ok = false;
    }
  }
  return ok;
}

Future<bool> _checkStorageBuckets(String url, String anonKey, List<String> requiredBuckets) async {
  print('\n📁 Checking storage buckets...');
  var allOk = true;
  for (final bucket in requiredBuckets) {
    try {
      final response = await http.post(
        Uri.parse('$url/storage/v1/object/list/$bucket'),
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({'prefix': ''}),
      );
      if (response.statusCode == 200) {
        print('✅ Bucket "$bucket" is accessible');
      } else if (response.statusCode == 404) {
        print('❌ Bucket "$bucket" not found');
        allOk = false;
      } else {
        print('❌ Bucket "$bucket" error: ${response.statusCode}');
        print('   Response: ${response.body}');
        allOk = false;
      }
    } catch (e) {
      print('❌ Error checking bucket "$bucket": $e');
      allOk = false;
    }
  }

  try {
    final listResp = await http.get(
      Uri.parse('$url/storage/v1/bucket'),
      headers: {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
      },
    );
    if (listResp.statusCode == 200) {
      final parsed = json.decode(listResp.body);
      print('ℹ️  Bucket list (anon-visible): ${parsed is List ? parsed.length : 0}');
    }
  } catch (_) {}

  return allOk;
}

Future<bool> _checkCanaries(String url, String anonKey, List<String> buckets, String canaryPath) async {
  print('\n🪺 Checking canary objects...');
  var allOk = true;
  for (final bucket in buckets) {
    final publicUrl = '$url/storage/v1/object/public/$bucket/$canaryPath';
    try {
      final resp = await http.get(Uri.parse(publicUrl), headers: {
        'apikey': anonKey,
      });
      if (resp.statusCode == 200) {
        print('✅ Canary present for "$bucket" at $canaryPath');
      } else {
        print('❌ Canary missing for "$bucket" (HTTP ${resp.statusCode})');
        allOk = false;
      }
    } catch (e) {
      print('❌ Canary check error for "$bucket": $e');
      allOk = false;
    }
  }
  return allOk;
}

Future<bool> _checkPolicies(String url, String anonKey) async {
  print('\n🔐 Checking security policies...');
  try {
    final response = await http.get(
      Uri.parse('$url/rest/v1/users?select=*&limit=1'),
      headers: {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
      },
    );
    if (response.statusCode == 200) {
      print('✅ Database policies working (can read users table)');
      return true;
    } else {
      print('❌ Database policies issue: ${response.statusCode}') ;
      print('   Response: ${response.body}');
      return false;
    }
  } catch (e) {
    print('❌ Policy check error: $e');
    return false;
  }
}


/// Verification script to check Supabase setup
void main() async {
  print('🔍 Verifying Supabase Setup');
  print('==========================');
  
  // Allow overriding via environment for CI (recommended)
  final env = Platform.environment;
  final String url = env['SUPABASE_URL'] ?? 'https://dsttvxuislebwriaprmt.supabase.co';
  final String anonKey = env['SUPABASE_ANON_KEY'] ?? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRzdHR2eHVpc2xlYndyaWFwcm10Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ1NzcxNTksImV4cCI6MjA3MDE1MzE1OX0.pYf0E9-BAXAq8rQC9Cjxuy_f1hfz9hQ1YQNGWInjANU';
  final String bucketsCsv = env['BUCKETS'] ?? 'user-avatars,spot-images,list-images';
  final List<String> requiredBuckets = bucketsCsv
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  final bool requireCanary = (env['REQUIRE_CANARY'] ?? 'false').toLowerCase() == 'true';
  final String canaryPath = env['CANARY_PATH'] ?? 'health/_canary.txt';
  final String canaryBucketsCsv = env['CANARY_BUCKETS'] ?? '';
  final List<String> canaryBuckets = (canaryBucketsCsv.isEmpty
          ? requiredBuckets
          : canaryBucketsCsv
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList());
  
  try {
    var failed = false;
    // Test 1: Check if tables exist
    final tablesOk = await checkTables(url, anonKey);
    failed = failed || !tablesOk;
    
    // Test 2: Check if storage buckets exist
    final bucketsOk = await checkStorageBuckets(url, anonKey, requiredBuckets);
    failed = failed || !bucketsOk;
    
    // Test 2b: Optional canary checks
    if (requireCanary) {
      final canaryOk = await checkCanaries(url, anonKey, canaryBuckets, canaryPath);
      failed = failed || !canaryOk;
    }
    
    // Test 3: Check if policies exist
    final policiesOk = await checkPolicies(url, anonKey);
    failed = failed || !policiesOk;
    
    if (failed) {
      stderr.writeln('\n❌ Verification failed');
      exit(1);
    }
    
    print('\n✅ Verification passed');
    
  } catch (e) {
    print('❌ Verification failed: $e');
    exit(1);
  }
}

/// Check if database tables exist
Future<bool> checkTables(String url, String anonKey) async {
  print('\n🗄️  Checking database tables...');
  
  final tables = ['users', 'spots', 'spot_lists', 'spot_list_items', 'user_respects', 'user_follows'];
  var ok = true;
  
  for (final table in tables) {
    try {
      final response = await http.get(
        Uri.parse('$url/rest/v1/$table?select=count'),
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
        },
      );
      
      if (response.statusCode == 200) {
        print('✅ Table "$table" exists');
      } else {
        print('❌ Table "$table" not found (${response.statusCode})');
        ok = false;
      }
    } catch (e) {
      print('❌ Error checking table "$table": $e');
      ok = false;
    }
  }
  return ok;
}

/// Check if storage buckets exist
Future<bool> checkStorageBuckets(String url, String anonKey, List<String> requiredBuckets) async {
  print('\n📁 Checking storage buckets...');

  // Note: Listing buckets often requires a service role. With anon, rely on per-bucket object listing.
  var allOk = true;

  for (final bucket in requiredBuckets) {
    try {
      final response = await http.post(
        Uri.parse('$url/storage/v1/object/list/$bucket'),
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({'prefix': ''}),
      );

      if (response.statusCode == 200) {
        print('✅ Bucket "$bucket" is accessible (0 objects or more)');
      } else if (response.statusCode == 404) {
        print('❌ Bucket "$bucket" not found');
        allOk = false;
      } else {
        print('❌ Bucket "$bucket" error: ${response.statusCode}');
        print('   Response: ${response.body}');
        allOk = false;
      }
    } catch (e) {
      print('❌ Error checking bucket "$bucket": $e');
      allOk = false;
    }
  }

  // Optional best-effort bucket listing (may return empty under anon role)
  try {
    final listResp = await http.get(
      Uri.parse('$url/storage/v1/bucket'),
      headers: {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
      },
    );
    if (listResp.statusCode == 200) {
      final parsed = json.decode(listResp.body);
      print('ℹ️  Bucket list (anon-visible): ${parsed is List ? parsed.length : 0}');
    }
  } catch (_) {}

  return allOk;
}

/// Optional: verify public canary objects exist for each bucket.
Future<bool> checkCanaries(String url, String anonKey, List<String> buckets, String canaryPath) async {
  print('\n🪺 Checking canary objects...');
  var allOk = true;
  for (final bucket in buckets) {
    final publicUrl = '$url/storage/v1/object/public/$bucket/$canaryPath';
    try {
      final resp = await http.get(Uri.parse(publicUrl), headers: {
        'apikey': anonKey,
      });
      if (resp.statusCode == 200) {
        print('✅ Canary present for "$bucket" at $canaryPath');
      } else {
        print('❌ Canary missing for "$bucket" (HTTP ${resp.statusCode})');
        allOk = false;
      }
    } catch (e) {
      print('❌ Canary check error for "$bucket": $e');
      allOk = false;
    }
  }
  return allOk;
}

/// Check if policies exist (basic check)
Future<bool> checkPolicies(String url, String anonKey) async {
  print('\n🔐 Checking security policies...');
  
  try {
    // Try to read from users table (should work if policies are set up)
    final response = await http.get(
      Uri.parse('$url/rest/v1/users?select=*&limit=1'),
      headers: {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
      },
    );
    
    if (response.statusCode == 200) {
      print('✅ Database policies working (can read users table)');
      return true;
    } else {
      print('❌ Database policies issue: ${response.statusCode}');
      print('   Response: ${response.body}');
      return false;
    }
  } catch (e) {
    print('❌ Policy check error: $e');
    return false;
  }
}



