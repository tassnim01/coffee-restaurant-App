import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/order_status.dart';

/// Onglets : Toutes | En attente | Reçues | En cours | Prêtes | Livrées.
class OrderTabsBar extends StatelessWidget {
  final OrderTab selected;
  final ValueChanged<OrderTab> onChanged;

  const OrderTabsBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: OrderTab.values.map((tab) {
          final isSelected = tab == selected;
          return Padding(
            padding: EdgeInsets.only(
              right: tab == OrderTab.values.last ? 0 : 8,
            ),
            child: GestureDetector(
              onTap: () => onChanged(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.forestGreen : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.forestGreen
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  tab.label,
                  style: AppTextStyles.toggle.copyWith(
                    fontSize: 12.5,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
