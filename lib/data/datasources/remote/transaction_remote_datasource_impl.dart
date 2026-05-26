import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/common/result.dart';
import '../../../core/constants/constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../models/ordered_product_model.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
import '../interfaces/transaction_datasource.dart';

class TransactionRemoteDatasourceImpl extends TransactionDatasource {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  TransactionRemoteDatasourceImpl({
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
  Future<Result<int>> createTransaction(TransactionModel transaction) async {
    try {
      final currentUserEmail = apiClient.supabaseClient.auth.currentUser?.email ?? 'Unknown';

      final res = await apiClient.post<Map<String, dynamic>>(
        '/api/shops/$shopId/orders',
        body: transaction.toBackendJson(shopId, currentUserEmail),
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      // Lấy id đơn hàng được tạo từ Backend NextJS ERP
      final createdId = res.data?['id'] ?? res.data?['order_id'];
      final intId = int.tryParse(createdId?.toString() ?? '') ?? transaction.id;

      return Result.success(data: intId);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateTransaction(TransactionModel transaction) async {
    try {
      final currentUserEmail = apiClient.supabaseClient.auth.currentUser?.email ?? 'Unknown';

      final res = await apiClient.put<void>(
        '/api/shops/$shopId/orders/${transaction.id}',
        body: transaction.toBackendJson(shopId, currentUserEmail),
      );

      if (res.isFailure) return Result.failure(error: res.error!);
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteTransaction(int id) async {
    try {
      final res = await apiClient.delete<void>(
        '/api/shops/$shopId/orders/$id',
      );
      if (res.isFailure) return Result.failure(error: res.error!);
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<TransactionModel?>> getTransaction(int id) async {
    try {
      final res = await apiClient.get<Map<String, dynamic>>(
        '/api/shops/$shopId/orders/$id',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (res.isFailure) return Result.failure(error: res.error!);
      if (res.data == null) return Result.success(data: null);

      final currentUserId = apiClient.supabaseClient.auth.currentUser?.id ?? '';
      final currentUserEmail = apiClient.supabaseClient.auth.currentUser?.email ?? '';

      final userModel = UserModel(
        id: currentUserId,
        email: currentUserEmail,
        name: currentUserEmail.split('@')[0],
      );

      // Tải các order items liên quan của order này
      final itemsRes = await apiClient.get<Map<String, dynamic>>(
        '/api/shops/$shopId/order-items?order_id=$id',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      final List<dynamic> itemsList = itemsRes.data?['data'] ?? [];
      final orderedProducts = itemsList.map((e) => OrderedProductModel.fromBackendJson(e)).toList();

      return Result.success(
        data: TransactionModel.fromBackendJson(res.data!, userModel, orderedProducts),
      );
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<TransactionModel>>> getAllUserTransactions(String userId) async {
    try {
      final res = await apiClient.get<Map<String, dynamic>>(
        '/api/shops/$shopId/orders?limit=2000',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      final currentUserEmail = apiClient.supabaseClient.auth.currentUser?.email ?? '';
      final userModel = UserModel(
        id: userId,
        email: currentUserEmail,
        name: currentUserEmail.split('@')[0],
      );

      final List<dynamic> ordersList = res.data?['data'] ?? [];

      // Tải song song tất cả các order-items của shop này
      final itemsRes = await apiClient.get<Map<String, dynamic>>(
        '/api/shops/$shopId/order-items?limit=5000',
        fromJson: (json) => json as Map<String, dynamic>,
      );
      final List<dynamic> allItemsList = itemsRes.data?['data'] ?? [];
      final itemsByOrderId = allItemsList.fold<Map<String, List<OrderedProductModel>>>({}, (acc, item) {
        final orderId = item['order_id']?.toString() ?? '';
        acc[orderId] = acc[orderId] ?? [];
        acc[orderId]!.add(OrderedProductModel.fromBackendJson(item));
        return acc;
      });

      final transactions = ordersList.map((order) {
        final orderIdStr = order['id']?.toString() ?? '';
        final items = itemsByOrderId[orderIdStr] ?? <OrderedProductModel>[];
        return TransactionModel.fromBackendJson(order, userModel, items);
      }).toList();

      return Result.success(data: transactions);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<TransactionModel>>> getUserTransactions(
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
        '/api/shops/$shopId/orders?$queryParams',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      final currentUserEmail = apiClient.supabaseClient.auth.currentUser?.email ?? '';
      final userModel = UserModel(
        id: userId,
        email: currentUserEmail,
        name: currentUserEmail.split('@')[0],
      );

      final List<dynamic> ordersList = res.data?['data'] ?? [];

      // Tải song song tất cả các order-items của shop này
      final itemsRes = await apiClient.get<Map<String, dynamic>>(
        '/api/shops/$shopId/order-items?limit=5000',
        fromJson: (json) => json as Map<String, dynamic>,
      );
      final List<dynamic> allItemsList = itemsRes.data?['data'] ?? [];

      final Map<String, List<OrderedProductModel>> itemsByOrderId = {};
      for (final item in allItemsList) {
        final orderId = item['order_id']?.toString() ?? '';
        itemsByOrderId[orderId] = itemsByOrderId[orderId] ?? [];
        itemsByOrderId[orderId]!.add(OrderedProductModel.fromBackendJson(item));
      }

      final transactions = ordersList.map((order) {
        final orderIdStr = order['id']?.toString() ?? '';
        final items = itemsByOrderId[orderIdStr] ?? <OrderedProductModel>[];
        return TransactionModel.fromBackendJson(order, userModel, items);
      }).toList();

      return Result.success(data: transactions);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
