import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Face ID / empreinte : vérification du propriétaire du téléphone et
/// stockage sécurisé des identifiants pour les prochaines connexions.
class BiometricService {
  BiometricService._();

  static final LocalAuthentication _auth = LocalAuthentication();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const _emailKey = 'bio_email';
  static const _passwordKey = 'bio_password';

  /// Nom affiché dans l'interface.
  static String get label => defaultTargetPlatform == TargetPlatform.iOS
      ? 'Face ID'
      : 'Face ID / empreinte';

  /// Détecte l'étiquette correspondant aux biométries réellement disponibles.
  static Future<String> detectedLabel() async {
    if (kIsWeb) return 'Face ID / empreinte';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'Face ID';
    try {
      final biometrics = await _auth.getAvailableBiometrics();
      if (biometrics.contains(BiometricType.face)) return 'Face ID';
      if (biometrics.contains(BiometricType.fingerprint)) return 'Empreinte';
      return 'Face ID / empreinte';
    } catch (_) {
      return 'Face ID / empreinte';
    }
  }

  /// true si le téléphone a une biométrie configurée (jamais sur le web).
  static Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      final enrolled = await _auth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Affiche la fenêtre du système. true si le propriétaire est reconnu.
  static Future<bool> authenticate(String reason) async {
    if (kIsWeb) return false;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
      );
    } catch (_) {
      return false; // annulé, verrouillé, non disponible...
    }
  }

  /// true si Face ID a déjà été activé pour un compte sur ce téléphone.
  static Future<bool> isEnabled() async {
    try {
      final email = await _storage.read(key: _emailKey);
      final password = await _storage.read(key: _passwordKey);
      return email != null && password != null;
    } catch (_) {
      return false;
    }
  }

  static Future<void> enable(String email, String password) async {
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _passwordKey, value: password);
  }

  static Future<({String email, String password})?> read() async {
    try {
      final email = await _storage.read(key: _emailKey);
      final password = await _storage.read(key: _passwordKey);
      if (email == null || password == null) return null;
      return (email: email, password: password);
    } catch (_) {
      return null;
    }
  }

  /// Désactive Face ID : supprime les identifiants enregistrés.
  static Future<void> clear() async {
    try {
      await _storage.delete(key: _emailKey);
      await _storage.delete(key: _passwordKey);
    } catch (_) {}
  }
}
