import 'package:spots/core/models/user.dart' as local;
import 'package:spots/data/datasources/remote/auth_remote_datasource.dart';
import 'package:spots_network/spots_network.dart';
import 'package:spots_core/spots_core.dart' as core;
import 'package:spots/injection_container.dart' as di;

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthBackend get _auth => di.sl<AuthBackend>();
  @override
  Future<local.User?> signIn(String email, String password) async {
    final coreUser = await _auth.signInWithEmailPassword(email, password);
    return coreUser == null ? null : _toLocalUser(coreUser);
  }

  @override
  Future<local.User?> signUp(String email, String password, String name) async {
    final coreUser = await _auth.registerWithEmailPassword(email, password, name);
    return coreUser == null ? null : _toLocalUser(coreUser);
  }

  @override
  Future<void> signOut() async => _auth.signOut();

  @override
  Future<local.User?> getCurrentUser() async {
    final coreUser = await _auth.getCurrentUser();
    return coreUser == null ? null : _toLocalUser(coreUser);
  }

  @override
  Future<local.User?> updateUser(local.User user) async {
    // Fast path: return local user for now to avoid cross-model conversion.
    // Backend profile update can be wired later if needed.
    return user;
  }

  local.User _toLocalUser(core.User u) {
    final role = _mapRole(u.role);
    return local.User(
      id: u.id,
      email: u.email,
      name: u.name,
      displayName: u.displayName,
      role: role,
      createdAt: u.createdAt,
      updatedAt: u.updatedAt,
      isOnline: u.isOnline,
    );
  }

  local.UserRole _mapRole(core.UserRole r) {
    switch (r) {
      case core.UserRole.admin:
        return local.UserRole.admin;
      default:
        return local.UserRole.user;
    }
  }
}
