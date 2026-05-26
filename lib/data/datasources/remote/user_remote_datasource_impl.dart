import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/common/result.dart';
import '../../models/user_model.dart';
import '../interfaces/user_datasource.dart';

class UserRemoteDatasourceImpl extends UserDatasource {
  final supabase.SupabaseClient supabaseClient;

  UserRemoteDatasourceImpl(this.supabaseClient);

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
      try {
        await supabaseClient.from('tenant_user_profiles').upsert({
          'user_id': user.id,
          'display_name': user.name,
          'login_email': user.email ?? '',
        });
      } catch (_) {
        // RLS might block client direct inserts
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
      try {
        await supabaseClient
            .from('tenant_user_profiles')
            .update({'display_name': user.name})
            .eq('user_id', user.id);
      } catch (_) {
        // RLS might block client direct updates
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
        final profile = await supabaseClient
            .from('tenant_user_profiles')
            .select()
            .eq('user_id', id)
            .maybeSingle();

        if (profile != null) {
          return Result.success(
            data: UserModel(
              id: id,
              email: profile['login_email'] ?? currentUser.email,
              name:
                  profile['display_name'] ?? currentUser.userMetadata?['name'],
              phone: currentUser.phone ?? currentUser.userMetadata?['phone'],
              gender: currentUser.userMetadata?['gender'],
              birthdate: currentUser.userMetadata?['birthdate'],
              imageUrl: currentUser.userMetadata?['avatar_url'],
              createdAt: profile['created_at'] ?? currentUser.createdAt,
              updatedAt: currentUser.updatedAt,
            ),
          );
        }
        return Result.success(data: UserModel.fromSupabaseUser(currentUser));
      }

      final profile = await supabaseClient
          .from('tenant_user_profiles')
          .select()
          .eq('user_id', id)
          .maybeSingle();

      if (profile == null) {
        return Result.success(data: null);
      }

      return Result.success(
        data: UserModel(
          id: id,
          email: profile['login_email'],
          name: profile['display_name'],
          createdAt: profile['created_at'],
          updatedAt: profile['created_at'],
        ),
      );
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
