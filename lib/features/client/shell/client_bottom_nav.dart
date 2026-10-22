import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

/// Accueil | Menu | Panier | Compte
class ClientBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ClientBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = <_NavItem>[
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'Accueil'),
    _NavItem(Icons.restaurant_menu_outlined, Icons.restaurant_menu_rounded, 'Menu'),
    _NavItem(Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Panier'),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Compte'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final selected = i == currentIndex;
              final color = selected ? AppColors.forestGreen : AppColors.gray;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(selected ? item.activeIcon : item.icon,
                            color: color, size: 25),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: AppTextStyles.chip.copyWith(
                            fontSize: 11.5,
                            color: color,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}