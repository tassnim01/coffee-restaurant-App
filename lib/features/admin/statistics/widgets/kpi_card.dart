import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Carte « libellé, grande valeur, évolution en % ».
class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final double? change; // null = pas de période précédente à comparer

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    final c = change;
    final up = c == null || c >= 0;
    final color = up ? AppColors.forestGreen : AppColors.burgundy;

    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.chip.copyWith(fontSize: 12.5),
          ),
          const SizedBox(height: 8),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTextStyles.screenTitle.copyWith(fontSize: 22),
            ),
          ),
          const SizedBox(height: 8),
          if (c == null)
            Text('—',
                style: AppTextStyles.chip.copyWith(color: AppColors.gray))
          else
            Row(
              children: [
                Icon(
                  up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  size: 18,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  '${c >= 0 ? '+' : ''}${c.round()}%',
                  style: AppTextStyles.chip.copyWith(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}