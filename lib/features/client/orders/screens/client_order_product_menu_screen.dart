import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../admin/menu/models/product.dart';
import '../../../admin/menu/providers/menu_provider.dart';
import '../../../admin/menu/widgets/menu_search_field.dart';
import '../../cart/models/cart_item.dart';
import '../../menu/screens/product_detail_screen.dart';
import '../../menu/widgets/client_category_tabs.dart';
import '../../menu/widgets/client_product_tile.dart';

class ClientOrderProductMenuScreen extends StatefulWidget {
  const ClientOrderProductMenuScreen({super.key});

  @override
  State<ClientOrderProductMenuScreen> createState() =>
      _ClientOrderProductMenuScreenState();
}

class _ClientOrderProductMenuScreenState
    extends State<ClientOrderProductMenuScreen> {
  String? _categoryId;
  String _query = '';

  Future<void> _selectProduct(Product product) async {
    final item = await Navigator.of(context).push<CartItem>(
      MaterialPageRoute(
        builder: (_) =>
            ProductDetailScreen(product: product, selectionMode: true),
      ),
    );
    if (item != null && mounted) {
      Navigator.of(context).pop(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final selectedCategoryId =
        menu.categories.any((category) => category.id == _categoryId)
        ? _categoryId
        : null;
    final query = _query.trim().toLowerCase();
    final products = menu.products.where((product) {
      if (!product.isAvailable) return false;
      if (selectedCategoryId != null &&
          product.categoryId != selectedCategoryId) {
        return false;
      }
      return query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text('Menu', style: AppTextStyles.screenTitle),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choisissez un produit à ajouter à votre commande.',
                style: AppTextStyles.body.copyWith(color: AppColors.gray),
              ),
              const SizedBox(height: 14),
              ClientCategoryTabs(
                categories: menu.categories,
                selectedCategoryId: selectedCategoryId,
                onSelected: (id) => setState(() => _categoryId = id),
              ),
              const SizedBox(height: 14),
              MenuSearchField(
                hint: 'Rechercher un plat...',
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: menu.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : menu.error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(menu.error!, style: AppTextStyles.body),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: menu.loadMenu,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.forestGreen,
                              ),
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      )
                    : products.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun produit disponible.',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.gray,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: products.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ClientProductTile(
                            product: product,
                            onTap: () => _selectProduct(product),
                            onAdd: () => _selectProduct(product),
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
}
