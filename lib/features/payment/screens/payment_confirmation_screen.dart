import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../admin/orders/models/order_status.dart';
import '../../admin/orders/providers/orders_provider.dart';
import '../../admin/orders/widgets/order_status_chip.dart';
import '../widgets/payment_status_chip.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final String orderId;

  const PaymentConfirmationScreen({super.key, required this.orderId});

  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  bool _busy = false;

  Future<void> _confirm() async {
    final provider = context.read<OrdersProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await provider.confirmPayment(widget.orderId);
      navigator.pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Paiement confirmé.')));
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        messenger.showSnackBar(
          const SnackBar(content: Text('Erreur : paiement non enregistré.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrdersProvider>().byId(widget.orderId);
    final canConfirm =
        order != null && order.status == OrderStatus.delivered && !order.isPaid;

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
                      'Paiement de la commande',
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
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _card(
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: AppColors.chipBackground,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long_outlined,
                                    color: AppColors.forestGreen,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.code,
                                        style: AppTextStyles.productName,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Client : ${order.clientName}',
                                        style: AppTextStyles.body,
                                      ),
                                      Text(
                                        'Montant : ${Formatters.dt(order.total)}',
                                        style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _card(
                            child: Column(
                              children: [
                                _statusRow(
                                  'Statut de livraison',
                                  OrderStatusChip(status: order.status),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Divider(
                                    height: 1,
                                    color: AppColors.border,
                                  ),
                                ),
                                _statusRow(
                                  'Statut de paiement',
                                  PaymentStatusChip(isPaid: order.isPaid),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          if (canConfirm)
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: FilledButton.icon(
                                onPressed: _busy ? null : _confirm,
                                icon: const Icon(
                                  Icons.payments_outlined,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Confirmer le paiement en espèces',
                                  style: AppTextStyles.button,
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.forestGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            )
                          else
                            Text(
                              order.isPaid
                                  ? 'Le paiement de cette commande est enregistré.'
                                  : 'Le paiement pourra être confirmé une fois la commande livrée.',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.gray,
                              ),
                            ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.forestGreen.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 20,
                                  color: AppColors.forestGreen,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Après confirmation du paiement, le client pourra accéder à nouveau à l'application.",
                                    style: AppTextStyles.chip.copyWith(
                                      fontSize: 12.5,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _statusRow(String label, Widget chip) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.body)),
        chip,
      ],
    );
  }
}
