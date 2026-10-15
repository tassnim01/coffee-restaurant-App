import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/utils/formatters.dart';
import '../data/client_repository.dart';
import '../models/restaurant_client.dart';

class ClientsProvider extends ChangeNotifier {
  final ClientRepository _repository;
  StreamSubscription<List<RestaurantClient>>? _subscription;

  List<RestaurantClient> _clients = [];
  bool _isLoading = true;
  String? _error;

  ClientsProvider(this._repository) {
    _subscribe();
  }

  List<RestaurantClient> get clients => List.unmodifiable(_clients);
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _subscribe() {
    _isLoading = true;
    _error = null;
    _subscription?.cancel();
    _subscription = _repository.watchClients().listen(
      (data) {
        _clients = data;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        _error = 'Impossible de charger les clients.';
        notifyListeners();
      },
    );
  }

  void retry() {
    _subscribe();
    notifyListeners();
  }

  List<RestaurantClient> filtered(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return clients;
    final qPhone = Formatters.normalizePhone(q);
    return _clients.where((c) {
      return c.name.toLowerCase().contains(q) ||
          (qPhone.isNotEmpty &&
              Formatters.normalizePhone(c.phone).contains(qPhone));
    }).toList();
  }

  /// Vrai si un autre client utilise déjà ce numéro.
  bool phoneExists(String phone, {String? excludeId}) {
    final target = Formatters.normalizePhone(phone);
    return _clients.any(
      (c) => c.id != excludeId && Formatters.normalizePhone(c.phone) == target,
    );
  }

  // L'interface se met à jour via le flux temps réel.
  Future<void> addClient(RestaurantClient client) =>
      _repository.addClient(client);

  Future<void> updateClient(RestaurantClient client) =>
      _repository.updateClient(client);

  Future<void> deleteClient(String clientId) =>
      _repository.deleteClient(clientId);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}