import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money.dart';
import '../../../admin/orders/models/order_item.dart';
import '../../../admin/orders/models/order_status.dart';
import '../../../admin/orders/models/restaurant_order.dart';
import '../../../admin/orders/widgets/product_thumb.dart';
import '../../../admin/orders/widgets/order_status_stepper.dart';
import '../providers/client_orders_provider.dart';

class ClientOrderDetailScreen extends StatelessWidget {
  final String orderId;

  const ClientOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final order = context.watch<ClientOrdersProvider>().byId(orderId);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.chevron_left_rounded, size: 28),
                  ),
                  Expanded(
                    child: Text(
                      order == null ? 'Commande' : 'Commande ${order.code}',
                      style: AppTextStyles.screenTitle,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: order == null
                  ? Center(
                      child: Text(
                        'Commande introuvable',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.gray,
                        ),
                      ),
                    )
                  : _buildContent(order),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(RestaurantOrder order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: OrderStatusStepper(current: order.status),
          ),
          const SizedBox(height: 26),
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: AppColors.forestGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              order.status.trackingIcon,
              size: 46,
              color: AppColors.forestGreen,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            order.status.trackingTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.productName.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            order.status.trackingSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.chip.copyWith(
              color: AppColors.gray,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Articles', style: AppTextStyles.productName),
          ),
          const SizedBox(height: 10),
          ...order.items.map(_itemRow),
          const SizedBox(height: 8),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          _totalRow('Sous-total', money(order.subtotal)),
          if (order.vatPercent > 0)
            _totalRow('TVA (${percent(order.vatPercent)}%)', money(order.vat)),
          const SizedBox(height: 4),
          _totalRow('Total', money(order.total), big: true),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Paiement en espèces à la caisse.',
              style: AppTextStyles.chip.copyWith(
                color: AppColors.gray,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ProductThumb(
              productId: item.productId,
              imageUrl: item.imageUrl,
              size: 46,
              radius: 12,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.productName.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.quantity} x ${money(item.unitPrice + item.supplementsTotal)}',
                    style: AppTextStyles.chip.copyWith(
                      color: AppColors.gray,
                      fontSize: 12,
                    ),
                  ),
                  if (item.supplements.isNotEmpty)
                    Text(
                      '+ ${item.supplements.map((s) => s.name).join(', ')}',
                      style: AppTextStyles.chip.copyWith(
                        color: AppColors.gray,
                        fontSize: 11.5,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              money(item.lineTotal),
              style: AppTextStyles.productName.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, String value, {bool big = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: big
                  ? AppTextStyles.productName.copyWith(fontSize: 16)
                  : AppTextStyles.body,
            ),
          ),
          Text(
            value,
            style: big
                ? AppTextStyles.screenTitle.copyWith(fontSize: 17)
                : AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
