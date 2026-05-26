import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/common/result.dart';
import '../../models/user_model.dart';
import '../interfaces/user_datasource.dart';
import '../../../core/services/network/api_client.dart';

class UserRemoteDatasourceImpl extends UserDatasource {
  final supabase.SupabaseClient supabaseClient;
  final ApiClient apiClient;

  UserRemoteDatasourceImpl({
    required this.supabaseClient,
    required this.apiClient,
  });

  @override
  Future<Result<String>> createUser(UserModel user) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser != null && currentUser.id == user.id) {
        await supabaseClient.auth.updateUser(
          supabase.UserAttributes(
            data: {
              'name': user.name,
              'gender': user.gender,
              'birthdate': user.birthdate,
              'avatar_url': user.imageUrl,
            },
          ),
        );
      }
      return Result.success(data: user.id);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateUser(UserModel user) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser != null && currentUser.id == user.id) {
        await supabaseClient.auth.updateUser(
          supabase.UserAttributes(
            data: {
              'name': user.name,
              'gender': user.gender,
              'birthdate': user.birthdate,
              'avatar_url': user.imageUrl,
            },
          ),
        );
      }
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteUser(String id) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser != null && currentUser.id == id) {
        // Clients typically cannot delete themselves from standard SDK without admin/service_role API.
        // We will sign out the user, and Giai Đoạn 4 will connect this to `/api/users/delete` endpoint.
        await supabaseClient.auth.signOut();
      }
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<UserModel?>> getUser(String id) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser != null && currentUser.id == id) {
        final result = await apiClient.get<UserModel?>(
          '/api/auth/me',
          fromJson: (json) => json['user'] != null ? UserModel.fromJson(json['user']) : null,
        );
        return result;
      }

      // Fallback for other users (not typically queried in POS client)
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
