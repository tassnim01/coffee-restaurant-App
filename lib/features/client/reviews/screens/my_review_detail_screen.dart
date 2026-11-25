import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/product_image.dart';
import '../../../admin/menu/providers/menu_provider.dart';
import '../../../reviews/models/product_review.dart';

class MyReviewDetailScreen extends StatelessWidget {
  final ProductReview review;

  const MyReviewDetailScreen({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final matchingProducts = menu.products
        .where((item) => item.id == review.productId)
        .toList();
    final product = matchingProducts.isEmpty ? null : matchingProducts.first;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Expanded(
                    child: Text(
                      'Détail de l’avis',
                      style: AppTextStyles.screenTitle,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.chipBackground,
                          child: Text(
                            review.userName.isEmpty
                                ? 'C'
                                : review.userName.characters.first
                                      .toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.forestGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.userName,
                                style: AppTextStyles.productName,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  ...List.generate(
                                    5,
                                    (index) => Icon(
                                      index < review.rating
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      size: 16,
                                      color: AppColors.warmBeige,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatDate(review.createdAt),
                                    style: AppTextStyles.chip.copyWith(
                                      color: AppColors.gray,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (review.comment.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(review.comment, style: AppTextStyles.body),
                    ],
                    if (review.photoUrl.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: ProductImage(
                          imageUrl: review.photoUrl,
                          width: double.infinity,
                          height: 220,
                          radius: 14,
                        ),
                      ),
                    ],
                    if (product != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            ProductImage(
                              imageUrl: product.imageUrl,
                              size: 64,
                              radius: 10,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: AppTextStyles.productName,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    money(product.price),
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.forestGreen,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (review.adminResponse.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Réponse du restaurant',
                        style: AppTextStyles.productName,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.chipBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          review.adminResponse,
                          style: AppTextStyles.body,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.chipBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        'Merci pour votre avis. Votre retour nous aide à améliorer notre restaurant.',
                        style: AppTextStyles.body,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}
