import 'dart:async';
import 'dart:developer' as developer;
import 'package:app_links/app_links.dart';

/// OAuth Deep Link Handler
///
/// Handles OAuth callback deep links in the format:
/// `spots://oauth/[platform]/callback?code=...&state=...`
///
/// **Usage:**
/// ```dart
/// final handler = OAuthDeepLinkHandler();
/// handler.onOAuthCallback = (platform, params) {
///   // Handle OAuth callback
/// };
/// handler.startListening();
/// ```
class OAuthDeepLinkHandler {
  static const String _logName = 'OAuthDeepLinkHandler';
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  /// Callback for OAuth completion
  /// Parameters: platform name, query parameters from OAuth callback
  Function(String platform, Map<String, String> params)? onOAuthCallback;

  /// Start listening for deep links
  void startListening() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        developer.log(
          'Deep link error: $err',
          name: _logName,
        );
      },
    );

    developer.log('🔗 Started listening for OAuth deep links', name: _logName);
  }

  /// Handle incoming deep link
  void _handleDeepLink(Uri uri) {
    developer.log(
      '📥 Received deep link: ${uri.toString()}',
      name: _logName,
    );

    // Check if this is an OAuth callback
    if (uri.scheme == 'spots' && uri.host == 'oauth') {
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.isNotEmpty && pathSegments[0] == 'callback') {
        // Extract platform from path: spots://oauth/[platform]/callback
        final platform = pathSegments.length > 1
            ? pathSegments[1]
            : (uri.queryParameters['platform'] ?? 'unknown');

        developer.log(
          '✅ OAuth callback received for platform: $platform',
          name: _logName,
        );

        // Convert query parameters to Map<String, String>
        final params = <String, String>{};
        uri.queryParameters.forEach((key, value) {
          params[key] = value;
        });

        // Trigger callback
        onOAuthCallback?.call(platform, params);
      }
    }
  }

  /// Get initial deep link (if app was opened via deep link)
  Future<Uri?> getInitialLink() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        developer.log(
          '📥 Initial deep link: ${initialLink.toString()}',
          name: _logName,
        );
        _handleDeepLink(initialLink);
      }
      return initialLink;
    } catch (e) {
      developer.log(
        'Error getting initial link: $e',
        name: _logName,
      );
      return null;
    }
  }

  /// Stop listening for deep links
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    developer.log('🔗 Stopped listening for OAuth deep links', name: _logName);
  }
}

