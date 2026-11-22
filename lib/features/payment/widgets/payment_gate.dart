import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../admin/orders/models/order_status.dart';
import '../../admin/orders/models/restaurant_order.dart';
import '../../client/orders/providers/client_orders_provider.dart';

/// Bloque l'application tant qu'une commande livrée n'est pas payée.
/// [isClient] : true pour l'espace client, false pour le responsable.
class PaymentGate extends StatefulWidget {
  final bool isClient;
  final Widget child;

  const PaymentGate({super.key, required this.isClient, required this.child});

  @override
  State<PaymentGate> createState() => _PaymentGateState();
}

class _PaymentGateState extends State<PaymentGate> with WidgetsBindingObserver {
  String? _blockedCode; // client : dernière commande qui bloquait
  String? _successCode;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // L'app redevient visible : on force l'affichage immédiat du blocage
    // (évite une frame où l'ancien contenu serait visible).
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() {});
    }
  }

  void _setImmersive(bool on) {
    SystemChrome.setEnabledSystemUIMode(
      on ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  RestaurantOrder? _blocking(BuildContext context) {
    if (!widget.isClient) return null;
    for (final o in context.watch<ClientOrdersProvider>().orders) {
      if (o.status == OrderStatus.delivered && !o.isPaid) return o;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final blocking = _blocking(context);

    // Client : détecte le passage « bloqué » -> « payé » pour afficher le message.
    if (widget.isClient) {
      if (blocking != null) {
        _blockedCode = blocking.code;
      } else if (_blockedCode != null) {
        _successCode = _blockedCode;
        _blockedCode = null;
      }
    }

    Widget? overlay;
    if (_successCode != null) {
      final code = _successCode!;
      overlay = _PaymentCard(
        icon: Icons.check_rounded,
        iconColor: AppColors.forestGreen,
        title: 'Paiement reçu !',
        message:
            "Merci ! Votre commande $code a bien été réglée. Vous pouvez maintenant accéder à l'application.",
        buttonLabel: 'OK',
        onPressed: () => setState(() => _successCode = null),
      );
    } else if (blocking != null) {
      overlay = const _ClientBlockedCard();
    }

    _setImmersive(overlay != null);

    return PopScope(
      // Le bouton retour (et le geste retour) ne fait rien tant que bloqué.
      canPop: overlay == null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (overlay != null)
            Positioned.fill(child: _Barrier(fillScreen: true, child: overlay)),
        ],
      ),
    );
  }
}

/// Fond sombre qui bloque tous les appuis sur l'application.
class _Barrier extends StatelessWidget {
  final Widget child;
  final bool fillScreen;

  const _Barrier({required this.child, this.fillScreen = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Material(
            color: Colors.black.withValues(alpha: 0.78),
            child: SafeArea(
              child: fillScreen
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: SizedBox.expand(child: child),
                    )
                  : Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: child,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClientBlockedCard extends StatelessWidget {
  const _ClientBlockedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF171B18).withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Application bloquée',
            textAlign: TextAlign.center,
            style: AppTextStyles.screenTitle.copyWith(
              color: Colors.white,
              fontSize: 21,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Votre commande n'est pas encore payée. "
            "L'application est temporairement bloquée jusqu’à "
            'la confirmation du paiement en espèces à la livraison.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _PaymentCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.screenTitle.copyWith(fontSize: 19),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.gray,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(buttonLabel, style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
