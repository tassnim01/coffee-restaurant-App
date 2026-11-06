import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/auth_sheet.dart';
import '../orders/screens/my_orders_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Compte', style: AppTextStyles.screenTitle),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.chipBackground,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 30,
                        color: AppColors.gray,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: user == null
                          ? Text(
                              'Vous n\'êtes pas connecté.',
                              style: AppTextStyles.body,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: AppTextStyles.productName,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.email,
                                  style: AppTextStyles.chip.copyWith(
                                    color: AppColors.gray,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  user.phone,
                                  style: AppTextStyles.chip.copyWith(
                                    color: AppColors.gray,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (user == null) ...[
                _button(
                  "S'inscrire",
                  filled: true,
                  onTap: () => showAuthSheet(context),
                ),
                const SizedBox(height: 10),
                _button(
                  'Se connecter',
                  onTap: () => showAuthSheet(context, startWithLogin: true),
                ),
              ] else ...[
                _button(
                  'Mes commandes',
                  filled: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                  ),
                ),
                const SizedBox(height: 10),
                _button('Se déconnecter', onTap: () => auth.logout()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _button(
    String label, {
    bool filled = false,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: filled
          ? FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(label, style: AppTextStyles.button),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: AppColors.forestGreen,
                  width: 1.3,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                label,
                style: AppTextStyles.toggle.copyWith(
                  color: AppColors.forestGreen,
                ),
              ),
            ),
    );
  }
}
