import 'dart:convert';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Affiche une image depuis une URL http, un asset ou une data URL base64.
class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double? width;
  final double? height;
  final double radius;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.size = 68,
    this.width,
    this.height,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width ?? size,
        height: height ?? size,
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    final url = imageUrl;
    if (url == null || url.isEmpty) return _placeholder();

    if (url.startsWith('data:image')) {
      try {
        return Image.memory(
          base64Decode(url.split(',').last),
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => _placeholder(),
        );
      } catch (_) {
        return _placeholder();
      }
    }

    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _placeholder(loading: true),
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }

    return Image.asset(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _placeholder(),
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
