import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/common/result.dart';
import '../../models/user_model.dart';
import '../interfaces/auth_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthDataSource {
  final supabase.SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({
    required this.supabaseClient,
  });

  @override
  Future<Result<UserModel>> signInWithEmailAndPassword(
    String subdomain,
    String email,
    String password,
  ) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return Result.failure(error: 'Dữ liệu người dùng trống sau khi đăng nhập.');
      }

      return Result.success(data: UserModel.fromSupabaseUser(response.user!));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await supabaseClient.auth.signOut();
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<UserModel?>> getCurrentUser() async {
    try {
      final supabaseUser = supabaseClient.auth.currentUser;
      return Result.success(
        data: supabaseUser != null ? UserModel.fromSupabaseUser(supabaseUser) : null,
      );
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
