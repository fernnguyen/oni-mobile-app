import '../../../core/common/result.dart';
import '../../models/user_model.dart';

abstract class AuthDataSource {
  Future<Result<UserModel>> signInWithEmailAndPassword(
    String subdomain,
    String email,
    String password,
  );

  Future<Result<void>> signOut();

  Future<Result<UserModel?>> getCurrentUser();
}
