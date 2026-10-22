import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../shell/client_shell.dart';

/// Écran de bienvenue : image plein écran + bouton "Commencer".
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _start(BuildContext context) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const ClientShell()));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/splash_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const ColoredBox(color: AppColors.darkPanel),
            ),
            Positioned(
              left: 28,
              right: 28,
              bottom: MediaQuery.of(context).padding.bottom + 44,
              child: SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: () => _start(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.warmBeige,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Commencer',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.black,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
