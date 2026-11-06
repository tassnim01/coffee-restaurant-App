import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../admin/orders/models/order_status.dart';
import '../../../admin/orders/models/restaurant_order.dart';
import '../../../admin/orders/widgets/order_status_chip.dart';
import '../../../admin/orders/widgets/product_thumb.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/client_orders_provider.dart';
import 'client_order_detail_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  static const _tabs = [
    OrderTab.pending,
    OrderTab.inProgress,
    OrderTab.ready,
    OrderTab.delivered,
  ];
  OrderTab _tab = OrderTab.inProgress;

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<ClientOrdersProvider>();
    final visible = orders.orders
        .where((o) => _tab.includes(o.status))
        .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: _buildTabs(),
            ),
            Expanded(
              child: orders.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : visible.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: visible.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, i) =>
                          _OrderCard(order: visible[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Container(
      color: AppColors.darkPanel,
      padding: EdgeInsets.fromLTRB(
        8,
        MediaQuery.of(context).padding.top + 8,
        12,
        12,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          Expanded(
            child: Text(
              'Mes commandes',
              style: AppTextStyles.screenTitle.copyWith(color: Colors.white),
            ),
          ),
          PopupMenuButton<String>(
            color: AppColors.surface,
            onSelected: (value) async {
              if (value == 'logout') {
                final navigator = Navigator.of(context);
                await auth.logout();
                navigator.pop();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Text(auth.user?.name ?? '', style: AppTextStyles.body),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Text('Se déconnecter', style: AppTextStyles.body),
              ),
            ],
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: _tabs.map((tab) {
        final selected = tab == _tab;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: tab == _tabs.last ? 0 : 8),
            child: GestureDetector(
              onTap: () => setState(() => _tab = tab),
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
                  tab.label,
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

  Widget _buildEmpty() {
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
}

class _OrderCard extends StatelessWidget {
  final RestaurantOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final subtle = AppTextStyles.chip.copyWith(
      color: AppColors.gray,
      fontSize: 12,
    );

    return Container(
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
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ClientOrderDetailScreen(orderId: order.id),
            ),
          ),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ProductThumb(
                  productId: order.items.isEmpty
                      ? null
                      : order.items.first.productId,
                  imageUrl: order.coverImage,
                  size: 58,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.code, style: AppTextStyles.productName),
                      const SizedBox(height: 4),
                      Text(Formatters.dateTime(order.createdAt), style: subtle),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    OrderStatusChip(status: order.status),
                    const SizedBox(height: 14),
                    Text(
                      Formatters.dt(order.total),
                      style: AppTextStyles.productName.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
