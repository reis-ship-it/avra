import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart' as sembast_memory;
import 'package:flutter/foundation.dart';
import 'package:avrai/core/services/logger.dart';

class SembastDatabase {
  static const AppLogger _logger = AppLogger(defaultTag: 'SPOTS', minimumLevel: LogLevel.debug);
  // ignore: unused_field
  static const String _preferencesStoreName = 'preferences';
  // ignore: unused_field - Reserved for future onboarding storage
  static const String _onboardingStoreName = 'onboarding';

  static Database? _database;
  // ignore: unused_field
  static bool _initializing = false;
  // ignore: unused_field
  static late StoreRef<String, Map<String, dynamic>> _usersStore;
  // ignore: unused_field
  static late StoreRef<String, Map<String, dynamic>> _spotsStore;
  // ignore: unused_field - Reserved for future lists storage
  static late StoreRef<String, Map<String, dynamic>> _listsStore;
  // ignore: unused_field - Reserved for future preferences storage
  static late StoreRef<String, Map<String, dynamic>> _preferencesStore;
  // ignore: unused_field - Reserved for future onboarding storage
  static late StoreRef<String, Map<String, dynamic>> _onboardingStore;

  static const String _dbName = 'spots.db';

  // Allow tests to override DB factory to in-memory
  static DatabaseFactory? _overrideFactory;
  static int _testDbCounter = 0;
  static String? _overrideDbName;
  static void useInMemoryForTests() {
    _overrideFactory = sembast_memory.databaseFactoryMemory;
    // Use a unique in-memory DB name per test to avoid cross-test contamination.
    _overrideDbName = 'spots_test_${_testDbCounter++}.db';
    _database = null;
    _initializing = false;
  }
  
  /// Test helper: reset the cached database instance so each test starts clean.
  /// Note: Sembast's in-memory DB can be cached across tests; closing without clearing
  /// `_database` may leave a closed instance that later calls reuse.
  static Future<void> resetForTests() async {
    try {
      await _database?.close();
    } catch (_) {
      // ignore - best effort cleanup for tests
    }
    _database = null;
    _initializing = false;
  }

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    
    // Prevent concurrent initialization
    if (_initializing) {
      // Wait a bit and retry
      await Future.delayed(const Duration(milliseconds: 100));
      // ignore: recursive_getters - Recursive call needed to wait for initialization
      return await database;
    }
    
    _initializing = true;
    try {
      // Database not initialized yet, initialize it
      if (_overrideFactory != null) {
        _database = await _overrideFactory!.openDatabase(_overrideDbName ?? 'spots_test.db');
      } else if (kIsWeb) {
        // Use web factory for web platform (IndexedDB)
        // On web, Sembast uses IndexedDB automatically via sembast_io
        try {
          _database = await databaseFactoryIo.openDatabase('spots_web.db');
        } catch (e) {
          // Fallback to in-memory if IndexedDB fails
          _logger.warn('IndexedDB initialization failed, using in-memory database: $e', tag: 'SembastDatabase');
          _database = await sembast_memory.databaseFactoryMemory.openDatabase('spots_web_memory.db');
        }
      } else {
        final documentsDirectory = await getApplicationDocumentsDirectory();
        final path = join(documentsDirectory.path, _dbName);
        _database = await databaseFactoryIo.openDatabase(path);
      }
      _initializing = false;
      return _database!;
    } catch (e, stackTrace) {
      _initializing = false;
      _logger.error('Database initialization failed', tag: 'SembastDatabase', error: e);
      _logger.debug('Stack trace: $stackTrace', tag: 'SembastDatabase');
      // Try fallback to in-memory database
      try {
        _database = await sembast_memory.databaseFactoryMemory.openDatabase('spots_fallback.db');
        _initializing = false;
        return _database!;
      } catch (fallbackError) {
        _logger.error('Fallback database also failed', tag: 'SembastDatabase', error: fallbackError);
        rethrow;
      }
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
  static final StoreRef<String, Map<String, dynamic>> taxProfilesStore = 
      stringMapStoreFactory.store('tax_profiles');
  static final StoreRef<String, Map<String, dynamic>> taxDocumentsStore = 
      stringMapStoreFactory.store('tax_documents');
  static final StoreRef<String, Map<String, dynamic>> decoherencePatternStore = 
      stringMapStoreFactory.store('decoherence_patterns');
}
