import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/product_image.dart';
import '../../../admin/menu/models/product.dart';
import '../../../admin/menu/models/supplement.dart';
import '../../cart/models/cart_item.dart';
import '../../cart/providers/cart_provider.dart';
import '../../../reviews/providers/reviews_provider.dart';
import '../../reviews/screens/product_reviews_screen.dart';
import '../../reviews/screens/write_review_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final bool selectionMode;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.selectionMode = false,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  final Set<int> _selected = {};
  bool _favorite = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewsProvider>().watchProduct(widget.product.id);
    });
  }

  List<Supplement> get _chosen => [
    for (final i in _selected) widget.product.supplements[i],
  ];

  void _addToCart() {
    final p = widget.product;
    if (widget.selectionMode) {
      Navigator.of(
        context,
      ).pop(CartItem.fromProduct(p, supplements: _chosen, quantity: _quantity));
      return;
    }

    context.read<CartProvider>().add(
      p,
      supplements: _chosen,
      quantity: _quantity,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('« ${p.name} » ajouté au panier.')),
      );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final top = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    ProductImage(
                      imageUrl: p.imageUrl,
                      width: double.infinity,
                      height: 300,
                      radius: 0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 276),
                      child: _buildSheet(p),
                    ),
                    Positioned(
                      top: top + 8,
                      left: 16,
                      child: _circleButton(
                        Icons.arrow_back_rounded,
                        () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    Positioned(
                      top: top + 8,
                      right: 16,
                      child: _circleButton(
                        _favorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        () => setState(() => _favorite = !_favorite),
                        color: _favorite ? AppColors.burgundy : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _circleButton(
    IconData icon,
    VoidCallback onTap, {
    Color color = Colors.black,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 22, color: color),
        ),
      ),
    );
  }

  Widget _buildSheet(Product p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.name, style: AppTextStyles.screenTitle.copyWith(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            money(p.price),
            style: AppTextStyles.screenTitle.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 10),
          Text(
            p.description,
            style: AppTextStyles.body.copyWith(color: AppColors.gray),
          ),
          if (p.supplements.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Suppléments', style: AppTextStyles.productName),
            const SizedBox(height: 6),
            for (var i = 0; i < p.supplements.length; i++)
              _supplementRow(i, p.supplements[i]),
          ],
          const SizedBox(height: 24),
          _buildReviews(p),
        ],
      ),
    );
  }

  Widget _buildReviews(Product p) {
    final reviewsProvider = context.watch<ReviewsProvider>();
    final reviews = reviewsProvider.reviewsFor(p.id);
    final average = reviews.isEmpty
        ? 0.0
        : reviews.fold<int>(0, (sum, review) => sum + review.rating) /
              reviews.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(
            reviews.isEmpty ? '0' : average.toStringAsFixed(1),
            style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < average.round()
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 17,
                      color: AppColors.warmBeige,
                    ),
                  ),
                ),
                Text(
                  '${reviews.length} avis',
                  style: AppTextStyles.chip.copyWith(color: AppColors.gray),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductReviewsScreen(product: p),
              ),
            ),
            child: const Text('Voir les avis'),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => WriteReviewScreen(product: p)),
            ),
            tooltip: 'Écrire un avis',
            icon: const Icon(
              Icons.rate_review_outlined,
              color: AppColors.forestGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _supplementRow(int index, Supplement s) {
    final checked = _selected.contains(index);
    return InkWell(
      onTap: () => setState(() {
        checked ? _selected.remove(index) : _selected.add(index);
      }),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: checked,
                onChanged: (v) => setState(() {
                  v == true ? _selected.add(index) : _selected.remove(index);
                }),
                activeColor: AppColors.forestGreen,
                side: BorderSide(color: AppColors.gray, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(s.name, style: AppTextStyles.body)),
            Text(
              plusMoney(s.price),
              style: AppTextStyles.chip.copyWith(
                color: AppColors.gray,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        14 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _roundButton(Icons.remove_rounded, () {
                  if (_quantity > 1) setState(() => _quantity--);
                }),
                Text(
                  '$_quantity',
                  style: AppTextStyles.productName.copyWith(fontSize: 17),
                ),
                _roundButton(
                  Icons.add_rounded,
                  () => setState(() => _quantity++),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: _addToCart,
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                widget.selectionMode
                    ? 'Ajouter à la commande'
                    : 'Ajouter au panier',
                style: AppTextStyles.button,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 1.3),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
