import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/order_status.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_status_stepper.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrdersProvider>().byId(orderId);

    return Scaffold(
      body: SafeArea(
        child: order == null
            ? Center(
                child: Text(
                  'Commande introuvable',
                  style: AppTextStyles.body.copyWith(color: AppColors.gray),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.chevron_left_rounded,
                              size: 28),
                        ),
                        Expanded(
                          child: Text(
                            'Commande ${order.code}',
                            style: AppTextStyles.screenTitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: OrderStatusStepper(current: order.status),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: AppColors.forestGreen
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                order.status.trackingIcon,
                                size: 64,
                                color: AppColors.forestGreen,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              order.status.trackingTitle,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.productName
                                  .copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              order.status.trackingSubtitle,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.chip.copyWith(
                                  color: AppColors.gray, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.forestGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text('Voir les articles',
                            style: AppTextStyles.button),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}