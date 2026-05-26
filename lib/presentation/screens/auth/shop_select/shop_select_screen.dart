import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../providers/auth/auth_notifier.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';

class Shop {
  final String id;
  final String name;
  final String slug;
  final String? address;

  Shop({
    required this.id,
    required this.name,
    required this.slug,
    this.address,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      address: json['address'] as String?,
    );
  }
}

class ShopSelectScreen extends ConsumerStatefulWidget {
  const ShopSelectScreen({super.key});

  @override
  ConsumerState<ShopSelectScreen> createState() => _ShopSelectScreenState();
}

class _ShopSelectScreenState extends ConsumerState<ShopSelectScreen> {
  List<Shop> _shops = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchShops();
  }

  Future<void> _fetchShops() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final supabaseClient = ref.read(supabaseClientProvider);

      // Lấy danh sách các cửa hàng được phân quyền trực tiếp từ view shops_view
      final List<dynamic> response = await supabaseClient
          .from('shops_view')
          .select('id, name, slug, address');

      setState(() {
        _shops = response.map((data) => Shop.fromJson(data)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không tải được danh sách cửa hàng: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectShop(Shop shop) async {
    try {
      final sharedPreferences = ref.read(sharedPreferencesProvider);

      // Lưu lại Shop ID và Shop Name vào SharedPreferences
      await sharedPreferences.setString(Constants.selectedShopIdKey, shop.id);
      await sharedPreferences.setString(
        Constants.selectedShopNameKey,
        shop.name,
      );

      if (mounted) {
        // Làm mới route để tự động chuyển hướng đến màn hình /home
        ref.read(appRoutesProvider).router.refresh();
      }
    } catch (e) {
      AppDialog.showError(error: 'Lỗi khi lưu thông tin cửa hàng: $e');
    }
  }

  Future<void> _handleLogout() async {
    final res = await AppDialog.showProgress(() async {
      return ref.read(authNotifierProvider.notifier).signOut();
    });

    if (res.isSuccess) {
      if (mounted) {
        ref.read(appRoutesProvider).router.refresh();
      }
    } else {
      if (mounted) {
        AppDialog.showError(
          error: res.error?.toString() ?? 'Đăng xuất thất bại.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn Cửa Hàng / Chi Nhánh'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Đăng xuất',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Chào mừng bạn đến với hệ thống!',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Vui lòng chọn chi nhánh làm việc bên dưới để bắt đầu ca bán hàng.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSizes.padding * 1.5),
              Expanded(
                child: _buildBody(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchShops,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_shops.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.storefront_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Tài khoản của bạn chưa được phân quyền truy cập chi nhánh nào.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppSizes.padding),
            AppButton(
              text: 'ĐĂNG XUẤT',
              onTap: _handleLogout,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _shops.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final shop = _shops[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: InkWell(
            onTap: () => _selectShop(shop),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.store_rounded,
                      size: 28,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mã định danh: ${shop.slug}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (shop.address != null &&
                            shop.address!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  shop.address!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
