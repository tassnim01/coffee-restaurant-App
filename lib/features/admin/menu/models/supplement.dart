class Supplement {
  final String name;
  final double price; // en DT

  const Supplement({required this.name, required this.price});

  Map<String, dynamic> toMap() => {'name': name, 'price': price};

  factory Supplement.fromMap(Map<String, dynamic> map) => Supplement(
        name: map['name'] as String? ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0,
      );
}