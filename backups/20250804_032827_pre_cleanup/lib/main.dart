import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';
import 'package:spots/app.dart';
import 'package:spots/injection_container.dart' as di;
import 'package:spots/data/datasources/local/sembast_seeder.dart';
import 'package:spots/data/datasources/local/sembast_database.dart';
import 'package:spots/data/datasources/local/auth_sembast_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Temporarily disable Firebase for web compatibility
  // TODO: Fix Firebase web compatibility issues
  developer.log('Firebase temporarily disabled for web compatibility', name: 'main');
  
  // Helper function to check if data already exists
  Future<bool> _checkIfDataExists() async {
    try {
      final db = await SembastDatabase.database;
      final users = await SembastDatabase.usersStore.find(db, finder: Finder());
      return users.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  try {
    if (kIsWeb) {
      // Web platform - skip database initialization for now
      developer.log('Web platform detected, skipping database initialization', name: 'main');
    } else {
      // Initialize Sembast database (only once)
      developer.log('Initializing Sembast database...', name: 'main');
      final database = await SembastDatabase.database;
      developer.log('Sembast database initialized.', name: 'main');
      
      // Check if data already exists before seeding
      final hasData = await _checkIfDataExists();
      if (!hasData) {
        developer.log('Seeding demo data...', name: 'main');
        await SembastSeeder.seedDatabase();
        developer.log('Demo data seeded.', name: 'main');
      } else {
        developer.log('Data already exists, skipping seeding.', name: 'main');
      }
      
      // Debug: Check database contents
      await AuthSembastDataSource.debugDatabaseContents();
      
      // Also check if demo user exists specifically
      try {
        final db = await SembastDatabase.database;
        final finder = Finder(filter: Filter.equals('email', 'demo@spots.com'));
        final records = await SembastDatabase.usersStore.find(db, finder: finder);
        print('🔍 Main: Found ${records.length} demo users in database');
        for (final record in records) {
          print('🔍 Main: Demo user record: ${record.value}');
        }
      } catch (e) {
        print('🔍 Main: Error checking demo user: $e');
      }
    }

    // Initialize dependency injection
    developer.log('Initializing dependency injection...', name: 'main');
    await di.init();
    developer.log('Dependency injection initialized.', name: 'main');
    
    developer.log('Running app...', name: 'main');
    runApp(const SpotsApp());
  } catch (e) {
    developer.log('Error during app initialization: $e', name: 'main');
    // Still run the app even if there are errors
    runApp(const SpotsApp());
  }
}
