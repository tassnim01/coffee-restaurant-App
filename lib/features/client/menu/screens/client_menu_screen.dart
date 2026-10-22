import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/category_icons.dart';
import '../../../admin/menu/models/product.dart';
import '../../../admin/menu/providers/menu_provider.dart';
import '../../../admin/menu/widgets/menu_search_field.dart';
import '../widgets/client_category_tabs.dart';
import '../widgets/client_product_tile.dart';

class ClientMenuScreen extends StatefulWidget {
  /// Catégorie sélectionnée (null = Tous), partagée avec l'accueil.
  final ValueNotifier<String?> categoryFilter;

  const ClientMenuScreen({super.key, required this.categoryFilter});

  @override
  State<ClientMenuScreen> createState() => _ClientMenuScreenState();
}

class _ClientMenuScreenState extends State<ClientMenuScreen> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    widget.categoryFilter.addListener(_onFilterChanged);
  }

  @override
  void dispose() {
    widget.categoryFilter.removeListener(_onFilterChanged);
    super.dispose();
  }

  void _onFilterChanged() {
    if (mounted) setState(() {});
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Plats disponibles, filtrés par catégorie et par recherche.
  List<Product> _visibleProducts(MenuProvider menu, String? categoryId) {
    final q = _query.trim().toLowerCase();
    return menu.products.where((p) {
      if (!p.isAvailable) return false;
      if (categoryId != null && p.categoryId != categoryId) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();

    // Ignore la catégorie sélectionnée si elle a été supprimée entre-temps.
    final selected = widget.categoryFilter.value;
    final categoryId =
        menu.categories.any((c) => c.id == selected) ? selected : null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(menu, categoryId),
              const SizedBox(height: 16),
              ClientCategoryTabs(
                categories: menu.categories,
                selectedCategoryId: categoryId,
                onSelected: (id) => widget.categoryFilter.value = id,
              ),
              const SizedBox(height: 14),
              MenuSearchField(
                hint: 'Rechercher un plat...',
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 14),
              Expanded(child: _buildList(menu, categoryId)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(MenuProvider menu, String? categoryId) {
    var title = 'Menu';
    var icon = Icons.restaurant_menu_rounded;
    for (final c in menu.categories) {
      if (c.id == categoryId) {
        title = c.name;
        icon = CategoryIcons.byKey(c.iconKey);
      }
    }

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.forestGreen.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 21, color: AppColors.forestGreen),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: AppTextStyles.screenTitle)),
      ],
    );
  }

  Widget _buildList(MenuProvider menu, String? categoryId) {
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

    final products = _visibleProducts(menu, categoryId);

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.restaurant_outlined,
                size: 46, color: AppColors.gray),
            const SizedBox(height: 10),
            Text('Aucun plat trouvé',
                style: AppTextStyles.body.copyWith(color: AppColors.gray)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.forestGreen,
      onRefresh: menu.loadMenu,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final product = products[i];
          return ClientProductTile(
            product: product,
            onTap: () =>
                _showInfo('Le détail de « ${product.name} » arrive bientôt.'),
            onAdd: () => _showInfo("Le panier arrive à l'étape suivante."),
          );
        },
      ),
    );
  }
}