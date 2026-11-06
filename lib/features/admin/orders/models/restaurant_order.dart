import 'order_item.dart';
import 'order_status.dart';

class RestaurantOrder {
  final String id;
  final int number; // 1045 -> "#C-1045"
  final String? userId; // compte du client (null pour les commandes de démo)
  final String clientName;
  final String clientPhone;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final double vatPercent; // taux appliqué à cette commande (13 = 13 %)

  const RestaurantOrder({
    required this.id,
    required this.number,
    this.userId,
    required this.clientName,
    required this.clientPhone,
    required this.items,
    required this.status,
    required this.createdAt,
    this.vatPercent = 0,
  });

  String get code => '#C-$number';

  double get subtotal => items.fold<double>(0, (sum, i) => sum + i.lineTotal);
  double get vat => subtotal * vatPercent / 100;
  double get total => subtotal + vat;

  String? get coverImage => items.isEmpty ? null : items.first.imageUrl;

  Map<String, dynamic> toMap() => {
        'number': number,
        'userId': userId,
        'clientName': clientName,
        'clientPhone': clientPhone,
        'items': items.map((i) => i.toMap()).toList(),
        'status': status.name,
        'subtotal': subtotal,
        'vatPercent': vatPercent,
        'vat': vat,
        'total': total,
      };

  factory RestaurantOrder.fromMap(
    String id,
    Map<String, dynamic> map, {
    required DateTime createdAt,
  }) =>
      RestaurantOrder(
        id: id,
        number: (map['number'] as num?)?.toInt() ?? 0,
        userId: map['userId'] as String?,
        clientName: map['clientName'] as String? ?? '',
        clientPhone: map['clientPhone'] as String? ?? '',
        items: (map['items'] as List<dynamic>? ?? [])
            .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
        status: orderStatusFromKey(map['status'] as String?),
        createdAt: createdAt,
        vatPercent: (map['vatPercent'] as num?)?.toDouble() ?? 0,
      );
}