class RestaurantClient {
  final String id;
  final String name;
  final String phone;
  final DateTime createdAt; // "Client depuis le ..."

  const RestaurantClient({
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
  });

  RestaurantClient copyWith({
    String? id,
    String? name,
    String? phone,
    DateTime? createdAt,
  }) =>
      RestaurantClient(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        createdAt: createdAt ?? this.createdAt,
      );

  /// createdAt est géré par le repository (horodatage serveur).
  Map<String, dynamic> toMap() => {'name': name, 'phone': phone};

  factory RestaurantClient.fromMap(
    String id,
    Map<String, dynamic> map, {
    required DateTime createdAt,
  }) =>
      RestaurantClient(
        id: id,
        name: map['name'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        createdAt: createdAt,
      );
}