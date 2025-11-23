import 'package:get_storage/get_storage.dart';

/// Mock GetStorage implementation for testing
/// Uses GetStorage factory with initialData to avoid platform channel requirements
class MockGetStorage {
  static GetStorage? _instance;
  static final Map<String, dynamic> _initialData = {};
  
  /// Get a GetStorage instance for testing
  /// Uses factory constructor with initialData to avoid platform channel init
  static GetStorage getInstance() {
    _instance ??= GetStorage('test_box', null, _initialData);
    return _instance!;
  }
  
  static void reset() {
    _initialData.clear();
    _instance = null;
  }
}

