import 'package:flutter/foundation.dart';
import '../../../admin/menu/models/product.dart';
import '../../../admin/menu/models/supplement.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;

  /// Nombre total d'articles (somme des quantités), pour le badge.
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => _items.fold(0.0, (sum, i) => sum + i.lineTotal);

  /// TVA pour un taux donné en pourcentage (13 = 13 %).
  double vatFor(double percent) => subtotal * percent / 100;

  double totalFor(double percent) => subtotal + vatFor(percent);

  void add(
    Product product, {
    List<Supplement> supplements = const [],
    int quantity = 1,
  }) {
    final candidate = CartItem.fromProduct(
      product,
      supplements: supplements,
      quantity: quantity,
    );
    final index = _items.indexWhere((e) => e.key == candidate.key);
    if (index == -1) {
      _items.add(candidate);
    } else {
      _items[index].quantity += quantity;
    }
    notifyListeners();
  }

  void increment(String key) {
    final index = _items.indexWhere((e) => e.key == key);
    if (index == -1) return;
    _items[index].quantity++;
    notifyListeners();
  }

  /// La quantité ne descend pas sous 1 : on retire la ligne avec la corbeille.
  void decrement(String key) {
    final index = _items.indexWhere((e) => e.key == key);
    if (index == -1 || _items[index].quantity <= 1) return;
    _items[index].quantity--;
    notifyListeners();
  }

  void remove(String key) {
    _items.removeWhere((e) => e.key == key);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}