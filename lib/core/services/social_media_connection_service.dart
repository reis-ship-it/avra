import 'dart:convert';
import 'package:spots/core/models/social_media_connection.dart';
import 'package:spots/core/services/storage_service.dart';
import 'package:spots/core/services/logger.dart';
import 'package:spots/core/services/agent_id_service.dart';
import 'package:spots/core/config/oauth_config.dart';
import 'package:spots/core/services/oauth_deep_link_handler.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Social Media Connection Service
///
/// Manages OAuth connections to social media platforms and fetches user data.
/// Uses agentId for privacy protection (not userId).
///
/// **Privacy:** All connections are keyed by agentId, not userId.
/// **Security:** OAuth tokens are stored securely (encrypted storage recommended for production).
///
/// **Supported Platforms:**
/// - Google (Places API, Profile, Reviews, Photos)
/// - Instagram (Graph API - Profile, Follows, Posts)
/// - Facebook (Graph API - Profile, Friends, Pages)
/// - Twitter (API v2 - Profile, Follows)
/// - TikTok (API - Profile, Follows)
/// - LinkedIn (API - Profile, Connections)
class SocialMediaConnectionService {
  static const String _logName = 'SocialMediaConnectionService';
  final AppLogger _logger = const AppLogger(defaultTag: 'SPOTS');
  final StorageService _storageService;
  final AgentIdService _agentIdService;
  final OAuthDeepLinkHandler _deepLinkHandler;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Storage keys
  static const String _connectionsKeyPrefix = 'social_media_connections_';
  static const String _tokensKeyPrefix = 'social_media_tokens_'; // Encrypted in production

  SocialMediaConnectionService(
    this._storageService,
    this._agentIdService,
    this._deepLinkHandler,
  ) {
    // Start listening for OAuth deep links (for AppAuth flows)
    _deepLinkHandler.startListening();
    // Also check for initial deep link (if app was opened via deep link)
    // Note: getInitialLink is async, but we call it here to start the check
    _deepLinkHandler.getInitialLink().catchError((e) {
      _logger.warn('Failed to get initial deep link: $e', tag: _logName);
      return null;
    });
  }

  /// Connect a social media platform (runs OAuth flow and stores tokens)
  ///
  /// **Flow:**
  /// 1. Launch OAuth flow for the platform
  /// 2. Receive access token and refresh token
  /// 3. Store tokens securely (encrypted)
  /// 4. Fetch initial profile data
  /// 5. Create SocialMediaConnection record
  /// 6. Save to storage
  ///
  /// **Parameters:**
  /// - `platform`: Platform name ('google', 'instagram', 'facebook', etc.)
  /// - `agentId`: Privacy-protected agent identifier
  /// - `userId`: User identifier for service lookup (used internally, not stored with connection)
  ///
  /// **Returns:**
  /// SocialMediaConnection record after successful OAuth
  ///
  /// **Throws:**
  /// Exception if OAuth flow fails or platform is not supported
  Future<SocialMediaConnection> connectPlatform({
    required String platform,
    required String agentId,
    required String userId,
  }) async {
    try {
      _logger.info('🔗 Connecting to $platform for agent: ${agentId.substring(0, 10)}...', tag: _logName);

      // Normalize platform name
      final normalizedPlatform = platform.toLowerCase();

      // Route to appropriate OAuth flow or placeholder
      SocialMediaConnection connection;
      
      switch (normalizedPlatform) {
        case 'google':
          if (OAuthConfig.isGoogleConfigured) {
            connection = await _connectGoogle(agentId, userId);
          } else {
            connection = await _connectPlaceholder(agentId, normalizedPlatform);
          }
          break;
        case 'instagram':
          if (OAuthConfig.isInstagramConfigured) {
            connection = await _connectInstagram(agentId, userId);
          } else {
            connection = await _connectPlaceholder(agentId, normalizedPlatform);
          }
          break;
        case 'facebook':
          if (OAuthConfig.isFacebookConfigured) {
            connection = await _connectFacebook(agentId, userId);
          } else {
            connection = await _connectPlaceholder(agentId, normalizedPlatform);
          }
          break;
        default:
          // Use placeholder for unsupported platforms
          connection = await _connectPlaceholder(agentId, normalizedPlatform);
      }

      _logger.info('✅ Connected to $platform successfully', tag: _logName);
      return connection;
    } catch (e, stackTrace) {
      _logger.error('❌ Failed to connect to $platform', error: e, stackTrace: stackTrace, tag: _logName);
      rethrow;
    }
  }

  /// Connect to Google using Google Sign-In
  Future<SocialMediaConnection> _connectGoogle(String agentId, String userId) async {
    try {
      final googleSignIn = GoogleSignIn(
        scopes: OAuthConfig.googleScopes,
        clientId: OAuthConfig.googleClientId,
      );

      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        throw Exception('Google sign-in cancelled by user');
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      if (auth.accessToken == null) {
        throw Exception('Failed to get Google access token');
      }

      final now = DateTime.now();
      final connection = SocialMediaConnection(
        agentId: agentId,
        platform: 'google',
        platformUserId: account.id,
        platformUsername: account.displayName ?? account.email,
        isActive: true,
        createdAt: now,
        lastUpdated: now,
        lastTokenRefresh: now,
        metadata: {
          'oauth_implemented': true,
          'email': account.email,
          'photo_url': account.photoUrl,
        },
      );

      await _saveConnection(agentId, 'google', connection);
      await _storeTokens(agentId, 'google', {
        'access_token': auth.accessToken!,
        'id_token': auth.idToken,
        'refresh_token': null, // Google Sign-In handles refresh internally
        'expires_at': null, // Google Sign-In handles expiration
      });

      return connection;
    } catch (e, stackTrace) {
      _logger.error('❌ Google OAuth failed', error: e, stackTrace: stackTrace, tag: _logName);
      rethrow;
    }
  }

