import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../menu/widgets/menu_search_field.dart';
import '../models/order_status.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_card.dart';
import '../widgets/order_tabs_bar.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const OrdersScreen({super.key, this.onMenuTap});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  OrderTab _tab = OrderTab.all;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              OrderTabsBar(
                selected: _tab,
                onChanged: (t) => setState(() => _tab = t),
              ),
              const SizedBox(height: 12),
              MenuSearchField(
                hint: 'Rechercher une commande...',
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 14),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: widget.onMenuTap ?? () => Navigator.of(context).maybePop(),
          icon: Icon(
            widget.onMenuTap != null
                ? Icons.menu_rounded
                : Icons.chevron_left_rounded,
            size: 28,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            'Gestion des commandes',
            style: AppTextStyles.screenTitle,
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    final provider = context.watch<OrdersProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.error!, style: AppTextStyles.body),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: provider.retry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
              ),
              child: Text('Réessayer', style: AppTextStyles.button),
            ),
          ],
        ),
      );
    }

    final orders = provider.filtered(tab: _tab, query: _query);

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 46,
              color: AppColors.gray,
            ),
            const SizedBox(height: 10),
            Text(
              'Aucune commande',
              style: AppTextStyles.body.copyWith(color: AppColors.gray),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final order = orders[i];
        return OrderCard(
          order: order,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OrderDetailsScreen(orderId: order.id),
            ),
          ),
        );
      },
    );
  }
}
