import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/product_image.dart';
import '../models/restaurant_order.dart';
import 'order_status_chip.dart';

class OrderCard extends StatelessWidget {
  final RestaurantOrder order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ProductImage(imageUrl: order.coverImage, size: 60, radius: 14),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.code, style: AppTextStyles.productName),
                      const SizedBox(height: 4),
                      Text(
                        'Client : ${order.clientName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.chip
                            .copyWith(color: AppColors.gray, fontSize: 12),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        Formatters.time(order.createdAt),
                        style: AppTextStyles.chip
                            .copyWith(color: AppColors.gray, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    OrderStatusChip(status: order.status),
                    const SizedBox(height: 14),
                    Text(
                      Formatters.dt(order.total),
                      style:
                          AppTextStyles.productName.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}