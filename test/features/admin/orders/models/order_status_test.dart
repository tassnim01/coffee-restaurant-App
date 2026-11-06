import 'package:flutter_test/flutter_test.dart';
import 'package:projet_test/features/admin/orders/models/order_status.dart';

void main() {
  group('pending order status', () {
    test('has a label and advances to received when accepted', () {
      expect(OrderStatus.pending.label, 'En attente');
      expect(OrderStatus.pending.next, OrderStatus.received);
      expect(OrderStatus.pending.actionLabel, 'Accepter la commande');
    });

    test('has its own filter and is included in all orders', () {
      expect(OrderTab.pending.includes(OrderStatus.pending), isTrue);
      expect(OrderTab.pending.includes(OrderStatus.received), isFalse);
      expect(OrderTab.all.includes(OrderStatus.pending), isTrue);
    });

    test('keeps decoding previously stored statuses', () {
      expect(orderStatusFromKey('received'), OrderStatus.received);
      expect(orderStatusFromKey('pending'), OrderStatus.pending);
    });
  });
}
