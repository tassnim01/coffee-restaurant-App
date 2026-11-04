import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_settings.dart';
import 'settings_repository.dart';

/// Document Firestore : settings/restaurant
class FirebaseSettingsRepository implements SettingsRepository {
  final FirebaseFirestore _db;

  FirebaseSettingsRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _db.collection('settings').doc('restaurant');

  @override
  Stream<RestaurantSettings> watchSettings() {
    // Document absent = paramètres par défaut.
    return _doc
        .snapshots()
        .map((snap) => RestaurantSettings.fromMap(snap.data() ?? {}));
  }

  @override
  Future<void> updateVatPercent(double percent) {
    return _doc.set(
      {
        'vatPercent': percent,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}