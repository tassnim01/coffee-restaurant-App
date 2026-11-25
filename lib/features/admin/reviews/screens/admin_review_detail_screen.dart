import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/product_image.dart';
import '../../../admin/menu/models/product.dart';
import '../../../reviews/models/product_review.dart';
import '../../../reviews/providers/reviews_provider.dart';

class AdminReviewDetailScreen extends StatefulWidget {
  final ProductReview review;
  final Product? product;

  const AdminReviewDetailScreen({
    super.key,
    required this.review,
    this.product,
  });

  @override
  State<AdminReviewDetailScreen> createState() =>
      _AdminReviewDetailScreenState();
}

class _AdminReviewDetailScreenState extends State<AdminReviewDetailScreen> {
  late final TextEditingController _responseController;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _responseController = TextEditingController(
      text: widget.review.adminResponse,
    );
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final review = context
        .watch<ReviewsProvider>()
        .allReviews
        .where((item) => item.id == widget.review.id)
        .firstOrNull;
    final currentReview = review ?? widget.review;

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
                            currentReview.userName.isEmpty
                                ? 'C'
                                : currentReview.userName.characters.first
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
                                currentReview.userName,
                                style: AppTextStyles.productName,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  ...List.generate(
                                    5,
                                    (index) => Icon(
                                      index < currentReview.rating
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      size: 16,
                                      color: AppColors.warmBeige,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatDate(currentReview.createdAt),
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
                    if (currentReview.comment.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(currentReview.comment, style: AppTextStyles.body),
                    ],
                    if (currentReview.photoUrl.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: ProductImage(
                          imageUrl: currentReview.photoUrl,
                          width: double.infinity,
                          height: 220,
                          radius: 14,
                        ),
                      ),
                    ],
                    if (widget.product != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Produit concerné',
                        style: AppTextStyles.productName,
                      ),
                      const SizedBox(height: 8),
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
                              imageUrl: widget.product!.imageUrl,
                              size: 64,
                              radius: 10,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.product!.name,
                                    style: AppTextStyles.productName,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    money(widget.product!.price),
                                    style: AppTextStyles.price,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (currentReview.adminResponse.isNotEmpty) ...[
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
                          currentReview.adminResponse,
                          style: AppTextStyles.body,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      'Répondre à ce client',
                      style: AppTextStyles.productName,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _responseController,
                      minLines: 4,
                      maxLines: 6,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: 'Écrire une réponse...',
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _sending ? null : _sendResponse,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.forestGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _sending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                currentReview.adminResponse.isEmpty
                                    ? 'Répondre'
                                    : 'Modifier la réponse',
                              ),
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

  Future<void> _sendResponse() async {
    final response = _responseController.text.trim();
    if (response.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez écrire une réponse.')),
      );
      return;
    }

    setState(() => _sending = true);
    final provider = context.read<ReviewsProvider>();
    final success = await provider.respondToReview(widget.review.id, response);
    if (!mounted) return;
    setState(() => _sending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Réponse publiée.'
              : provider.error ?? 'Impossible d’envoyer la réponse.',
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
