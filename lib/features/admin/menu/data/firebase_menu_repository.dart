import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';
import '../models/product.dart';
import 'menu_repository.dart';
import 'mock_menu_data.dart';

/// Implémentation Firestore de MenuRepository.
/// Collections : "categories" et "products".
class FirebaseMenuRepository implements MenuRepository {
  final FirebaseFirestore _db;

  FirebaseMenuRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _categories =>
      _db.collection('categories');

  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection('products');

  // ---------- Données initiales ----------

  /// Si la base est vide, insère les catégories et produits de démonstration.
  /// À appeler une seule fois au démarrage.
  Future<void> seedIfEmpty() async {
    final existing = await _categories.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();
    final base = DateTime.now();

    for (var i = 0; i < MockMenuData.categories.length; i++) {
      final c = MockMenuData.categories[i];
      batch.set(_categories.doc(c.id), {
        ...c.toMap(),
        'createdAt': Timestamp.fromDate(base.add(Duration(milliseconds: i))),
      });
    }

    for (var i = 0; i < MockMenuData.products.length; i++) {
      final p = MockMenuData.products[i];
      batch.set(_products.doc(p.id), {
        ...p.toMap(),
        'createdAt': Timestamp.fromDate(base.add(Duration(milliseconds: i))),
      });
    }

    await batch.commit();
  }

  // ---------- Lecture ----------

  @override
  Future<List<Category>> fetchCategories() async {
    final snapshot = await _categories.orderBy('createdAt').get();
    return snapshot.docs
        .map((doc) => Category.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<Product>> fetchProducts() async {
    final snapshot = await _products.orderBy('createdAt').get();
    return snapshot.docs
        .map((doc) => Product.fromMap(doc.id, doc.data()))
        .toList();
  }

  // ---------- Produits ----------

  @override
  Future<Product> addProduct(Product product) async {
    final ref = _products.doc(); // id généré par Firestore
    await ref.set({
      ...product.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return product.copyWith(id: ref.id);
  }

  @override
  Future<void> updateProduct(Product product) async {
    // update() ne touche pas au champ createdAt
    await _products.doc(product.id).update(product.toMap());
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _products.doc(productId).delete();
  }

  // ---------- Catégories ----------

  @override
  Future<Category> addCategory(Category category) async {
    final ref = _categories.doc();
    await ref.set({
      ...category.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return category.copyWith(id: ref.id);
  }

  @override
  Future<void> updateCategory(Category category) async {
    await _categories.doc(category.id).update(category.toMap());
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _categories.doc(categoryId).delete();
  }
}