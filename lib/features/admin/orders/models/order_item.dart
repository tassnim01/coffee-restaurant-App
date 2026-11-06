import '../../menu/models/supplement.dart';

class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double unitPrice; // prix de base, sans suppléments
  final String? imageUrl;
  final List<Supplement> supplements;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.imageUrl,
    this.supplements = const [],
  });

  double get supplementsTotal =>
      supplements.fold(0.0, (sum, s) => sum + s.price);

  double get lineTotal => quantity * (unitPrice + supplementsTotal);

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'name': name,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'imageUrl': imageUrl,
        'supplements': supplements.map((s) => s.toMap()).toList(),
      };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        productId: map['productId'] as String? ?? '',
        name: map['name'] as String? ?? '',
        quantity: (map['quantity'] as num?)?.toInt() ?? 1,
        unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0,
        imageUrl: map['imageUrl'] as String?,
        supplements: (map['supplements'] as List<dynamic>? ?? [])
            .map((e) => Supplement.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}