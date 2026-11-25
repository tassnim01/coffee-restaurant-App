import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../admin/orders/models/order_item.dart';
import '../../../admin/orders/models/order_status.dart';
import '../../../admin/orders/models/restaurant_order.dart';
import '../services/order_invoice_generator.dart';
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
  Stream<List<RestaurantOrder>> watchOrdersOf(
    String userId, {
    String? clientName,
    String? clientPhone,
  }) {
    late StreamController<List<RestaurantOrder>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? uidSubscription;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? nameSubscription;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? phoneSubscription;
    var uidOrders = <RestaurantOrder>[];
    var nameOrders = <RestaurantOrder>[];
    var phoneOrders = <RestaurantOrder>[];

    void emit() {
      if (controller.isClosed) return;
      final merged = <String, RestaurantOrder>{};
      for (final order in [...uidOrders, ...nameOrders, ...phoneOrders]) {
        merged[order.id] = order;
      }
      final list = merged.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      controller.add(list);
    }

    controller = StreamController<List<RestaurantOrder>>(
      onListen: () {
        uidSubscription = _orders
            .where('userId', isEqualTo: userId)
            .snapshots()
            .listen((snapshot) {
              uidOrders = snapshot.docs.map(_fromDoc).toList();
              emit();
            }, onError: controller.addError);

        final exactName = clientName?.trim();
        if (exactName != null && exactName.isNotEmpty) {
          nameSubscription = _orders
              .where('clientName', isEqualTo: exactName)
              .snapshots()
              .listen((snapshot) {
                nameOrders = snapshot.docs
                    .map(_fromDoc)
                    .where((order) => order.userId == null)
                    .toList();
                emit();
              }, onError: controller.addError);
        }

        final exactPhone = clientPhone?.trim();
        if (exactPhone != null && exactPhone.isNotEmpty) {
          phoneSubscription = _orders
              .where('clientPhone', isEqualTo: exactPhone)
              .snapshots()
              .listen((snapshot) {
                phoneOrders = snapshot.docs
                    .map(_fromDoc)
                    .where((order) => order.userId == null)
                    .toList();
                emit();
              }, onError: controller.addError);
        }
      },
      onCancel: () async {
        await uidSubscription?.cancel();
        await nameSubscription?.cancel();
        await phoneSubscription?.cancel();
      },
    );

    return controller.stream;
  }

  @override
  Future<RestaurantOrder> createOrder({
    required String userId,
    required String clientName,
    required String clientPhone,
    required String tableNumber,
    required List<OrderItem> items,
  }) async {
    final counterRef = _db.collection('settings').doc('counters');
    final orderRef = _orders.doc();
    late RestaurantOrder created;

    // Transaction : le numéro de commande est unique et croissant.
    await _db.runTransaction((tx) async {
      final snap = await tx.get(counterRef);
      final last = (snap.data()?['lastOrderNumber'] as num?)?.toInt() ?? 1046;
      final number = last + 1;

      final order = RestaurantOrder(
        id: orderRef.id,
        number: number,
        userId: userId,
        clientName: clientName,
        clientPhone: clientPhone,
        tableNumber: tableNumber,
        items: items,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
      );
      final pdf = await OrderInvoiceGenerator.generate(order);
      final encodedPdf = base64Encode(pdf);
      if (encodedPdf.length > 500000) {
        throw StateError('The generated invoice exceeds the Firestore limit.');
      }
      created = order.copyWith(invoicePdfBase64: encodedPdf);

      tx.set(counterRef, {'lastOrderNumber': number}, SetOptions(merge: true));
      tx.set(orderRef, {
        ...created.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    return created;
  }

  @override
  Future<void> updatePendingOrder({
    required String userId,
    required String orderId,
    required List<OrderItem> items,
  }) async {
    if (items.isEmpty) {
      throw StateError('Une commande doit contenir au moins un article.');
    }

    final orderRef = _orders.doc(orderId);
    final snapshot = await orderRef.get();
    if (!snapshot.exists) {
      throw StateError('Cette commande n’existe plus.');
    }

    final order = _fromDoc(snapshot);
    if (order.userId != userId) {
      throw StateError('Vous ne pouvez pas modifier cette commande.');
    }
    if (order.status != OrderStatus.pending) {
      throw StateError('Cette commande n’est plus en attente.');
    }

    final updatedOrder = order.copyWith(items: items);
    final encodedPdf = base64Encode(
      await OrderInvoiceGenerator.generate(updatedOrder),
    );
    if (encodedPdf.length > 500000) {
      throw StateError('L’addition PDF dépasse la taille maximale autorisée.');
    }

    await _db.runTransaction((transaction) async {
      final currentSnapshot = await transaction.get(orderRef);
      if (!currentSnapshot.exists) {
        throw StateError('Cette commande n’existe plus.');
      }

      final currentData = currentSnapshot.data()!;
      if (currentData['userId'] != userId) {
        throw StateError('Vous ne pouvez pas modifier cette commande.');
      }
      if (orderStatusFromKey(currentData['status'] as String?) !=
          OrderStatus.pending) {
        throw StateError('Cette commande n’est plus en attente.');
      }

      transaction.update(orderRef, {
        'items': items.map((item) => item.toMap()).toList(),
        'subtotal': updatedOrder.subtotal,
        'total': updatedOrder.total,
        'vat': FieldValue.delete(),
        'vatPercent': FieldValue.delete(),
        'invoicePdfBase64': encodedPdf,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
