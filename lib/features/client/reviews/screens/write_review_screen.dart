import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/product_image.dart';
import '../../../admin/menu/models/product.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../reviews/providers/reviews_provider.dart';

class WriteReviewScreen extends StatefulWidget {
  final Product product;

  const WriteReviewScreen({super.key, required this.product});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _rating = 0;
  final _comment = TextEditingController();
  bool _submitting = false;
  String? _photoUrl;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      'Écrire un avis',
                      style: AppTextStyles.screenTitle,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ProductImage(
                          imageUrl: widget.product.imageUrl,
                          size: 72,
                          radius: 12,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.product.name,
                            style: AppTextStyles.productName,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Votre note', style: AppTextStyles.productName),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final rating = index + 1;
                        return IconButton(
                          onPressed: () => setState(() => _rating = rating),
                          iconSize: 38,
                          icon: Icon(
                            rating <= _rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: AppColors.warmBeige,
                            size: 38,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Text('Votre avis', style: AppTextStyles.productName),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _comment,
                      minLines: 5,
                      maxLines: 8,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: 'Partagez votre expérience...',
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
                    const SizedBox(height: 16),
                    _buildPhotoPicker(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _submitting ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.forestGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Publier l’avis'),
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

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir une note.')),
      );
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vous connecter pour publier.')),
      );
      return;
    }

    setState(() => _submitting = true);
    final reviewsProvider = context.read<ReviewsProvider>();
    final success = await reviewsProvider.addReview(
      productId: widget.product.id,
      userId: user.uid,
      userName: user.name,
      rating: _rating,
      comment: _comment.text,
      photoUrl: _photoUrl ?? '',
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Votre avis a été publié.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            reviewsProvider.error ?? 'Impossible de publier votre avis.',
          ),
        ),
      );
    }
  }

  Widget _buildPhotoPicker() {
    final photoUrl = _photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return GestureDetector(
        onTap: _pickPhoto,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: ProductImage(
                  imageUrl: photoUrl,
                  width: double.infinity,
                  height: 180,
                  radius: 13,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => setState(() => _photoUrl = null),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textPrimary,
                ),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _pickPhoto,
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, color: AppColors.forestGreen),
            SizedBox(height: 6),
            Text('Prendre une photo (optionnel)'),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 700,
        maxHeight: 700,
        imageQuality: 70,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      final dataUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      if (dataUrl.length > 700000) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image trop lourde, choisissez-en une plus petite.'),
          ),
        );
        return;
      }

      if (!mounted) return;
      setState(() => _photoUrl = dataUrl);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible de charger l'image.")),
      );
    }
  }
}
