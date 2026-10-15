import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/order_status.dart';

/// Reçue — En cours — Prête — Livrée.
class OrderStatusStepper extends StatelessWidget {
  final OrderStatus current;

  const OrderStatusStepper({super.key, required this.current});

  static const double _circle = 28;

  @override
  Widget build(BuildContext context) {
    final steps = OrderStatus.values;
    final children = <Widget>[];

    for (var i = 0; i < steps.length; i++) {
      children.add(_step(steps[i], i));
      if (i < steps.length - 1) {
        final reached = i < current.index;
        children.add(
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: _circle / 2 - 1),
              child: Container(
                height: 2,
                color: reached ? AppColors.forestGreen : AppColors.border,
              ),
            ),
          ),
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _step(OrderStatus status, int index) {
    final isFinal = current == OrderStatus.delivered;
    final done = index < current.index || (index == current.index && isFinal);
    final active = index == current.index && !isFinal;

    Widget circle;
    if (done) {
      circle = Container(
        width: _circle,
        height: _circle,
        decoration: const BoxDecoration(
          color: AppColors.forestGreen,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, size: 17, color: Colors.white),
      );
    } else if (active) {
      circle = Container(
        width: _circle,
        height: _circle,
        decoration: BoxDecoration(
          color: AppColors.forestGreen,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.forestGreen.withValues(alpha: 0.25),
            width: 4,
          ),
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    } else {
      circle = Container(
        width: _circle,
        height: _circle,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.gray, width: 1.5),
        ),
      );
    }

    return SizedBox(
      width: 64,
      child: Column(
        children: [
          circle,
          const SizedBox(height: 6),
          Text(
            status.label,
            textAlign: TextAlign.center,
            style: AppTextStyles.chip.copyWith(
              fontSize: 11.5,
              fontWeight: active || done ? FontWeight.w600 : FontWeight.w500,
              color: active || done ? AppColors.textPrimary : AppColors.gray,
            ),
          ),
        ],
      ),
    );
  }
}