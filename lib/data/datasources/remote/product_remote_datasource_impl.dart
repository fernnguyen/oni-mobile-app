import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/common/result.dart';
import '../../../core/constants/constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../models/product_model.dart';
import '../interfaces/product_datasource.dart';

class ProductRemoteDatasourceImpl extends ProductDatasource {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  ProductRemoteDatasourceImpl({
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

  @override
  Future<Result<int>> createProduct(ProductModel product) async {
    try {
      final res = await apiClient.post<Map<String, dynamic>>(
        '/api/shops/$shopId/products',
        body: product.toBackendJson(),
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      // Lấy id trả về của sản phẩm (NextJS ERP trả về dạng string id)
      final createdId = res.data?['product_id'] ?? res.data?['id'];
      final intId = int.tryParse(createdId?.toString() ?? '') ?? product.id;

      return Result.success(data: intId);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateProduct(ProductModel product) async {
    try {
      final res = await apiClient.put<void>(
        '/api/shops/$shopId/products/${product.id}',
        body: product.toBackendJson(),
      );
      if (res.isFailure) return Result.failure(error: res.error!);
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteProduct(int id) async {
    try {
      final res = await apiClient.delete<void>(
        '/api/shops/$shopId/products/$id',
      );
      if (res.isFailure) return Result.failure(error: res.error!);
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<ProductModel?>> getProduct(int id) async {
    try {
      final res = await apiClient.get<Map<String, dynamic>>(
        '/api/shops/$shopId/products/$id',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (res.isFailure) return Result.failure(error: res.error!);
      if (res.data == null) return Result.success(data: null);

      final currentUserId = apiClient.supabaseClient.auth.currentUser?.id ?? '';
      return Result.success(
        data: ProductModel.fromBackendJson(res.data!, currentUserId),
      );
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ProductModel>>> getAllUserProducts(String userId) async {
    try {
      // Gọi API tải tối đa 2000 sản phẩm phục vụ offline sync/cache
      final res = await apiClient.get<Map<String, dynamic>>(
        '/api/shops/$shopId/products?limit=2000',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      final List<dynamic> list = res.data?['data'] ?? [];
      final products = list.map((e) => ProductModel.fromBackendJson(e, userId)).toList();

      return Result.success(data: products);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ProductModel>>> getUserProducts(
    String userId, {
    String orderBy = 'createdAt',
    String sortBy = 'DESC',
    int limit = 10,
    int? offset,
    String? contains,
  }) async {
    try {
      final page = offset != null ? (offset / limit).toInt() + 1 : 1;

      final queryParams = Uri(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (contains != null && contains.isNotEmpty) 'search': contains,
        },
      ).query;

      final res = await apiClient.get<Map<String, dynamic>>(
        '/api/shops/$shopId/products?$queryParams',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      final List<dynamic> list = res.data?['data'] ?? [];
      final products = list.map((e) => ProductModel.fromBackendJson(e, userId)).toList();

      return Result.success(data: products);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
