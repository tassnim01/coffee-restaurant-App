import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money.dart';
import '../../../admin/menu/models/supplement.dart';
import '../../../admin/orders/models/order_item.dart';
import '../../../admin/orders/models/order_status.dart';
import '../../../admin/orders/models/restaurant_order.dart';
import '../../../admin/orders/widgets/product_thumb.dart';
import '../../../admin/orders/widgets/order_status_stepper.dart';
import '../../cart/models/cart_item.dart';
import '../services/order_invoice_generator.dart';
import 'client_order_product_menu_screen.dart';
import '../providers/client_orders_provider.dart';

class ClientOrderDetailScreen extends StatelessWidget {
  final String orderId;

  const ClientOrderDetailScreen({super.key, required this.orderId});

  Future<void> _openInvoice(BuildContext context, RestaurantOrder order) async {
    try {
      final bytes = await OrderInvoiceGenerator.generate(order);
      await Printing.layoutPdf(
        name: 'addition-${order.code.replaceAll('#', '')}.pdf',
        onLayout: (_) async => bytes,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text("Impossible d'ouvrir l'addition PDF.")),
        );
    }
  }

  Future<void> _editOrder(BuildContext context, RestaurantOrder order) async {
    final items = await showModalBottomSheet<List<OrderItem>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EditPendingOrderSheet(items: order.items),
    );
    if (items == null || !context.mounted) return;

    try {
      await context.read<ClientOrdersProvider>().updatePendingOrder(
        orderId: order.id,
        items: items,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Votre commande et son addition ont été modifiées.',
              ),
            ),
          );
      }
    } catch (error) {
      if (!context.mounted) return;
      final message = error.toString().replaceFirst('Bad state: ', '');
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

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
                  : _buildContent(context, order),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, RestaurantOrder order) {
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
          Row(
            children: [
              Expanded(
                child: Text('Articles', style: AppTextStyles.productName),
              ),
              if (order.status == OrderStatus.pending)
                TextButton.icon(
                  onPressed: () => _editOrder(
                    context,
                    context.read<ClientOrdersProvider>().byId(order.id) ??
                        order,
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Modifier'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.forestGreen,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ...order.items.map(_itemRow),
          const SizedBox(height: 8),
          Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          _totalRow('Total', money(order.total), big: true),
          if (order.status == OrderStatus.delivered) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _openInvoice(context, order),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Voir l’addition PDF'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.forestGreen,
                  side: const BorderSide(color: AppColors.forestGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
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

class _EditPendingOrderSheet extends StatefulWidget {
  final List<OrderItem> items;

  const _EditPendingOrderSheet({required this.items});

  @override
  State<_EditPendingOrderSheet> createState() => _EditPendingOrderSheetState();
}

class _EditPendingOrderSheetState extends State<_EditPendingOrderSheet> {
  late final List<OrderItem> _items = List.of(widget.items);

  double get _total => _items.fold(0, (total, item) => total + item.lineTotal);

  void _changeQuantity(int index, int delta) {
    final item = _items[index];
    final quantity = item.quantity + delta;
    setState(() {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = OrderItem(
          productId: item.productId,
          name: item.name,
          quantity: quantity,
          unitPrice: item.unitPrice,
          imageUrl: item.imageUrl,
          supplements: item.supplements,
        );
      }
    });
  }

  Future<void> _addProduct() async {
    final item = await Navigator.of(context).push<CartItem>(
      MaterialPageRoute(builder: (_) => const ClientOrderProductMenuScreen()),
    );
    if (item == null || !mounted) return;
    final orderItem = OrderItem(
      productId: item.productId,
      name: item.name,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      imageUrl: item.imageUrl,
      supplements: item.supplements,
    );

    final index = _items.indexWhere(
      (existing) =>
          existing.productId == orderItem.productId &&
          _sameSupplements(existing.supplements, orderItem.supplements),
    );
    setState(() {
      if (index == -1) {
        _items.add(orderItem);
      } else {
        final existing = _items[index];
        _items[index] = OrderItem(
          productId: existing.productId,
          name: existing.name,
          quantity: existing.quantity + orderItem.quantity,
          unitPrice: existing.unitPrice,
          imageUrl: existing.imageUrl,
          supplements: existing.supplements,
        );
      }
    });
  }

  bool _sameSupplements(List<Supplement> left, List<Supplement> right) {
    if (left.length != right.length) return false;
    final leftSorted = [...left]..sort((a, b) => a.name.compareTo(b.name));
    final rightSorted = [...right]..sort((a, b) => a.name.compareTo(b.name));
    for (var i = 0; i < leftSorted.length; i++) {
      if (leftSorted[i].name != rightSorted[i].name ||
          leftSorted[i].price != rightSorted[i].price) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      16,
      20,
      16,
      16 + MediaQuery.of(context).viewInsets.bottom,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Modifier la commande', style: AppTextStyles.screenTitle),
        const SizedBox(height: 6),
        Text(
          'Vous pouvez modifier les quantités ou retirer des articles tant '
          'que la commande est en attente.',
          style: AppTextStyles.body.copyWith(color: AppColors.gray),
        ),
        const SizedBox(height: 16),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = _items[index];
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: AppTextStyles.productName),
                          if (item.supplements.isNotEmpty)
                            Text(
                              item.supplements
                                  .map((supplement) => supplement.name)
                                  .join(', '),
                              style: AppTextStyles.chip.copyWith(
                                color: AppColors.gray,
                              ),
                            ),
                          Text(
                            money(item.lineTotal),
                            style: AppTextStyles.body,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _changeQuantity(index, -1),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('${item.quantity}', style: AppTextStyles.productName),
                    IconButton(
                      onPressed: () => _changeQuantity(index, 1),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addProduct,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Ajouter d’autres produits'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.forestGreen,
              side: const BorderSide(color: AppColors.forestGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: Text('Total', style: AppTextStyles.body)),
            Text(money(_total), style: AppTextStyles.productName),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: _items.isEmpty
                ? null
                : () => Navigator.of(context).pop(List.of(_items)),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.forestGreen,
            ),
            child: const Text('Enregistrer les modifications'),
          ),
        ),
      ],
    ),
  );
}
