import '../models/order_status.dart';
import '../models/restaurant_order.dart';

abstract class OrderRepository {
  /// Flux temps réel des commandes (les plus récentes d'abord).
  Stream<List<RestaurantOrder>> watchOrders();

  Future<void> updateStatus(String orderId, OrderStatus status);
}