import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_client.dart';
import 'client_repository.dart';

/// Collection Firestore : "clients".
class FirebaseClientRepository implements ClientRepository {
  final FirebaseFirestore _db;

  FirebaseClientRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _clients =>
      _db.collection('clients');

  RestaurantClient _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['createdAt'];
    return RestaurantClient.fromMap(
      doc.id,
      data,
      // null = horodatage serveur pas encore reçu (écriture en cours)
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }

  @override
  Stream<List<RestaurantClient>> watchClients() {
    return _clients
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  @override
  Future<void> addClient(RestaurantClient client) async {
    await _clients.add({
      ...client.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateClient(RestaurantClient client) async {
    // update() ne touche pas à createdAt
    await _clients.doc(client.id).update(client.toMap());
  }

  @override
  Future<void> deleteClient(String clientId) async {
    await _clients.doc(clientId).delete();
  }

  // ---------- Clients de démonstration ----------

  /// Si la collection est vide, crée quelques clients pour tester.
  /// À supprimer quand l'application client créera de vrais comptes.
  Future<void> seedIfEmpty() async {
    final existing = await _clients.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final demo = <({String name, String phone, DateTime since})>[
      (
        name: 'Ahmed Ben Ali',
        phone: '+216 98 123 456',
        since: DateTime(2025, 3, 12),
      ),
      (
        name: 'Sara Mahfoudh',
        phone: '+216 22 345 678',
        since: DateTime(2025, 4, 5),
      ),
      (
        name: 'Yassine Trabelsi',
        phone: '+216 55 678 901',
        since: DateTime(2025, 3, 18),
      ),
      (
        name: 'Leila Jaziri',
        phone: '+216 97 234 567',
        since: DateTime(2025, 4, 10),
      ),
      (
        name: 'Mohamed Gharbi',
        phone: '+216 29 876 543',
        since: DateTime(2025, 4, 21),
      ),
    ];

    final batch = _db.batch();
    for (final c in demo) {
      batch.set(_clients.doc(), {
        'name': c.name,
        'phone': c.phone,
        'createdAt': Timestamp.fromDate(c.since),
      });
    }
    await batch.commit();
  }
}