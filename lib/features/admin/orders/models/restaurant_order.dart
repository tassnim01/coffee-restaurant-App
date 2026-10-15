import 'order_item.dart';
import 'order_status.dart';

class RestaurantOrder {
  final String id;
  final int number; // 1045 -> "#C-1045"
  final String clientName;
  final String clientPhone;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;

  const RestaurantOrder({
    required this.id,
    required this.number,
    required this.clientName,
    required this.clientPhone,
    required this.items,
    required this.status,
    required this.createdAt,
  });

  String get code => '#C-$number';

  double get total => items.fold<double>(0, (sum, i) => sum + i.lineTotal);

  String? get coverImage => items.isEmpty ? null : items.first.imageUrl;

  Map<String, dynamic> toMap() => {
    'number': number,
    'clientName': clientName,
    'clientPhone': clientPhone,
    'items': items.map((i) => i.toMap()).toList(),
    'status': status.name,
    'total': total,
  };

  factory RestaurantOrder.fromMap(
    String id,
    Map<String, dynamic> map, {
    required DateTime createdAt,
  }) => RestaurantOrder(
    id: id,
    number: (map['number'] as num?)?.toInt() ?? 0,
    clientName: map['clientName'] as String? ?? '',
    clientPhone: map['clientPhone'] as String? ?? '',
    items: (map['items'] as List<dynamic>? ?? [])
        .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList(),
    status: orderStatusFromKey(map['status'] as String?),
    createdAt: createdAt,
  );
}
