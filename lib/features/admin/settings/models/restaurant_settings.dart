class RestaurantSettings {
  /// Taux utilisé tant que le responsable n'en a pas choisi un.
  static const double defaultVatPercent = 13;

  final double vatPercent; // en pourcentage : 13 = 13 %

  const RestaurantSettings({this.vatPercent = defaultVatPercent});

  Map<String, dynamic> toMap() => {'vatPercent': vatPercent};

  factory RestaurantSettings.fromMap(Map<String, dynamic> map) =>
      RestaurantSettings(
        vatPercent:
            (map['vatPercent'] as num?)?.toDouble() ?? defaultVatPercent,
      );
}