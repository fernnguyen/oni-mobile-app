import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/connectivity/ping_service.dart';
import '../../core/services/database/database_service.dart';
import '../../core/services/info/device_info_service.dart';
import '../../core/services/logger/error_logger_service.dart';
import '../../core/services/network/api_client.dart';
import '../../core/services/printer/printer_service.dart';
import '../../data/datasources/local/product_local_datasource_impl.dart';
import '../../data/datasources/local/queued_action_local_datasource_impl.dart';
import '../../data/datasources/local/transaction_local_datasource_impl.dart';
import '../../data/datasources/local/user_local_datasource_impl.dart';
import '../../data/datasources/remote/auth_remote_datasource_impl.dart';
import '../../data/datasources/remote/product_remote_datasource_impl.dart';
import '../../data/datasources/remote/storage_remote_datasource_impl.dart';
import '../../data/datasources/remote/transaction_remote_datasource_impl.dart';
import '../../data/datasources/remote/user_remote_datasource_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/queued_action_repository_impl.dart';
import '../../data/repositories/storage_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/queued_action_repository.dart';
import '../../domain/repositories/storage_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../routes/app_routes.dart';

// Startup overrides
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden at app startup.',
  ),
);

// Third parties
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);
final deviceInfoPluginProvider = Provider<DeviceInfoPlugin>(
  (ref) => DeviceInfoPlugin(),
);

// Routes
final appRoutesProvider = Provider<AppRoutes>((ref) => AppRoutes(ref));

// Services
final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => DatabaseService.instance,
);
final pingServiceProvider = Provider<PingService>((ref) => PingService());
final deviceInfoServiceProvider = Provider<DeviceInfoService>(
  (ref) => DeviceInfoService(ref.watch(deviceInfoPluginProvider)),
);
final errorLoggerServiceProvider = Provider<ErrorLoggerService>(
  (ref) => ErrorLoggerService(),
);
final printerServiceProvider = Provider<PrinterService>(
  (ref) => PrinterService(ref.watch(sharedPreferencesProvider)),
);
final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(
    sharedPreferences: ref.watch(sharedPreferencesProvider),
    supabaseClient: ref.watch(supabaseClientProvider),
  ),
);

// Datasources
// Local Datasources
final productLocalDatasourceProvider = Provider<ProductLocalDatasourceImpl>(
  (ref) => ProductLocalDatasourceImpl(ref.watch(databaseServiceProvider)),
);
final transactionLocalDatasourceProvider =
    Provider<TransactionLocalDatasourceImpl>(
      (ref) =>
          TransactionLocalDatasourceImpl(ref.watch(databaseServiceProvider)),
    );
final userLocalDatasourceProvider = Provider<UserLocalDatasourceImpl>(
  (ref) => UserLocalDatasourceImpl(ref.watch(databaseServiceProvider)),
);
final queuedActionLocalDatasourceProvider =
    Provider<QueuedActionLocalDatasourceImpl>(
      (ref) =>
          QueuedActionLocalDatasourceImpl(ref.watch(databaseServiceProvider)),
    );

// Remote Datasources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSourceImpl>(
  (ref) => AuthRemoteDataSourceImpl(
    supabaseClient: ref.watch(supabaseClientProvider),
  ),
);
final storageRemoteDataSourceProvider = Provider<StorageRemoteDataSourceImpl>(
  (ref) => StorageRemoteDataSourceImpl(
    apiClient: ref.watch(apiClientProvider),
    sharedPreferences: ref.watch(sharedPreferencesProvider),
  ),
);
final productRemoteDatasourceProvider = Provider<ProductRemoteDatasourceImpl>(
  (ref) => ProductRemoteDatasourceImpl(
    apiClient: ref.watch(apiClientProvider),
    sharedPreferences: ref.watch(sharedPreferencesProvider),
  ),
);
final transactionRemoteDatasourceProvider =
    Provider<TransactionRemoteDatasourceImpl>(
      (ref) => TransactionRemoteDatasourceImpl(
        apiClient: ref.watch(apiClientProvider),
        sharedPreferences: ref.watch(sharedPreferencesProvider),
      ),
    );
final userRemoteDatasourceProvider = Provider<UserRemoteDatasourceImpl>(
  (ref) => UserRemoteDatasourceImpl(
    supabaseClient: ref.watch(supabaseClientProvider),
    apiClient: ref.watch(apiClientProvider),
  ),
);

// Repositories
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    authRemoteDataSource: ref.watch(authRemoteDataSourceProvider),
  ),
);
final storageRepositoryProvider = Provider<StorageRepository>(
  (ref) => StorageRepositoryImpl(
    pingService: ref.watch(pingServiceProvider),
    storageRemoteDataSource: ref.watch(storageRemoteDataSourceProvider),
  ),
);
final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepositoryImpl(
    pingService: ref.watch(pingServiceProvider),
    productLocalDatasource: ref.watch(productLocalDatasourceProvider),
    productRemoteDatasource: ref.watch(productRemoteDatasourceProvider),
    queuedActionLocalDatasource: ref.watch(queuedActionLocalDatasourceProvider),
  ),
);
final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepositoryImpl(
    pingService: ref.watch(pingServiceProvider),
    transactionLocalDatasource: ref.watch(transactionLocalDatasourceProvider),
    transactionRemoteDatasource: ref.watch(transactionRemoteDatasourceProvider),
    queuedActionLocalDatasource: ref.watch(queuedActionLocalDatasourceProvider),
  ),
);
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(
    pingService: ref.watch(pingServiceProvider),
    userLocalDatasource: ref.watch(userLocalDatasourceProvider),
    userRemoteDatasource: ref.watch(userRemoteDatasourceProvider),
    queuedActionLocalDatasource: ref.watch(queuedActionLocalDatasourceProvider),
  ),
);
final queuedActionRepositoryProvider = Provider<QueuedActionRepository>(
  (ref) => QueuedActionRepositoryImpl(
    pingService: ref.watch(pingServiceProvider),
    queuedActionLocalDatasource: ref.watch(queuedActionLocalDatasourceProvider),
    userRemoteDatasource: ref.watch(userRemoteDatasourceProvider),
    transactionRemoteDatasource: ref.watch(transactionRemoteDatasourceProvider),
    productRemoteDatasource: ref.watch(productRemoteDatasourceProvider),
  ),
);
