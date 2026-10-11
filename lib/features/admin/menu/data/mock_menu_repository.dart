import '../models/category.dart';
import '../models/product.dart';
import 'menu_repository.dart';
import 'mock_menu_data.dart';

/// In-memory implementation used for testing without Firebase.
class MockMenuRepository implements MenuRepository {
  final List<Category> _categories = List.of(MockMenuData.categories);
  final List<Product> _products = List.of(MockMenuData.products);

  Future<void> _fakeDelay() =>
      Future<void>.delayed(const Duration(milliseconds: 350));

  String _newId(String prefix) =>
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}';

  @override
  Future<List<Category>> fetchCategories() async {
    await _fakeDelay();
    return List.of(_categories);
  }

  @override
  Future<List<Product>> fetchProducts() async {
    await _fakeDelay();
    return List.of(_products);
  }

  @override
  Future<Product> addProduct(Product product) async {
    final created = product.copyWith(id: _newId('p'));
    _products.add(created);
    return created;
  }

  @override
  Future<void> updateProduct(Product product) async {
    final i = _products.indexWhere((p) => p.id == product.id);
    if (i != -1) _products[i] = product;
  }

  @override
  Future<void> deleteProduct(String productId) async {
    _products.removeWhere((p) => p.id == productId);
  }

  @override
  Future<Category> addCategory(Category category) async {
    final created = category.copyWith(id: _newId('cat'));
    _categories.add(created);
    return created;
  }

  @override
  Future<void> updateCategory(Category category) async {
    final i = _categories.indexWhere((c) => c.id == category.id);
    if (i != -1) _categories[i] = category;
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    _categories.removeWhere((c) => c.id == categoryId);
  }
}