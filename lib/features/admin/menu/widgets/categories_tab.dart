import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/category_icons.dart';
import '../models/category.dart';
import '../providers/menu_provider.dart';

/// Onglet "Catégories" : liste, modification, suppression, ajout.
class CategoriesTab extends StatelessWidget {
  final VoidCallback onAdd;
  final ValueChanged<Category> onEdit;
  final ValueChanged<Category> onDelete;

  const CategoriesTab({
    super.key,
    required this.onAdd,
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
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final c = menu.categories[i];
                    return _CategoryCard(
                      category: c,
                      productCount: menu.productCountOf(c.id),
                      onEdit: () => onEdit(c),
                      onDelete: () => onDelete(c),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text('Ajouter une catégorie', style: AppTextStyles.button),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final int productCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.productCount,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final style = CategoryIcons.styleOf(category.iconKey);

    return Container(
      padding: const EdgeInsets.all(12),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: style.bg, shape: BoxShape.circle),
            child: Icon(
              CategoryIcons.byKey(category.iconKey),
              color: style.fg,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.productName,
                ),
                const SizedBox(height: 3),
                Text(
                  '$productCount produit${productCount > 1 ? 's' : ''}',
                  style: AppTextStyles.chip.copyWith(color: AppColors.gray),
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