import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/category_icons.dart';
import '../../../admin/menu/providers/menu_provider.dart';

/// Accueil client : localisation, bannière, recherche, catégories, promo.
class HomeScreen extends StatelessWidget {
  /// Ouvre l'onglet Menu (categoryId null = toutes les catégories).
  final ValueChanged<String?> onOpenMenu;

  const HomeScreen({super.key, required this.onOpenMenu});

  static const double _bannerRatio = 1376 / 768;

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTop(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
                child: _buildBottom(menu),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Partie sombre ----------
  Widget _buildTop(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.darkPanel,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          _buildLocationRow(),
          const SizedBox(height: 14),
          _banner('assets/images/welcome_banner.jpg'),
          const SizedBox(height: 14),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildLocationRow() {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined,
            color: AppColors.warmBeige, size: 24),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Restaurant',
                style: AppTextStyles.chip
                    .copyWith(color: AppColors.gray, fontSize: 11.5),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rue de Tunis, Tunis',
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Colors.white, size: 18),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          child: const Icon(Icons.notifications_none_rounded,
              color: Colors.white, size: 22),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => onOpenMenu(null),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.search_rounded,
                  color: AppColors.gray, size: 22),
              const SizedBox(width: 12),
              Text('Rechercher un plat...', style: AppTextStyles.hint),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Partie claire ----------
  Widget _buildBottom(MenuProvider menu) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Catégories', style: AppTextStyles.screenTitle),
            ),
            GestureDetector(
              onTap: () => onOpenMenu(null),
              child: Text(
                'Voir tout',
                style: AppTextStyles.toggle.copyWith(
                  fontSize: 13,
                  color: AppColors.forestGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCategories(menu),
        const SizedBox(height: 22),
        _buildPromo(),
      ],
    );
  }

  Widget _buildCategories(MenuProvider menu) {
    if (menu.isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (menu.categories.isEmpty) {
      return Text(
        'Aucune catégorie',
        style: AppTextStyles.body.copyWith(color: AppColors.gray),
      );
    }

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 8,
      childAspectRatio: 1,
      children: menu.categories.map((c) {
        final style = CategoryIcons.styleOf(c.iconKey);
        return InkWell(
          onTap: () => onOpenMenu(c.id),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration:
                    BoxDecoration(color: style.bg, shape: BoxShape.circle),
                child: Icon(CategoryIcons.byKey(c.iconKey),
                    color: style.fg, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                c.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.chip
                    .copyWith(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPromo() {
    return GestureDetector(
      onTap: () => onOpenMenu(null),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: _bannerRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/promo_banner.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const ColoredBox(color: AppColors.chipBackground),
              ),
              // Dégradé sombre à gauche pour lire le texte.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xCC000000), Color(0x00000000)],
                    stops: [0.0, 0.65],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.48,
                    child: Text(
                      'Un bon café pour une meilleure journée',
                      style: AppTextStyles.screenTitle.copyWith(
                        color: AppColors.warmBeige,
                        fontSize: 17,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _banner(String asset) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: _bannerRatio,
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const ColoredBox(color: AppColors.chipBackground),
        ),
      ),
    );
  }
}