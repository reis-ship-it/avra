import 'package:sembast/sembast.dart';
import 'package:spots/core/models/unified_models.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart' as sembast_memory;
import 'package:flutter/foundation.dart';

class SembastDatabase {
  static const String _preferencesStoreName = 'preferences';
  static const String _onboardingStoreName = 'onboarding';

  static late Database _database;
  static late StoreRef<String, Map<String, dynamic>> _usersStore;
  static late StoreRef<String, Map<String, dynamic>> _spotsStore;
  static late StoreRef<String, Map<String, dynamic>> _listsStore;
  static late StoreRef<String, Map<String, dynamic>> _preferencesStore;
  static late StoreRef<String, Map<String, dynamic>> _onboardingStore;

  static const String _dbName = 'spots.db';

  // Allow tests to override DB factory to in-memory
  static DatabaseFactory? _overrideFactory;
  static void useInMemoryForTests() {
    _overrideFactory = sembast_memory.databaseFactoryMemory;
  }

  static Future<Database> get database async {
    try {
      return _database;
    } catch (e) {
      // Database not initialized yet, initialize it
      if (_overrideFactory != null) {
        _database = await _overrideFactory!.openDatabase('spots_test.db');
      } else if (kIsWeb) {
        _database = await databaseFactoryIo.openDatabase('spots_web.db');
      } else {
        final documentsDirectory = await getApplicationDocumentsDirectory();
        final path = join(documentsDirectory.path, _dbName);
        _database = await databaseFactoryIo.openDatabase(path);
      }
      return _database;
    }
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
  static final StoreRef<String, Map<String, dynamic>> onboardingStore = 
      stringMapStoreFactory.store('onboarding');
  static final StoreRef<String, Map<String, dynamic>> respectsStore = 
      stringMapStoreFactory.store('respects');
}
