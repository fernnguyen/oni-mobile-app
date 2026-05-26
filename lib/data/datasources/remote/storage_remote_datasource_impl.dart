import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/common/result.dart';
import '../../../core/constants/constants.dart';
import '../../../core/services/network/api_client.dart';
import '../interfaces/storage_datasource.dart';

class StorageRemoteDataSourceImpl implements StorageDataSource {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  StorageRemoteDataSourceImpl({
    required this.apiClient,
    required this.sharedPreferences,
  });

  /// Lấy mã shopId hiện hành từ SharedPreferences
  String get shopId {
    final id = sharedPreferences.getString(Constants.selectedShopIdKey) ?? '';
    if (id.isEmpty) {
      throw Exception('Chưa chọn chi nhánh làm việc (shopId).');
    }
    return id;
  }

  Future<Result<String>> _uploadFile(String imgPath, String targetId) async {
    try {
      // 1. Lấy Pre-signed URL từ NextJS ERP
      final res = await apiClient.get<Map<String, dynamic>>(
        '/api/shops/$shopId/products/$targetId/upload-url',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      final uploadUrl = res.data?['uploadUrl']?.toString() ?? '';
      final publicUrl = res.data?['publicUrl']?.toString() ?? '';

      if (uploadUrl.isEmpty || publicUrl.isEmpty) {
        return Result.failure(
          error: 'Không nhận được đường dẫn tải ảnh lên từ máy chủ.',
        );
      }

      // 2. Đọc file hình ảnh dưới dạng bytes
      final file = File(imgPath);
      if (!await file.exists()) {
        return Result.failure(
          error: 'Tệp tin hình ảnh không tồn tại: $imgPath',
        );
      }
      final bytes = await file.readAsBytes();

      // 3. Thực hiện PUT trực tiếp lên Cloudflare R2
      final uploadResponse = await http.put(
        Uri.parse(uploadUrl),
        headers: {
          'Content-Type': 'image/webp',
        },
        body: bytes,
      );

      if (uploadResponse.statusCode >= 200 && uploadResponse.statusCode < 300) {
        return Result.success(data: publicUrl);
      } else {
        return Result.failure(
          error:
              'Lỗi tải ảnh lên Cloudflare R2 (${uploadResponse.statusCode}): ${uploadResponse.body}',
        );
      }
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<String>> uploadUserPhoto(String imgPath) async {
    final currentUser = apiClient.supabaseClient.auth.currentUser;
    final userId = currentUser?.id ?? 'temp_user';
    final targetId = 'profile_$userId';
    return _uploadFile(imgPath, targetId);
  }

  @override
  Future<Result<String>> uploadProductImage(String imgPath) async {
    // Vì khi tạo mới sản phẩm chưa có ID chính thức, ta sinh mã duy nhất bằng timestamp
    final tempProductId = 'prod_${DateTime.now().millisecondsSinceEpoch}';
    return _uploadFile(imgPath, tempProductId);
  }
}
