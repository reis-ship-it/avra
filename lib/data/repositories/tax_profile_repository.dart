import 'package:avrai/core/models/tax_profile.dart';
import 'package:avrai/data/datasources/local/sembast_database.dart';
import 'package:sembast/sembast.dart';
import 'package:avrai/core/services/logger.dart';
import 'package:avrai/data/repositories/repository_patterns.dart';

/// Tax Profile Repository
///
/// Handles persistence of tax profiles using Sembast database.
/// Local-only repository - no remote operations.
class TaxProfileRepository extends SimplifiedRepositoryBase {
  static const AppLogger _logger =
      AppLogger(defaultTag: 'SPOTS', minimumLevel: LogLevel.debug);

  TaxProfileRepository()
      : super(connectivity: null); // Local-only, no connectivity needed

  /// Save tax profile
  Future<void> saveTaxProfile(TaxProfile profile) async {
    return executeLocalOnly(
      localOperation: () async {
        final db = await SembastDatabase.database;
        await SembastDatabase.taxProfilesStore.record(profile.userId).put(
              db,
              profile.toJson(),
            );
        _logger.info('Tax profile saved: ${profile.userId}',
            tag: 'TaxProfileRepository');
      },
    );
  }

  /// Get tax profile by user ID
  Future<TaxProfile?> getTaxProfile(String userId) async {
    return executeLocalOnly<TaxProfile?>(
      localOperation: () async {
        final db = await SembastDatabase.database;
        final data =
            await SembastDatabase.taxProfilesStore.record(userId).get(db);

        if (data == null) {
          return null;
        }

        return TaxProfile.fromJson(data);
      },
    );
  }

  /// Get all tax profiles
  Future<List<TaxProfile>> getAllTaxProfiles() async {
    return executeLocalOnly<List<TaxProfile>>(
      localOperation: () async {
        final db = await SembastDatabase.database;
        final records = await SembastDatabase.taxProfilesStore.find(db);

        return records
            .map((record) => TaxProfile.fromJson(record.value))
            .toList();
      },
    );
  }

  /// Get users with W-9 submitted
  Future<List<String>> getUsersWithW9() async {
    return executeLocalOnly<List<String>>(
      localOperation: () async {
        final db = await SembastDatabase.database;
        final finder = Finder(filter: Filter.equals('w9Submitted', true));
        final records =
            await SembastDatabase.taxProfilesStore.find(db, finder: finder);

        return records.map((record) => record.key).toList();
      },
    );
  }

  /// Delete tax profile
  Future<void> deleteTaxProfile(String userId) async {
    return executeLocalOnly(
      localOperation: () async {
        final db = await SembastDatabase.database;
        await SembastDatabase.taxProfilesStore.record(userId).delete(db);
        _logger.info('Tax profile deleted: $userId',
            tag: 'TaxProfileRepository');
      },
    );
  }
}
