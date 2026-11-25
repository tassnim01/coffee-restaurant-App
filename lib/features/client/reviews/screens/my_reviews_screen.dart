import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/product_image.dart';
import '../../../admin/menu/providers/menu_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../reviews/models/product_review.dart';
import '../../../reviews/providers/reviews_provider.dart';
import 'my_review_detail_screen.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  String _filter = 'Tous';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewsProvider>().loadAllReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().user?.uid;
    final provider = context.watch<ReviewsProvider>();
    final menu = context.watch<MenuProvider>();
    final myAllReviews = provider.allReviews
        .where((review) => review.userId == userId)
        .toList();
    var reviews = provider.allReviews
        .where((review) => review.userId == userId)
        .toList();

    if (_filter != 'Tous') {
      reviews = reviews.where((review) {
        final product = menu.products
            .where((item) => item.id == review.productId)
            .firstOrNull;
        final category = product == null
            ? ''
            : menu.categoryNameOf(product.categoryId).toLowerCase();
        switch (_filter) {
          case 'Plats':
            return category.contains('plat') ||
                category.contains('dessert') ||
                category.contains('fast');
          case 'Cafés':
            return category.contains('caf');
          case 'Boissons':
            return category.contains('boisson');
          default:
            return true;
        }
      }).toList();
    }

    final average = myAllReviews.isEmpty
        ? 0.0
        : myAllReviews.map((review) => review.rating).reduce((a, b) => a + b) /
              myAllReviews.length;

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
                    child: Text('Mes avis', style: AppTextStyles.screenTitle),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: Row(
                children: [
                  _filterTab('Tous'),
                  _filterTab('Plats'),
                  _filterTab('Cafés'),
                  _filterTab('Boissons'),
                ],
              ),
            ),
            if (myAllReviews.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _buildSummary(myAllReviews, average),
              ),
            Expanded(
              child: provider.isLoadingAll
                  ? const Center(child: CircularProgressIndicator())
                  : reviews.isEmpty
                  ? Center(
                      child: Text(
                        'Vous n’avez pas encore publié d’avis.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.gray,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: reviews.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Avis sur le plat',
                                      style: AppTextStyles.productName,
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (star) => Icon(
                                        star < review.rating
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        size: 17,
                                        color: AppColors.warmBeige,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (review.comment.isNotEmpty)
                                Text(review.comment, style: AppTextStyles.body),
                              if (review.photoUrl.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: ProductImage(
                                    imageUrl: review.photoUrl,
                                    width: double.infinity,
                                    height: 180,
                                    radius: 12,
                                  ),
                                ),
                              ],
                              if (review.adminResponse.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.chipBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Réponse du restaurant',
                                        style: AppTextStyles.chip.copyWith(
                                          color: AppColors.forestGreen,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        review.adminResponse,
                                        style: AppTextStyles.body,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          MyReviewDetailScreen(review: review),
                                    ),
                                  ),
                                  child: const Text('Voir'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(List<ProductReview> allReviews, double average) {
    final ratings = List.generate(5, (index) => index + 1);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Column(
              children: [
                Text(
                  average.toStringAsFixed(1),
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 26),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < average.round()
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 14,
                      color: AppColors.warmBeige,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${allReviews.length} avis',
                  style: AppTextStyles.chip.copyWith(color: AppColors.gray),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: ratings.reversed.map((rating) {
                final count = allReviews
                    .where((review) => review.rating == rating)
                    .length;
                final percent = allReviews.isEmpty
                    ? 0.0
                    : count / allReviews.length;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        child: Text(
                          '$rating★',
                          style: AppTextStyles.chip.copyWith(fontSize: 10),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percent,
                            minHeight: 7,
                            color: AppColors.warmBeige,
                            backgroundColor: AppColors.chipBackground,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 34,
                        child: Text(
                          '${(percent * 100).round()}%',
                          style: AppTextStyles.chip.copyWith(
                            color: AppColors.gray,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterTab(String label) {
    final selected = _filter == label;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: GestureDetector(
          onTap: () => setState(() => _filter = label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.forestGreen : AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? AppColors.forestGreen : AppColors.border,
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.toggle.copyWith(
                fontSize: 12,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
