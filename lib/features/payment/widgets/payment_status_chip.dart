import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Pastille « Payé » (vert) ou « Non payé » (bordeaux).
class PaymentStatusChip extends StatelessWidget {
  final bool isPaid;

  const PaymentStatusChip({super.key, required this.isPaid});

  @override
  Widget build(BuildContext context) {
    final color = isPaid ? AppColors.brandForeground : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isPaid ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPaid ? 'Payé' : 'Non payé',
        style: AppTextStyles.chip.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
