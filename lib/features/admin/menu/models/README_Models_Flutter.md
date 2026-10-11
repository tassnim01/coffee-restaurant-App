# README — Models Flutter : Category & Product

Ce document résume **ce qu'il faut comprendre et savoir expliquer** concernant `lib/models/category.dart` et `lib/models/product.dart` dans notre application de restaurant (Flutter + Firestore).

## 1. À quoi sert le dossier `models/` ?

Un **model** représente les données métier sous forme d'objet Dart. Il ne construit pas l'interface graphique. `Category` représente une catégorie (Coffee, Desserts…), et `Product` représente un produit (nom, prix, disponibilité…). Séparer les models des écrans facilite l'organisation, la réutilisation, les tests et les échanges avec Firestore.

```text
lib/
  models/
    category.dart
    product.dart
  utils/
    category_icons.dart
  theme/
    app_colors.dart
    app_text_styles.dart
    app_theme.dart
```

## 2. Category : les notions à connaître

```dart
class Category {
  final String id;
  final String name;
  final String iconKey;

  const Category({
    required this.id,
    required this.name,
    this.iconKey = 'coffee',
  });

  Category copyWith({String? id, String? name, String? iconKey}) => Category(
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
```

| Élément | À retenir |
|---|---|
| `id` | Identifiant unique ; ici il correspond à l'ID du document Firestore. |
| `name` | Nom de la catégorie. |
| `iconKey` | Clé textuelle (`coffee`, `dessert`…) qui sera convertie en icône par `CategoryIcons.byKey()`. |
| `required` | Paramètre obligatoire à la construction. |
| `this.iconKey = 'coffee'` | Valeur par défaut si aucune clé n'est fournie. |

**Exemple :**

```dart
const category = Category(id: 'cat001', name: 'Desserts', iconKey: 'dessert');
```

## 3. Product : les notions à connaître

```dart
class Product {
  final String id;
  final String name;
  final String categoryId;
  final String description;
  final double price;
  final String? imageUrl;
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
  }) => Product(
    id: id ?? this.id,
    name: name ?? this.name,
    categoryId: categoryId ?? this.categoryId,
    description: description ?? this.description,
    price: price ?? this.price,
    imageUrl: imageUrl ?? this.imageUrl,
    isAvailable: isAvailable ?? this.isAvailable,
  );

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
```

| Attribut | Type | Sens |
|---|---|---|
| `id` | `String` | ID du document produit. |
| `name` | `String` | Nom du plat ou de la boisson. |
| `categoryId` | `String` | ID de la catégorie associée. |
| `description` | `String` | Description du produit. |
| `price` | `double` | Prix en dinars tunisiens (ex. `25.5`). |
| `imageUrl` | `String?` | URL réseau, chemin d'asset ou `null`. |
| `isAvailable` | `bool` | `true` disponible, `false` indisponible ; `true` par défaut. |

**Exemple :**

```dart
const pizza = Product(
  id: 'p001',
  name: 'Pizza Margherita',
  categoryId: 'cat001',
  description: 'Tomate et mozzarella',
  price: 25.5,
  imageUrl: 'assets/images/pizza.png',
);
// isAvailable == true par défaut
```

## 4. Syntaxe Dart essentielle (pour les deux fichiers)

| Syntaxe | Explication simple |
|---|---|
| `final` | Attribut assigné une seule fois : pas de modification directe après construction. |
| `const Category(...)` | Constructeur constant, utilisable avec des arguments constants. |
| `String?` / `double?` | Type nullable : accepte `null`. |
| `required` | Argument nommé obligatoire. |
| `this.name` | Fait référence à l'attribut de l'objet courant. |
| `??` | Prend la valeur de gauche si non nulle, sinon celle de droite. |
| `?.` | Appelle une méthode seulement si l'objet n'est pas `null`. |
| `=>` | Écriture courte d'une fonction qui retourne une expression. |
| `factory` | Constructeur capable de retourner une instance, ici construite depuis une Map. |
| `Map<String, dynamic>` | Dictionnaire : clés `String`, valeurs de types divers. |
| `as String?` | Cast vers une chaîne nullable ; un mauvais type non nul peut déclencher une erreur. |
| `num` | Supertype numérique de `int` et `double`. |

### Pourquoi `final` et `copyWith()` ensemble ?

On ne change pas directement un attribut `final` : on crée une **nouvelle instance** avec les valeurs souhaitées.

```dart
final updated = pizza.copyWith(price: 28.0, isAvailable: false);
// pizza reste inchangé ; updated a le nouveau prix et la nouvelle disponibilité.
```

