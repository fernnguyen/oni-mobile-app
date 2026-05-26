import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'params/no_param.dart';

class SignInParams {
  final String subdomain;
  final String email;
  final String password;

  SignInParams({
    required this.subdomain,
    required this.email,
    required this.password,
  });
}

class SignInWithEmailAndPasswordUsecase extends Usecase<Result, SignInParams> {
  SignInWithEmailAndPasswordUsecase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<UserEntity?>> call(SignInParams params) async =>
      _authRepository.signInWithEmailAndPassword(params.subdomain, params.email, params.password);
}

class SignOutUsecase extends Usecase<Result, NoParam> {
  SignOutUsecase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<void>> call(NoParam params) async => _authRepository.signOut();
}

class GetCurrentUserUsecase extends Usecase<Result, NoParam> {
  GetCurrentUserUsecase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<UserEntity?>> call(NoParam params) async => _authRepository.getCurrentUser();
}