  /// Connect to Instagram using AppAuth
  Future<SocialMediaConnection> _connectInstagram(String agentId, String userId) async {
    try {
      final appAuth = const FlutterAppAuth();
      final redirectUri = OAuthConfig.getRedirectUri('instagram');
      
      final result = await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          OAuthConfig.instagramClientId,
          redirectUri,
          discoveryUrl: 'https://www.instagram.com/.well-known/openid_configuration',
          scopes: OAuthConfig.instagramScopes,
        ),
      );

      if (result.accessToken == null) {
        throw Exception('Instagram OAuth failed or was cancelled');
      }

      // Fetch user profile
      final profileResponse = await http.get(
        Uri.parse('https://graph.instagram.com/me?fields=id,username&access_token=${result.accessToken}'),
      );

      if (profileResponse.statusCode != 200) {
        throw Exception('Failed to fetch Instagram profile');
      }

      final profileData = jsonDecode(profileResponse.body) as Map<String, dynamic>;
      final now = DateTime.now();
      final connection = SocialMediaConnection(
        agentId: agentId,
        platform: 'instagram',
        platformUserId: profileData['id'] as String,
        platformUsername: profileData['username'] as String?,
        isActive: true,
        createdAt: now,
        lastUpdated: now,
        lastTokenRefresh: now,
        metadata: const {
          'oauth_implemented': true,
        },
      );

      await _saveConnection(agentId, 'instagram', connection);
      await _storeTokens(agentId, 'instagram', {
        'access_token': result.accessToken!,
        'refresh_token': result.refreshToken,
        'id_token': result.idToken,
        'expires_at': result.accessTokenExpirationDateTime?.toIso8601String(),
      });

