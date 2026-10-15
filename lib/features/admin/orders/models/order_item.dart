class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double unitPrice; // en DT
  final String? imageUrl;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.imageUrl,
  });

  double get lineTotal => quantity * unitPrice;

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'name': name,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'imageUrl': imageUrl,
      };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        productId: map['productId'] as String? ?? '',
        name: map['name'] as String? ?? '',
        quantity: (map['quantity'] as num?)?.toInt() ?? 1,
        unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0,
        imageUrl: map['imageUrl'] as String?,
      );
}