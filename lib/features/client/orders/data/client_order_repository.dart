import '../../../admin/orders/models/order_item.dart';
import '../../../admin/orders/models/restaurant_order.dart';

abstract class ClientOrderRepository {
  /// Flux temps réel des commandes d'un client.
  Stream<List<RestaurantOrder>> watchOrdersOf(String userId);

  /// Enregistre la commande (statut "reçue") avec un numéro automatique.
  Future<RestaurantOrder> createOrder({
    required String userId,
    required String clientName,
    required String clientPhone,
    required List<OrderItem> items,
    required double vatPercent,
  });
}