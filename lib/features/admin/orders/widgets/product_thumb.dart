import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/product_image.dart';
import '../../menu/providers/menu_provider.dart';

/// Image d'un produit : utilise imageUrl, sinon la retrouve via productId.
class ProductThumb extends StatelessWidget {
  final String? productId;
  final String? imageUrl;
  final double size;
  final double radius;

  const ProductThumb({
    super.key,
    this.productId,
    this.imageUrl,
    this.size = 56,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    var url = imageUrl;
    if ((url == null || url.isEmpty) && productId != null) {
      for (final p in context.watch<MenuProvider>().products) {
        if (p.id == productId) url = p.imageUrl;
      }
    }
    return ProductImage(imageUrl: url, size: size, radius: radius);
  }
}
