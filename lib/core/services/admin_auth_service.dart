import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Admin Authentication Service
/// Handles god-mode admin login and session management
/// OUR_GUTS.md: "Privacy and Control Are Non-Negotiable" - Admin access requires strict authentication
class AdminAuthService {
  static const String _logName = 'AdminAuthService';
  static const String _adminSessionKey = 'admin_session';
  static const String _adminLoginAttemptsKey = 'admin_login_attempts';
  static const String _adminLockoutKey = 'admin_lockout_until';
  
  final SharedPreferences _prefs;
  
  // Maximum login attempts before lockout
  static const int _maxLoginAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 15);
  
  AdminAuthService(this._prefs);
  
  /// Authenticate admin with god-mode credentials
  /// Returns true if authentication successful
  Future<AdminAuthResult> authenticate({
    required String username,
    required String password,
    String? twoFactorCode,
  }) async {
    try {
      // Check for lockout
      final lockoutUntil = _prefs.getInt(_adminLockoutKey);
      if (lockoutUntil != null && DateTime.now().millisecondsSinceEpoch < lockoutUntil) {
        final remaining = Duration(milliseconds: lockoutUntil - DateTime.now().millisecondsSinceEpoch);
        return AdminAuthResult.lockedOut(remaining);
      }
      
      // Verify credentials (in production, this would check against secure backend)
      final isValid = await _verifyCredentials(username, password, twoFactorCode);
      
      if (!isValid) {
        // Increment failed attempts
        final attempts = _prefs.getInt(_adminLoginAttemptsKey) ?? 0;
        final newAttempts = attempts + 1;
        await _prefs.setInt(_adminLoginAttemptsKey, newAttempts);
        
        // Lockout if too many attempts
        if (newAttempts >= _maxLoginAttempts) {
          final lockoutUntil = DateTime.now().add(_lockoutDuration).millisecondsSinceEpoch;
          await _prefs.setInt(_adminLockoutKey, lockoutUntil);
          return AdminAuthResult.lockedOut(_lockoutDuration);
        }
        
        return AdminAuthResult.failed(remainingAttempts: _maxLoginAttempts - newAttempts);
      }
      
      // Reset failed attempts on success
      await _prefs.remove(_adminLoginAttemptsKey);
      await _prefs.remove(_adminLockoutKey);
      
      // Create admin session
      final session = AdminSession(
        username: username,
        loginTime: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 8)),
        accessLevel: AdminAccessLevel.godMode,
        permissions: AdminPermissions.all(),
      );
      
      await _saveSession(session);
      
      developer.log('Admin authenticated: $username', name: _logName);
      return AdminAuthResult.success(session);
    } catch (e) {
      developer.log('Error during admin authentication: $e', name: _logName);
      return AdminAuthResult.error(e.toString());
    }
  }
  
  /// Verify admin credentials
  /// In production, this would call a secure backend API
  Future<bool> _verifyCredentials(String username, String password, String? twoFactorCode) async {
    // Hash password for comparison
    final passwordHash = sha256.convert(utf8.encode(password)).toString();
    
    // In production, this would check against a secure database
    // For now, using environment variables or secure config
    // TODO: Implement secure credential verification via backend API
    
    // Placeholder: Check against expected hash
    // In real implementation, this should be server-side only
    final expectedHash = _getExpectedPasswordHash(username);
    
    if (expectedHash == null) {
      return false; // User not found
    }
    
    if (passwordHash != expectedHash) {
      return false; // Wrong password
    }
    
    // If 2FA is required, verify code
    if (twoFactorCode != null && !_verifyTwoFactorCode(username, twoFactorCode)) {
      return false;
    }
    
    return true;
  }
  
  /// Get expected password hash for username
  /// In production, this would be fetched from secure backend
  String? _getExpectedPasswordHash(String username) {
    // TODO: Fetch from secure backend or environment
    // For now, return null (no default credentials)
    return null;
  }
  
  /// Verify 2FA code
  bool _verifyTwoFactorCode(String username, String code) {
    // TODO: Implement 2FA verification
    // For now, return true if code is provided (placeholder)
    return code.isNotEmpty;
  }
  
  /// Get current admin session
  AdminSession? getCurrentSession() {
    try {
      final sessionJson = _prefs.getString(_adminSessionKey);
      if (sessionJson == null) return null;
      
      final sessionMap = jsonDecode(sessionJson) as Map<String, dynamic>;
      return AdminSession.fromJson(sessionMap);
    } catch (e) {
      developer.log('Error loading admin session: $e', name: _logName);
      return null;
    }
  }
  
  /// Check if admin is currently authenticated
  bool isAuthenticated() {
    final session = getCurrentSession();
    if (session == null) return false;
    
    // Check if session expired
    if (DateTime.now().isAfter(session.expiresAt)) {
      logout();
      return false;
    }
    
    return true;
  }
  
  /// Check if admin has specific permission
  bool hasPermission(AdminPermission permission) {
    final session = getCurrentSession();
    if (session == null) return false;
    
    return session.permissions.hasPermission(permission);
  }
  
  /// Logout admin
  Future<void> logout() async {
    await _prefs.remove(_adminSessionKey);
    developer.log('Admin logged out', name: _logName);
  }
  
  /// Save admin session
  Future<void> _saveSession(AdminSession session) async {
    final sessionJson = jsonEncode(session.toJson());
    await _prefs.setString(_adminSessionKey, sessionJson);
  }
  
  /// Extend session
  Future<void> extendSession() async {
    final session = getCurrentSession();
    if (session != null) {
      final extendedSession = session.copyWith(
        expiresAt: DateTime.now().add(const Duration(hours: 8)),
      );
      await _saveSession(extendedSession);
    }
  }
}

