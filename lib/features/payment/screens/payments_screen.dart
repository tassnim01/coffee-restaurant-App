import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../admin/orders/models/order_status.dart';
import '../../admin/orders/models/restaurant_order.dart';
import '../../admin/orders/providers/orders_provider.dart';
import '../widgets/payment_status_chip.dart';
import 'payment_confirmation_screen.dart';

class PaymentsScreen extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const PaymentsScreen({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final delivered = context
        .watch<OrdersProvider>()
        .orders
        .where((o) => o.userId != null && o.status == OrderStatus.delivered)
        .toList();
    final pending = delivered.where((o) => !o.isPaid).toList();
    final paid = delivered.where((o) => o.isPaid).take(10).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: onMenuTap,
                    icon: const Icon(Icons.menu_rounded, size: 28),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('Paiements', style: AppTextStyles.screenTitle),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    _infoCard(),
                    const SizedBox(height: 18),
                    _section(
                      context,
                      'En attente de paiement',
                      pending,
                      'Aucune commande en attente de paiement.',
                    ),
                    const SizedBox(height: 18),
                    _section(
                      context,
                      'Payées',
                      paid,
                      'Aucun paiement enregistré.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: AppColors.forestGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.payments_outlined,
              size: 38,
              color: AppColors.forestGreen,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Paiement en espèces uniquement',
            textAlign: TextAlign.center,
            style: AppTextStyles.productName.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Le paiement se fait uniquement en espèces sur place, lorsque le client reçoit sa commande.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.gray),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.forestGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 19,
                  color: AppColors.forestGreen,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Après confirmation de la livraison, vous devez changer le statut de la commande sur « Livrée » dans l'application de responsable.",
                    style: AppTextStyles.chip.copyWith(fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    List<RestaurantOrder> orders,
    String emptyText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.productName),
        const SizedBox(height: 10),
        if (orders.isEmpty)
          Text(
            emptyText,
            style: AppTextStyles.body.copyWith(color: AppColors.gray),
          )
        else
          for (final o in orders)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PaymentConfirmationScreen(orderId: o.id),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(o.code, style: AppTextStyles.productName),
                              Text(
                                o.clientName,
                                style: AppTextStyles.chip.copyWith(
                                  color: AppColors.gray,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            PaymentStatusChip(isPaid: o.isPaid),
                            const SizedBox(height: 6),
                            Text(
                              Formatters.dt(o.total),
                              style: AppTextStyles.productName.copyWith(
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
