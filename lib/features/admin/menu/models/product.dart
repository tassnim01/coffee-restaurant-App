import 'supplement.dart';

class Product {
  final String id;
  final String name;
  final String categoryId;
  final String description;
  final double price; // en Dinar tunisien (DT)
  final String? imageUrl; // URL réseau, asset, data URL ou null
  final bool isAvailable;
  final List<Supplement> supplements;

  const Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.description,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
    this.supplements = const [],
  });

  Product copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? description,
    double? price,
    String? imageUrl,
    bool? isAvailable,
    List<Supplement>? supplements,
  }) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        categoryId: categoryId ?? this.categoryId,
        description: description ?? this.description,
        price: price ?? this.price,
        imageUrl: imageUrl ?? this.imageUrl,
        isAvailable: isAvailable ?? this.isAvailable,
        supplements: supplements ?? this.supplements,
      );

  /// Sérialisation Firestore (l'id est l'identifiant du document).
  Map<String, dynamic> toMap() => {
        'name': name,
        'categoryId': categoryId,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'isAvailable': isAvailable,
        'supplements': supplements.map((s) => s.toMap()).toList(),
      };

  factory Product.fromMap(String id, Map<String, dynamic> map) => Product(
        id: id,
        name: map['name'] as String? ?? '',
        categoryId: map['categoryId'] as String? ?? '',
        description: map['description'] as String? ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0,
        imageUrl: map['imageUrl'] as String?,
        isAvailable: map['isAvailable'] as bool? ?? true,
        supplements: (map['supplements'] as List<dynamic>? ?? [])
            .map((e) => Supplement.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}