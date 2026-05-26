import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../../core/locale/app_localizations.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../../core/utilities/currency_formatter.dart';
import '../../../providers/home/home_notifier.dart';
import '../../../widgets/app_empty_state.dart';
import 'order_card.dart';

class CartPanelBody extends StatelessWidget {
  final PanelController panelController;

  const CartPanelBody({super.key, required this.panelController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 62),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _OrderList(panelController: panelController),
          const _OrderTotal(),
        ],
      ),
    );
  }
}

class _OrderList extends ConsumerStatefulWidget {
  final PanelController panelController;

  const _OrderList({required this.panelController});

  @override
  ConsumerState<_OrderList> createState() => _OrderListState();
}

class _OrderListState extends ConsumerState<_OrderList> {
  final scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);

    if (homeState.orderedProducts.isEmpty) {
      return SizedBox(
        height: AppSizes.screenHeight(context) - 272,
        child: AppEmptyState(
          title: context.loc.emptyCart,
          subtitle: context.loc.emptyCartSubtitle,
        ),
      );
    }

    return SizedBox(
      height: AppSizes.screenHeight(context) - 272,
      child: Scrollbar(
        controller: scrollController,
        child: ListView.builder(
          controller: scrollController,
          itemCount: homeState.orderedProducts.length,
          padding: const EdgeInsets.all(AppSizes.padding),
          itemBuilder: (context, i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.padding),
              child: OrderCard(
                name: homeState.orderedProducts[i].name,
                imageUrl: homeState.orderedProducts[i].imageUrl,
                stock: homeState.orderedProducts[i].stock,
                price: homeState.orderedProducts[i].price,
                initialQuantity: homeState.orderedProducts[i].quantity,
                onChangedQuantity: (val) {
                  ref.read(homeNotifierProvider.notifier).onChangedOrderedProductQuantity(i, val);
                },
                onTapRemove: () {
                  final isLast = homeState.orderedProducts.length == 1;
                  ref.read(homeNotifierProvider.notifier).onRemoveOrderedProduct(homeState.orderedProducts[i]);
                  if (isLast) widget.panelController.close();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrderTotal extends ConsumerWidget {
  const _OrderTotal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeNotifierProvider);

    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1,
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${context.loc.total} (${homeState.orderedProducts.length})',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            CurrencyFormatter.format(ref.read(homeNotifierProvider.notifier).getTotalAmount()),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
