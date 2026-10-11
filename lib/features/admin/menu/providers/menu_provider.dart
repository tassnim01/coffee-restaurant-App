import 'package:flutter/foundation.dart' hide Category;
import '../data/menu_repository.dart';
import '../models/category.dart';
import '../models/product.dart';

class MenuProvider extends ChangeNotifier {
  final MenuRepository _repository;

  MenuProvider(this._repository);

  List<Category> _categories = [];
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategoryId; // null = all categories

  // ---------- Getters ----------
  List<Category> get categories => List.unmodifiable(_categories);
  List<Product> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;

  /// Products after applying the search text and the category filter.
  List<Product> get filteredProducts {
    final query = _searchQuery.trim().toLowerCase();
    return _products.where((p) {
      final matchesCategory =
          _selectedCategoryId == null || p.categoryId == _selectedCategoryId;
      final matchesSearch = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.description.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  String categoryNameOf(String categoryId) {
    for (final c in _categories) {
      if (c.id == categoryId) return c.name;
    }
    return 'Sans catégorie';
  }

  int productCountOf(String categoryId) =>
      _products.where((p) => p.categoryId == categoryId).length;

  // ---------- Loading ----------
  Future<void> loadMenu() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.fetchCategories(),
        _repository.fetchProducts(),
      ]);
      _categories = results[0] as List<Category>;
      _products = results[1] as List<Product>;
    } catch (e) {
      _error = 'Impossible de charger le menu.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------- Filters ----------
  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void selectCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  // ---------- Product CRUD ----------
  Future<void> addProduct(Product product) async {
    final created = await _repository.addProduct(product);
    _products.add(created);
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    await _repository.updateProduct(product);
    final i = _products.indexWhere((p) => p.id == product.id);
    if (i != -1) _products[i] = product;
    notifyListeners();
  }

  Future<void> toggleAvailability(String productId) async {
    final i = _products.indexWhere((p) => p.id == productId);
    if (i == -1) return;
    final updated =
        _products[i].copyWith(isAvailable: !_products[i].isAvailable);
    _products[i] = updated; // optimistic update
    notifyListeners();
    await _repository.updateProduct(updated);
  }

  Future<void> deleteProduct(String productId) async {
    await _repository.deleteProduct(productId);
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  // ---------- Category CRUD (used in a later step) ----------
  Future<void> addCategory(Category category) async {
    final created = await _repository.addCategory(category);
    _categories.add(created);
    notifyListeners();
  }

  Future<void> updateCategory(Category category) async {
    await _repository.updateCategory(category);
    final i = _categories.indexWhere((c) => c.id == category.id);
    if (i != -1) _categories[i] = category;
    notifyListeners();
  }

  /// Returns false if the category still contains products.
  Future<bool> deleteCategory(String categoryId) async {
    if (productCountOf(categoryId) > 0) return false;
    await _repository.deleteCategory(categoryId);
    _categories.removeWhere((c) => c.id == categoryId);
    if (_selectedCategoryId == categoryId) _selectedCategoryId = null;
    notifyListeners();
    return true;
  }
}