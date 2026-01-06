import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:spots/app.dart';
import 'package:spots/injection_container.dart' as di;
import 'package:spots/data/datasources/local/sembast_seeder.dart';
import 'package:spots/data/datasources/local/sembast_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:spots/core/services/storage_health_checker.dart';
import 'package:spots/core/services/logger.dart';
import 'package:spots/data/datasources/local/onboarding_completion_service.dart';
import 'package:spots/core/services/supabase_service.dart';
import 'package:spots/core/crypto/signal/signal_protocol_service.dart';
import 'package:spots/core/services/signal_protocol_initialization_service.dart';
import 'package:spots_core/services/atomic_clock_service.dart';
import 'package:spots/core/services/local_llm/local_llm_auto_install_service.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const logger = AppLogger(defaultTag: 'MAIN', minimumLevel: LogLevel.debug);

  logger.info('🚀 [MAIN] App starting...');

  // Initialize Firebase (mobile and desktop; web via options)
  try {
    logger.info('🔥 [MAIN] Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.info('✅ [MAIN] Firebase initialized successfully');
  } catch (e, stackTrace) {
    logger.error('❌ [MAIN] Firebase init failed', error: e);
    logger.debug('Stack trace: $stackTrace');
    // Continue - Firebase is optional for some features
  }

  // Helper function to check if data already exists
  Future<bool> checkIfDataExists() async {
    try {
      final db = await SembastDatabase.database;
      final users = await SembastDatabase.usersStore.find(db, finder: Finder());
      logger.debug('Found ${users.length} users in database');
      return users.isNotEmpty;
    } catch (e) {
      logger.error('Error checking data', error: e);
      return false;
    }
  }

  try {
    // Initialize DI and backend (spots_network creates Supabase backend under the hood)
    logger.info('🔧 [MAIN] Initializing dependency injection...');
    await di.init();
    logger.info('✅ [MAIN] Dependency injection initialized.');

    // Best-effort: auto-install local LLM pack if user opted-in and eligible.
    // This keeps “best quality” offline chat one tap away without bloating the app download.
    try {
      unawaited(LocalLlmAutoInstallService().maybeAutoInstall());
    } catch (_) {
      // Ignore.
    }

    // Initialize Atomic Clock (central time authority; best-effort).
    try {
      logger.info('🕰️ [MAIN] Initializing AtomicClockService...');
      final atomicClock = di.sl<AtomicClockService>();
      final supabaseService = di.sl<SupabaseService>();

      // Configure server time provider (authoritative time source).
      atomicClock.configure(
          serverTimeProvider: () => supabaseService.getServerTime());

      await atomicClock.initialize();
      logger.info(
          '✅ [MAIN] AtomicClockService initialized (synchronized=${atomicClock.isSynchronized()})');
    } catch (e, stackTrace) {
      logger.warn('⚠️ [MAIN] AtomicClockService init failed (non-fatal): $e');
      logger.debug('Stack trace: $stackTrace');
    }

    // Storage health check (non-fatal)
    try {
      logger.info('📦 [MAIN] Checking storage health...');
      // Only check storage if Supabase is initialized
      try {
        final client = Supabase.instance.client;
        final storageHealth = StorageHealthChecker(client);
        final results = await storageHealth.checkAllBuckets([
          'user-avatars',
          'spot-images',
          'list-images',
        ]);
        logger.info(
            '✅ [MAIN] Storage health: ${results.entries.map((e) => '${e.key}=${e.value ? 'OK' : 'FAIL'}').join(', ')}');
      } catch (e) {
        logger.warn(
            '⚠️ [MAIN] Supabase not initialized, skipping storage health check: $e');
      }
    } catch (e) {
      logger.warn('⚠️ [MAIN] Storage health check error: $e');
    }

    // Initialize Sembast database (works on both web and mobile now)
    logger.info('💾 [MAIN] Initializing Sembast database...');
    await SembastDatabase.database;
    logger.info('✅ [MAIN] Sembast database initialized.');

    // Clear demo user cache and onboarding data to prevent crashes
    try {
      logger.info('🧹 [MAIN] Clearing demo user cache and data...');
      OnboardingCompletionService.clearAllCache();
      await OnboardingCompletionService.resetOnboardingCompletion(
          'demo-user-1');

      // Delete demo user from database
      final db = await SembastDatabase.database;
      await SembastDatabase.usersStore.record('demo-user-1').delete(db);
      await SembastDatabase.preferencesStore.record('currentUser').delete(db);

      logger.info('✅ [MAIN] Demo user cache and data cleared.');
    } catch (e) {
      logger.warn('⚠️ [MAIN] Error clearing demo user cache: $e');
    }

    // Delete demo user from database
    try {
      logger.info('🗑️ [MAIN] Deleting demo user from database...');
      final db = await SembastDatabase.database;
      await SembastDatabase.usersStore.record('demo-user-1').delete(db);
      await SembastDatabase.preferencesStore.record('currentUser').delete(db);
      logger.info('✅ [MAIN] Demo user deleted.');
    } catch (e) {
      logger.warn('⚠️ [MAIN] Error deleting demo user: $e');
    }

    // Check if data already exists before seeding
    logger.info('🔍 [MAIN] Checking if data exists...');
    final hasData = await checkIfDataExists();
    if (!hasData) {
      logger.info('🌱 [MAIN] Seeding demo data...');
      await SembastSeeder.seedDatabase();
      logger.info('✅ [MAIN] Demo data seeded.');
    } else {
      logger.info('ℹ️ [MAIN] Data already exists, skipping seeding.');
    }

    // Initialize Signal Protocol (non-blocking, fallback to AES-256-GCM if fails)
    try {
      logger.info('🔐 [MAIN] Initializing Signal Protocol...');
      final signalInitService = di.sl<SignalProtocolInitializationService>();
      await signalInitService.initialize();
      logger.info('✅ [MAIN] Signal Protocol initialized');

      // Best-effort: publish our prekey bundle if we already have an authenticated user session.
      //
      // This is required for other users/businesses to establish a Signal session to us
      // (X3DH needs the recipient's prekey bundle to be available on the key server).
      try {
        final supabaseService = di.sl<SupabaseService>();
        final currentUser = supabaseService.currentUser;
        if (currentUser != null && currentUser.id.isNotEmpty) {
          final signalProtocol = di.sl<SignalProtocolService>();
          await signalProtocol.uploadPreKeyBundle(currentUser.id);
          logger.info(
              '✅ [MAIN] Published Signal prekey bundle for userId=${currentUser.id}');
        } else {
          logger.info(
              'ℹ️ [MAIN] No authenticated user yet; skipping prekey bundle publish');
        }
      } catch (e, stackTrace) {
        logger.warn('⚠️ [MAIN] Prekey bundle publish failed (non-fatal): $e');
        logger.debug('Stack trace: $stackTrace');
      }
    } catch (e, stackTrace) {
      logger.warn('⚠️ [MAIN] Signal Protocol initialization failed: $e');
      logger.debug('Stack trace: $stackTrace');
      logger.info('ℹ️ [MAIN] App will use fallback encryption (AES-256-GCM)');
      // Continue - Signal Protocol is optional, app can work with fallback
    }

    logger.info('🎬 [MAIN] Running app...');
    runApp(const SpotsApp());
    logger.info('✅ [MAIN] App started successfully');
  } catch (e, stackTrace) {
    logger.error('❌ [MAIN] Error during app initialization', error: e);
    logger.debug('Stack trace: $stackTrace');
    // Still run the app even if there are errors
    logger.info('🔄 [MAIN] Attempting to run app despite errors...');
    runApp(const SpotsApp());
  }
}
