import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/product_image.dart';
import '../models/order_item.dart';
import '../models/order_status.dart';
import '../models/restaurant_order.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_status_chip.dart';
import 'order_tracking_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _updating = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _advance(RestaurantOrder order) async {
    final next = order.status.next;
    if (next == null) return;

    final provider = context.read<OrdersProvider>();
    setState(() => _updating = true);
    try {
      await provider.updateStatus(order.id, next);
      if (mounted) _showMessage('${order.code} : ${next.label}');
    } catch (_) {
      if (mounted) _showMessage('Erreur lors de la mise à jour du statut.');
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrdersProvider>().byId(widget.orderId);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: order == null
                  ? Center(
                      child: Text(
                        'Commande introuvable',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.gray),
                      ),
                    )
                  : _buildContent(order),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.chevron_left_rounded, size: 28),
          ),
          Expanded(
            child: Text('Détails de la commande',
                style: AppTextStyles.screenTitle),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(RestaurantOrder order) {
    final actionLabel = order.status.actionLabel;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.code,
                        style: AppTextStyles.screenTitle
                            .copyWith(fontSize: 20),
                      ),
                    ),
                    OrderStatusChip(status: order.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.dateTime(order.createdAt),
                  style: AppTextStyles.chip
                      .copyWith(color: AppColors.gray, fontSize: 12.5),
                ),
                const SizedBox(height: 20),
                Text('Client', style: AppTextStyles.productName),
                const SizedBox(height: 10),
                _buildClientCard(order),
                const SizedBox(height: 20),
                Text('Articles', style: AppTextStyles.productName),
                const SizedBox(height: 10),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildItemRow(item),
                  ),
                ),
                const SizedBox(height: 6),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text('Total', style: AppTextStyles.body),
                    ),
                    Text(
                      Formatters.dt(order.total),
                      style: AppTextStyles.screenTitle,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            children: [
              if (actionLabel != null) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _updating ? null : () => _advance(order),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColors.forestGreen, width: 1.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _updating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            actionLabel,
                            style: AppTextStyles.toggle
                                .copyWith(color: AppColors.forestGreen),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          OrderTrackingScreen(orderId: order.id),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text('Suivi de la commande',
                      style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClientCard(RestaurantOrder order) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.person_outline_rounded,
                color: AppColors.gray),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.clientName, style: AppTextStyles.productName),
                const SizedBox(height: 3),
                Text(
                  order.clientPhone,
                  style: AppTextStyles.chip
                      .copyWith(color: AppColors.gray, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(OrderItem item) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ProductImage(imageUrl: item.imageUrl, size: 46, radius: 12),
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
                const SizedBox(height: 3),
                Text(
                  '${item.quantity} x ${Formatters.dt(item.unitPrice)}',
                  style: AppTextStyles.chip
                      .copyWith(color: AppColors.gray, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            Formatters.dt(item.lineTotal),
            style: AppTextStyles.productName.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}