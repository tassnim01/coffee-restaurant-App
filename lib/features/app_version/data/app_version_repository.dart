import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_version_config.dart';

class AppVersionRepository {
  final FirebaseFirestore _db;

  AppVersionRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Flux temps réel : si le responsable relève la version minimale,
  /// les clients sont bloqués sans redémarrer l'app.
  Stream<AppVersionConfig> watch() {
    return _db.collection('settings').doc('app_version').snapshots().map(
          (snap) => AppVersionConfig.fromMap(snap.data() ?? {}),
        );
  }
}