import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/locale/app_localizations.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../../core/utilities/currency_formatter.dart';
import '../../../providers/home/home_notifier.dart';
import '../../../providers/locale/locale_notifier.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/app_drop_down.dart';
import '../../../widgets/app_snack_bar.dart';
import '../../../widgets/app_text_field.dart';

class CartPanelFooter extends ConsumerWidget {
  final PanelController panelController;

  const CartPanelFooter({super.key, required this.panelController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPanelExpanded = ref.watch(homeNotifierProvider.select((s) => s.isPanelExpanded));

    return Container(
      width: AppSizes.screenWidth(context),
      padding: const EdgeInsets.fromLTRB(AppSizes.padding, 0, AppSizes.padding, AppSizes.padding),
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Row(
        children: [
          AnimatedContainer(
            width: isPanelExpanded ? AppSizes.screenWidth(context) / 3 : 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: AppSizes.screenWidth(context) / 3 - AppSizes.padding / 2,
                child: _BackButton(panelController: panelController),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _PayButton(panelController: panelController),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends ConsumerWidget {
  final PanelController panelController;

  const _BackButton({required this.panelController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppButton(
      text: context.loc.cancel,
      buttonColor: Theme.of(context).colorScheme.surface,
      borderColor: Theme.of(context).colorScheme.primary,
      textColor: Theme.of(context).colorScheme.primary,
      onTap: () => panelController.close(),
    );
  }
}

class _PayButton extends ConsumerWidget {
  final PanelController panelController;

  const _PayButton({required this.panelController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeNotifierProvider);
    final homeNotifier = ref.read(homeNotifierProvider.notifier);
    final isVietnamese = ref.watch(localeNotifierProvider).languageCode == 'vi';

    return AppButton(
      text: !homeState.isPanelExpanded
          ? homeState.orderedProducts.isNotEmpty
              ? isVietnamese
                  ? "${homeState.orderedProducts.length} sản phẩm = ${CurrencyFormatter.format(homeNotifier.getTotalAmount())}"
                  : "${homeState.orderedProducts.length} Items = ${CurrencyFormatter.format(homeNotifier.getTotalAmount())}"
              : context.loc.navSales
          : context.loc.pay,
      enabled: homeState.orderedProducts.isNotEmpty,
      onTap: () {
        if (homeState.isPanelExpanded) {
          // Initialize customer to Walk-in (Khách lẻ) if not set yet
          if (homeState.customerName == null) {
            homeNotifier.onChangedCustomerDetails(
              'C-DEFAULT-RETAIL',
              isVietnamese ? 'Khách lẻ' : 'General Guest',
              '',
            );
          }
          AppDialog.show(
            child: const _AdditionalInfoDialog(),
            showButtons: false,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding, vertical: AppSizes.padding / 2),
          );
        } else {
          panelController.open();
        }
      },
    );
  }
}

class _AdditionalInfoDialog extends ConsumerStatefulWidget {
  const _AdditionalInfoDialog();

  @override
  ConsumerState<_AdditionalInfoDialog> createState() => _AdditionalInfoDialogState();
}

class _AdditionalInfoDialogState extends ConsumerState<_AdditionalInfoDialog> {
  final _amountController = TextEditingController();
  final _customerSearchController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<dynamic> _searchResults = [];
  bool _isLoadingCustomers = false;
  bool _isCreatingCustomer = false;
  bool _showCreateForm = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Default amount controller to total amount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final total = ref.read(homeNotifierProvider.notifier).getTotalAmount();
      _amountController.text = total.toString();
      ref.read(homeNotifierProvider.notifier).onChangedReceivedAmount(total);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _customerSearchController.dispose();
    _customerPhoneController.dispose();
    _descriptionController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchCustomer(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _executeSearch(query);
    });
  }

  Future<void> _executeSearch(String query) async {
    final search = query.trim();
    if (search.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoadingCustomers = false;
      });
      return;
    }

    setState(() => _isLoadingCustomers = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      final prefs = ref.read(sharedPreferencesProvider);
      final shopId = prefs.getString(Constants.selectedShopIdKey) ?? '';

      final res = await apiClient.get<Map<String, dynamic>>(
        '/api/shops/$shopId/customers?search=$search',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (res.isSuccess) {
        final List<dynamic> data = res.data?['data'] ?? [];
        setState(() {
          _searchResults = data;
          _isLoadingCustomers = false;
        });
      } else {
        setState(() => _isLoadingCustomers = false);
      }
    } catch (_) {
      setState(() => _isLoadingCustomers = false);
    }
  }

  Future<void> _onCreateCustomer(HomeNotifier homeNotifier, bool isVietnamese) async {
    final name = _customerSearchController.text.trim();
    final phone = _customerPhoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) return;

    setState(() => _isCreatingCustomer = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      final prefs = ref.read(sharedPreferencesProvider);
      final shopId = prefs.getString(Constants.selectedShopIdKey) ?? '';

      final createRes = await apiClient.post<Map<String, dynamic>>(
        '/api/shops/$shopId/customers',
        body: {
          'name': name,
          'phone': phone,
          'customer_type': 'retail',
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      setState(() => _isCreatingCustomer = false);

      if (createRes.isSuccess) {
        final newCust = createRes.data!;
        final String newCustId = newCust['customer_id']?.toString() ?? newCust['id']?.toString() ?? '';
        final String newCustName = newCust['name']?.toString() ?? '';
        final String newCustPhone = newCust['phone']?.toString() ?? '';

        homeNotifier.onChangedCustomerDetails(newCustId, newCustName, newCustPhone);
        _customerSearchController.clear();
        _customerPhoneController.clear();
        setState(() {
          _searchResults = [];
          _showCreateForm = false;
        });
        AppSnackBar.show(isVietnamese ? 'Đã tạo khách hàng mới thành công!' : 'Customer created successfully!');
      } else {
        AppDialog.showError(error: createRes.error?.toString());
      }
    } catch (e) {
      setState(() => _isCreatingCustomer = false);
      AppDialog.showError(error: e.toString());
    }
  }

  Future<void> onPay({
    required GoRouter router,
    required HomeNotifier homeNotifier,
  }) async {
    var res = await AppDialog.showProgress(() {
      return homeNotifier.createTransaction();
    });

    if (res.isSuccess) {
      router.go('/transactions/transaction-detail/${res.data}');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final homeNotifier = ref.read(homeNotifierProvider.notifier);
    final isVietnamese = ref.watch(localeNotifierProvider).languageCode == 'vi';

    final total = homeNotifier.getTotalAmount();
    final returnAmount = homeState.receivedAmount - total;
    final isVirtualRetail = homeState.customerId == 'C-DEFAULT-RETAIL';

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isVietnamese ? 'Thanh toán đơn hàng' : 'Order Checkout',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.padding / 2),
          const Divider(),

          // Section 1: Customer Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isVietnamese ? 'KHÁCH HÀNG' : 'CUSTOMER',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              Text(
                isVirtualRetail ? (isVietnamese ? 'Khách lẻ' : 'Walk-in') : (homeState.customerName ?? ''),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (!isVirtualRetail)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest, width: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          homeState.customerName ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        if (homeState.customerPhone != null && homeState.customerPhone!.isNotEmpty)
                          Text(
                            homeState.customerPhone!,
                            style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      homeNotifier.onChangedCustomerDetails(
                        'C-DEFAULT-RETAIL',
                        isVietnamese ? 'Khách lẻ' : 'General Guest',
                        '',
                      );
                    },
                  )
                ],
              ),
            )
          else ...[
            if (!_showCreateForm) ...[
              AppTextField(
                controller: _customerSearchController,
                hintText: isVietnamese ? 'Tìm khách hàng (Tên hoặc SĐT)...' : 'Search customer...',
                onChanged: _onSearchCustomer,
                suffixWidget: _isLoadingCustomers
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              if (_searchResults.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, idx) {
                        final cust = _searchResults[idx];
                        final String name = cust['name']?.toString() ?? '';
                        final String phone = cust['phone']?.toString() ?? '';
                        final String custId = cust['customer_id']?.toString() ?? cust['id']?.toString() ?? '';
                        return ListTile(
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          subtitle: phone.isNotEmpty ? Text(phone, style: const TextStyle(fontSize: 11)) : null,
                          dense: true,
                          onTap: () {
                            homeNotifier.onChangedCustomerDetails(custId, name, phone);
                            _customerSearchController.clear();
                            setState(() => _searchResults = []);
                          },
                        );
                      },
                    ),
                  ),
                ),
              if (_customerSearchController.text.trim().isNotEmpty && _searchResults.isEmpty && !_isLoadingCustomers)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: AppButton(
                    text: isVietnamese
                        ? '+ Thêm mới: "${_customerSearchController.text.trim()}"'
                        : '+ Create: "${_customerSearchController.text.trim()}"',
                    buttonColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    textColor: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    onTap: () {
                      setState(() {
                        _showCreateForm = true;
                        _customerPhoneController.clear();
                      });
                    },
                  ),
                ),
            ] else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isVietnamese ? 'Tạo nhanh khách hàng mới' : 'Quick Create Customer',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _customerSearchController,
                      labelText: isVietnamese ? 'Tên khách *' : 'Name *',
                    ),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _customerPhoneController,
                      labelText: isVietnamese ? 'Số điện thoại *' : 'Phone *',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: isVietnamese ? 'Hủy' : 'Cancel',
                            buttonColor: Colors.white,
                            borderColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            textColor: Colors.grey,
                            onTap: () => setState(() => _showCreateForm = false),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppButton(
                            text: isVietnamese ? 'Tạo mới' : 'Create',
                            enabled: !_isCreatingCustomer &&
                                _customerSearchController.text.trim().isNotEmpty &&
                                _customerPhoneController.text.trim().isNotEmpty,
                            onTap: () => _onCreateCustomer(homeNotifier, isVietnamese),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
          ],

          const SizedBox(height: AppSizes.padding),

          // Section 2: Items Summary Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest, width: 0.5),
            ),
            child: Column(
              children: [
                ...homeState.orderedProducts.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.name} x ${item.quantity}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(item.price * item.quantity),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isVietnamese ? 'Giảm giá:' : 'Discount:', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const Text('0đ', style: TextStyle(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isVietnamese ? 'Tổng cộng:' : 'Total:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(
                      CurrencyFormatter.format(total),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.padding),

          // Section 3: Ghi chú
          AppTextField(
            controller: _descriptionController,
            labelText: isVietnamese ? 'Ghi chú đơn hàng...' : 'Order notes...',
            hintText: isVietnamese ? 'Nhập ghi chú (nếu có)...' : 'Enter notes (optional)...',
            onChanged: (v) => homeNotifier.onChangedDescription(v),
          ),

          const SizedBox(height: AppSizes.padding),

          // Section 4: Payment Details
          Text(
            isVietnamese ? 'PHƯƠNG THỨC THANH TOÁN' : 'PAYMENT METHOD',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: AppDropDown(
                  labelText: '',
                  selectedValue: homeState.selectedPaymentMethod,
                  dropdownItems: [
                    DropdownMenuItem(
                      value: 'cash',
                      child: Text(isVietnamese ? 'Tiền mặt' : 'Cash'),
                    ),
                    DropdownMenuItem(
                      value: 'bank',
                      child: Text(isVietnamese ? 'Chuyển khoản' : 'Bank Transfer'),
                    ),
                  ],
                  onChanged: (v) => homeNotifier.onChangedPaymentMethod(v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: AppTextField(
                  keyboardType: TextInputType.number,
                  controller: _amountController,
                  labelText: '',
                  hintText: '118.000',
                  type: AppTextFieldType.currency,
                  onChanged: (val) {
                    homeNotifier.onChangedReceivedAmount(int.tryParse(val) ?? 0);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Post Funds Info Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFFFEDD5), width: 0.5),
            ),
            child: Row(
              children: [
                Icon(Icons.arrow_forward_rounded, color: Theme.of(context).colorScheme.primary, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    homeState.selectedPaymentMethod == 'cash'
                        ? (isVietnamese
                            ? 'Dòng tiền sẽ được đưa vào quỹ: Két tiền mặt tại quầy'
                            : 'Funds will be posted to Register Cash Drawer')
                        : (isVietnamese
                            ? 'Dòng tiền sẽ được đưa vào quỹ: Tài khoản ngân hàng'
                            : 'Funds will be posted to Bank Account'),
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isVietnamese ? 'Số tiền nhận:' : 'Amount received:',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Text(
                CurrencyFormatter.format(homeState.receivedAmount),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                ),
              ),
            ],
          ),

          if (returnAmount > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isVietnamese ? 'Tiền thừa trả khách:' : 'Change returned:',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  CurrencyFormatter.format(returnAmount),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: AppSizes.padding * 1.5),

          // Dialog Action Buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: isVietnamese ? 'Hủy' : 'Cancel',
                  buttonColor: Colors.white,
                  borderColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  textColor: Colors.grey,
                  onTap: () {
                    context.pop();
                  },
                ),
              ),
              const SizedBox(width: AppSizes.padding / 2),
              Expanded(
                flex: 2,
                child: AppButton(
                  text: isVietnamese ? 'Hoàn tất' : 'Complete',
                  enabled: homeState.receivedAmount >= total,
                  onTap: () {
                    final router = ref.read(appRoutesProvider).router;
                    context.pop();
                    onPay(
                      homeNotifier: homeNotifier,
                      router: router,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
