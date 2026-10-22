import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Page provisoire pour les onglets pas encore développés.
class ClientPlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const ClientPlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 46, color: AppColors.gray),
              const SizedBox(height: 12),
              Text(title, style: AppTextStyles.screenTitle),
              const SizedBox(height: 6),
              Text(
                'Cet écran arrive bientôt',
                style: AppTextStyles.body.copyWith(color: AppColors.gray),
              ),
            ],
          ),
        ),
      ),
    );
  }
}