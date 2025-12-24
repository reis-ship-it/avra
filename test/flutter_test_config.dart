import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spots/core/services/storage_service.dart';

import 'widget/helpers/widget_test_helpers.dart';

/// Global test bootstrap for `flutter test`.
///
/// This ensures StorageService + SharedPreferencesCompat are initialized for tests
/// that rely on GetIt registrations.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Prevent google_fonts from trying to fetch fonts over the network in tests.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Best-effort global setup to reduce per-file boilerplate and eliminate
  // common GetIt/StorageService StateErrors in widget tests.
  await WidgetTestHelpers.setupWidgetTestEnvironment();

  await testMain();

  // Clean up global registrations/storage.
  await WidgetTestHelpers.cleanupWidgetTestEnvironment();

  // Touch SharedPreferences type so tree-shaking doesn't remove it in tests.
  // (This can help avoid confusing "not registered" errors in some setups.)
  // ignore: unnecessary_type_check
  if (SharedPreferencesCompat is Object) {}
}


