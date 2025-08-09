import "dart:developer" as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spots/data/datasources/local/auth_local_datasource.dart';
import 'package:spots/core/models/user.dart';
import 'dart:convert';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'user_token';
  static const String _isOfflineKey = 'is_offline_mode';
  static const String _onboardingKey = 'is_onboarding_completed';

  @override
  Future<User?> signIn(String email, String password) async {
    // For local implementation, we just return the saved user if credentials match
    final user = await getUser();
    if (user != null && user.email == email) {
      return user;
    }
    return null;
  }

  @override
  Future<User?> signUp(String email, String password, User user) async {
    // For local implementation, we just save the user
    await saveUser(user);
    return user;
  }

  @override
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;

    try {
      return User.fromJson(jsonDecode(userJson));
    } catch (e) {
      developer.log('Error parsing user from local storage: $e', name: 'AuthLocalDataSource');
      return null;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    return await getUser();
  }

  @override
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  @override
  Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  Future<void> saveUserToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> setOfflineMode(bool isOffline) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isOfflineKey, isOffline);
  }

  Future<bool> isOfflineMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isOfflineKey) ?? false;
  }
}
