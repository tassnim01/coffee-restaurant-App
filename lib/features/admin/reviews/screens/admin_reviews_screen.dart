import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/product_image.dart';
import '../../../admin/menu/models/product.dart';
import '../../../admin/menu/providers/menu_provider.dart';
import '../../../reviews/models/product_review.dart';
import '../../../reviews/providers/reviews_provider.dart';
import 'admin_review_detail_screen.dart';

class AdminReviewsScreen extends StatefulWidget {
  final VoidCallback onMenuTap;

  const AdminReviewsScreen({super.key, required this.onMenuTap});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  final _searchController = TextEditingController();
  int? _ratingFilter;
  String _productFilter = 'Tous';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewsProvider>().loadAllReviews();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReviewsProvider>();
    final menu = context.watch<MenuProvider>();
    var reviews = List<ProductReview>.from(provider.allReviews);

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      reviews = reviews.where((review) {
        final product = _productFor(review.productId, menu);
        return review.userName.toLowerCase().contains(query) ||
            review.comment.toLowerCase().contains(query) ||
            (product?.name.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (_ratingFilter != null) {
      reviews = reviews
          .where((review) => review.rating == _ratingFilter)
          .toList();
    }
    if (_productFilter != 'Tous') {
      reviews = reviews.where((review) {
        final product = _productFor(review.productId, menu);
        if (product == null) return false;
        return menu.categoryNameOf(product.categoryId).toLowerCase().trim() ==
            _productFilter.toLowerCase().trim();
      }).toList();
    }
    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final average = provider.allReviews.isEmpty
        ? 0.0
        : provider.allReviews
                  .map((review) => review.rating)
                  .reduce((a, b) => a + b) /
              provider.allReviews.length;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onMenuTap,
                    icon: const Icon(Icons.menu_rounded, size: 28),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Avis clients',
                      style: AppTextStyles.screenTitle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Rechercher un avis, un client ou un plat...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: provider.isLoadingAll
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: provider.loadAllReviews,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAdminFilters(menu),
                              const SizedBox(height: 12),
                              _buildSummary(provider.allReviews, average),
                              const SizedBox(height: 12),
                              _buildDistribution(provider.allReviews),
                              const SizedBox(height: 12),
                              _buildRecentSection(reviews, menu),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: FilledButton(
                                  onPressed: () =>
                                      _openAllReviewsSheet(reviews, menu),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.forestGreen,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text('Voir tous les avis'),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Product? _productFor(String productId, MenuProvider menu) {
    for (final product in menu.products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  Widget _buildAdminFilters(MenuProvider menu) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtrer par note',
          style: AppTextStyles.productName.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _filterChip(
                'Tout',
                _ratingFilter == null,
                () => setState(() => _ratingFilter = null),
              ),
            ),
            for (final rating in [5, 4, 3, 2, 1])
              Expanded(
                child: _filterChip(
                  '$rating★',
                  _ratingFilter == rating,
                  () => setState(() => _ratingFilter = rating),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Filtrer par plat',
          style: AppTextStyles.productName.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _categoryChip(
                'Tous',
                _productFilter == 'Tous',
                () => setState(() => _productFilter = 'Tous'),
              ),
              for (final category in menu.categories)
                _categoryChip(
                  category.name,
                  _productFilter == category.name,
                  () => setState(() => _productFilter = category.name),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.forestGreen : AppColors.surface,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected ? AppColors.forestGreen : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.toggle.copyWith(
              fontSize: 11,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 36,
        constraints: const BoxConstraints(minWidth: 72),
        padding: const EdgeInsets.symmetric(horizontal: 14),
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
            fontSize: 11,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildDistribution(List<ProductReview> allReviews) {
    final total = allReviews.length;
    final positive = allReviews.where((review) => review.rating >= 4).length;
    final neutral = allReviews.where((review) => review.rating == 3).length;
    final negative = allReviews.where((review) => review.rating <= 2).length;
    final positivePercent = total == 0 ? 0.0 : positive / total;
    final neutralPercent = total == 0 ? 0.0 : neutral / total;
    final negativePercent = total == 0 ? 0.0 : negative / total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Répartition des avis', style: AppTextStyles.productName),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 92,
                height: 92,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(92, 92),
                      painter: _ReviewDistributionPainter(
                        positive: positivePercent,
                        neutral: neutralPercent,
                        negative: negativePercent,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$total',
                          style: AppTextStyles.screenTitle.copyWith(
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'avis',
                          style: AppTextStyles.chip.copyWith(
                            color: AppColors.gray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: [
                    _distributionLegend(
                      AppColors.forestGreen,
                      'Positifs',
                      positivePercent,
                    ),
                    _distributionLegend(
                      AppColors.warmBeige,
                      'Neutres',
                      neutralPercent,
                    ),
                    _distributionLegend(
                      AppColors.burgundy,
                      'Négatifs',
                      negativePercent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _distributionLegend(Color color, String label, double percent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: AppTextStyles.chip)),
          Text(
            '${(percent * 100).round()}%',
            style: AppTextStyles.chip.copyWith(color: AppColors.gray),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSection(List<ProductReview> reviews, MenuProvider menu) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Avis récents', style: AppTextStyles.productName),
          const SizedBox(height: 8),
          if (reviews.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  'Aucun avis trouvé.',
                  style: AppTextStyles.body.copyWith(color: AppColors.gray),
                ),
              ),
            )
          else
            for (final review in reviews.take(3))
              _buildReviewCard(review, _productFor(review.productId, menu)),
        ],
      ),
    );
  }

  Future<void> _openAllReviewsSheet(
    List<ProductReview> reviews,
    MenuProvider menu,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.82,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tous les avis',
                    style: AppTextStyles.screenTitle,
                  ),
                ),
              ),
              Expanded(
                child: reviews.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun avis trouvé.',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.gray,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: reviews.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return _buildReviewCard(
                            review,
                            _productFor(review.productId, menu),
                          );
                        },
                      ),
              ),
            ],
          ),
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
            width: 92,
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

  Widget _buildReviewCard(ProductReview review, Product? product) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              AdminReviewDetailScreen(review: review, product: product),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
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
                        style: AppTextStyles.chip.copyWith(
                          color: AppColors.gray,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') _confirmDelete(review);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: AppColors.burgundy),
                          SizedBox(width: 8),
                          Text('Supprimer'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
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
                if (product != null)
                  Expanded(
                    child: Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.chip.copyWith(
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ),
              ],
            ),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(review.comment, style: AppTextStyles.body),
            ],
            if (review.photoUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ProductImage(
                  imageUrl: review.photoUrl,
                  width: double.infinity,
                  height: 150,
                  radius: 12,
                ),
              ),
            ],
            const SizedBox(height: 8),
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
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AdminReviewDetailScreen(
                        review: review,
                        product: product,
                      ),
                    ),
                  ),
                  child: Text(
                    review.adminResponse.isEmpty
                        ? 'Répondre'
                        : 'Voir la réponse',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(ProductReview review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cet avis ?'),
        content: const Text('Cette action est définitive.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.burgundy),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<ReviewsProvider>();
    final success = await provider.deleteReview(review.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Avis supprimé.'
              : provider.error ?? 'Impossible de supprimer cet avis.',
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

class _ReviewDistributionPainter extends CustomPainter {
  final double positive;
  final double neutral;
  final double negative;

  const _ReviewDistributionPainter({
    required this.positive,
    required this.neutral,
    required this.negative,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 10.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final segments = [
      (AppColors.forestGreen, positive),
      (AppColors.warmBeige, neutral),
      (AppColors.burgundy, negative),
    ];
    var start = -math.pi / 2;
    for (final segment in segments) {
      if (segment.$2 <= 0) continue;
      paint.color = segment.$1;
      final sweep = segment.$2 * math.pi * 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        start,
        sweep,
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _ReviewDistributionPainter oldDelegate) {
    return oldDelegate.positive != positive ||
        oldDelegate.neutral != neutral ||
        oldDelegate.negative != negative;
  }
}
