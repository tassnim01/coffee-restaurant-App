import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';

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
import '../../../payment/widgets/payment_section.dart';
import '../../../client/orders/services/order_invoice_generator.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _updating = false;
  bool _paymentPromptShown = false;

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

  Future<void> _openInvoice(RestaurantOrder order) async {
    try {
      final bytes = await OrderInvoiceGenerator.generate(order);
      await Printing.layoutPdf(
        name: 'addition-${order.code.replaceAll('#', '')}.pdf',
        onLayout: (_) async => bytes,
      );
    } catch (_) {
      if (mounted) _showMessage("Impossible d'ouvrir l'addition PDF.");
    }
  }

  void _maybePromptPayment(RestaurantOrder order) {
    if (_paymentPromptShown ||
        order.status != OrderStatus.delivered ||
        order.isPaid) {
      return;
    }

    _paymentPromptShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final confirmed = await _showUnpaidPaymentDialog(order);
      if (confirmed && mounted) {
        _showMessage(
          'Paiement de ${order.code} confirmé${order.tableNumber == null || order.tableNumber!.isEmpty ? '' : ' — table ${order.tableNumber}'}.',
        );
      }
    });
  }

  Future<bool> _showUnpaidPaymentDialog(RestaurantOrder order) async {
    var busy = false;
    String? error;
    final table = order.tableNumber?.trim();
    final tableLabel = table == null || table.isEmpty
        ? 'Table non renseignée'
        : 'Table $table';

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              icon: const Icon(
                Icons.lock_rounded,
                color: AppColors.burgundy,
                size: 38,
              ),
              title: Text(
                'Commande non payée',
                textAlign: TextAlign.center,
                style: AppTextStyles.screenTitle.copyWith(fontSize: 19),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'La commande ${order.code} ($tableLabel) a été livrée. '
                    'Confirmez le paiement en espèces pour débloquer l’application du client.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.gray,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warmBeige.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Le client sera débloqué automatiquement après votre confirmation.',
                      style: AppTextStyles.chip.copyWith(fontSize: 12),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.burgundy,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: busy
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Plus tard'),
                ),
                FilledButton.icon(
                  onPressed: busy
                      ? null
                      : () async {
                          setDialogState(() {
                            busy = true;
                            error = null;
                          });
                          try {
                            await dialogContext
                                .read<OrdersProvider>()
                                .confirmPayment(order.id);
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop(true);
                            }
                          } catch (_) {
                            if (dialogContext.mounted) {
                              setDialogState(() {
                                busy = false;
                                error = 'Erreur lors de l’enregistrement du paiement.';
                              });
                            }
                          }
                        },
                  icon: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.payments_outlined),
                  label: const Text('Confirmer le paiement'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                  ),
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrdersProvider>().byId(widget.orderId);
    if (order != null) _maybePromptPayment(order);

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
            child: Text(
              'Détails de la commande',
              style: AppTextStyles.screenTitle,
            ),
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
                        style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
                      ),
                    ),
                    OrderStatusChip(status: order.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.dateTime(order.createdAt),
                  style: AppTextStyles.chip.copyWith(
                    color: AppColors.gray,
                    fontSize: 12.5,
                  ),
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
                Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: Text('Total', style: AppTextStyles.body)),
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
              if (order.invoicePdfBase64 != null) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _openInvoice(order),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Ouvrir l’addition PDF'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.forestGreen,
                        width: 1.3,
                      ),
                      foregroundColor: AppColors.forestGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              PaymentSection(order: order),
              if (actionLabel != null) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _updating ? null : () => _advance(order),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.forestGreen,
                        width: 1.3,
                      ),
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
                            style: AppTextStyles.toggle.copyWith(
                              color: AppColors.forestGreen,
                            ),
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
                      builder: (_) => OrderTrackingScreen(orderId: order.id),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Suivi de la commande',
                    style: AppTextStyles.button,
                  ),
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
            child: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.gray,
            ),
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
                  style: AppTextStyles.chip.copyWith(
                    color: AppColors.gray,
                    fontSize: 12.5,
                  ),
                ),
                if (order.tableNumber != null &&
                    order.tableNumber!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Table : ${order.tableNumber}',
                    style: AppTextStyles.chip.copyWith(
                      color: AppColors.forestGreen,
                      fontSize: 12.5,
                    ),
                  ),
                ],
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
            Formatters.dt(item.lineTotal),
            style: AppTextStyles.productName.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
