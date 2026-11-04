import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/settings_repository.dart';
import '../models/restaurant_settings.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;
  StreamSubscription<RestaurantSettings>? _subscription;

  RestaurantSettings _settings = const RestaurantSettings();
  bool _isLoading = true;

  SettingsProvider(this._repository) {
    _subscription = _repository.watchSettings().listen(
      (data) {
        _settings = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        // En cas d'erreur, on garde le taux par défaut.
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  bool get isLoading => _isLoading;

  /// Taux de TVA en pourcentage (13 = 13 %).
  double get vatPercent => _settings.vatPercent;

  Future<void> updateVat(double percent) =>
      _repository.updateVatPercent(percent);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}