import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../orders/widgets/product_thumb.dart';
import '../../orders/providers/orders_provider.dart';
import '../models/stats_data.dart';
import '../widgets/kpi_card.dart';
import '../widgets/sales_chart.dart';

class StatisticsScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const StatisticsScreen({super.key, this.onMenuTap});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  StatsPeriod _period = StatsPeriod.week;
  bool _showAll = false;

  BoxDecoration get _card => BoxDecoration(
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

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>();
    final data = StatsData.compute(orders.orders, _period, DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed:
                        widget.onMenuTap ?? () => Navigator.of(context).maybePop(),
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
                    child: Text('Statistiques', style: AppTextStyles.screenTitle),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildTabs(),
              const SizedBox(height: 14),
              Expanded(
                child: orders.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: KpiCard(
                                    label: "Chiffre d'affaires",
                                    value: Formatters.dt(data.revenue),
                                    change: data.revenueChange,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: KpiCard(
                                    label: 'Nombre de commandes',
                                    value: '${data.orderCount}',
                                    change: data.ordersChange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _buildChartCard(data),
                            const SizedBox(height: 14),
                            _buildTopDishes(data),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: StatsPeriod.values.map((p) {
        final selected = p == _period;
        return Expanded(
          child: Padding(
            padding:
                EdgeInsets.only(right: p == StatsPeriod.values.last ? 0 : 8),
            child: GestureDetector(
              onTap: () => setState(() => _period = p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.forestGreen : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppColors.forestGreen : AppColors.border,
                  ),
                ),
                child: Text(
                  p.label,
                  style: AppTextStyles.toggle.copyWith(
                    fontSize: 13,
                    color: selected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChartCard(StatsData data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Évolution des ventes', style: AppTextStyles.productName),
          const SizedBox(height: 12),
          SalesChart(values: data.series, labels: data.labels),
        ],
      ),
    );
  }

  Widget _buildTopDishes(StatsData data) {
    final dishes = data.topDishes;
    final visible = _showAll ? dishes : dishes.take(3).toList();
    final maxQty = dishes.isEmpty ? 1 : dishes.first.quantity;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Top plats', style: AppTextStyles.productName),
              ),
              if (dishes.length > 3)
                GestureDetector(
                  onTap: () => setState(() => _showAll = !_showAll),
                  child: Text(
                    _showAll ? 'Réduire' : 'Voir tout',
                    style: AppTextStyles.toggle.copyWith(
                      fontSize: 12.5,
                      color: AppColors.forestGreen,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Text(
                  'Aucune vente sur cette période',
                  style: AppTextStyles.body.copyWith(color: AppColors.gray),
                ),
              ),
            )
          else
            for (final d in visible) _dishRow(d, maxQty),
        ],
      ),
    );
  }

  Widget _dishRow(TopDish dish, int maxQty) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ProductThumb(
            productId: dish.productId,
            imageUrl: dish.imageUrl,
            size: 48,
            radius: 12,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.productName.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  '${dish.quantity} vente${dish.quantity > 1 ? 's' : ''}',
                  style: AppTextStyles.chip
                      .copyWith(color: AppColors.gray, fontSize: 12),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: dish.quantity / maxQty,
                    minHeight: 5,
                    backgroundColor: AppColors.border,
                    color: AppColors.forestGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            Formatters.dt(dish.revenue),
            style: AppTextStyles.productName.copyWith(fontSize: 13.5),
          ),
        ],
      ),
    );
  }
}