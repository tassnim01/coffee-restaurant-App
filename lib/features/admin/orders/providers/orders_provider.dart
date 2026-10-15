import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/order_repository.dart';
import '../models/order_status.dart';
import '../models/restaurant_order.dart';

class OrdersProvider extends ChangeNotifier {
  final OrderRepository _repository;
  StreamSubscription<List<RestaurantOrder>>? _subscription;

  List<RestaurantOrder> _orders = [];
  bool _isLoading = true;
  String? _error;

  OrdersProvider(this._repository) {
    _subscribe();
  }

  List<RestaurantOrder> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _subscribe() {
    _isLoading = true;
    _error = null;
    _subscription?.cancel();
    _subscription = _repository.watchOrders().listen(
      (data) {
        _orders = data;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        _error = 'Impossible de charger les commandes.';
        notifyListeners();
      },
    );
  }

  void retry() {
    _subscribe();
    notifyListeners();
  }

  RestaurantOrder? byId(String id) {
    for (final o in _orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  List<RestaurantOrder> filtered({
    required OrderTab tab,
    String query = '',
  }) {
    final q = query.trim().toLowerCase();
    return _orders.where((o) {
      final matchesQuery = q.isEmpty ||
          o.code.toLowerCase().contains(q) ||
          o.number.toString().contains(q) ||
          o.clientName.toLowerCase().contains(q);
      return tab.includes(o.status) && matchesQuery;
    }).toList();
  }

  /// Écrit le nouveau statut dans Firestore.
  /// L'interface se met à jour via le flux temps réel.
  Future<void> updateStatus(String orderId, OrderStatus status) {
    return _repository.updateStatus(orderId, status);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}