Attention : dans la version actuelle, `copyWith(imageUrl: null)` **ne supprime pas** une image existante, car `null ?? this.imageUrl` conserve l'ancienne valeur. Il faut adapter la méthode si cette opération est nécessaire.

## 5. `toMap()` et `fromMap()` : les deux sens à retenir

**`toMap()` : objet Dart → Map compatible avec les champs Firestore.**

```dart
final data = pizza.toMap();
// {'name': ..., 'categoryId': ..., 'description': ..., 'price': ..., 'imageUrl': ..., 'isAvailable': ...}
```

**`fromMap()` : données Firestore → objet Dart.**

```dart
final product = Product.fromMap(doc.id, doc.data());
final category = Category.fromMap(doc.id, doc.data());
```

Dans cette conception, `id` est transmis séparément depuis `doc.id` : il n'apparaît donc pas dans `toMap()`.

### La ligne du prix, décomposée

```dart
price: (map['price'] as num?)?.toDouble() ?? 0,
```

1. `map['price']` lit le champ.
2. `as num?` accepte `int`, `double` ou `null`.
3. `?.toDouble()` convertit un nombre non nul en `double`.
4. `?? 0` fournit `0.0` si le champ est absent ou nul (le résultat est affecté au `double price`).

Exemples : `25` → `25.0` ; `25.5` → `25.5` ; `null` → `0.0`. Une chaîne comme `'25'` n'est **pas** acceptée par ce cast.

## 6. Relation Category ↔ Product

Une catégorie peut contenir plusieurs produits. `Product.categoryId` fait référence à `Category.id`.

```text
Category(id: 'cat001', name: 'Fast Food')
          ↑
          └── Product(id: 'p001', name: 'Burger', categoryId: 'cat001')
          └── Product(id: 'p002', name: 'Sandwich', categoryId: 'cat001')
```

Il s'agit ici d'une **référence logique** par identifiant : le model ne vérifie pas à lui seul que la catégorie existe réellement dans Firestore.

`Category.iconKey` est une chaîne enregistrable dans Firestore. `CategoryIcons.byKey(category.iconKey)` la transforme en `IconData` pour l'affichage. On ne stocke pas directement un `IconData` dans Firestore.

## 7. Exemple de structure Firestore

```text
categories (collection)
  cat001 (document)
    name: "Fast Food"
    iconKey: "fastfood"

products (collection)
  p001 (document)
    name: "Burger"
    categoryId: "cat001"
    description: "Burger au fromage"
    price: 18.5
    imageUrl: null
    isAvailable: true
```

Les models préparent et interprètent les données ; **ils n'effectuent pas eux-mêmes** la lecture ou l'écriture réseau. Ces opérations appartiennent typiquement à un service ou repository Firestore.

## 8. Questions fréquentes du professeur (réponses courtes)

**Pourquoi le dossier `models` ?** Pour séparer la représentation des données de l'interface utilisateur et de l'accès à la base.

**Pourquoi `copyWith()` ?** Pour obtenir une nouvelle instance avec certains champs modifiés, sans changer l'objet initial.

**Différence entre `toMap()` et `fromMap()` ?** `toMap()` prépare les champs à enregistrer ; `fromMap()` reconstruit l'objet depuis les données récupérées.

**Pourquoi `id` n'est-il pas dans `toMap()` ?** Parce que notre modèle utilise l'ID du document Firestore, transmis séparément.

**Pourquoi `categoryId` dans Product ?** Pour relier chaque produit à sa catégorie sans recopier toutes les informations de celle-ci.

**Pourquoi `String? imageUrl` ?** Un produit peut ne pas avoir d'image.

**Pourquoi convertir le prix avec `num?.toDouble()` ?** Pour accepter les valeurs numériques `int` et `double` venant de Firestore tout en garantissant un `double` dans le modèle.

**Que signifie `isAvailable = true` ?** Un nouveau produit est considéré disponible si aucune autre valeur n'est fournie.

## 9. Mini fiche de révision

- **Category** = `id`, `name`, `iconKey`.
- **Product** = `id`, `name`, `categoryId`, `description`, `price`, `imageUrl`, `isAvailable`.
- **`final`** = propriétés non réassignables ; **`copyWith`** = nouvelle copie modifiée.
- **`toMap`** = objet → données ; **`fromMap`** = données → objet.
- **`??`** = valeur de secours ; **`?.`** = accès sécurisé si non nul.
- **`categoryId`** relie Product à Category ; **`iconKey`** relie Category à CategoryIcons.
- Les models ne dessinent pas l'UI et ne contactent pas Firestore directement.
