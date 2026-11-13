import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../orders/widgets/product_thumb.dart';
import '../../orders/models/restaurant_order.dart';
import '../../orders/providers/orders_provider.dart';
import '../../orders/screens/order_details_screen.dart';
import '../../orders/widgets/order_status_chip.dart';
import '../models/dashboard_stats.dart';
import '../widgets/stat_card.dart';
import '../widgets/status_donut.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback onSeeOrders;

  const DashboardScreen({super.key, this.onMenuTap, required this.onSeeOrders});

  // Couleurs de l'anneau : En cours, Prêtes, Livrées.
  static const _colors = [
    AppColors.warmBeige,
    AppColors.forestGreen,
    AppColors.darkPanel,
  ];

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>();
    final stats = DashboardStats.from(orders.orders, DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              Expanded(
                child: orders.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildTopCards(stats),
                            const SizedBox(height: 14),
                            _buildStatusCard(stats),
                            const SizedBox(height: 14),
                            _buildRecentCard(context, stats),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: onSeeOrders,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.forestGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text('Voir toutes les commandes',
                        style: AppTextStyles.button),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onMenuTap ?? () => Navigator.of(context).maybePop(),
          icon: Icon(
            onMenuTap != null
                ? Icons.menu_rounded
                : Icons.chevron_left_rounded,
            size: 28,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text('Tableau de bord', style: AppTextStyles.screenTitle),
        ),
      ],
    );
  }

  Widget _buildTopCards(DashboardStats stats) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: "Commandes aujourd'hui",
            value: '${stats.todayCount}',
            icon: Icons.receipt_long_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            label: "Chiffre d'affaires",
            value: Formatters.dt(stats.todayRevenue),
            icon: Icons.monetization_on_outlined,
          ),
        ),
      ],
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
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
      );

  Widget _buildStatusCard(DashboardStats stats) {
    final entries = [
      ('En cours', stats.inProgress),
      ('Prêtes', stats.ready),
      ('Livrées', stats.delivered),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Statut des commandes', style: AppTextStyles.productName),
          const SizedBox(height: 14),
          Row(
            children: [
              StatusDonut(
                values: entries.map((e) => e.$2.toDouble()).toList(),
                colors: _colors,
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  children: [
                    for (var i = 0; i < entries.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _colors[i],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(entries[i].$1,
                                  style: AppTextStyles.body),
                            ),
                            Text(
                              '${entries[i].$2}',
                              style: AppTextStyles.productName
                                  .copyWith(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Commandes d'aujourd'hui",
            style: AppTextStyles.chip.copyWith(color: AppColors.gray),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCard(BuildContext context, DashboardStats stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Commandes récentes', style: AppTextStyles.productName),
          const SizedBox(height: 10),
          if (stats.recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  'Aucune commande pour le moment',
                  style: AppTextStyles.body.copyWith(color: AppColors.gray),
                ),
              ),
            )
          else
            for (final order in stats.recent) _recentRow(context, order),
        ],
      ),
    );
  }

  Widget _recentRow(BuildContext context, RestaurantOrder order) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OrderDetailsScreen(orderId: order.id),
        ),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            ProductThumb(
              productId:
                  order.items.isEmpty ? null : order.items.first.productId,
              imageUrl: order.coverImage,
              size: 44,
              radius: 12,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.code,
                      style: AppTextStyles.productName.copyWith(fontSize: 13.5)),
                  Text(
                    Formatters.time(order.createdAt),
                    style: AppTextStyles.chip
                        .copyWith(color: AppColors.gray, fontSize: 11.5),
                  ),
                ],
              ),
            ),
            OrderStatusChip(status: order.status),
            const SizedBox(width: 12),
            SizedBox(
              width: 64,
              child: Text(
                Formatters.dt(order.total),
                textAlign: TextAlign.right,
                style: AppTextStyles.productName.copyWith(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}