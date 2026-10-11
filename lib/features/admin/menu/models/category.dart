class Category {
  final String id;
  final String name;
  final String iconKey;

  const Category({
    required this.id,
    required this.name,
    this.iconKey = 'coffee',
  });

  Category copyWith({
    String? id,
     String? name,
      String? iconKey}) => Category(
        id: id ?? this.id,
        name: name ?? this.name,
        iconKey: iconKey ?? this.iconKey,
      );

  Map<String, dynamic> toMap() => {'name': name, 'iconKey': iconKey};

  factory Category.fromMap(String id, Map<String, dynamic> map) => Category(
        id: id,
        name: map['name'] as String? ?? '',
        iconKey: map['iconKey'] as String? ?? 'coffee',
      );
}