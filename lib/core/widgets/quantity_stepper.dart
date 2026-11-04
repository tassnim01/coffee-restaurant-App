import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Sélecteur de quantité : (−) 1 (+)
class QuantityStepper extends StatelessWidget {
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const QuantityStepper({
    super.key,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _button(Icons.remove_rounded, onMinus),
        SizedBox(
          width: 38,
          child: Center(
            child: Text('$value', style: AppTextStyles.productName),
          ),
        ),
        _button(Icons.add_rounded, onPlus),
      ],
    );
  }

  Widget _button(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.black, width: 1.3),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}