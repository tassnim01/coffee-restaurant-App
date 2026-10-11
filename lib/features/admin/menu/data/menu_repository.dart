import '../models/category.dart';
import '../models/product.dart';

/// Contract between the app and the data source.
/// Mock now, Firestore + Storage later.
abstract class MenuRepository {
  Future<List<Category>> fetchCategories();
  Future<List<Product>> fetchProducts();

  Future<Product> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String productId);

  Future<Category> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String categoryId);
}