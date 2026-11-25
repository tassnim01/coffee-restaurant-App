import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:projet_test/features/admin/orders/models/order_item.dart';
import 'package:projet_test/features/admin/orders/models/order_status.dart';
import 'package:projet_test/features/admin/orders/models/restaurant_order.dart';
import 'package:projet_test/features/client/orders/data/client_order_repository.dart';
import 'package:projet_test/features/client/orders/providers/client_orders_provider.dart';
import 'package:projet_test/features/payment/widgets/payment_gate.dart';

void main() {
  testWidgets(
    'shows the dark blocked-application screen for an unpaid client order',
    (tester) async {
      final provider = ClientOrdersProvider(_UnpaidOrderRepository())
        ..setUser('client-1');
      addTearDown(provider.dispose);

      await tester.pumpWidget(
        ChangeNotifierProvider<ClientOrdersProvider>.value(
          value: provider,
          child: const MaterialApp(
            home: PaymentGate(
              isClient: true,
              child: Scaffold(body: Text('Espace client')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Application bloquée'), findsOneWidget);
      expect(
        find.text(
          "Votre commande n'est pas encore payée. L'application est "
          'temporairement bloquée jusqu’à la confirmation du paiement '
          'en espèces à la livraison.',
        ),
        findsOneWidget,
      );
      expect(find.text('Confirmer le paiement'), findsNothing);
      expect(find.text('Espace client'), findsOneWidget);

      final card = find
          .ancestor(
            of: find.text('Application bloquée'),
            matching: find.byType(Container),
          )
          .first;
      final cardSize = tester.getSize(card);
      expect(
        cardSize.width,
        greaterThan(
          tester.view.physicalSize.width / tester.view.devicePixelRatio * 0.9,
        ),
      );
      expect(
        cardSize.height,
        greaterThan(
          tester.view.physicalSize.height / tester.view.devicePixelRatio * 0.8,
        ),
      );
    },
  );
}

class _UnpaidOrderRepository implements ClientOrderRepository {
  @override
  Stream<List<RestaurantOrder>> watchOrdersOf(
    String userId, {
    String? clientName,
    String? clientPhone,
  }) => Stream.value([
    RestaurantOrder(
      id: 'order-1',
      number: 1049,
      userId: userId,
      clientName: 'Client',
      clientPhone: '',
      tableNumber: '4',
      items: const <OrderItem>[],
      status: OrderStatus.delivered,
      createdAt: DateTime(2026),
    ),
  ]);

  @override
  Future<RestaurantOrder> createOrder({
    required String userId,
    required String clientName,
    required String clientPhone,
    required String tableNumber,
    required List<OrderItem> items,
  }) => throw UnimplementedError();

  @override
  Future<void> updatePendingOrder({
    required String userId,
    required String orderId,
    required List<OrderItem> items,
  }) => throw UnimplementedError();
}
