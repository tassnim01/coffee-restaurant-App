import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/category_icons.dart';
import '../models/category.dart';
import '../providers/menu_provider.dart';

/// Onglet "Catégories" : liste, modification, suppression, ajout.
class CategoriesTab extends StatelessWidget {
  final ValueChanged<Category> onView;
  final ValueChanged<Category> onEdit;
  final ValueChanged<Category> onDelete;

  const CategoriesTab({
    super.key,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();

    if (menu.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: menu.categories.isEmpty
              ? Center(
                  child: Text(
                    'Aucune catégorie',
                    style: AppTextStyles.body.copyWith(color: AppColors.gray),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: menu.categories.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final c = menu.categories[i];
                    return _CategoryCard(
                      category: c,
                      productCount: menu.productCountOf(c.id),
                      onView: () => onView(c),
                      onEdit: () => onEdit(c),
                      onDelete: () => onDelete(c),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final int productCount;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.productCount,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CategoryIcons.badge(category.iconKey, size: 64),
        title: Text(
          category.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        subtitle: Text(
          '$productCount produit${productCount > 1 ? 's' : ''}',
          style: AppTextStyles.chip.copyWith(color: AppColors.gray),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onView,
              tooltip: 'Voir',
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.visibility_outlined, size: 20),
            ),
            IconButton(
              onPressed: onEdit,
              tooltip: 'Modifier',
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.edit_outlined, size: 20),
            ),
            IconButton(
              onPressed: onDelete,
              tooltip: 'Supprimer',
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.burgundy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
