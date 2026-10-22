// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:projet_test/main.dart';
import 'package:projet_test/features/admin/gestion_client/data/client_repository.dart';
import 'package:projet_test/features/admin/menu/data/menu_repository.dart';
import 'package:projet_test/features/admin/menu/models/category.dart';
import 'package:projet_test/features/admin/menu/models/product.dart';
import 'package:projet_test/features/admin/orders/data/order_repository.dart';
import 'package:projet_test/features/admin/orders/models/order_status.dart';
import 'package:projet_test/features/admin/orders/models/restaurant_order.dart';
import 'package:projet_test/features/admin/gestion_client/models/restaurant_client.dart';

void main() {
  testWidgets('client can open welcome, home, and menu screens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      CoffeeShopApp(
        menuRepository: _FakeMenuRepository(),
        orderRepository: _FakeOrderRepository(),
        clientRepository: _FakeClientRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Good Food\nGood Mood'), findsOneWidget);
    await tester.tap(find.text('Commencer'));
    await tester.pumpAndSettle();

    expect(find.text('Catégories'), findsOneWidget);
    await tester.tap(find.text('Voir tout'));
    await tester.pumpAndSettle();

    expect(find.text('Menu'), findsNWidgets(2));
  });
}

class _FakeMenuRepository implements MenuRepository {
  @override
  Future<List<Category>> fetchCategories() async => [];

  @override
  Future<List<Product>> fetchProducts() async => [];

  @override
  Future<Product> addProduct(Product product) => throw UnimplementedError();

  @override
  Future<void> updateProduct(Product product) => throw UnimplementedError();

  @override
  Future<void> deleteProduct(String productId) => throw UnimplementedError();

  @override
  Future<Category> addCategory(Category category) => throw UnimplementedError();

  @override
  Future<void> updateCategory(Category category) => throw UnimplementedError();

  @override
  Future<void> deleteCategory(String categoryId) => throw UnimplementedError();
}

class _FakeOrderRepository implements OrderRepository {
  @override
  Stream<List<RestaurantOrder>> watchOrders() => Stream.value([]);

  @override
  Future<void> updateStatus(String orderId, OrderStatus status) =>
      throw UnimplementedError();
}

class _FakeClientRepository implements ClientRepository {
  @override
  Stream<List<RestaurantClient>> watchClients() => Stream.value([]);

  @override
  Future<void> addClient(RestaurantClient client) => throw UnimplementedError();

  @override
  Future<void> updateClient(RestaurantClient client) =>
      throw UnimplementedError();

  @override
  Future<void> deleteClient(String clientId) => throw UnimplementedError();
}
