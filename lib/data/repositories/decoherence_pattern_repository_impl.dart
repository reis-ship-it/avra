import 'package:spots/core/models/decoherence_pattern.dart';
import 'package:spots/domain/repositories/decoherence_pattern_repository.dart';
import 'package:spots/data/datasources/local/decoherence_pattern_local_datasource.dart';

/// Decoherence Pattern Repository Implementation
///
/// Implements offline-first storage for decoherence patterns.
///
/// **Implementation:**
/// Part of Quantum Enhancement Implementation Plan - Phase 2.1
class DecoherencePatternRepositoryImpl
    implements DecoherencePatternRepository {
  final DecoherencePatternLocalDataSource _localDataSource;

  DecoherencePatternRepositoryImpl({
    required DecoherencePatternLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<DecoherencePattern?> getByUserId(String userId) async {
    try {
      return await _localDataSource.getByUserId(userId);
    } catch (e) {
      // Return null on error (non-critical operation)
      return null;
    }
  }

  @override
  Future<void> save(DecoherencePattern pattern) async {
    try {
      await _localDataSource.save(pattern);
    } catch (e) {
      // Log but don't throw (non-critical operation)
      // Error handling is done at service level
      rethrow;
    }
  }

  @override
  Future<List<DecoherencePattern>> getByBehaviorPhase(
    BehaviorPhase phase,
  ) async {
    try {
      final allPatterns = await _localDataSource.getAll();
      return allPatterns
          .where((pattern) => pattern.behaviorPhase == phase)
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<DecoherencePattern>> getByTimeRange({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final allPatterns = await _localDataSource.getAll();
      return allPatterns.where((pattern) {
        final lastUpdated = pattern.lastUpdated.serverTime;
        return lastUpdated.isAfter(start) && lastUpdated.isBefore(end);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> delete(String userId) async {
    try {
      await _localDataSource.delete(userId);
    } catch (e) {
      // Log but don't throw (non-critical operation)
      rethrow;
    }
  }
}

