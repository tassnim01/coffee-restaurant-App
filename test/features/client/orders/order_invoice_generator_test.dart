import 'package:flutter_test/flutter_test.dart';
import 'package:projet_test/features/admin/menu/models/supplement.dart';
import 'package:projet_test/features/admin/orders/models/order_item.dart';
import 'package:projet_test/features/admin/orders/models/order_status.dart';
import 'package:projet_test/features/admin/orders/models/restaurant_order.dart';
import 'package:projet_test/features/client/orders/services/order_invoice_generator.dart';

void main() {
  test('generates a PDF invoice with the order total and table', () async {
    final order = RestaurantOrder(
      id: 'order-1',
      number: 1047,
      userId: 'client-1',
      clientName: 'Ahmed Ben Salah',
      clientPhone: '+216 98 123 456',
      tableNumber: '12',
      items: const [
        OrderItem(
          productId: 'coffee',
          name: 'Cafe',
          quantity: 2,
          unitPrice: 4.5,
          supplements: [Supplement(name: 'Lait', price: 0.5)],
        ),
      ],
      status: OrderStatus.pending,
      createdAt: DateTime(2026, 11, 13, 9, 30),
    );

    final pdf = await OrderInvoiceGenerator.generate(order);

    expect(String.fromCharCodes(pdf.take(5)), '%PDF-');
    expect(order.subtotal, 10);
    expect(order.total, 10);
  });
}
