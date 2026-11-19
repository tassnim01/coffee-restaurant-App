import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../admin/orders/models/order_status.dart';
import '../../admin/orders/models/restaurant_order.dart';
import '../screens/payment_confirmation_screen.dart';
import 'payment_status_chip.dart';

/// « Statut de paiement » + bouton de confirmation (commande livrée non payée).
class PaymentSection extends StatelessWidget {
  final RestaurantOrder order;

  const PaymentSection({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final canConfirm = order.status == OrderStatus.delivered && !order.isPaid;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Statut de paiement', style: AppTextStyles.body),
            ),
            PaymentStatusChip(isPaid: order.isPaid),
          ],
        ),
        if (canConfirm) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PaymentConfirmationScreen(orderId: order.id),
                ),
              ),
              icon: const Icon(
                Icons.payments_outlined,
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                'Confirmer le paiement en espèces',
                style: AppTextStyles.button.copyWith(fontSize: 13.5),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),
      ],
    );
  }
}
