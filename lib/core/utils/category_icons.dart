import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Associe une clé (stockée dans Firestore) à une icône et des couleurs.
class CategoryIcons {
  CategoryIcons._();

  static const Map<String, IconData> icons = {
    'coffee': Icons.local_cafe_outlined,
    'drink': Icons.local_drink_outlined,
    'fastfood': Icons.fastfood_outlined,
    'dish': Icons.restaurant_outlined,
    'dessert': Icons.cake_outlined,
    'bakery': Icons.bakery_dining_outlined,
    'icecream': Icons.icecream_outlined,
    'lunch': Icons.lunch_dining_outlined,
    'pizza': Icons.local_pizza_outlined,
    'bar': Icons.local_bar_outlined,
  };

  static IconData byKey(String key) => icons[key] ?? Icons.category_outlined;

  /// Couleur de fond et couleur de l'icône pour une clé donnée.
  static ({Color bg, Color fg}) styleOf(String key) {
    switch (key) {
      case 'coffee':
      case 'fastfood':
      case 'bakery':
        return (bg: AppColors.warmBeige.withValues(alpha: 0.6), fg: AppColors.forestGreen);
      case 'drink':
      case 'dish':
      case 'dessert':
      case 'icecream':
        return (bg: AppColors.burgundy.withValues(alpha: 0.14), fg: AppColors.burgundy);
      default:
        return (bg: AppColors.forestGreen.withValues(alpha: 0.14), fg: AppColors.forestGreen);
    }
  }
}