/// OAuth Configuration
///
/// Manages OAuth credentials, redirect URIs, and scopes for social media platforms.
/// Credentials are provided via --dart-define flags for security.
///
/// **Usage:**
/// ```bash
/// flutter run --dart-define=GOOGLE_OAUTH_CLIENT_ID=your_client_id \
///            --dart-define=INSTAGRAM_OAUTH_CLIENT_ID=your_instagram_id \
///            --dart-define=FACEBOOK_OAUTH_CLIENT_ID=your_facebook_id
/// ```
///
/// **Feature Flag:**
/// Set `USE_REAL_OAUTH=true` to enable real OAuth flows (defaults to false for placeholder mode).
class OAuthConfig {
  /// Feature flag: Use real OAuth or placeholders
  static const bool useRealOAuth = bool.fromEnvironment(
    'USE_REAL_OAUTH',
    defaultValue: false, // Default to placeholders for development
  );

  // Google OAuth
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_OAUTH_CLIENT_ID',
    defaultValue: '', // Empty = use placeholder
  );

  // Instagram OAuth
  static const String instagramClientId = String.fromEnvironment(
    'INSTAGRAM_OAUTH_CLIENT_ID',
    defaultValue: '',
  );
  static const String instagramClientSecret = String.fromEnvironment(
    'INSTAGRAM_OAUTH_CLIENT_SECRET',
    defaultValue: '',
  );

  // Facebook OAuth
  static const String facebookClientId = String.fromEnvironment(
    'FACEBOOK_OAUTH_CLIENT_ID',
    defaultValue: '',
  );
  static const String facebookClientSecret = String.fromEnvironment(
    'FACEBOOK_OAUTH_CLIENT_SECRET',
    defaultValue: '',
  );

  // Redirect URI Configuration
  static const String redirectUriScheme = 'spots';
  static String getRedirectUri(String platform) =>
      '$redirectUriScheme://oauth/$platform/callback';

  // OAuth Scopes
  static const List<String> googleScopes = [
    'profile',
    'email',
    'https://www.googleapis.com/auth/places',
    'https://www.googleapis.com/auth/photos',
  ];

  static const List<String> instagramScopes = [
    'user_profile',
    'user_media',
  ];

  static const List<String> facebookScopes = [
    'public_profile',
    'email',
    'user_friends',
  ];

  /// Check if Google OAuth is configured
  static bool get isGoogleConfigured =>
      useRealOAuth && googleClientId.isNotEmpty;

  /// Check if Instagram OAuth is configured
  static bool get isInstagramConfigured =>
      useRealOAuth &&
      instagramClientId.isNotEmpty &&
      instagramClientSecret.isNotEmpty;

  /// Check if Facebook OAuth is configured
  static bool get isFacebookConfigured =>
      useRealOAuth &&
      facebookClientId.isNotEmpty &&
      facebookClientSecret.isNotEmpty;

  /// Get OAuth authorization URL for a platform
  static String getAuthorizationUrl(String platform) {
    switch (platform.toLowerCase()) {
      case 'google':
        return 'https://accounts.google.com/o/oauth2/v2/auth';
      case 'instagram':
        return 'https://api.instagram.com/oauth/authorize';
      case 'facebook':
        return 'https://www.facebook.com/v18.0/dialog/oauth';
      default:
        throw ArgumentError('Unsupported platform: $platform');
    }
  }

  /// Get OAuth token exchange URL for a platform
  static String getTokenExchangeUrl(String platform) {
    switch (platform.toLowerCase()) {
      case 'google':
        return 'https://oauth2.googleapis.com/token';
      case 'instagram':
        return 'https://api.instagram.com/oauth/access_token';
      case 'facebook':
        return 'https://graph.facebook.com/v18.0/oauth/access_token';
      default:
        throw ArgumentError('Unsupported platform: $platform');
    }
  }
}

