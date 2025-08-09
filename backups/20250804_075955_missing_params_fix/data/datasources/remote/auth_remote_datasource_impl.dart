import 'package:spots/core/models/user.dart';
import 'package:spots/core/models/unified_models.dart';import 'package:spots/data/datasources/remote/auth_remote_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<User?> signIn(String email, String password) async {
    // Mock implementation
    return null;
  }

  @override
  Future<User?> signUp(String email, String password, String name) async {
    // Mock implementation
    return null;
  }

  @override
  Future<void> signOut() async {
    // Mock implementation
  }

  @override
  Future<User?> getCurrentUser() async {
    // Mock implementation
    return null;
  }

  @override
  Future<User?> updateUser(User user) async {
    // Mock implementation
    return user;
  }
}
