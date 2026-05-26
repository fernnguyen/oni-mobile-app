import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../providers/auth/auth_notifier.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/brand_logo.dart';

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

      final sharedPreferences = ref.read(sharedPreferencesProvider);
      final savedSubdomain = sharedPreferences.getString(Constants.selectedSubdomainKey) ?? '';

      if (savedSubdomain.isEmpty) {
        setState(() {
          _errorMessage = 'Không tìm thấy thông tin subdomain doanh nghiệp. Vui lòng đăng nhập lại.';
          _isLoading = false;
        });
        return;
      }

      final supabaseClient = ref.read(supabaseClientProvider);
      final userId = supabaseClient.auth.currentUser?.id;

      if (userId == null) {
        setState(() {
          _errorMessage = 'Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.';
          _isLoading = false;
        });
        return;
      }

      // 1. Lấy tenant_id từ tenants table theo slug = savedSubdomain
      final tenantRes = await supabaseClient
          .from('tenants')
          .select('id')
          .eq('slug', savedSubdomain)
          .maybeSingle();

      if (tenantRes == null) {
        setState(() {
          _errorMessage = 'Không tìm thấy doanh nghiệp với subdomain "$savedSubdomain". Vui lòng kiểm tra lại.';
          _isLoading = false;
        });
        return;
      }

      final String tenantId = tenantRes['id'] as String;

      // 2. Kiểm tra xem user có phải là owner/admin ở tenant này không (user_tenants)
      final userTenantRes = await supabaseClient
          .from('user_tenants')
          .select('role_id')
          .eq('user_id', userId)
          .eq('tenant_id', tenantId)
          .maybeSingle();

      final bool isTenantOwner = userTenantRes != null;

      // 3. Lấy danh sách shops được phân quyền ở user_shops (nếu không phải là owner/admin)
      final Set<String> allowedShopIds = {};
      if (!isTenantOwner) {
        final List<dynamic> userShopsRes = await supabaseClient
            .from('user_shops')
            .select('shop_id')
            .eq('user_id', userId);
        for (var item in userShopsRes) {
          if (item['shop_id'] != null) {
            allowedShopIds.add(item['shop_id'] as String);
          }
        }
      }

      // 4. Lấy danh sách tất cả shops thuộc tenant này
      final List<dynamic> response = await supabaseClient
          .from('shops_view')
          .select('id, name, slug, address')
          .eq('tenant_id', tenantId);

      final List<Shop> loadedShops = response.map((data) => Shop.fromJson(data)).toList();

      // 5. Lọc danh sách shops tương ứng
      setState(() {
        if (isTenantOwner) {
          _shops = loadedShops;
        } else {
          _shops = loadedShops.where((shop) => allowedShopIds.contains(shop.id)).toList();
        }
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
        title: const Text('Chọn Chi Nhánh'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.grey),
            tooltip: 'Đăng xuất',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding * 1.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Unified Brand Logo for consistency
              const Center(
                child: BrandLogo(size: 60, fontSize: 20),
              ),
              const SizedBox(height: AppSizes.padding * 1.5),
              Text(
                'Vui lòng chọn chi nhánh làm việc bên dưới để bắt đầu ca bán hàng:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
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
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 44,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchShops,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_shops.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Chưa được phân quyền chi nhánh',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tài khoản của bạn chưa được cấp quyền truy cập chi nhánh nào thuộc doanh nghiệp này.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: AppSizes.padding * 1.5),
              AppButton(
                text: 'ĐĂNG XUẤT TÀI KHOẢN',
                onTap: _handleLogout,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _shops.length,
      padding: const EdgeInsets.only(bottom: AppSizes.padding * 1.5),
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final shop = _shops[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.08),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _selectShop(shop),
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.store_rounded,
                          size: 28,
                          color: AppColors.primary,
                        ),
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
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Slug: ${shop.slug}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (shop.address != null &&
                              shop.address!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 13,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    shop.address!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                      height: 1.2,
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
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
