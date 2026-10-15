import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../providers/menu_provider.dart';
import '../widgets/admin_product_card.dart';
import '../widgets/categories_tab.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/category_form_sheet.dart';
import '../widgets/menu_search_field.dart';
import '../widgets/menu_item_details_sheet.dart';
import '../widgets/segmented_toggle.dart';
import 'product_form_screen.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  int _tabIndex = 0; // 0 = Produits, 1 = Catégories

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------- Produits ----------
  Future<void> _openProductForm([Product? product]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
    );
    if (saved == true && mounted) {
      _showInfo(product == null
          ? 'Produit ajouté.'
          : 'Modifications enregistrées.');
    }
  }

  Future<void> _confirmDeleteProduct(Product product) async {
    final provider = context.read<MenuProvider>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Supprimer le produit',
      message: 'Voulez-vous vraiment supprimer "${product.name}" ?',
    );
    if (!confirmed || !mounted) return;
    try {
      await provider.deleteProduct(product.id);
      if (mounted) _showInfo('"${product.name}" a été supprimé.');
    } catch (_) {
      if (mounted) _showInfo('Erreur lors de la suppression.');
    }
  }

  void _showProductDetails(Product product) {
    showProductDetailsSheet(
      context,
      product: product,
      categoryName: context.read<MenuProvider>().categoryNameOf(
            product.categoryId,
          ),
    );
  }

  // ---------- Catégories ----------
  Future<void> _openCategoryForm([Category? category]) async {
    final provider = context.read<MenuProvider>();
    final result = await showCategoryFormSheet(context, category: category);
    if (result == null || !mounted) return;
    try {
      if (category == null) {
        await provider.addCategory(result);
        if (mounted) _showInfo('Catégorie ajoutée.');
      } else {
        await provider.updateCategory(result);
        if (mounted) _showInfo('Catégorie modifiée.');
      }
    } catch (_) {
      if (mounted) _showInfo("Erreur lors de l'enregistrement.");
    }
  }

  void _showCategoryDetails(Category category) {
    final menu = context.read<MenuProvider>();
    showCategoryDetailsSheet(
      context,
      category: category,
      products: menu.products
          .where((product) => product.categoryId == category.id)
          .toList(),
    );
  }

  Future<void> _confirmDeleteCategory(Category category) async {
    final provider = context.read<MenuProvider>();

    if (provider.productCountOf(category.id) > 0) {
      _showInfo(
        'Impossible : "${category.name}" contient encore des produits.',
      );
      return;
    }

    final confirmed = await showConfirmDialog(
      context,
      title: 'Supprimer la catégorie',
      message: 'Voulez-vous vraiment supprimer "${category.name}" ?',
    );
    if (!confirmed || !mounted) return;
    try {
      await provider.deleteCategory(category.id);
      if (mounted) _showInfo('Catégorie supprimée.');
    } catch (_) {
      if (mounted) _showInfo('Erreur lors de la suppression.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              SegmentedToggle(
                labels: const ['Produits', 'Catégories'],
                selectedIndex: _tabIndex,
                onChanged: (i) {
                  // Le champ de recherche est recréé au retour sur l'onglet
                  // Produits : on réinitialise donc aussi le filtre.
                  if (i == 1) context.read<MenuProvider>().setSearchQuery('');
                  setState(() => _tabIndex = i);
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _tabIndex == 0
                    ? _buildProductsTab()
                    : CategoriesTab(
                        onAdd: _openCategoryForm,
                        onView: _showCategoryDetails,
                        onEdit: _openCategoryForm,
                        onDelete: _confirmDeleteCategory,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- En-tête ----------
  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text('Gestion du menu', style: AppTextStyles.screenTitle),
        ),
        InkWell(
          onTap: () =>
              _tabIndex == 0 ? _openProductForm() : _openCategoryForm(),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.black, width: 1.4),
            ),
            child: const Icon(Icons.add_rounded, size: 22),
          ),
        ),
      ],
    );
  }

  // ---------- Onglet Produits ----------
  Widget _buildProductsTab() {
    final menu = context.watch<MenuProvider>();

    if (menu.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (menu.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(menu.error!, style: AppTextStyles.body),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: menu.loadMenu,
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forestGreen),
              child: Text('Réessayer', style: AppTextStyles.button),
            ),
          ],
        ),
      );
    }

    final products = menu.filteredProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MenuSearchField(onChanged: menu.setSearchQuery),
        const SizedBox(height: 12),
        CategoryFilterBar(
          categories: menu.categories,
          selectedCategoryId: menu.selectedCategoryId,
          onSelected: menu.selectCategory,
        ),
        const SizedBox(height: 14),
        Expanded(
          child: products.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return AdminProductCard(
                      product: product,
                      categoryName: menu.categoryNameOf(product.categoryId),
                      onAvailabilityChanged: (_) =>
                          menu.toggleAvailability(product.id),
                      onView: () => _showProductDetails(product),
                      onEdit: () => _openProductForm(product),
                      onDelete: () => _confirmDeleteProduct(product),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: _openProductForm,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text('Ajouter un produit', style: AppTextStyles.button),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, size: 46, color: AppColors.gray),
          const SizedBox(height: 10),
          Text('Aucun produit trouvé',
              style: AppTextStyles.body.copyWith(color: AppColors.gray)),
        ],
      ),
    );
  }
}