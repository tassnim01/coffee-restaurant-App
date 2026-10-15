import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../models/restaurant_client.dart';

class ClientCard extends StatelessWidget {
  final RestaurantClient client;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ClientCard({
    super.key,
    required this.client,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final subtle =
        AppTextStyles.chip.copyWith(color: AppColors.gray, fontSize: 12);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
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
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.chipBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded,
                size: 30, color: AppColors.gray),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.productName,
                ),
                const SizedBox(height: 3),
                Text(client.phone, style: subtle),
                const SizedBox(height: 2),
                Text(
                  'Client depuis le ${Formatters.date(client.createdAt)}',
                  style: subtle,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            tooltip: 'Modifier',
            icon: const Icon(Icons.edit_outlined, size: 20),
          ),
          IconButton(
            onPressed: onDelete,
            tooltip: 'Supprimer',
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: AppColors.burgundy,
            ),
          ),
        ],
      ),
    );
  }
}