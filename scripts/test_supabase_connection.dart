import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Test script to verify Supabase connection
/// Run this after setting up your Supabase project
void main() async {
  print('🧪 Testing Supabase Connection');
  print('==============================');
  
  // Configuration - replace with your actual values
  const String url = 'https://dsttvxuislebwriaprmt.supabase.co'; 
  const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRzdHR2eHVpc2xlYndyaWFwcm10Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ1NzcxNTksImV4cCI6MjA3MDE1MzE1OX0.pYf0E9-BAXAq8rQC9Cjxuy_f1hfz9hQ1YQNGWInjANU'; // Replace with your actual anon key
  
  if (url == 'YOUR_SUPABASE_URL' || anonKey == 'YOUR_SUPABASE_ANON_KEY') {
    print('❌ Please update the configuration with your actual Supabase credentials');
    print('   Update the url and anonKey constants in this file');
    exit(1);
  }
  
  try {
    print('🔧 Initializing Supabase...');
    
    // Initialize Supabase
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      debug: true,
    );
    
    final client = Supabase.instance.client;
    print('✅ Supabase initialized successfully');
    
    // Test authentication
    print('\n🔐 Testing Authentication...');
    await testAuthentication(client);
    
    // Test database operations
    print('\n🗄️  Testing Database Operations...');
    await testDatabaseOperations(client);
    
    // Test storage operations
    print('\n📁 Testing Storage Operations...');
    await testStorageOperations(client);
    
    // Test realtime
    print('\n📡 Testing Realtime...');
    await testRealtime(client);
    
    print('\n✅ All tests passed! Your Supabase backend is working correctly.');
    
  } catch (e) {
    print('❌ Test failed: $e');
    exit(1);
  }
}

/// Test authentication functionality
Future<void> testAuthentication(SupabaseClient client) async {
  try {
    // Test anonymous sign in
    final response = await client.auth.signInAnonymously();
    print('✅ Anonymous sign in successful');
    
    // Test sign out
    await client.auth.signOut();
    print('✅ Sign out successful');
    
  } catch (e) {
    print('❌ Authentication test failed: $e');
    rethrow;
  }
}

/// Test database operations
Future<void> testDatabaseOperations(SupabaseClient client) async {
  try {
    // Test reading from users table
    final response = await client
        .from('users')
        .select()
        .limit(1);
    
    print('✅ Database read successful');
    
    // Test creating a test user (if authenticated)
    if (client.auth.currentUser != null) {
      final testUser = {
        'id': client.auth.currentUser!.id,
        'email': 'test@example.com',
        'name': 'Test User',
      };
      
      await client
          .from('users')
          .upsert(testUser, onConflict: 'id');
      
      print('✅ Database write successful');
    }
    
  } catch (e) {
    print('❌ Database test failed: $e');
    rethrow;
  }
}

/// Test storage operations
Future<void> testStorageOperations(SupabaseClient client) async {
  try {
    // Test listing buckets
    final buckets = await client.storage.listBuckets();
    print('✅ Storage buckets accessible');
    
    // Test if required buckets exist
    final bucketNames = buckets.map((b) => b.name).toList();
    final requiredBuckets = ['user-avatars', 'spot-images', 'list-images'];
    
    for (final bucket in requiredBuckets) {
      if (bucketNames.contains(bucket)) {
        print('✅ Bucket "$bucket" exists');
      } else {
        print('⚠️  Bucket "$bucket" not found');
      }
    }
    
  } catch (e) {
    print('❌ Storage test failed: $e');
    rethrow;
  }
}

/// Test realtime functionality
Future<void> testRealtime(SupabaseClient client) async {
  try {
    // Test realtime subscription
    final channel = client.channel('test-channel');
    
    await channel.subscribe((status, [error]) {
      if (status == 'SUBSCRIBED') {
        print('✅ Realtime subscription successful');
      } else if (status == 'CHANNEL_ERROR') {
        print('❌ Realtime subscription failed: $error');
      }
    });
    
    // Wait a moment for subscription to establish
    await Future.delayed(Duration(seconds: 2));
    
    // Unsubscribe
    await channel.unsubscribe();
    print('✅ Realtime unsubscribe successful');
    
  } catch (e) {
    print('❌ Realtime test failed: $e');
    rethrow;
  }
}
