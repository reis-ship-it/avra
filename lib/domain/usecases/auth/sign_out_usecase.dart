import 'package:spots/domain/repositories/auth_repository.dart';
import 'package:spots/core/models/unified_models.dart';
class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<void> call() async {
    await repository.signOut();
  }
}