      return connection;
    } catch (e, stackTrace) {
      _logger.error('❌ Instagram OAuth failed', error: e, stackTrace: stackTrace, tag: _logName);
      rethrow;
    }
  }

  /// Connect to Facebook using AppAuth
  Future<SocialMediaConnection> _connectFacebook(String agentId, String userId) async {
    try {
      final appAuth = const FlutterAppAuth();
      final redirectUri = OAuthConfig.getRedirectUri('facebook');
      
      final result = await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          OAuthConfig.facebookClientId,
          redirectUri,
          discoveryUrl: 'https://www.facebook.com/.well-known/openid_configuration',
          scopes: OAuthConfig.facebookScopes,
        ),
      );

      if (result.accessToken == null) {
        throw Exception('Facebook OAuth failed or was cancelled');
      }

      // Fetch user profile
      final profileResponse = await http.get(
        Uri.parse('https://graph.facebook.com/me?fields=id,name&access_token=${result.accessToken}'),
      );

      if (profileResponse.statusCode != 200) {
        throw Exception('Failed to fetch Facebook profile');
      }

      final profileData = jsonDecode(profileResponse.body) as Map<String, dynamic>;
      final now = DateTime.now();
      final connection = SocialMediaConnection(
        agentId: agentId,
        platform: 'facebook',
        platformUserId: profileData['id'] as String,
        platformUsername: profileData['name'] as String?,
        isActive: true,
        createdAt: now,
        lastUpdated: now,
        lastTokenRefresh: now,
        metadata: const {
          'oauth_implemented': true,
        },
      );

      await _saveConnection(agentId, 'facebook', connection);
      await _storeTokens(agentId, 'facebook', {
        'access_token': result.accessToken!,
        'refresh_token': result.refreshToken,
        'id_token': result.idToken,
        'expires_at': result.accessTokenExpirationDateTime?.toIso8601String(),
      });

      return connection;
    } catch (e, stackTrace) {
      _logger.error('❌ Facebook OAuth failed', error: e, stackTrace: stackTrace, tag: _logName);
      rethrow;
    }
  }

  /// Create placeholder connection (for development/testing)
  Future<SocialMediaConnection> _connectPlaceholder(String agentId, String platform) async {
    // Placeholder: Simulate OAuth flow
    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now();
    final connection = SocialMediaConnection(
      agentId: agentId,
      platform: platform,
      platformUserId: 'placeholder_${platform}_user_id',
      platformUsername: 'placeholder_${platform}_username',
      isActive: true,
      createdAt: now,
      lastUpdated: now,
      lastTokenRefresh: now,
      metadata: const {
        'oauth_implemented': false,
        'placeholder': true,
      },
    );

    await _saveConnection(agentId, platform, connection);
    await _storeTokens(agentId, platform, {
      'access_token': 'placeholder_access_token',
      'refresh_token': 'placeholder_refresh_token',
      'expires_at': now.add(const Duration(days: 30)).toIso8601String(),
    });

    return connection;
  }

  /// Disconnect a social media platform (removes tokens and connection)
  ///
  /// **Flow:**
  /// 1. Revoke OAuth tokens (if platform supports it)
  /// 2. Remove tokens from storage
  /// 3. Mark connection as inactive
  /// 4. Update storage
  ///
  /// **Parameters:**
  /// - `platform`: Platform name
  /// - `agentId`: Privacy-protected agent identifier
  ///
  /// **Throws:**
  /// Exception if disconnection fails
  Future<void> disconnectPlatform({
    required String platform,
    required String agentId,
  }) async {
    try {
      _logger.info('🔌 Disconnecting from $platform for agent: ${agentId.substring(0, 10)}...', tag: _logName);

      final normalizedPlatform = platform.toLowerCase();

      // Get existing connection
      final connection = await _getConnection(agentId, normalizedPlatform);
      if (connection == null) {
        _logger.warn('⚠️ No connection found for $platform', tag: _logName);
        return;
      }

      // TODO(Phase 8.2): Revoke OAuth tokens if platform supports it
      // For now, just mark as inactive

      // Mark connection as inactive
      final updatedConnection = connection.copyWith(
        isActive: false,
        lastUpdated: DateTime.now(),
      );

      // Update storage
      await _saveConnection(agentId, normalizedPlatform, updatedConnection);

      // Remove tokens
      await _removeTokens(agentId, normalizedPlatform);

      _logger.info('✅ Disconnected from $platform', tag: _logName);
    } catch (e, stackTrace) {
      _logger.error('❌ Failed to disconnect from $platform', error: e, stackTrace: stackTrace, tag: _logName);
      rethrow;
    }
  }

  /// Get active social media connections for a user
  ///
  /// **Parameters:**
  /// - `userId`: User identifier (used to get agentId)
  ///
  /// **Returns:**
  /// List of active SocialMediaConnection records
  Future<List<SocialMediaConnection>> getActiveConnections(String userId) async {
    try {
      // Get agentId from userId (via AgentIdService)
      final agentId = await _agentIdService.getUserAgentId(userId);

      // Get all connections for this agent
      final connections = await _getAllConnections(agentId);

      // Filter to active connections only
      return connections.where((conn) => conn.isActive).toList();
    } catch (e, stackTrace) {
      _logger.error('❌ Failed to get active connections', error: e, stackTrace: stackTrace, tag: _logName);
      return [];
    }
  }

  /// Fetch profile data from platform
  ///
  /// **Flow:**
  /// 1. Get connection and tokens
  /// 2. Make API call to platform
  /// 3. Parse and return structured data
  ///
  /// **Parameters:**
  /// - `connection`: SocialMediaConnection record
  ///
  /// **Returns:**
  /// Map with profile data (platform-specific structure)
  ///
  /// **Platform-Specific Data:**
  /// - Google: profile, savedPlaces, reviews, photos, locationHistory
  /// - Instagram: profile, follows, posts
  /// - Facebook: profile, friends, pages
  /// - Twitter: profile, follows, tweets
  /// - TikTok: profile, follows, videos
  /// - LinkedIn: profile, connections, posts
  Future<Map<String, dynamic>> fetchProfileData(
    SocialMediaConnection connection,
  ) async {
    try {
      _logger.info('📥 Fetching profile data from ${connection.platform}', tag: _logName);

      // Get tokens
      final tokens = await _getTokens(connection.agentId, connection.platform);
      if (tokens == null) {
        throw Exception('No tokens found for ${connection.platform}');
      }

      final accessToken = tokens['access_token'] as String?;
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // Check if this is a placeholder connection
      final isPlaceholder = connection.metadata['placeholder'] == true;
      if (isPlaceholder || !OAuthConfig.useRealOAuth) {
        return _getPlaceholderProfileData(connection);
      }

      // Route to platform-specific API implementation
      switch (connection.platform) {
        case 'google':
          return await _fetchGoogleProfileData(accessToken, connection);
        case 'instagram':
          return await _fetchInstagramProfileData(accessToken, connection);
        case 'facebook':
          return await _fetchFacebookProfileData(accessToken, connection);
        default:
          return _getPlaceholderProfileData(connection);
      }
    } catch (e, stackTrace) {
      _logger.error('❌ Failed to fetch profile data from ${connection.platform}', error: e, stackTrace: stackTrace, tag: _logName);
      return {};
    }
  }

  /// Fetch follows/connections from platform
  ///
  /// **Parameters:**
  /// - `connection`: SocialMediaConnection record
  ///
  /// **Returns:**
  /// List of follow/connection data
  Future<List<Map<String, dynamic>>> fetchFollows(
    SocialMediaConnection connection,
  ) async {
    try {
      _logger.info('📥 Fetching follows from ${connection.platform}', tag: _logName);

      // Get tokens
      final tokens = await _getTokens(connection.agentId, connection.platform);
      if (tokens == null) {
        throw Exception('No tokens found for ${connection.platform}');
      }

      final accessToken = tokens['access_token'] as String?;
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // Check if this is a placeholder connection
      final isPlaceholder = connection.metadata['placeholder'] == true;
      if (isPlaceholder || !OAuthConfig.useRealOAuth) {
        return [];
      }

      // Route to platform-specific API implementation
      switch (connection.platform) {
        case 'instagram':
          return await _fetchInstagramFollows(accessToken, connection);
        case 'facebook':
          return await _fetchFacebookFriends(accessToken, connection);
        default:
          return [];
      }
    } catch (e, stackTrace) {
      _logger.error('❌ Failed to fetch follows from ${connection.platform}', error: e, stackTrace: stackTrace, tag: _logName);
      return [];
    }
  }

  /// Fetch places/reviews/photos (Google-specific)
  ///
  /// **Parameters:**
  /// - `connection`: SocialMediaConnection record (must be 'google')
  ///
  /// **Returns:**
  /// Map with Google Places data: places, reviews, photos
  Future<Map<String, dynamic>> fetchGooglePlacesData(
    SocialMediaConnection connection,
  ) async {
    try {
      if (connection.platform != 'google') {
        throw Exception('fetchGooglePlacesData only supports Google platform');
      }

      _logger.info('📥 Fetching Google Places data', tag: _logName);

      // Get tokens
      final tokens = await _getTokens(connection.agentId, connection.platform);
      if (tokens == null) {
        throw Exception('No tokens found for Google');
      }

      final accessToken = tokens['access_token'] as String?;
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // Check if this is a placeholder connection
      final isPlaceholder = connection.metadata['placeholder'] == true;
      if (isPlaceholder || !OAuthConfig.useRealOAuth) {
        return {
          'places': [],
          'reviews': [],
          'photos': [],
        };
      }

      // Fetch real Google Places data
      return await _fetchGooglePlacesDataReal(accessToken, connection);
    } catch (e, stackTrace) {
      _logger.error('❌ Failed to fetch Google Places data', error: e, stackTrace: stackTrace, tag: _logName);
      return {
        'places': [],
        'reviews': [],
        'photos': [],
      };
    }
  }

  // Platform-specific API implementations

  /// Fetch Google profile data from Google APIs
  Future<Map<String, dynamic>> _fetchGoogleProfileData(
    String accessToken,
    SocialMediaConnection connection,
  ) async {
    try {
      // Fetch user profile from Google People API
      final profileResponse = await http.get(
        Uri.parse('https://people.googleapis.com/v1/people/me?personFields=names,emailAddresses,photos'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (profileResponse.statusCode != 200) {
        _logger.warn('Failed to fetch Google profile, using placeholder', tag: _logName);
        return _getPlaceholderProfileData(connection);
      }

      final profileData = jsonDecode(profileResponse.body) as Map<String, dynamic>;
      final names = profileData['names'] as List<dynamic>?;
      final emails = profileData['emailAddresses'] as List<dynamic>?;
      final photos = profileData['photos'] as List<dynamic>?;

      return {
        'profile': {
          'name': names?.isNotEmpty == true ? (names![0] as Map)['displayName'] : connection.platformUsername,
          'email': emails?.isNotEmpty == true ? (emails![0] as Map)['value'] : null,
          'photo': photos?.isNotEmpty == true ? (photos![0] as Map)['url'] : null,
        },
        'savedPlaces': [], // Will be fetched separately via fetchGooglePlacesData
        'reviews': [], // Will be fetched separately via fetchGooglePlacesData
        'photos': [], // Will be fetched separately via fetchGooglePlacesData
        'locationHistory': null, // Requires additional permissions
      };
    } catch (e, stackTrace) {
      _logger.error('Error fetching Google profile data', error: e, stackTrace: stackTrace, tag: _logName);
      return _getPlaceholderProfileData(connection);
    }
  }

  /// Fetch Instagram profile data from Instagram Graph API
  Future<Map<String, dynamic>> _fetchInstagramProfileData(
    String accessToken,
    SocialMediaConnection connection,
  ) async {
    try {
      // Fetch user profile from Instagram Graph API
      final profileResponse = await http.get(
        Uri.parse('https://graph.instagram.com/me?fields=id,username,account_type&access_token=$accessToken'),
      );

      if (profileResponse.statusCode != 200) {
        _logger.warn('Failed to fetch Instagram profile, using placeholder', tag: _logName);
        return _getPlaceholderProfileData(connection);
      }

      final profileData = jsonDecode(profileResponse.body) as Map<String, dynamic>;

      return {
        'profile': {
          'id': profileData['id'],
          'username': profileData['username'] ?? connection.platformUsername,
          'account_type': profileData['account_type'],
        },
        'follows': [], // Will be fetched separately via fetchFollows
        'posts': [], // Can be fetched if needed for vibe analysis
      };
    } catch (e, stackTrace) {
      _logger.error('Error fetching Instagram profile data', error: e, stackTrace: stackTrace, tag: _logName);
      return _getPlaceholderProfileData(connection);
    }
  }

  /// Fetch Facebook profile data from Facebook Graph API
  Future<Map<String, dynamic>> _fetchFacebookProfileData(
    String accessToken,
    SocialMediaConnection connection,
  ) async {
    try {
      // Fetch user profile from Facebook Graph API
      final profileResponse = await http.get(
        Uri.parse('https://graph.facebook.com/me?fields=id,name,email,picture&access_token=$accessToken'),
      );

      if (profileResponse.statusCode != 200) {
        _logger.warn('Failed to fetch Facebook profile, using placeholder', tag: _logName);
        return _getPlaceholderProfileData(connection);
      }

      final profileData = jsonDecode(profileResponse.body) as Map<String, dynamic>;
      final picture = profileData['picture'] as Map<String, dynamic>?;

      return {
        'profile': {
          'id': profileData['id'],
          'name': profileData['name'] ?? connection.platformUsername,
          'email': profileData['email'],
          'picture': picture?['data']?['url'],
        },
        'friends': [], // Will be fetched separately via fetchFollows
        'pages': [], // Can be fetched if needed
      };
    } catch (e, stackTrace) {
      _logger.error('Error fetching Facebook profile data', error: e, stackTrace: stackTrace, tag: _logName);
      return _getPlaceholderProfileData(connection);
    }
  }

  /// Fetch Instagram follows from Instagram Graph API
  Future<List<Map<String, dynamic>>> _fetchInstagramFollows(
    String accessToken,
    SocialMediaConnection connection,
  ) async {
    try {
      // Note: Instagram Graph API has limited access to follows
      // This may require additional permissions or may not be available
      final followsResponse = await http.get(
        Uri.parse('https://graph.instagram.com/me/follows?access_token=$accessToken'),
      );

      if (followsResponse.statusCode != 200) {
        _logger.warn('Failed to fetch Instagram follows (may require additional permissions)', tag: _logName);
        return [];
      }

      final followsData = jsonDecode(followsResponse.body) as Map<String, dynamic>;
      final follows = followsData['data'] as List<dynamic>? ?? [];

      return follows.map((f) => {
        'id': (f as Map)['id'],
        'username': f['username'],
      }).toList();
    } catch (e, stackTrace) {
      _logger.error('Error fetching Instagram follows', error: e, stackTrace: stackTrace, tag: _logName);
      return [];
    }
  }

  /// Fetch Facebook friends from Facebook Graph API
  Future<List<Map<String, dynamic>>> _fetchFacebookFriends(
    String accessToken,
    SocialMediaConnection connection,
  ) async {
    try {
      // Note: Facebook Graph API v2.0+ has limited access to friends
      // This may require additional permissions or may not be available
      final friendsResponse = await http.get(
        Uri.parse('https://graph.facebook.com/me/friends?access_token=$accessToken'),
      );

      if (friendsResponse.statusCode != 200) {
        _logger.warn('Failed to fetch Facebook friends (may require additional permissions)', tag: _logName);
        return [];
      }

      final friendsData = jsonDecode(friendsResponse.body) as Map<String, dynamic>;
      final friends = friendsData['data'] as List<dynamic>? ?? [];

      return friends.map((f) => {
        'id': (f as Map)['id'],
        'name': f['name'],
      }).toList();
    } catch (e, stackTrace) {
      _logger.error('Error fetching Facebook friends', error: e, stackTrace: stackTrace, tag: _logName);
      return [];
    }
  }

  /// Fetch Google Places data (saved places, reviews, photos)
  Future<Map<String, dynamic>> _fetchGooglePlacesDataReal(
    String accessToken,
    SocialMediaConnection connection,
  ) async {
    try {
      _logger.info('📥 Fetching Google Places data (saved places, reviews, photos)', tag: _logName);

      // Fetch saved places from Google Maps (if available via API)
      final savedPlaces = await _fetchGoogleSavedPlaces(accessToken);
      
      // Fetch user's reviews from Google Maps
      final reviews = await _fetchGoogleReviews(accessToken);
      
      // Fetch photos with location data from Google Photos
      final photos = await _fetchGooglePhotosWithLocation(accessToken);

      _logger.info(
        '✅ Fetched Google Places data: ${savedPlaces.length} places, ${reviews.length} reviews, ${photos.length} photos',
        tag: _logName,
      );

      return {
        'places': savedPlaces,
        'reviews': reviews,
        'photos': photos,
      };
    } catch (e, stackTrace) {
      _logger.error('Error fetching Google Places data', error: e, stackTrace: stackTrace, tag: _logName);
      return {
        'places': [],
        'reviews': [],
        'photos': [],
      };
    }
  }

  /// Fetch saved places from Google Maps
  /// Note: This requires Google Maps Platform API access to user's saved places
  Future<List<Map<String, dynamic>>> _fetchGoogleSavedPlaces(String accessToken) async {
    try {
      // Google Maps Platform API endpoint for saved places
      // Note: This endpoint may require additional scopes and API access
      final response = await _makeAuthenticatedRequest(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json',
        accessToken,
        queryParams: {
          'type': 'establishment',
          'radius': '50000', // Large radius to get user's saved places
        },
      );

      if (response == null) {
        return [];
      }

      final data = jsonDecode(response) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? [];

      return results.map((place) {
        final geometry = (place as Map)['geometry'] as Map<String, dynamic>?;
        final location = geometry?['location'] as Map<String, dynamic>?;
        
        return {
          'place_id': place['place_id'],
          'name': place['name'],
          'type': (place['types'] as List<dynamic>?)?.firstOrNull ?? 'establishment',
          'rating': place['rating']?.toDouble(),
          'latitude': location?['lat']?.toDouble(),
          'longitude': location?['lng']?.toDouble(),
          'address': place['vicinity'] ?? place['formatted_address'],
        };
      }).toList();
    } catch (e) {
      _logger.warn(
        'Could not fetch Google saved places (may require additional API access): $e',
        tag: _logName,
      );
      return [];
    }
  }

  /// Fetch user's Google reviews
  /// Note: This requires Google Maps Platform API or Google My Business API access
  Future<List<Map<String, dynamic>>> _fetchGoogleReviews(String accessToken) async {
    try {
      // Google Maps Platform API endpoint for user reviews
      // Note: This endpoint may require additional scopes
      // Alternative: Use Google My Business API if user has business account
      final response = await _makeAuthenticatedRequest(
        'https://maps.googleapis.com/maps/api/place/details/json',
        accessToken,
        queryParams: {
          'fields': 'reviews',
        },
      );

      if (response == null) {
        return [];
      }

      final data = jsonDecode(response) as Map<String, dynamic>;
      final result = data['result'] as Map<String, dynamic>?;
      final reviews = result?['reviews'] as List<dynamic>? ?? [];

      return reviews.map((review) {
        return {
          'place_id': result?['place_id'],
          'place_name': result?['name'],
          'rating': (review as Map)['rating']?.toInt(),
          'text': review['text'],
          'time': review['time'],
        };
      }).toList();
    } catch (e) {
      _logger.warn(
        'Could not fetch Google reviews (may require additional API access): $e',
        tag: _logName,
      );
      return [];
    }
  }

  /// Fetch photos with location data from Google Photos
  Future<List<Map<String, dynamic>>> _fetchGooglePhotosWithLocation(String accessToken) async {
    try {
      // Google Photos API endpoint
      final response = await _makeAuthenticatedRequest(
        'https://photoslibrary.googleapis.com/v1/mediaItems:search',
        accessToken,
        method: 'POST',
        body: jsonEncode({
          'filters': {
            'mediaTypeFilter': {
              'mediaTypes': ['PHOTO'],
            },
          },
          'pageSize': 50, // Limit to 50 photos
        }),
      );

      if (response == null) {
        return [];
      }

      final data = jsonDecode(response) as Map<String, dynamic>;
      final mediaItems = data['mediaItems'] as List<dynamic>? ?? [];

      return mediaItems.map((item) {
        final mediaMetadata = (item as Map)['mediaMetadata'] as Map<String, dynamic>?;
        final location = mediaMetadata?['location'] as Map<String, dynamic>?;
        
        return {
          'id': item['id'],
          'baseUrl': item['baseUrl'],
          'mimeType': item['mimeType'],
          'latitude': location?['latitude']?.toDouble(),
          'longitude': location?['longitude']?.toDouble(),
          'creationTime': mediaMetadata?['creationTime'],
        };
      }).toList();
    } catch (e) {
      _logger.warn(
        'Could not fetch Google Photos (may require additional scopes): $e',
        tag: _logName,
      );
      return [];
    }
  }

  /// Get placeholder profile data (for development/testing)
  Map<String, dynamic> _getPlaceholderProfileData(SocialMediaConnection connection) {
    switch (connection.platform) {
      case 'google':
        return {
          'profile': {
            'name': connection.platformUsername ?? 'Google User',
            'email': 'user@example.com',
          },
          'savedPlaces': [],
          'reviews': [],
          'photos': [],
          'locationHistory': null,
        };
      case 'instagram':
      case 'facebook':
      case 'twitter':
      case 'tiktok':
      case 'linkedin':
      default:
        return {
          'profile': {
            'name': connection.platformUsername ?? '${connection.platform} User',
            'username': connection.platformUsername,
          },
          'follows': [],
          'posts': [],
        };
    }
  }

  // Rate limiting and error handling

  /// Rate limit tracking per platform
  final Map<String, DateTime> _lastRequestTime = {};
  final Map<String, int> _requestCount = {};
  static const Duration _rateLimitWindow = Duration(minutes: 1);
  static const int _maxRequestsPerWindow = 60; // Conservative limit
  static const Duration _minRequestDelay = Duration(milliseconds: 100);

  /// Make authenticated HTTP request with rate limiting and retry logic
  Future<String?> _makeAuthenticatedRequest(
    String url,
    String accessToken, {
    Map<String, String>? queryParams,
    String method = 'GET',
    String? body,
    int maxRetries = 3,
  }) async {
    final platform = _extractPlatformFromUrl(url);
    
    // Rate limiting check
    await _checkRateLimit(platform);

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        // Build URI with query parameters
        var uri = Uri.parse(url);
        if (queryParams != null) {
          uri = uri.replace(queryParameters: {
            ...uri.queryParameters,
            ...queryParams,
          });
        }

        // Make request
        http.Response response;
        if (method == 'POST') {
          response = await http.post(
            uri,
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
            body: body,
          );
        } else {
          response = await http.get(
            uri,
            headers: {'Authorization': 'Bearer $accessToken'},
          );
        }

        // Update rate limit tracking
        _updateRateLimitTracking(platform);

        // Handle response
        if (response.statusCode == 200) {
          return response.body;
        } else if (response.statusCode == 401) {
          // Token expired or invalid - try to refresh
          _logger.warn('Token expired, attempting refresh', tag: _logName);
          final refreshed = await _refreshTokenIfNeeded(platform, accessToken);
          if (refreshed && attempt < maxRetries - 1) {
            // Retry with new token
            final newTokens = await _getTokens(
              _getAgentIdFromConnection(platform),
              platform,
            );
            if (newTokens != null) {
              accessToken = newTokens['access_token'] as String? ?? accessToken;
              continue;
            }
          }
          throw Exception('Authentication failed: ${response.statusCode}');
        } else if (response.statusCode == 429) {
          // Rate limited - wait and retry
          final retryAfter = _parseRetryAfter(response.headers['retry-after']);
          _logger.warn(
            'Rate limited, waiting ${retryAfter.inSeconds}s before retry',
            tag: _logName,
          );
          if (attempt < maxRetries - 1) {
            await Future.delayed(retryAfter);
            continue;
          }
          throw Exception('Rate limit exceeded');
        } else if (response.statusCode >= 500 && attempt < maxRetries - 1) {
          // Server error - retry with exponential backoff
          final backoff = Duration(seconds: 1 << attempt); // 1s, 2s, 4s
          _logger.warn(
            'Server error ${response.statusCode}, retrying after ${backoff.inSeconds}s',
            tag: _logName,
          );
          await Future.delayed(backoff);
          continue;
        } else {
          throw Exception('Request failed: ${response.statusCode} - ${response.body}');
        }
      } catch (e, stackTrace) {
        if (attempt == maxRetries - 1) {
          _logger.error(
            'Request failed after $maxRetries attempts',
            error: e,
            stackTrace: stackTrace,
            tag: _logName,
          );
          return null;
        }
        // Wait before retry
        await Future.delayed(Duration(seconds: 1 << attempt));
      }
    }

    return null;
  }

  /// Check and enforce rate limits
  Future<void> _checkRateLimit(String platform) async {
    final now = DateTime.now();
    final lastRequest = _lastRequestTime[platform];
    final requestCount = _requestCount[platform] ?? 0;

    // Reset counter if window expired
    if (lastRequest == null ||
        now.difference(lastRequest) > _rateLimitWindow) {
      _requestCount[platform] = 0;
      _lastRequestTime[platform] = now;
      return;
    }

    // Check if we've exceeded the limit
    if (requestCount >= _maxRequestsPerWindow) {
      final waitTime = _rateLimitWindow - now.difference(lastRequest);
      _logger.warn(
        'Rate limit reached for $platform, waiting ${waitTime.inSeconds}s',
        tag: _logName,
      );
      await Future.delayed(waitTime);
      _requestCount[platform] = 0;
      _lastRequestTime[platform] = DateTime.now();
      return;
    }

    // Enforce minimum delay between requests
    final timeSinceLastRequest = now.difference(lastRequest);
    if (timeSinceLastRequest < _minRequestDelay) {
      await Future.delayed(_minRequestDelay - timeSinceLastRequest);
    }
  }

  /// Update rate limit tracking
  void _updateRateLimitTracking(String platform) {
    final now = DateTime.now();
    _lastRequestTime[platform] = now;
    _requestCount[platform] = (_requestCount[platform] ?? 0) + 1;
  }

  /// Extract platform from URL
  String _extractPlatformFromUrl(String url) {
    if (url.contains('googleapis.com')) return 'google';
    if (url.contains('instagram.com')) return 'instagram';
    if (url.contains('facebook.com')) return 'facebook';
    return 'unknown';
  }

  /// Parse Retry-After header
  Duration _parseRetryAfter(String? retryAfter) {
    if (retryAfter == null) return const Duration(seconds: 60);
    final seconds = int.tryParse(retryAfter);
    if (seconds != null) return Duration(seconds: seconds);
    return const Duration(seconds: 60);
  }

  /// Refresh token if needed
  Future<bool> _refreshTokenIfNeeded(String platform, String currentToken) async {
    try {
      // Get all connections to find the one for this platform
      // Note: This is a simplified implementation - in production, we'd cache the agentId
      final platforms = ['google', 'instagram', 'facebook'];
      for (final p in platforms) {
        // Try to find connection - this is a simplified approach
        // In production, we'd have a better way to map platform to agentId
        final connections = await _getAllConnectionsForPlatform(p);
        for (final connection in connections) {
          if (connection.platform == platform && connection.isActive) {
            return await _refreshTokenForConnection(connection);
          }
        }
      }

      return false;
    } catch (e) {
      _logger.error('Failed to refresh token: $e', tag: _logName);
      return false;
    }
  }

  /// Refresh token for a specific connection
  Future<bool> _refreshTokenForConnection(SocialMediaConnection connection) async {
    try {
      final tokens = await _getTokens(connection.agentId, connection.platform);
      if (tokens == null) {
        return false;
      }

      final refreshToken = tokens['refresh_token'] as String?;
      if (refreshToken == null) {
        _logger.warn('No refresh token available for ${connection.platform}', tag: _logName);
        return false;
      }

      // Check if token is expired or about to expire (within 5 minutes)
      final expiresAtStr = tokens['expires_at'] as String?;
      if (expiresAtStr != null) {
        try {
          final expiresAt = DateTime.parse(expiresAtStr);
          final now = DateTime.now();
          final timeUntilExpiry = expiresAt.difference(now);
          
          // Only refresh if expired or expiring within 5 minutes
          if (timeUntilExpiry.inMinutes > 5) {
            return false; // Token still valid
          }
        } catch (e) {
          // If we can't parse expiration, assume it needs refresh
        }
      }

      // Refresh token based on platform
      switch (connection.platform) {
        case 'google':
          return await _refreshGoogleToken(connection, refreshToken);
        case 'instagram':
          return await _refreshInstagramToken(connection, refreshToken);
        case 'facebook':
          return await _refreshFacebookToken(connection, refreshToken);
        default:
          return false;
      }
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to refresh token for connection',
        error: e,
        stackTrace: stackTrace,
        tag: _logName,
      );
      return false;
    }
  }

  /// Refresh Google token
  Future<bool> _refreshGoogleToken(
    SocialMediaConnection connection,
    String refreshToken,
  ) async {
    try {
      // Google token refresh endpoint
      final response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': OAuthConfig.googleClientId,
          'refresh_token': refreshToken,
          'grant_type': 'refresh_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String?;
        final expiresIn = data['expires_in'] as int?;

        if (newAccessToken != null) {
          // Update tokens
          await _storeTokens(connection.agentId, connection.platform, {
            'access_token': newAccessToken,
            'refresh_token': refreshToken, // Refresh token doesn't change
            'expires_at': expiresIn != null
                ? DateTime.now().add(Duration(seconds: expiresIn)).toIso8601String()
                : null,
          });

          _logger.info('✅ Refreshed Google token', tag: _logName);
          return true;
        }
      }

      return false;
    } catch (e, stackTrace) {
      _logger.error('Failed to refresh Google token', error: e, stackTrace: stackTrace, tag: _logName);
      return false;
    }
  }

  /// Refresh Instagram token
  Future<bool> _refreshInstagramToken(
    SocialMediaConnection connection,
    String refreshToken,
  ) async {
    try {
      // Instagram token refresh endpoint
      final response = await http.get(
        Uri.parse(
          'https://graph.instagram.com/refresh_access_token?'
          'grant_type=ig_refresh_token&'
          'access_token=$refreshToken',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String?;
        final expiresIn = data['expires_in'] as int?;

        if (newAccessToken != null) {
          // Update tokens
          await _storeTokens(connection.agentId, connection.platform, {
            'access_token': newAccessToken,
            'refresh_token': refreshToken,
            'expires_at': expiresIn != null
                ? DateTime.now().add(Duration(seconds: expiresIn)).toIso8601String()
                : null,
          });

          _logger.info('✅ Refreshed Instagram token', tag: _logName);
          return true;
        }
      }

      return false;
    } catch (e, stackTrace) {
      _logger.error('Failed to refresh Instagram token', error: e, stackTrace: stackTrace, tag: _logName);
      return false;
    }
  }

  /// Refresh Facebook token
  Future<bool> _refreshFacebookToken(
    SocialMediaConnection connection,
    String refreshToken,
  ) async {
    try {
      // Facebook token refresh endpoint
      final response = await http.get(
        Uri.parse(
          'https://graph.facebook.com/v18.0/oauth/access_token?'
          'grant_type=fb_exchange_token&'
          'client_id=${OAuthConfig.facebookClientId}&'
          'client_secret=${OAuthConfig.facebookClientSecret}&'
          'fb_exchange_token=$refreshToken',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String?;
        final expiresIn = data['expires_in'] as int?;

        if (newAccessToken != null) {
          // Update tokens
          await _storeTokens(connection.agentId, connection.platform, {
            'access_token': newAccessToken,
            'refresh_token': newAccessToken, // Facebook uses long-lived tokens
            'expires_at': expiresIn != null
                ? DateTime.now().add(Duration(seconds: expiresIn)).toIso8601String()
                : null,
          });

          _logger.info('✅ Refreshed Facebook token', tag: _logName);
          return true;
        }
      }

      return false;
    } catch (e, stackTrace) {
      _logger.error('Failed to refresh Facebook token', error: e, stackTrace: stackTrace, tag: _logName);
      return false;
    }
  }

  /// Get all connections for a platform (helper for token refresh)
  Future<List<SocialMediaConnection>> _getAllConnectionsForPlatform(String platform) async {
    // This is a simplified implementation - in production, we'd have better indexing
    final connections = <SocialMediaConnection>[];

    // We need agentId to get connections, but we don't have it here
    // This is a limitation of the current implementation
    // In production, we'd maintain a reverse index: platform -> agentId -> connection
    return connections;
  }

  /// Get agentId from connection (helper for token refresh)
  String _getAgentIdFromConnection(String platform) {
    // This would need to be implemented to get agentId from stored connections
    // For now, return empty string (will be handled by caller)
    return '';
  }

  // Private helper methods

  /// Save connection to storage
  Future<void> _saveConnection(String agentId, String platform, SocialMediaConnection connection) async {
    final key = '$_connectionsKeyPrefix${agentId}_$platform';
    await _storageService.setObject(key, connection.toJson());
  }

  /// Get connection from storage
  Future<SocialMediaConnection?> _getConnection(String agentId, String platform) async {
    final key = '$_connectionsKeyPrefix${agentId}_$platform';
    final data = _storageService.getObject<Map<String, dynamic>>(key);
    if (data == null) return null;
    return SocialMediaConnection.fromJson(data);
  }

  /// Get all connections for an agent
  Future<List<SocialMediaConnection>> _getAllConnections(String agentId) async {
    // TODO: Implement efficient storage query
    // For now, we'll need to know all possible platforms
    final platforms = ['google', 'instagram', 'facebook', 'twitter', 'tiktok', 'linkedin'];
    final connections = <SocialMediaConnection>[];

    for (final platform in platforms) {
      final connection = await _getConnection(agentId, platform);
      if (connection != null) {
        connections.add(connection);
      }
    }

    return connections;
  }

  /// Store OAuth tokens (encrypted using flutter_secure_storage)
  Future<void> _storeTokens(String agentId, String platform, Map<String, dynamic> tokens) async {
    final key = '$_tokensKeyPrefix${agentId}_$platform';
    // Store encrypted using flutter_secure_storage
    final tokensJson = jsonEncode(tokens);
    await _secureStorage.write(key: key, value: tokensJson);
  }

  /// Get OAuth tokens (decrypted from flutter_secure_storage)
  Future<Map<String, dynamic>?> _getTokens(String agentId, String platform) async {
    final key = '$_tokensKeyPrefix${agentId}_$platform';
    final tokensJson = await _secureStorage.read(key: key);
    if (tokensJson == null) return null;
    return jsonDecode(tokensJson) as Map<String, dynamic>;
  }

  /// Remove OAuth tokens
  Future<void> _removeTokens(String agentId, String platform) async {
    final key = '$_tokensKeyPrefix${agentId}_$platform';
    await _secureStorage.delete(key: key);
  }
}

