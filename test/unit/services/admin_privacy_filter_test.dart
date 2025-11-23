import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/services/admin_privacy_filter.dart';

/// Admin Privacy Filter Tests
/// Tests privacy filtering for admin access
/// OUR_GUTS.md: "Privacy and Control Are Non-Negotiable"
void main() {
  group('AdminPrivacyFilter', () {
    group('filterPersonalData', () {
      test('should filter out personal data keys', () {
        final data = {
          'name': 'John Doe',
          'email': 'john@example.com',
          'phone': '123-456-7890',
          'user_id': 'user-123',
          'ai_signature': 'ai-sig-123',
        };
        
        final filtered = AdminPrivacyFilter.filterPersonalData(data);
        
        expect(filtered.containsKey('name'), isFalse);
        expect(filtered.containsKey('email'), isFalse);
        expect(filtered.containsKey('phone'), isFalse);
        expect(filtered.containsKey('user_id'), isTrue);
        expect(filtered.containsKey('ai_signature'), isTrue);
      });

      test('should allow AI-related data', () {
        final data = {
          'ai_signature': 'sig-123',
          'ai_connections': ['conn-1', 'conn-2'],
          'ai_status': 'active',
        };
        
        final filtered = AdminPrivacyFilter.filterPersonalData(data);
        
        expect(filtered.containsKey('ai_signature'), isTrue);
        expect(filtered.containsKey('ai_connections'), isTrue);
        expect(filtered.containsKey('ai_status'), isTrue);
        
        // Note: Nested maps are filtered recursively, so they may be excluded if empty after filtering
      });

      test('should allow location data (vibe indicator)', () {
        final data = {
          'current_location': 'San Francisco',
          'visited_locations': ['SF', 'NYC'],
          'location_history': ['NYC'],
          'vibe_location': 'SF',
        };
        
        final filtered = AdminPrivacyFilter.filterPersonalData(data);
        
        expect(filtered.containsKey('current_location'), isTrue);
        expect(filtered.containsKey('visited_locations'), isTrue);
        expect(filtered.containsKey('location_history'), isTrue);
        expect(filtered.containsKey('vibe_location'), isTrue);
        
        // Note: Nested maps are filtered recursively, so they may be excluded if empty after filtering
      });

      test('should filter out home address', () {
        final data = {
          'home_address': '123 Main St',
          'homeaddress': '456 Oak Ave',
          'residential_address': '789 Pine Rd',
          'personal_address': '321 Elm St',
          'visited_locations': ['SF', 'NYC'],
        };
        
        final filtered = AdminPrivacyFilter.filterPersonalData(data);
        
        // Home address keys should be filtered out
        expect(filtered.containsKey('home_address'), isFalse);
        expect(filtered.containsKey('homeaddress'), isFalse);
        expect(filtered.containsKey('residential_address'), isFalse);
        expect(filtered.containsKey('personal_address'), isFalse);
        // Location data should be preserved (vibe indicator)
        expect(filtered.containsKey('visited_locations'), isTrue);
      });

      test('should filter nested maps recursively', () {
        final data = {
          'user_data': {
            'name': 'John Doe',
            'email': 'john@example.com',
            'ai_signature': 'sig-123',
          },
          'profile': {
            'displayname': 'John',
            'username': 'johndoe',
          },
        };
        
        final filtered = AdminPrivacyFilter.filterPersonalData(data);
        
        if (filtered.containsKey('user_data')) {
          final userData = filtered['user_data'] as Map<String, dynamic>;
          expect(userData.containsKey('name'), isFalse);
          expect(userData.containsKey('email'), isFalse);
          expect(userData.containsKey('ai_signature'), isTrue);
        }
        
        expect(filtered.containsKey('profile'), isFalse);
      });

      test('should handle empty map', () {
        final data = <String, dynamic>{};
        
        final filtered = AdminPrivacyFilter.filterPersonalData(data);
        
        expect(filtered, isEmpty);
      });

      test('should handle case-insensitive key matching', () {
        final data = {
          'NAME': 'John Doe',
          'Email': 'john@example.com',
          'PHONE': '123-456-7890',
          'User_ID': 'user-123',
        };
        
        final filtered = AdminPrivacyFilter.filterPersonalData(data);
        
        expect(filtered.containsKey('NAME'), isFalse);
        expect(filtered.containsKey('Email'), isFalse);
        expect(filtered.containsKey('PHONE'), isFalse);
        expect(filtered.containsKey('User_ID'), isTrue);
      });

      test('should filter contact information', () {
        final data = {
          'contact': {
            'phone': '123-456-7890',
            'email': 'test@example.com',
          },
          'ai_status': 'active',
        };
        
        final filtered = AdminPrivacyFilter.filterPersonalData(data);
        
        expect(filtered.containsKey('contact'), isFalse);
        expect(filtered.containsKey('ai_status'), isTrue);
      });

      test('should preserve allowed keys', () {
        final data = <String, dynamic>{
          'user_id': 'user-123',
          'ai_signature': 'sig-123',
          'ai_connections': ['conn1'],
          'connection_id': 'conn-123',
          'ai_status': 'active',
          'ai_activity': 'learning',
          'current_location': 'SF',
          'visited_locations': ['SF'],
          'location_history': ['NYC'],
          'vibe_location': 'SF',
          'spot_locations': ['spot1'],
        };
        
        final filtered = AdminPrivacyFilter.filterPersonalData(data);
        
        // Verify that allowed keys are preserved
        expect(filtered.containsKey('user_id'), isTrue);
        expect(filtered.containsKey('ai_signature'), isTrue);
        expect(filtered.containsKey('ai_connections'), isTrue);
        expect(filtered.containsKey('connection_id'), isTrue);
        expect(filtered.containsKey('ai_status'), isTrue);
        expect(filtered.containsKey('ai_activity'), isTrue);
        expect(filtered.containsKey('current_location'), isTrue);
        expect(filtered.containsKey('visited_locations'), isTrue);
        expect(filtered.containsKey('location_history'), isTrue);
        expect(filtered.containsKey('vibe_location'), isTrue);
        expect(filtered.containsKey('spot_locations'), isTrue);
      });

      test('should filter displayname and username', () {
        final data = {
          'displayname': 'John Doe',
          'username': 'johndoe',
          'user_id': 'user-123',
        };
        
        final filtered = AdminPrivacyFilter.filterPersonalData(data);
        
        expect(filtered.containsKey('displayname'), isFalse);
        expect(filtered.containsKey('username'), isFalse);
        expect(filtered.containsKey('user_id'), isTrue);
      });
    });
  });
}

