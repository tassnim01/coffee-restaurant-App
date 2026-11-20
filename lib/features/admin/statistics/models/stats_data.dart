import '../../orders/models/restaurant_order.dart';

/// true = ne compter que les commandes payées (encaissées).
/// false = compter toutes les commandes, comme le tableau de bord.
const bool kStatsOnlyPaidOrders = false;

enum StatsPeriod { week, days30, month }

extension StatsPeriodX on StatsPeriod {
  String get label {
    switch (this) {
      case StatsPeriod.week:
        return '7 jours';
      case StatsPeriod.days30:
        return '30 jours';
      case StatsPeriod.month:
        return 'Mois';
    }
  }
}

/// Un plat du classement.
class TopDish {
  final String name;
  final String? productId;
  final String? imageUrl;
  final int quantity;
  final double revenue;

  const TopDish({
    required this.name,
    required this.productId,
    required this.imageUrl,
    required this.quantity,
    required this.revenue,
  });
}

class _Acc {
  final String name;
  final String? productId;
  final String? imageUrl;
  int quantity = 0;
  double revenue = 0;

  _Acc(this.name, this.productId, this.imageUrl);
}

/// Chiffres d'une période, comparés à la période précédente.
class StatsData {
  final double revenue;
  final double previousRevenue;
  final int orderCount;
  final int previousOrderCount;
  final List<double> series; // chiffre d'affaires par jour
  final List<String> labels; // étiquettes de l'axe horizontal
  final List<TopDish> topDishes;

  const StatsData({
    required this.revenue,
    required this.previousRevenue,
    required this.orderCount,
    required this.previousOrderCount,
    required this.series,
    required this.labels,
    required this.topDishes,
  });

  /// Évolution en % par rapport à la période précédente (null si impossible).
  double? get revenueChange => _change(revenue, previousRevenue);
  double? get ordersChange =>
      _change(orderCount.toDouble(), previousOrderCount.toDouble());

  static double? _change(double current, double previous) {
    if (previous == 0) return null;
    return (current - previous) / previous * 100;
  }

  static const _weekdays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  factory StatsData.compute(
    List<RestaurantOrder> all,
    StatsPeriod period,
    DateTime now,
  ) {
    // Dates en UTC pour éviter les décalages d'heure d'été.
    DateTime day(DateTime d) => DateTime.utc(d.year, d.month, d.day);
    final today = day(now);

    late final DateTime start;
    late final int days;
    late final DateTime prevStart;
    late final int prevDays;

    switch (period) {
      case StatsPeriod.week:
        days = 7;
        prevDays = 7;
        start = today.subtract(const Duration(days: 6));
        prevStart = start.subtract(const Duration(days: 7));
        break;
      case StatsPeriod.days30:
        days = 30;
        prevDays = 30;
        start = today.subtract(const Duration(days: 29));
        prevStart = start.subtract(const Duration(days: 30));
        break;
      case StatsPeriod.month:
        start = DateTime.utc(now.year, now.month, 1);
        days = today.day;
        prevStart = DateTime.utc(now.year, now.month - 1, 1);
        final prevMonthLength = DateTime.utc(now.year, now.month, 0).day;
        prevDays = days < prevMonthLength ? days : prevMonthLength;
        break;
    }

    int indexIn(DateTime d, DateTime s, int n) {
      final i = d.difference(s).inDays;
      return (i >= 0 && i < n) ? i : -1;
    }

    final series = List<double>.filled(days, 0);
    final dishes = <String, _Acc>{};
    var revenue = 0.0;
    var count = 0;
    var prevRevenue = 0.0;
    var prevCount = 0;

    for (final o in all) {
      if (kStatsOnlyPaidOrders && !o.isPaid) continue;
      final d = day(o.createdAt);

      final i = indexIn(d, start, days);
      if (i != -1) {
        series[i] += o.total;
        revenue += o.total;
        count++;
        for (final item in o.items) {
          final key = item.productId.isNotEmpty ? item.productId : item.name;
          final acc = dishes.putIfAbsent(
            key,
            () => _Acc(
              item.name,
              item.productId.isEmpty ? null : item.productId,
              item.imageUrl,
            ),
          );
          acc.quantity += item.quantity;
          acc.revenue += item.lineTotal;
        }
        continue;
      }

      if (indexIn(d, prevStart, prevDays) != -1) {
        prevRevenue += o.total;
        prevCount++;
      }
    }

    final labels = List<String>.generate(days, (i) {
      final date = start.add(Duration(days: i));
      return period == StatsPeriod.week
          ? _weekdays[date.weekday - 1]
          : '${date.day}';
    });

    final top = dishes.values.toList()
      ..sort((a, b) {
        final byQty = b.quantity.compareTo(a.quantity);
        return byQty != 0 ? byQty : b.revenue.compareTo(a.revenue);
      });

    return StatsData(
      revenue: revenue,
      previousRevenue: prevRevenue,
      orderCount: count,
      previousOrderCount: prevCount,
      series: series,
      labels: labels,
      topDishes: top
          .take(10)
          .map((a) => TopDish(
                name: a.name,
                productId: a.productId,
                imageUrl: a.imageUrl,
                quantity: a.quantity,
                revenue: a.revenue,
              ))
          .toList(),
    );
  }
}