/// Admin session data
class AdminSession {
  final String username;
  final DateTime loginTime;
  final DateTime expiresAt;
  final AdminAccessLevel accessLevel;
  final AdminPermissions permissions;
  
  AdminSession({
    required this.username,
    required this.loginTime,
    required this.expiresAt,
    required this.accessLevel,
    required this.permissions,
  });
  
  AdminSession copyWith({
    String? username,
    DateTime? loginTime,
    DateTime? expiresAt,
    AdminAccessLevel? accessLevel,
    AdminPermissions? permissions,
  }) {
    return AdminSession(
      username: username ?? this.username,
      loginTime: loginTime ?? this.loginTime,
      expiresAt: expiresAt ?? this.expiresAt,
      accessLevel: accessLevel ?? this.accessLevel,
      permissions: permissions ?? this.permissions,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'loginTime': loginTime.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'accessLevel': accessLevel.name,
      'permissions': permissions.toJson(),
    };
  }
  
  factory AdminSession.fromJson(Map<String, dynamic> json) {
    return AdminSession(
      username: json['username'] as String,
      loginTime: DateTime.parse(json['loginTime'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      accessLevel: AdminAccessLevel.values.firstWhere(
        (e) => e.name == json['accessLevel'],
        orElse: () => AdminAccessLevel.standard,
      ),
      permissions: AdminPermissions.fromJson(json['permissions'] as Map<String, dynamic>),
    );
  }
}

/// Admin access levels
enum AdminAccessLevel {
  standard,
  elevated,
  godMode,
}

/// Admin permissions
class AdminPermissions {
  final bool viewUserData;
  final bool viewAIData;
  final bool viewCommunications;
  final bool viewUserProgress;
  final bool viewUserPredictions;
  final bool viewBusinessAccounts;
  final bool viewRealTimeData;
  final bool modifyUserData;
  final bool modifyAIData;
  final bool modifyBusinessData;
  final bool accessAuditLogs;
  
  AdminPermissions({
    this.viewUserData = false,
    this.viewAIData = false,
    this.viewCommunications = false,
    this.viewUserProgress = false,
    this.viewUserPredictions = false,
    this.viewBusinessAccounts = false,
    this.viewRealTimeData = false,
    this.modifyUserData = false,
    this.modifyAIData = false,
    this.modifyBusinessData = false,
    this.accessAuditLogs = false,
  });
  
  factory AdminPermissions.all() {
    return AdminPermissions(
      viewUserData: true,
      viewAIData: true,
      viewCommunications: true,
      viewUserProgress: true,
      viewUserPredictions: true,
      viewBusinessAccounts: true,
      viewRealTimeData: true,
      modifyUserData: true,
      modifyAIData: true,
      modifyBusinessData: true,
      accessAuditLogs: true,
    );
  }
  
  bool hasPermission(AdminPermission permission) {
    switch (permission) {
      case AdminPermission.viewUserData:
        return viewUserData;
      case AdminPermission.viewAIData:
        return viewAIData;
      case AdminPermission.viewCommunications:
        return viewCommunications;
      case AdminPermission.viewUserProgress:
        return viewUserProgress;
      case AdminPermission.viewUserPredictions:
        return viewUserPredictions;
      case AdminPermission.viewBusinessAccounts:
        return viewBusinessAccounts;
      case AdminPermission.viewRealTimeData:
        return viewRealTimeData;
      case AdminPermission.modifyUserData:
        return modifyUserData;
      case AdminPermission.modifyAIData:
        return modifyAIData;
      case AdminPermission.modifyBusinessData:
        return modifyBusinessData;
      case AdminPermission.accessAuditLogs:
        return accessAuditLogs;
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'viewUserData': viewUserData,
      'viewAIData': viewAIData,
      'viewCommunications': viewCommunications,
      'viewUserProgress': viewUserProgress,
      'viewUserPredictions': viewUserPredictions,
      'viewBusinessAccounts': viewBusinessAccounts,
      'viewRealTimeData': viewRealTimeData,
      'modifyUserData': modifyUserData,
      'modifyAIData': modifyAIData,
      'modifyBusinessData': modifyBusinessData,
      'accessAuditLogs': accessAuditLogs,
    };
  }
  
  factory AdminPermissions.fromJson(Map<String, dynamic> json) {
    return AdminPermissions(
      viewUserData: json['viewUserData'] as bool? ?? false,
      viewAIData: json['viewAIData'] as bool? ?? false,
      viewCommunications: json['viewCommunications'] as bool? ?? false,
      viewUserProgress: json['viewUserProgress'] as bool? ?? false,
      viewUserPredictions: json['viewUserPredictions'] as bool? ?? false,
      viewBusinessAccounts: json['viewBusinessAccounts'] as bool? ?? false,
      viewRealTimeData: json['viewRealTimeData'] as bool? ?? false,
      modifyUserData: json['modifyUserData'] as bool? ?? false,
      modifyAIData: json['modifyAIData'] as bool? ?? false,
      modifyBusinessData: json['modifyBusinessData'] as bool? ?? false,
      accessAuditLogs: json['accessAuditLogs'] as bool? ?? false,
    );
  }
}

/// Admin permission types
enum AdminPermission {
  viewUserData,
  viewAIData,
  viewCommunications,
  viewUserProgress,
  viewUserPredictions,
  viewBusinessAccounts,
  viewRealTimeData,
  modifyUserData,
  modifyAIData,
  modifyBusinessData,
  accessAuditLogs,
}

/// Admin authentication result
class AdminAuthResult {
  final bool success;
  final AdminSession? session;
  final String? error;
  final bool lockedOut;
  final Duration? lockoutRemaining;
  final int? remainingAttempts;
  
  AdminAuthResult({
    required this.success,
    this.session,
    this.error,
    this.lockedOut = false,
    this.lockoutRemaining,
    this.remainingAttempts,
  });
  
  factory AdminAuthResult.success(AdminSession session) {
    return AdminAuthResult(success: true, session: session);
  }
  
  factory AdminAuthResult.failed({String? error, int? remainingAttempts}) {
    return AdminAuthResult(
      success: false,
      error: error ?? 'Invalid credentials',
      remainingAttempts: remainingAttempts,
    );
  }
  
  factory AdminAuthResult.lockedOut(Duration remaining) {
    return AdminAuthResult(
      success: false,
      lockedOut: true,
      lockoutRemaining: remaining,
      error: 'Account locked. Try again in ${remaining.inMinutes} minutes.',
    );
  }
  
  factory AdminAuthResult.error(String error) {
    return AdminAuthResult(success: false, error: error);
  }
}

