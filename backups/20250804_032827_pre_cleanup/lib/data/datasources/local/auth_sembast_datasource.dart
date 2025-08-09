import 'dart:developer' as developer;
import 'package:spots/core/models/unified_models.dart';import 'package:sembast/sembast.dart';
import 'package:spots/core/models/user.dart';
import 'package:spots/data/datasources/local/auth_local_datasource.dart';
import 'package:spots/data/datasources/local/sembast_database.dart';

class AuthSembastDataSource implements AuthLocalDataSource {
  final StoreRef<String, Map<String, dynamic>> _usersStore;
  final StoreRef<String, Map<String, dynamic>> _preferencesStore;

  AuthSembastDataSource()
      : _usersStore = SembastDatabase.usersStore,
        _preferencesStore = SembastDatabase.preferencesStore;

  @override
  Future<User?> signIn(String email, String password) async {
    try {
      print('🔐 AuthSembastDataSource: Starting sign in for $email');
      developer.log('Attempting sign in for: $email', name: 'AuthSembastDataSource');
      final db = await SembastDatabase.database;
      print('🔐 AuthSembastDataSource: Database obtained');
      final finder = Finder(filter: Filter.equals('email', email));
      final records = await _usersStore.find(db, finder: finder);
      
      print('🔐 AuthSembastDataSource: Found ${records.length} users with email: $email');
      developer.log('Found ${records.length} users with email: $email', name: 'AuthSembastDataSource');
      
      if (records.isNotEmpty) {
        final userData = records.first.value;
        print('🔐 AuthSembastDataSource: User data found: $userData');
        developer.log('User data: $userData', name: 'AuthSembastDataSource');
        final user = User.fromJson(userData);
        
        // For demo purposes, accept any password for demo@spots.com
        // In a real app, you'd verify the password hash
        if (email == 'demo@spots.com' || password.isNotEmpty) {
          // Save current user
          await _preferencesStore.record('currentUser').put(db, {'key': 'currentUser', 'value': user.id});
          print('🔐 AuthSembastDataSource: Demo user signed in successfully: $email');
          developer.log('Demo user signed in successfully: $email', name: 'AuthSembastDataSource');
          return user;
        }
      }
      
      // TEMPORARY: Create demo user on-the-fly if not found
      if (email == 'demo@spots.com') {
        print('🔐 AuthSembastDataSource: Creating demo user on-the-fly');
        developer.log('Creating demo user on-the-fly', name: 'AuthSembastDataSource');
        final now = DateTime.now();
        final demoUser = User(
          id: 'demo-user-1',
          email: 'demo@spots.com',
          name: 'Demo User',
          displayName: 'Demo User',
          role: UserRole.user,
          createdAt: now,
          updatedAt: now,
          isOnline: true,
        );
        
        // Save demo user to database
        await _usersStore.record(demoUser.id).put(db, demoUser.toJson());
        print('🔐 AuthSembastDataSource: Demo user saved to database');
        
        // Save current user
        await _preferencesStore.record('currentUser').put(db, {'key': 'currentUser', 'value': demoUser.id});
        print('🔐 AuthSembastDataSource: Demo user created and signed in successfully: $email');
        developer.log('Demo user created and signed in successfully: $email', name: 'AuthSembastDataSource');
        return demoUser;
      }
      
      print('🔐 AuthSembastDataSource: Invalid credentials for: $email');
      developer.log('Invalid credentials for: $email', name: 'AuthSembastDataSource');
      return null;
    } catch (e) {
      print('🔐 AuthSembastDataSource: Error signing in: $e');
      developer.log('Error signing in: $e', name: 'AuthSembastDataSource');
      return null;
    }
  }

  @override
  Future<User?> signUp(String email, String password, User user) async {
    try {
      final db = await SembastDatabase.database;
      final userData = user.toJson();
      final key = await _usersStore.add(db, userData);
      return user.copyWith(id: key);
    } catch (e) {
      developer.log('Error signing up: $e', name: 'AuthSembastDataSource');
      return null;
    }
  }

  @override
  Future<void> saveUser(User user) async {
    try {
      final db = await SembastDatabase.database;
      final userData = user.toJson();
      await _usersStore.record(user.id).put(db, userData);
    } catch (e) {
      developer.log('Error saving user: $e', name: 'AuthSembastDataSource');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final db = await SembastDatabase.database;
      final records = await _preferencesStore.find(db, finder: Finder(filter: Filter.equals('key', 'currentUser')));
      
      if (records.isNotEmpty) {
        final userId = records.first.value['value'] as String?;
        if (userId != null) {
          final userRecord = await _usersStore.record(userId).get(db);
          if (userRecord != null) {
            return User.fromJson(userRecord);
          }
        }
      }
      return null;
    } catch (e) {
      developer.log('Error getting current user: $e', name: 'AuthSembastDataSource');
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      final db = await SembastDatabase.database;
      await _preferencesStore.record('currentUser').delete(db);
    } catch (e) {
      developer.log('Error clearing user: $e', name: 'AuthSembastDataSource');
    }
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    try {
      final db = await SembastDatabase.database;
      final records = await _preferencesStore.find(db, finder: Finder(filter: Filter.equals('key', 'onboardingCompleted')));
      return records.isNotEmpty && records.first.value['value'] == true;
    } catch (e) {
      developer.log('Error checking onboarding status: $e', name: 'AuthSembastDataSource');
      return false;
    }
  }

  @override
  Future<void> markOnboardingCompleted() async {
    try {
      final db = await SembastDatabase.database;
      await _preferencesStore.record('onboardingCompleted').put(db, {'key': 'onboardingCompleted', 'value': true});
    } catch (e) {
      developer.log('Error marking onboarding completed: $e', name: 'AuthSembastDataSource');
    }
  }

  // Debug method to check database contents
  static Future<void> debugDatabaseContents() async {
    try {
      final db = await SembastDatabase.database;
      final users = await SembastDatabase.usersStore.find(db, finder: Finder());
      developer.log('Database contains ${users.length} users', name: 'AuthSembastDataSource');
      for (final user in users) {
        developer.log('User: ${user.value}', name: 'AuthSembastDataSource');
      }
    } catch (e) {
      developer.log('Error debugging database: $e', name: 'AuthSembastDataSource');
    }
  }
}
