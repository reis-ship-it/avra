class PerformanceMonitor {
  Future<void> startMonitoring() async {}
  Future<void> stopMonitoring() async {}
  Future<int> getCurrentMemoryUsage() async => 100 * 1024 * 1024; // 100MB
}


