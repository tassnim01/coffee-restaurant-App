import 'order_item.dart';
import 'order_status.dart';

class RestaurantOrder {
  final String id;
  final int number; // 1045 -> "#C-1045"
  final String? userId; // compte du client (null pour les commandes de démo)
  final String clientName;
  final String clientPhone;
  final String? tableNumber;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final String? invoicePdfBase64;
  final bool isPaid; // true après confirmation du paiement en espèces

  const RestaurantOrder({
    required this.id,
    required this.number,
    this.userId,
    required this.clientName,
    required this.clientPhone,
    this.tableNumber,
    required this.items,
    required this.status,
    required this.createdAt,
    this.invoicePdfBase64,
    this.isPaid = false,
  });

  String get code => '#C-$number';

  double get subtotal => items.fold<double>(0, (sum, i) => sum + i.lineTotal);
  double get total => subtotal;

  String? get coverImage => items.isEmpty ? null : items.first.imageUrl;

  Map<String, dynamic> toMap() => {
    'number': number,
    'userId': userId,
    'clientName': clientName,
    'clientPhone': clientPhone,
    'tableNumber': tableNumber,
    'items': items.map((i) => i.toMap()).toList(),
    'status': status.name,
    'subtotal': subtotal,
    'total': total,
    if (invoicePdfBase64 != null) 'invoicePdfBase64': invoicePdfBase64,
  };

  factory RestaurantOrder.fromMap(
    String id,
    Map<String, dynamic> map, {
    required DateTime createdAt,
  }) => RestaurantOrder(
    id: id,
    number: (map['number'] as num?)?.toInt() ?? 0,
    userId: map['userId'] as String?,
    clientName: map['clientName'] as String? ?? '',
    clientPhone: map['clientPhone'] as String? ?? '',
    tableNumber: map['tableNumber'] as String?,
    items: (map['items'] as List<dynamic>? ?? [])
        .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList(),
    status: orderStatusFromKey(map['status'] as String?),
    createdAt: createdAt,
    invoicePdfBase64: map['invoicePdfBase64'] as String?,
    isPaid: map['isPaid'] as bool? ?? false,
  );

  RestaurantOrder copyWith({
    List<OrderItem>? items,
    String? invoicePdfBase64,
  }) => RestaurantOrder(
    id: id,
    number: number,
    userId: userId,
    clientName: clientName,
    clientPhone: clientPhone,
    tableNumber: tableNumber,
    items: items ?? this.items,
    status: status,
    createdAt: createdAt,
    invoicePdfBase64: invoicePdfBase64 ?? this.invoicePdfBase64,
  );
}
