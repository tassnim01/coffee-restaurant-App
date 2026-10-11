import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Displays a product image from a network URL or an asset,
/// with loading and error fallbacks. Local file support (image_picker)
/// will be added with the Add Product screen.
class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double radius;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.size = 68,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: size, height: size, child: _buildImage()),
    );
  }

  Widget _buildImage() {
    final url = imageUrl;
    if (url == null || url.isEmpty) return _placeholder();

    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _placeholder(loading: true),
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return Image.asset(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder({bool loading = false}) {
    return Container(
      color: AppColors.chipBackground,
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.local_cafe_outlined, color: AppColors.gray),
    );
  }
}