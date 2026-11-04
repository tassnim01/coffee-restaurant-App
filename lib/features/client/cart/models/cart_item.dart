import '../../../admin/menu/models/product.dart';
import '../../../admin/menu/models/supplement.dart';

/// Une ligne du panier : un produit, ses suppléments choisis, une quantité.
class CartItem {
  final String productId;
  final String name;
  final String? imageUrl;
  final double unitPrice;
  final List<Supplement> supplements;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.supplements,
    this.quantity = 1,
  });

  factory CartItem.fromProduct(
    Product p, {
    List<Supplement> supplements = const [],
    int quantity = 1,
  }) =>
      CartItem(
        productId: p.id,
        name: p.name,
        imageUrl: p.imageUrl,
        unitPrice: p.price,
        supplements: List.unmodifiable(supplements),
        quantity: quantity,
      );

  /// Deux lignes avec le même produit et les mêmes suppléments sont fusionnées.
  String get key {
    final names = supplements.map((s) => s.name).toList()..sort();
    return '$productId|${names.join(',')}';
  }

  double get supplementsTotal =>
      supplements.fold(0.0, (sum, s) => sum + s.price);

  /// Prix d'une unité avec ses suppléments.
  double get unitTotal => unitPrice + supplementsTotal;

  double get lineTotal => unitTotal * quantity;

  /// "Caramel (+0.500 DT), Frites (+1.000 DT)"
  String get supplementsLabel => supplements
      .map((s) => '${s.name} (+${s.price.toStringAsFixed(3)} DT)')
      .join(', ');
}