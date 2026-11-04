import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/product_image.dart';
import '../../../../core/widgets/quantity_stepper.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../../../admin/settings/providers/settings_provider.dart';

class CartScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSeeMenu;

  const CartScreen({super.key, required this.onBack, required this.onSeeMenu});

  Future<void> _clear(BuildContext context) async {
    final cart = context.read<CartProvider>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Vider le panier',
      message: 'Voulez-vous retirer tous les articles du panier ?',
      confirmLabel: 'Vider',
    );
    if (confirmed) cart.clear();
  }

  void _validate(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            "La validation de la commande (inscription, PDF) arrive à l'étape suivante.",
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final vatPercent = context.watch<SettingsProvider>().vatPercent;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Column(
          children: [
            _buildHeader(context, cart),
            Expanded(
              child: cart.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      itemCount: cart.items.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, i) => _CartItemTile(
                        item: cart.items[i],
                        onMinus: () => cart.decrement(cart.items[i].key),
                        onPlus: () => cart.increment(cart.items[i].key),
                        onDelete: () => cart.remove(cart.items[i].key),
                      ),
                    ),
            ),
            if (!cart.isEmpty) _buildSummary(context, cart, vatPercent),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CartProvider cart) {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(
        8,
        MediaQuery.of(context).padding.top + 8,
        8,
        12,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
              size: 26,
            ),
          ),
          const Icon(
            Icons.shopping_bag_outlined,
            color: AppColors.forestGreen,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Mon panier',
              style: AppTextStyles.screenTitle.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (!cart.isEmpty)
            IconButton(
              onPressed: () => _clear(context),
              tooltip: 'Vider le panier',
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 56,
            color: AppColors.gray,
          ),
          const SizedBox(height: 12),
          Text('Votre panier est vide', style: AppTextStyles.screenTitle),
          const SizedBox(height: 6),
          Text(
            'Ajoutez des plats depuis le menu.',
            style: AppTextStyles.body.copyWith(color: AppColors.gray),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onSeeMenu,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.forestGreen,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text('Voir le menu', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(
    BuildContext context,
    CartProvider cart,
    double vatPercent,
  ) {
    Widget row(String label, String value, {bool big = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: big
                  ? AppTextStyles.productName.copyWith(fontSize: 16)
                  : AppTextStyles.body,
            ),
          ),
          Text(
            value,
            style: big
                ? AppTextStyles.screenTitle.copyWith(fontSize: 17)
                : AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.of(context).padding.bottom * 0,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          row('Sous-total', money(cart.subtotal)),
          row('TVA (${percent(vatPercent)}%)', money(cart.vatFor(vatPercent))),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(height: 1, color: AppColors.border),
          ),
          row('TVA (${percent(vatPercent)}%)', money(cart.vatFor(vatPercent))),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () => _validate(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Valider la commande', style: AppTextStyles.button),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onDelete;

  const _CartItemTile({
    required this.item,
    required this.onMinus,
    required this.onPlus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImage(imageUrl: item.imageUrl, size: 78, radius: 14),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.productName,
                      ),
                    ),
                    InkWell(
                      onTap: onDelete,
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: AppColors.burgundy,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  money(item.unitPrice),
                  style: AppTextStyles.productName.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 6),
                QuantityStepper(
                  value: item.quantity,
                  onMinus: onMinus,
                  onPlus: onPlus,
                ),
                if (item.supplements.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.supplementsLabel,
                    style: AppTextStyles.chip.copyWith(
                      color: AppColors.gray,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
