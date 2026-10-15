import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/category_icons.dart';
import '../../../../core/widgets/product_image.dart';
import '../models/category.dart';
import '../models/product.dart';

Future<void> showProductDetailsSheet(
  BuildContext context, {
  required Product product,
  required String categoryName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ProductImage(
                imageUrl: product.imageUrl,
                width: 180,
                height: 160,
                radius: 18,
              ),
            ),
            const SizedBox(height: 18),
            Text(product.name, style: AppTextStyles.screenTitle),
            const SizedBox(height: 8),
            _CategoryChip(name: categoryName),
            const SizedBox(height: 16),
            Text(
              '${product.price.toStringAsFixed(3)} DT',
              style: AppTextStyles.price,
            ),
            const SizedBox(height: 16),
            Text('Description', style: AppTextStyles.productName),
            const SizedBox(height: 6),
            Text(
              product.description,
              style: AppTextStyles.body.copyWith(color: AppColors.gray),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  product.isAvailable
                      ? Icons.check_circle_outline
                      : Icons.remove_circle_outline,
                  color: product.isAvailable
                      ? AppColors.forestGreen
                      : AppColors.gray,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  product.isAvailable ? 'Disponible' : 'Indisponible',
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> showCategoryDetailsSheet(
  BuildContext context, {
  required Category category,
  required List<Product> products,
}) {
  final iconStyle = CategoryIcons.styleOf(category.iconKey);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: iconStyle.bg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CategoryIcons.byKey(category.iconKey),
                    color: iconStyle.fg,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(category.name, style: AppTextStyles.screenTitle),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Produits de la catégorie (${products.length})',
              style: AppTextStyles.productName,
            ),
            const SizedBox(height: 10),
            if (products.isEmpty)
              Text(
                'Aucun produit dans cette catégorie.',
                style: AppTextStyles.body.copyWith(color: AppColors.gray),
              )
            else
              ...products.map(
                (product) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      ProductImage(
                        imageUrl: product.imageUrl,
                        size: 48,
                        radius: 10,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body,
                        ),
                      ),
                      Text(
                        '${product.price.toStringAsFixed(3)} DT',
                        style: AppTextStyles.price,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _CategoryChip extends StatelessWidget {
  final String name;

  const _CategoryChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(name, style: AppTextStyles.chip),
    );
  }
}
