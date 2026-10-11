import '../models/category.dart';
import '../models/product.dart';

/// Seed data. These image URLs are placeholders: if one fails to load,
/// the UI shows a fallback icon. Replace them with your own images later.
class MockMenuData {
  MockMenuData._();

  static const List<Category> categories = [
    Category(id: 'cat_cafes', name: 'Cafés', iconKey: 'coffee'),
    Category(id: 'cat_boissons', name: 'Boissons', iconKey: 'drink'),
    Category(id: 'cat_fastfood', name: 'Fast-food', iconKey: 'fastfood'),
    Category(id: 'cat_plats', name: 'Plats', iconKey: 'dish'),
    Category(id: 'cat_desserts', name: 'Desserts', iconKey: 'dessert'),
  ];

  static const List<Product> products = [
    Product(
      id: 'p1',
      name: 'Cappuccino',
      categoryId: 'cat_cafes',
      description: 'Café italien avec une mousse de lait.',
      price: 6.500,
      imageUrl:
          'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=400',
    ),
    Product(
      id: 'p2',
      name: 'Espresso',
      categoryId: 'cat_cafes',
      description: 'Café court, intense et corsé.',
      price: 4.500,
      imageUrl:
          'https://images.unsplash.com/photo-1510707577719-ae7c14805e3a?w=400',
    ),
    Product(
      id: 'p3',
      name: 'Burger classique',
      categoryId: 'cat_fastfood',
      description: 'Steak haché, cheddar, salade, tomate et sauce maison.',
      price: 12.000,
      imageUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
    ),
    Product(
      id: 'p4',
      name: 'Pâtes carbonara',
      categoryId: 'cat_plats',
      description: 'Pâtes crémeuses, lardons et parmesan.',
      price: 14.000,
      imageUrl:
          'https://images.unsplash.com/photo-1612874742237-6526221588e3?w=400',
    ),
    Product(
      id: 'p5',
      name: 'Cheesecake',
      categoryId: 'cat_desserts',
      description: 'Cheesecake onctueux avec coulis de fruits rouges.',
      price: 7.000,
      imageUrl:
          'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?w=400',
    ),
    Product(
      id: 'p6',
      name: 'Citronnade menthe',
      categoryId: 'cat_boissons',
      description: 'Citron pressé frais et menthe.',
      price: 5.500,
      imageUrl:
          'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400',
      isAvailable: false,
    ),
  ];
}