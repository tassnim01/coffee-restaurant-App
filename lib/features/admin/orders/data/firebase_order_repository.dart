import 'package:cloud_firestore/cloud_firestore.dart';
import '../../menu/data/mock_menu_data.dart';
import '../models/order_item.dart';
import '../models/order_status.dart';
import '../models/restaurant_order.dart';
import 'order_repository.dart';

/// Collection Firestore : "orders".
class FirebaseOrderRepository implements OrderRepository {
  final FirebaseFirestore _db;

  FirebaseOrderRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');

  RestaurantOrder _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['createdAt'];
    return RestaurantOrder.fromMap(
      doc.id,
      data,
      // null = horodatage serveur pas encore reçu (écriture en cours)
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }

  @override
  Stream<List<RestaurantOrder>> watchOrders() {
    return _orders
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  @override
  Future<void> updateStatus(String orderId, OrderStatus status) {
    return _orders.doc(orderId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------- Commandes de démonstration ----------

  OrderItem _item(String productId, int quantity) {
    final p = MockMenuData.products.firstWhere((p) => p.id == productId);
    return OrderItem(
      productId: p.id,
      name: p.name,
      quantity: quantity,
      unitPrice: p.price,
      imageUrl: p.imageUrl,
    );
  }

  /// Si la collection est vide, crée quelques commandes pour tester.
  /// À supprimer quand l'application client enverra de vraies commandes.
  Future<void> seedIfEmpty() async {
    final existing = await _orders.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final now = DateTime.now();
    final demo = <({
      int number,
      String name,
      String phone,
      OrderStatus status,
      int minutesAgo,
      List<OrderItem> items,
    })>[
      (
        number: 1046,
        name: 'Nour Ben Salah',
        phone: '+216 50 112 233',
        status: OrderStatus.received,
        minutesAgo: 2,
        items: [_item('p3', 2)],
      ),
      (
        number: 1045,
        name: 'Ahmed Ben Ali',
        phone: '+216 98 123 456',
        status: OrderStatus.preparing,
        minutesAgo: 10,
        items: [_item('p1', 2), _item('p5', 1), _item('p6', 1)],
      ),
      (
        number: 1044,
        name: 'Sara Mahfoudh',
        phone: '+216 22 345 678',
        status: OrderStatus.ready,
        minutesAgo: 25,
        items: [_item('p2', 2), _item('p5', 1)],
      ),
      (
        number: 1043,
        name: 'Yassine Trabelsi',
        phone: '+216 55 678 901',
        status: OrderStatus.preparing,
        minutesAgo: 40,
        items: [_item('p3', 1), _item('p6', 1)],
      ),
      (
        number: 1042,
        name: 'Leila Jaziri',
        phone: '+216 97 234 567',
        status: OrderStatus.delivered,
        minutesAgo: 70,
        items: [_item('p4', 2), _item('p5', 1)],
      ),
      (
        number: 1041,
        name: 'Mohamed Gharbi',
        phone: '+216 29 876 543',
        status: OrderStatus.delivered,
        minutesAgo: 95,
        items: [_item('p4', 1), _item('p2', 1)],
      ),
    ];

    final batch = _db.batch();
    for (final o in demo) {
      final order = RestaurantOrder(
        id: '',
        number: o.number,
        clientName: o.name,
        clientPhone: o.phone,
        items: o.items,
        status: o.status,
        createdAt: now,
      );
      batch.set(_orders.doc(), {
        ...order.toMap(),
        'createdAt':
            Timestamp.fromDate(now.subtract(Duration(minutes: o.minutesAgo))),
      });
    }
    await batch.commit();
  }
}