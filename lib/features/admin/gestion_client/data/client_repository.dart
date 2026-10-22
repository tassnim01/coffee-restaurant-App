import '../models/restaurant_client.dart';

abstract interface class ClientRepository {
  Stream<List<RestaurantClient>> watchClients();

  Future<void> addClient(RestaurantClient client);

  Future<void> updateClient(RestaurantClient client);

  Future<void> deleteClient(String clientId);
}
