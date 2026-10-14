import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/product_image.dart';
import '../models/product.dart';
import '../providers/menu_provider.dart';

class ProductFormScreen extends StatefulWidget {
  /// null = ajout, non null = modification.
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;

  String? _categoryId;
  String? _imageUrl;
  bool _isAvailable = true;
  bool _saving = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(
      text: p == null ? '' : p.price.toStringAsFixed(3),
    );
    _categoryId = p?.categoryId;
    _imageUrl = p?.imageUrl;
    _isAvailable = p?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickImage() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 700,
        maxHeight: 700,
        imageQuality: 70,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final dataUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      // Un document Firestore est limité à 1 Mo.
      if (dataUrl.length > 700000) {
        _showMessage('Image trop lourde, choisissez-en une plus petite.');
        return;
      }
      if (!mounted) return;
      setState(() => _imageUrl = dataUrl);
    } catch (_) {
      if (mounted) _showMessage("Impossible de charger l'image.");
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final menu = context.read<MenuProvider>();
    final price = double.parse(_priceCtrl.text.trim().replaceAll(',', '.'));

    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await menu.updateProduct(
          widget.product!.copyWith(
            name: _nameCtrl.text.trim(),
            categoryId: _categoryId,
            description: _descCtrl.text.trim(),
            price: price,
            imageUrl: _imageUrl,
            isAvailable: _isAvailable,
          ),
        );
      } else {
        await menu.addProduct(
          Product(
            id: '',
            name: _nameCtrl.text.trim(),
            categoryId: _categoryId!,
            description: _descCtrl.text.trim(),
            price: price,
            imageUrl: _imageUrl,
            isAvailable: _isAvailable,
          ),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage("Erreur lors de l'enregistrement. Réessayez.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<MenuProvider>().categories;
    // Évite une erreur si la catégorie du produit n'existe plus.
    final validCategoryId =
        categories.any((c) => c.id == _categoryId) ? _categoryId : null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.chevron_left_rounded, size: 28),
                  ),
                  Expanded(
                    child: Text(
                      _isEdit ? 'Modifier un produit' : 'Ajouter un produit',
                      style: AppTextStyles.screenTitle,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImagePicker(),
                      const SizedBox(height: 20),
                      AppTextField(
                        label: 'Nom du produit',
                        controller: _nameCtrl,
                        hint: 'Ex. Cappuccino',
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Le nom est obligatoire'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      const FieldLabel('Catégorie', required: true),
                      DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: validCategoryId,
                        isExpanded: true,
                        style: AppTextStyles.body,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        dropdownColor: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        decoration:
                            appInputDecoration(hint: 'Sélectionner une catégorie'),
                        items: categories
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _categoryId = v),
                        validator: (v) =>
                            v == null ? 'Sélectionnez une catégorie' : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Description',
                        controller: _descCtrl,
                        hint: 'Description du produit...',
                        maxLines: 4,
                        maxLength: 200,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'La description est obligatoire'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      AppTextField(
                        label: 'Prix (DT)',
                        controller: _priceCtrl,
                        hint: 'Ex. 6.500',
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        validator: (v) {
                          final value =
                              double.tryParse((v ?? '').trim().replaceAll(',', '.'));
                          if (value == null || value <= 0) {
                            return 'Entrez un prix valide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildAvailabilityRow(),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined, color: Colors.white),
                  label: Text(
                    _isEdit ? 'Enregistrer les modifications' : 'Ajouter le produit',
                    style: AppTextStyles.button,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    disabledBackgroundColor:
                        AppColors.forestGreen.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final hasImage = _imageUrl != null && _imageUrl!.isNotEmpty;

    if (hasImage) {
      return Center(
        child: GestureDetector(
          onTap: _pickImage,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ProductImage(imageUrl: _imageUrl, size: 120, radius: 18),
              Positioned(
                right: -6,
                bottom: -6,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      size: 17, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.chipBackground.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: AppColors.border,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_camera_outlined,
                      color: AppColors.gray, size: 26),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.forestGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_rounded,
                        size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Ajouter une image',
              style: AppTextStyles.body.copyWith(color: AppColors.gray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Produit disponible',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Switch(
            value: _isAvailable,
            onChanged: (v) => setState(() => _isAvailable = v),
          ),
        ],
      ),
    );
  }
}