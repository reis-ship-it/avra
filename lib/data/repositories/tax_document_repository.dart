import 'package:spots/core/models/tax_document.dart';
import 'package:spots/data/datasources/local/sembast_database.dart';
import 'package:sembast/sembast.dart';
import 'package:spots/core/services/logger.dart';
import 'package:spots/data/repositories/repository_patterns.dart';

/// Tax Document Repository
///
/// Handles persistence of tax documents using Sembast database.
/// Local-only repository - no remote operations.
class TaxDocumentRepository extends SimplifiedRepositoryBase {
  static const AppLogger _logger =
      AppLogger(defaultTag: 'SPOTS', minimumLevel: LogLevel.debug);

  TaxDocumentRepository()
      : super(connectivity: null); // Local-only, no connectivity needed

  /// Save tax document
  Future<void> saveTaxDocument(TaxDocument document) async {
    try {
      final db = await SembastDatabase.database;
      await SembastDatabase.taxDocumentsStore.record(document.id).put(
            db,
            document.toJson(),
          );
      _logger.info('Tax document saved: ${document.id}',
          tag: 'TaxDocumentRepository');
    } catch (e) {
      _logger.error('Failed to save tax document',
          error: e, tag: 'TaxDocumentRepository');
      rethrow;
    }
  }

  /// Get tax document by ID
  Future<TaxDocument?> getTaxDocument(String documentId) async {
    return executeLocalOnly<TaxDocument?>(
      localOperation: () async {
        final db = await SembastDatabase.database;
        final data =
            await SembastDatabase.taxDocumentsStore.record(documentId).get(db);

        if (data == null) {
          return null;
        }

        return TaxDocument.fromJson(data);
      },
    );
  }

  /// Get tax documents for user and year
  Future<List<TaxDocument>> getTaxDocuments(String userId, int year) async {
    return executeLocalOnly<List<TaxDocument>>(
      localOperation: () async {
        final db = await SembastDatabase.database;
        final finder = Finder(
          filter: Filter.and([
            Filter.equals('userId', userId),
            Filter.equals('taxYear', year),
          ]),
        );
        final records =
            await SembastDatabase.taxDocumentsStore.find(db, finder: finder);

        return records
            .map((record) => TaxDocument.fromJson(record.value))
            .toList();
      },
    );
  }

  /// Get all tax documents for a user
  Future<List<TaxDocument>> getAllTaxDocuments(String userId) async {
    return executeLocalOnly<List<TaxDocument>>(
      localOperation: () async {
        final db = await SembastDatabase.database;
        final finder = Finder(filter: Filter.equals('userId', userId));
        final records =
            await SembastDatabase.taxDocumentsStore.find(db, finder: finder);

        return records
            .map((record) => TaxDocument.fromJson(record.value))
            .toList();
      },
    );
  }

  /// Get all tax documents for a year
  Future<List<TaxDocument>> getTaxDocumentsForYear(int year) async {
    return executeLocalOnly<List<TaxDocument>>(
      localOperation: () async {
        final db = await SembastDatabase.database;
        final finder = Finder(filter: Filter.equals('taxYear', year));
        final records =
            await SembastDatabase.taxDocumentsStore.find(db, finder: finder);

        return records
            .map((record) => TaxDocument.fromJson(record.value))
            .toList();
      },
    );
  }

  /// Get users with earnings >= threshold for a year
  Future<List<String>> getUsersWithEarningsAboveThreshold(
      int year, double threshold) async {
    return executeLocalOnly<List<String>>(
      localOperation: () async {
        final db = await SembastDatabase.database;
        final finder = Finder(
          filter: Filter.and([
            Filter.equals('taxYear', year),
            Filter.greaterThanOrEquals('totalEarnings', threshold),
          ]),
        );
        final records =
            await SembastDatabase.taxDocumentsStore.find(db, finder: finder);

        // Extract unique user IDs
        final userIds = <String>{};
        for (final record in records) {
          final doc = TaxDocument.fromJson(record.value);
          userIds.add(doc.userId);
        }

        return userIds.toList();
      },
    );
  }

  /// Delete tax document
  Future<void> deleteTaxDocument(String documentId) async {
    return executeLocalOnly(
      localOperation: () async {
        final db = await SembastDatabase.database;
        await SembastDatabase.taxDocumentsStore.record(documentId).delete(db);
        _logger.info('Tax document deleted: $documentId',
            tag: 'TaxDocumentRepository');
      },
    );
  }
}
