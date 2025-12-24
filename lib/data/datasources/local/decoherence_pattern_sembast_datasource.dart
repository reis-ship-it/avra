import 'package:spots/core/services/logger.dart';
import 'package:sembast/sembast.dart';
import 'package:spots/core/models/decoherence_pattern.dart';
import 'package:spots/data/datasources/local/sembast_database.dart';
import 'package:spots/data/datasources/local/decoherence_pattern_local_datasource.dart';

/// Sembast Data Source Implementation for Decoherence Patterns
///
/// Stores decoherence patterns in local Sembast database (offline-first).
class DecoherencePatternSembastDataSource
    implements DecoherencePatternLocalDataSource {
  final StoreRef<String, Map<String, dynamic>> _store;
  final AppLogger _logger = const AppLogger(
    defaultTag: 'SPOTS',
    minimumLevel: LogLevel.debug,
  );

  DecoherencePatternSembastDataSource()
      : _store = SembastDatabase.decoherencePatternStore;

  @override
  Future<DecoherencePattern?> getByUserId(String userId) async {
    try {
      final db = await SembastDatabase.database;
      final record = await _store.record(userId).get(db);
      if (record != null) {
        return DecoherencePattern.fromJson(record);
      }
      return null;
    } catch (e) {
      _logger.error(
        'Error getting decoherence pattern',
        error: e,
        tag: 'DecoherencePatternSembastDataSource',
      );
      return null;
    }
  }

  @override
  Future<void> save(DecoherencePattern pattern) async {
    try {
      final db = await SembastDatabase.database;
      final patternData = pattern.toJson();
      await _store.record(pattern.userId).put(db, patternData);
    } catch (e) {
      _logger.error(
        'Error saving decoherence pattern',
        error: e,
        tag: 'DecoherencePatternSembastDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<List<DecoherencePattern>> getAll() async {
    try {
      final db = await SembastDatabase.database;
      final records = await _store.find(db);
      return records
          .map((record) => DecoherencePattern.fromJson(record.value))
          .toList();
    } catch (e) {
      _logger.error(
        'Error getting all decoherence patterns',
        error: e,
        tag: 'DecoherencePatternSembastDataSource',
      );
      return [];
    }
  }

  @override
  Future<void> delete(String userId) async {
    try {
      final db = await SembastDatabase.database;
      await _store.record(userId).delete(db);
    } catch (e) {
      _logger.error(
        'Error deleting decoherence pattern',
        error: e,
        tag: 'DecoherencePatternSembastDataSource',
      );
      rethrow;
    }
  }
}

