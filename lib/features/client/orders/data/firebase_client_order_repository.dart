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
    required String tableNumber,
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
        vatPercent: vatPercent,
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
        'vat': updatedOrder.vat,
        'total': updatedOrder.total,
        'invoicePdfBase64': encodedPdf,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
