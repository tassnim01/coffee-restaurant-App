import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../admin/orders/models/order_item.dart';
import '../../../admin/orders/models/restaurant_order.dart';
import '../../../auth/models/app_user.dart';
import '../../cart/models/cart_item.dart';
import '../data/client_order_repository.dart';

class ClientOrdersProvider extends ChangeNotifier {
  final ClientOrderRepository _repository;
  StreamSubscription<List<RestaurantOrder>>? _subscription;

  String? _uid;
  List<RestaurantOrder> _orders = [];
  bool _isLoading = false;
  bool _disposed = false;

  ClientOrdersProvider(this._repository);

  List<RestaurantOrder> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;

  /// Appelé quand l'utilisateur connecté change.
  void setUser(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _subscription?.cancel();
    _orders = [];

    if (uid == null) {
      _isLoading = false;
      scheduleMicrotask(() {
        if (!_disposed) notifyListeners();
      });
      return;
    }

    _isLoading = true;
    _subscription = _repository.watchOrdersOf(uid).listen(
      (data) {
        _orders = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  RestaurantOrder? byId(String id) {
    for (final o in _orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  /// Transforme le panier en commande et l'enregistre dans Firestore.
  Future<RestaurantOrder> placeOrder({
    required AppUser user,
    required List<CartItem> items,
    required double vatPercent,
  }) {
    final orderItems = items
        .map(
          (i) => OrderItem(
            productId: i.productId,
            name: i.name,
            quantity: i.quantity,
            unitPrice: i.unitPrice,
            // Les images encodées sont trop lourdes pour une commande.
            imageUrl: (i.imageUrl != null && i.imageUrl!.startsWith('http'))
                ? i.imageUrl
                : null,
            supplements: i.supplements,
          ),
        )
        .toList();

    return _repository.createOrder(
      userId: user.uid,
      clientName: user.name,
      clientPhone: user.phone,
      items: orderItems,
      vatPercent: vatPercent,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}