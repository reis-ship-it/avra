import 'package:supabase_flutter/supabase_flutter.dart';
import '../../interfaces/auth_backend.dart';
import '../../models/api_response.dart';

/// Supabase authentication backend implementation
class SupabaseAuthBackend implements AuthBackend {
  final SupabaseClient _client;
  Map<String, dynamic> _config = {};
  bool _isInitialized = false;
  
  SupabaseAuthBackend(this._client);
  
  @override
  bool get isInitialized => _isInitialized;
  
  @override
  Future<void> initialize(Map<String, dynamic> config) async {
    _config = Map.unmodifiable(config);
    _isInitialized = true;
  }
  
  @override
  Future<void> dispose() async {
    _isInitialized = false;
  }
  
  @override
  Future<ApiResponse<User>> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        final user = _convertSupabaseUser(response.user!);
        return ApiResponse.success(user);
      } else {
        return ApiResponse.error('Sign in failed: No user returned');
      }
      
    } catch (e) {
      return ApiResponse.error('Sign in failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<User>> signUp(String email, String password, String name) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      
      if (response.user != null) {
        final user = _convertSupabaseUser(response.user!);
        return ApiResponse.success(user);
      } else {
        return ApiResponse.error('Sign up failed: No user returned');
      }
      
    } catch (e) {
      return ApiResponse.error('Sign up failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<void>> signOut() async {
    try {
      await _client.auth.signOut();
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error('Sign out failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<User?>> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user != null) {
        final convertedUser = _convertSupabaseUser(user);
        return ApiResponse.success(convertedUser);
      }
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error('Get current user failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<User>> updateUser(User user) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(
          email: user.email,
          data: {
            'name': user.name,
            'updated_at': DateTime.now().toIso8601String(),
          },
        ),
      );
      
      if (response.user != null) {
        final updatedUser = _convertSupabaseUser(response.user!);
        return ApiResponse.success(updatedUser);
      } else {
        return ApiResponse.error('Update user failed: No user returned');
      }
      
    } catch (e) {
      return ApiResponse.error('Update user failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<void>> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error('Reset password failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<User>> signInWithProvider(String provider) async {
    try {
      final response = await _client.auth.signInWithOAuth(
        Provider.values.firstWhere((p) => p.name == provider),
        redirectTo: 'io.supabase.flutter://login-callback/',
      );
      
      // Note: OAuth flow requires additional handling for mobile
      // This is a simplified implementation
      return ApiResponse.error('OAuth sign in not fully implemented yet');
      
    } catch (e) {
      return ApiResponse.error('OAuth sign in failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<String>> getAccessToken() async {
    try {
      final session = _client.auth.currentSession;
      if (session != null) {
        return ApiResponse.success(session.accessToken);
      }
      return ApiResponse.error('No active session');
    } catch (e) {
      return ApiResponse.error('Get access token failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<String>> getRefreshToken() async {
    try {
      final session = _client.auth.currentSession;
      if (session != null) {
        return ApiResponse.success(session.refreshToken);
      }
      return ApiResponse.error('No active session');
    } catch (e) {
      return ApiResponse.error('Get refresh token failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<bool>> isAuthenticated() async {
    try {
      final user = _client.auth.currentUser;
      return ApiResponse.success(user != null);
    } catch (e) {
      return ApiResponse.error('Check authentication failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<void>> enableMFA() async {
    try {
      // Supabase MFA implementation would go here
      return ApiResponse.error('MFA not implemented yet');
    } catch (e) {
      return ApiResponse.error('Enable MFA failed: $e');
    }
  }
  
  @override
  Future<ApiResponse<bool>> verifyMFA(String code) async {
    try {
      // Supabase MFA verification would go here
      return ApiResponse.error('MFA verification not implemented yet');
    } catch (e) {
      return ApiResponse.error('MFA verification failed: $e');
    }
  }
  
  @override
  Stream<User?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      return user != null ? _convertSupabaseUser(user) : null;
    });
  }
  
  /// Convert Supabase User to our User model
  User _convertSupabaseUser(User supabaseUser) {
    return User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      name: supabaseUser.userMetadata?['name'] as String? ?? '',
      createdAt: supabaseUser.createdAt,
      updatedAt: supabaseUser.updatedAt,
      isEmailVerified: supabaseUser.emailConfirmedAt != null,
      lastSignInAt: supabaseUser.lastSignInAt,
    );
  }
}

/// User model for authentication
class User {
  final String id;
  final String email;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isEmailVerified;
  final DateTime? lastSignInAt;
  
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.createdAt,
    this.updatedAt,
    this.isEmailVerified = false,
    this.lastSignInAt,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'lastSignInAt': lastSignInAt?.toIso8601String(),
    };
  }
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String) 
        : null,
      updatedAt: json['updatedAt'] != null 
        ? DateTime.parse(json['updatedAt'] as String) 
        : null,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      lastSignInAt: json['lastSignInAt'] != null 
        ? DateTime.parse(json['lastSignInAt'] as String) 
        : null,
    );
  }
}
