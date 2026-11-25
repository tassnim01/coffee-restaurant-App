import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/product_image.dart';
import '../../../admin/menu/models/product.dart';
import '../../../reviews/models/product_review.dart';
import '../../../reviews/providers/reviews_provider.dart';
import 'write_review_screen.dart';

class ProductReviewsScreen extends StatefulWidget {
  final Product product;

  const ProductReviewsScreen({super.key, required this.product});

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  int _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewsProvider>().watchProduct(widget.product.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviews = context.watch<ReviewsProvider>().reviewsFor(
      widget.product.id,
    );
    final filtered = _selectedRating == 0
        ? reviews
        : reviews.where((review) => review.rating == _selectedRating).toList();
    final average = reviews.isEmpty
        ? 0.0
        : reviews.fold<int>(0, (sum, review) => sum + review.rating) /
              reviews.length;

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
                      'Avis clients',
                      style: AppTextStyles.screenTitle,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _openWriteReview(context),
                    tooltip: 'Laisser un avis',
                    icon: const Icon(
                      Icons.rate_review_outlined,
                      color: AppColors.forestGreen,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _summaryCard(reviews, average),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _filterChip('Tous', 0),
                        for (var rating = 5; rating >= 1; rating--)
                          _filterChip('$rating', rating),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (filtered.isEmpty)
                    _emptyState()
                  else
                    for (final review in filtered) _reviewCard(review),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(List<ProductReview> reviews, double average) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ProductImage(imageUrl: widget.product.imageUrl, size: 70, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.product.name, style: AppTextStyles.productName),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      average.toStringAsFixed(1),
                      style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
                    ),
                    const SizedBox(width: 6),
                    _stars(average.round(), size: 16),
                  ],
                ),
                Text(
                  '${reviews.length} avis',
                  style: AppTextStyles.chip.copyWith(color: AppColors.gray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, int rating) {
    final selected = _selectedRating == rating;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedRating = rating),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.forestGreen : AppColors.chipBackground,
            borderRadius: BorderRadius.circular(18),
          ),
          child: rating == 0
              ? Text(
                  label,
                  style: AppTextStyles.toggle.copyWith(
                    fontSize: 12,
                    color: selected ? Colors.white : AppColors.textPrimary,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.toggle.copyWith(
                        fontSize: 12,
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: selected ? Colors.white : AppColors.warmBeige,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _reviewCard(ProductReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.chipBackground,
                child: Text(
                  review.userName.isEmpty
                      ? 'C'
                      : review.userName.characters.first.toUpperCase(),
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
                    Text(review.userName, style: AppTextStyles.productName),
                    Text(
                      _formatDate(review.createdAt),
                      style: AppTextStyles.chip.copyWith(color: AppColors.gray),
                    ),
                  ],
                ),
              ),
              _stars(review.rating, size: 16),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(review.comment, style: AppTextStyles.body),
          ],
          if (review.photoUrl.isNotEmpty) ...[
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.chipBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Réponse du restaurant',
                    style: AppTextStyles.chip.copyWith(
                      color: AppColors.forestGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(review.adminResponse, style: AppTextStyles.body),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.thumb_up_alt_outlined,
                size: 16,
                color: AppColors.gray,
              ),
              const SizedBox(width: 6),
              Text(
                'Utile',
                style: AppTextStyles.chip.copyWith(color: AppColors.gray),
              ),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('Répondre')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stars(int count, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < count ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: AppColors.warmBeige,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.rate_review_outlined,
              size: 48,
              color: AppColors.gray,
            ),
            const SizedBox(height: 10),
            Text(
              'Aucun avis avec cette note.',
              style: AppTextStyles.body.copyWith(color: AppColors.gray),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openWriteReview(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WriteReviewScreen(product: widget.product),
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
