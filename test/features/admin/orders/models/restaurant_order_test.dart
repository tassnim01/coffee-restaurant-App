import 'package:flutter_test/flutter_test.dart';
import 'package:projet_test/features/admin/orders/models/order_item.dart';
import 'package:projet_test/features/admin/orders/models/order_status.dart';
import 'package:projet_test/features/admin/orders/models/restaurant_order.dart';

void main() {
  test('order totals no longer include VAT, including legacy stored VAT', () {
    final order = RestaurantOrder(
      id: 'order-1',
      number: 1047,
      clientName: 'Client',
      clientPhone: '',
      items: const [
        OrderItem(
          productId: 'coffee',
          name: 'Cafe',
          quantity: 2,
          unitPrice: 4.5,
        ),
      ],
      status: OrderStatus.pending,
      createdAt: DateTime(2026, 11, 12),
    );

    final serialized = order.toMap();
    final restored = RestaurantOrder.fromMap(order.id, {
      ...serialized,
      'vatPercent': 13,
      'vat': 1.17,
    }, createdAt: order.createdAt);

    expect(restored.total, 9);
    expect(serialized, isNot(contains('vatPercent')));
    expect(serialized, isNot(contains('vat')));
  });

  test('keeps the table number when an order is serialized', () {
    final order = RestaurantOrder(
      id: 'order-1',
      number: 1047,
      userId: 'client-1',
      clientName: 'Ahmed Ben Ali',
      clientPhone: '98123456',
      tableNumber: '12',
      items: const [],
      status: OrderStatus.pending,
      createdAt: DateTime(2026, 11, 12),
    );

    final restored = RestaurantOrder.fromMap(
      order.id,
      order.toMap(),
      createdAt: order.createdAt,
    );

    expect(restored.tableNumber, '12');
  });

  test('reads older orders that do not have a table number', () {
    final restored = RestaurantOrder.fromMap('order-previous', const {
      'number': 1046,
    }, createdAt: DateTime(2026, 11, 11));

    expect(restored.tableNumber, isNull);
  });

  test('keeps the generated invoice when an order is serialized', () {
    final order = RestaurantOrder(
      id: 'order-2',
      number: 1048,
      clientName: 'Client',
      clientPhone: '12345678',
      items: const [],
      status: OrderStatus.pending,
      createdAt: DateTime(2026, 11, 13),
      invoicePdfBase64: 'JVBERi0=',
    );

    final restored = RestaurantOrder.fromMap(
      order.id,
      order.toMap(),
      createdAt: order.createdAt,
    );

    expect(restored.invoicePdfBase64, 'JVBERi0=');
  });
}
