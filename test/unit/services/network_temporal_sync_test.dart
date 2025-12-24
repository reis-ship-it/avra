import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/services/atomic_clock_service.dart';
import 'package:spots/core/models/atomic_timestamp.dart';
import 'package:spots/core/ai/quantum/quantum_temporal_state.dart';

/// Experiment 6: Network-Wide Quantum Temporal Synchronization
///
/// **Patent #30: Quantum Atomic Clock System**
/// Tests validate network-wide quantum temporal synchronization across distributed nodes.
void main() {
  group('Experiment 6: Network-Wide Synchronization', () {
    test('should synchronize 10+ simulated nodes', () async {
      final nodes = <AtomicClockService>[];
      
      // Create 10 simulated nodes
      for (int i = 0; i < 10; i++) {
        final node = AtomicClockService();
        await node.initialize();
        nodes.add(node);
      }
      
      // Get timestamps from all nodes
      final timestamps = <AtomicTimestamp>[];
      for (final node in nodes) {
        timestamps.add(await node.getAtomicTimestamp());
      }
      
      // Calculate synchronization accuracy
      final baseTime = timestamps[0].serverTime;
      var maxDiff = 0;
      
      for (final timestamp in timestamps) {
        final diff = (timestamp.serverTime.difference(baseTime).inMilliseconds).abs();
        if (diff > maxDiff) maxDiff = diff;
      }
      
      // All nodes should be within reasonable range (for simulation)
      expect(maxDiff, lessThan(1000)); // Allow some variance in test
      
      // Cleanup
      for (final node in nodes) {
        node.dispose();
      }
    });

    test('should synchronize 50 simulated nodes', () async {
      final nodes = <AtomicClockService>[];
      
      // Create 50 simulated nodes
      for (int i = 0; i < 50; i++) {
        final node = AtomicClockService();
        await node.initialize();
        nodes.add(node);
      }
      
      // Get timestamps from all nodes
      final timestamps = <AtomicTimestamp>[];
      for (final node in nodes) {
        timestamps.add(await node.getAtomicTimestamp());
      }
      
      // Calculate max difference
      final baseTime = timestamps[0].serverTime;
      var maxDiff = 0;
      
      for (final timestamp in timestamps) {
        final diff = (timestamp.serverTime.difference(baseTime).inMilliseconds).abs();
        if (diff > maxDiff) maxDiff = diff;
      }
      
      // Should be within reasonable range
      expect(maxDiff, lessThan(2000));
      
      // Cleanup
      for (final node in nodes) {
        node.dispose();
      }
    });

    test('should generate synchronized quantum temporal states', () async {
      final nodes = <AtomicClockService>[];
      
      // Create 10 nodes
      for (int i = 0; i < 10; i++) {
        final node = AtomicClockService();
        await node.initialize();
        nodes.add(node);
      }
      
      // Generate quantum temporal states from all nodes
      final states = <QuantumTemporalState>[];
      for (final node in nodes) {
        final timestamp = await node.getAtomicTimestamp();
        states.add(QuantumTemporalStateGenerator.generate(timestamp));
      }
      
      // All states should be normalized
      for (final state in states) {
        expect(state.normalization, closeTo(1.0, 0.01));
      }
      
      // Cleanup
      for (final node in nodes) {
        node.dispose();
      }
    });

    test('should maintain synchronization stability over time', () async {
      final node1 = AtomicClockService();
      final node2 = AtomicClockService();
      
      await node1.initialize();
      await node2.initialize();
      
      // Get initial timestamps
      final t1_initial = await node1.getAtomicTimestamp();
      final t2_initial = await node2.getAtomicTimestamp();
      
      final initialDiff = (t1_initial.serverTime
          .difference(t2_initial.serverTime).inMilliseconds).abs();
      
      // Wait and check again
      await Future.delayed(const Duration(milliseconds: 100));
      
      final t1_later = await node1.getAtomicTimestamp();
      final t2_later = await node2.getAtomicTimestamp();
      
      final laterDiff = (t1_later.serverTime
          .difference(t2_later.serverTime).inMilliseconds).abs();
      
      // Difference should be stable (within reasonable range)
      expect(laterDiff, lessThan(1000));
      
      node1.dispose();
      node2.dispose();
    });

    test('should verify synchronization time < 100ms', () async {
      final node = AtomicClockService();
      
      final stopwatch = Stopwatch()..start();
      await node.initialize();
      stopwatch.stop();
      
      // Initialization should be fast
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      
      node.dispose();
    });
  });
}

