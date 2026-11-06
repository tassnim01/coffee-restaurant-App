import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../admin/orders/models/order_item.dart';
import '../../../admin/orders/models/order_status.dart';
import '../../../admin/orders/models/restaurant_order.dart';
import 'client_order_repository.dart';

class FirebaseClientOrderRepository implements ClientOrderRepository {
  final FirebaseFirestore _db;

  FirebaseClientOrderRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');

  RestaurantOrder _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['createdAt'];
    return RestaurantOrder.fromMap(
      doc.id,
      data,
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }

  @override
  Stream<List<RestaurantOrder>> watchOrdersOf(String userId) {
    // Tri côté application : évite de créer un index composite Firestore.
    return _orders.where('userId', isEqualTo: userId).snapshots().map((snap) {
      final list = snap.docs.map(_fromDoc).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<RestaurantOrder> createOrder({
    required String userId,
    required String clientName,
    required String clientPhone,
    required List<OrderItem> items,
    required double vatPercent,
  }) async {
    final counterRef = _db.collection('settings').doc('counters');
    final orderRef = _orders.doc();
    late RestaurantOrder created;

    // Transaction : le numéro de commande est unique et croissant.
    await _db.runTransaction((tx) async {
      final snap = await tx.get(counterRef);
      final last = (snap.data()?['lastOrderNumber'] as num?)?.toInt() ?? 1046;
      final number = last + 1;

      created = RestaurantOrder(
        id: orderRef.id,
        number: number,
        userId: userId,
        clientName: clientName,
        clientPhone: clientPhone,
        items: items,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        vatPercent: vatPercent,
      );

      tx.set(counterRef, {'lastOrderNumber': number}, SetOptions(merge: true));
      tx.set(orderRef, {
        ...created.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    return created;
  }
}