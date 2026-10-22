import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../admin/menu/models/category.dart';

/// Pastilles horizontales : "Tous" + une par catégorie.
class ClientCategoryTabs extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId; // null = Tous
  final ValueChanged<String?> onSelected;

  const ClientCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _tab('Tous', selectedCategoryId == null, () => onSelected(null)),
          for (final c in categories)
            _tab(c.name, selectedCategoryId == c.id, () => onSelected(c.id)),
        ],
      ),
    );
  }

  Widget _tab(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.forestGreen : AppColors.chipBackground,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            label,
            style: AppTextStyles.toggle.copyWith(
              fontSize: 13.5,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}