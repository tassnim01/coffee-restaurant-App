import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/order_status.dart';

class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.chip.copyWith(
          color: status.foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}