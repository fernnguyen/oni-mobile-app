// lib/features/auth/domain/repositories/auth_repository.dart

import '../../../../core/common/result.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> signInWithEmailAndPassword(
    String subdomain,
    String email,
    String password,
  );

  Future<Result<void>> signOut();

  Future<Result<UserEntity?>> getCurrentUser();
}
