import '../../../admin/orders/models/order_item.dart';
import '../../../admin/orders/models/restaurant_order.dart';

abstract class ClientOrderRepository {
  /// Flux temps réel des commandes d'un client.
  Stream<List<RestaurantOrder>> watchOrdersOf(
    String userId, {
    String? clientName,
    String? clientPhone,
  });

  /// Enregistre la commande (statut "reçue") avec un numéro automatique.
  Future<RestaurantOrder> createOrder({
    required String userId,
    required String clientName,
    required String clientPhone,
    required String tableNumber,
    required List<OrderItem> items,
  });

  /// Remplace les articles d'une commande uniquement si elle est en attente.
  Future<void> updatePendingOrder({
    required String userId,
    required String orderId,
    required List<OrderItem> items,
  });
}
