import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../core/locale/app_localizations.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../../core/utilities/currency_formatter.dart';
import '../../../providers/home/home_notifier.dart';
import '../../../providers/locale/locale_notifier.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/app_drop_down.dart';
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
          AppDialog.show(
            child: const _AdditionalInfoDialog(),
            showButtons: false,
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
  final _customerController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _customerController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTextField(
          autofocus: true,
          keyboardType: TextInputType.number,
          controller: _amountController,
          labelText: context.loc.paidAmount,
          hintText: isVietnamese ? 'Số tiền nhận...' : 'Received amount...',
          type: AppTextFieldType.currency,
          onChanged: (val) {
            homeNotifier.onChangedReceivedAmount(int.tryParse(val) ?? 0);
          },
        ),
        const SizedBox(height: AppSizes.padding),
        AppDropDown(
          labelText: isVietnamese ? 'Phương thức thanh toán' : 'Payment Method',
          selectedValue: homeState.selectedPaymentMethod,
          dropdownItems: [
            DropdownMenuItem(
              value: 'bank',
              child: Text(isVietnamese ? 'Chuyển khoản' : 'Bank Transfer'),
            ),
            DropdownMenuItem(
              value: 'cash',
              child: Text(context.loc.cash),
            ),
          ],
          onChanged: (v) => homeNotifier.onChangedPaymentMethod(v),
        ),
        const SizedBox(height: AppSizes.padding),
        AppTextField(
          controller: _customerController,
          labelText: isVietnamese ? 'Tên khách hàng (Tùy chọn)' : 'Customer Name (Optional)',
          hintText: 'e.g. John Doe',
          onChanged: (v) => homeNotifier.onChangedCustomerName(v),
        ),
        const SizedBox(height: AppSizes.padding),
        AppTextField(
          controller: _descriptionController,
          labelText: isVietnamese ? 'Mô tả (Tùy chọn)' : 'Description (Optional)',
          hintText: isVietnamese ? 'Mô tả đơn hàng...' : 'Description...',
          onChanged: (v) => homeNotifier.onChangedDescription(v),
        ),
        const SizedBox(height: AppSizes.padding * 1.5),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: context.loc.cancel,
                buttonColor: Theme.of(context).colorScheme.surface,
                borderColor: Theme.of(context).colorScheme.primary,
                textColor: Theme.of(context).colorScheme.primary,
                onTap: () {
                  context.pop();
                },
              ),
            ),
            const SizedBox(width: AppSizes.padding / 2),
            Expanded(
              flex: 2,
              child: AppButton(
                text: context.loc.pay,
                enabled: (int.tryParse(_amountController.text) ?? 0) >= homeNotifier.getTotalAmount(),
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
    );
  }
}
