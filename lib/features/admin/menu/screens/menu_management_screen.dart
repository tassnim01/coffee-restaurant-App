import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../models/product.dart';
import '../providers/menu_provider.dart';
import '../widgets/admin_product_card.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/menu_search_field.dart';
import '../widgets/segmented_toggle.dart';

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

  Future<void> _confirmDelete(Product product) async {
    final provider = context.read<MenuProvider>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Supprimer le produit',
      message: 'Voulez-vous vraiment supprimer "${product.name}" ?',
    );
    if (!confirmed || !mounted) return;
    await provider.deleteProduct(product.id);
    if (mounted) _showInfo('"${product.name}" a été supprimé.');
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
                onChanged: (i) => setState(() => _tabIndex = i),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _tabIndex == 0
                    ? _buildProductsTab()
                    : _buildCategoriesPlaceholder(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Header ----------
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
          onTap: () => _showInfo("L'écran « Ajouter un produit » arrive à l'étape suivante."),
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

  // ---------- Products tab ----------
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
                      onEdit: () => _showInfo(
                          "L'écran « Modifier un produit » arrive bientôt."),
                      onDelete: () => _confirmDelete(product),
                    );
                  },
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

  // ---------- Categories tab (implemented in a later step) ----------
  Widget _buildCategoriesPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.category_outlined, size: 46, color: AppColors.gray),
          const SizedBox(height: 10),
          Text(
            'La gestion des catégories arrive bientôt',
            style: AppTextStyles.body.copyWith(color: AppColors.gray),
          ),
        ],
      ),
    );
  }
}