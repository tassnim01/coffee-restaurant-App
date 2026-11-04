import '../models/restaurant_settings.dart';

abstract class SettingsRepository {
  /// Flux temps réel des paramètres du restaurant.
  Stream<RestaurantSettings> watchSettings();

  Future<void> updateVatPercent(double percent);
}