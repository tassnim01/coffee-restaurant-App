class Product {
  final String id;
  final String name;
  final String categoryId;
  final String description;
  final double price; // in Tunisian Dinar (DT)
  final String? imageUrl; // network URL, asset path, or null
  final bool isAvailable;

  const Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.description,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
  });

  Product copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? description,
    double? price,
    String? imageUrl,
    bool? isAvailable,
  }) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        categoryId: categoryId ?? this.categoryId,
        description: description ?? this.description,
        price: price ?? this.price,
        imageUrl: imageUrl ?? this.imageUrl,
        isAvailable: isAvailable ?? this.isAvailable,
      );

  /// Firestore-ready serialization (the id is the document id).
  Map<String, dynamic> toMap() => {
        'name': name,
        'categoryId': categoryId,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'isAvailable': isAvailable,
      };

  factory Product.fromMap(String id, Map<String, dynamic> map) => Product(
        id: id,
        name: map['name'] as String? ?? '',
        categoryId: map['categoryId'] as String? ?? '',
        description: map['description'] as String? ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0,
        imageUrl: map['imageUrl'] as String?,
        isAvailable: map['isAvailable'] as bool? ?? true,
      );
}