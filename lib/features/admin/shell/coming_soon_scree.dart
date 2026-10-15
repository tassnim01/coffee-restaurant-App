import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Page provisoire pour les modules pas encore développés.
class ComingSoonScreen extends StatelessWidget {
  final String title;
  final VoidCallback onMenuTap;

  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onMenuTap,
                    icon: const Icon(Icons.menu_rounded, size: 28),
                  ),
                  Expanded(child: Text(title, style: AppTextStyles.screenTitle)),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.construction_rounded,
                        size: 46, color: AppColors.gray),
                    const SizedBox(height: 10),
                    Text(
                      'Ce module arrive bientôt',
                      style:
                          AppTextStyles.body.copyWith(color: AppColors.gray),
                    ),
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