import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class _Category {
  const _Category(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

/// Page d'accueil client.
class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key, this.onSeeAll});

  /// Appelé par "Voir tout" (ex. aller à l'onglet Menu).
  final VoidCallback? onSeeAll;

  static const _categories = [
    _Category('Cafés', Icons.coffee_outlined, AppColors.chipBackground),
    _Category('Boissons', Icons.local_drink_outlined, Color(0xFFE9DCC0)),
    _Category('Fast-food', Icons.lunch_dining_outlined, Color(0xFFD6E0D1)),
    _Category('Plats', Icons.restaurant_outlined, Color(0xFFEAD3D0)),
    _Category('Desserts', Icons.cake_outlined, AppColors.chipBackground),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkPanel,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: const _WelcomeBanner(),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                  children: [
                    const _SearchBar(),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        const Text(
                          'Catégories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: onSeeAll,
                          child: const Text(
                            'Voir tout',
                            style: TextStyle(
                              color: AppColors.forestGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: 18,
                      spacing: 8,
                      children: _categories
                          .map((c) => _CategoryItem(category: c))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    const _PromoCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: AppColors.warmBeige,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Restaurant',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  'Rue de Tunis, Tunis',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.warmBeige,
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [AppColors.forestGreen, AppColors.darkPanel],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenue !',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Savourez le meilleur de notre menu',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Colors.white12,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.coffee_rounded,
              color: AppColors.warmBeige,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Rechercher un plat...',
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.category});

  final _Category category;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: category.color,
              shape: BoxShape.circle,
            ),
            child: Icon(category.icon, color: AppColors.forestGreen, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            category.label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [AppColors.darkPanel, AppColors.forestGreen],
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Un bon café\npour une meilleure\njournée',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 19,
                height: 1.25,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.white12,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_cafe_rounded,
              color: AppColors.warmBeige,
              size: 38,
            ),
          ),
        ],
      ),
    );
  }
}
