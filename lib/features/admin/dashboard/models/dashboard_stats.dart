import '../../orders/models/order_status.dart';
import '../../orders/models/restaurant_order.dart';

/// Chiffres du jour calculés à partir de la liste des commandes.
class DashboardStats {
  final int todayCount;
  final double todayRevenue;
  final int inProgress; // reçues + en cours
  final int ready;
  final int delivered;
  final List<RestaurantOrder> recent; // les 5 plus récentes

  const DashboardStats({
    required this.todayCount,
    required this.todayRevenue,
    required this.inProgress,
    required this.ready,
    required this.delivered,
    required this.recent,
  });

  factory DashboardStats.from(List<RestaurantOrder> orders, DateTime now) {
    bool isToday(DateTime d) =>
        d.year == now.year && d.month == now.month && d.day == now.day;

    final today = orders.where((o) => isToday(o.createdAt)).toList();

    int count(bool Function(OrderStatus) test) =>
        today.where((o) => test(o.status)).length;

    // Les commandes arrivent déjà triées de la plus récente à la plus ancienne.
    return DashboardStats(
      todayCount: today.length,
      todayRevenue: today.fold(0.0, (sum, o) => sum + o.total),
      inProgress: count(
        (s) => s == OrderStatus.received || s == OrderStatus.preparing,
      ),
      ready: count((s) => s == OrderStatus.ready),
      delivered: count((s) => s == OrderStatus.delivered),
      recent: orders.take(5).toList(),
    );
  }
}
