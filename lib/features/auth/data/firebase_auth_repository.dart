import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import 'auth_repository.dart';

/// Comptes dans Firebase Authentication ; profils dans "users/{uid}" ;
/// fiche visible du responsable dans "clients/{uid}".
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  AuthFailure _failure(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return const AuthFailure('Cette adresse e-mail est déjà utilisée.');
      case 'invalid-email':
        return const AuthFailure('Adresse e-mail invalide.');
      case 'weak-password':
        return const AuthFailure('Mot de passe trop faible (6 caractères minimum).');
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthFailure('E-mail ou mot de passe incorrect.');
      case 'network-request-failed':
        return const AuthFailure('Problème de connexion internet.');
      case 'too-many-requests':
        return const AuthFailure('Trop de tentatives. Réessayez plus tard.');
      case 'operation-not-allowed':
        return const AuthFailure(
            "L'inscription par e-mail n'est pas activée dans Firebase.");
      default:
        return const AuthFailure('Une erreur est survenue. Réessayez.');
    }
  }

  @override
  Stream<String?> authStateChanges() =>
      _auth.authStateChanges().map((user) => user?.uid);

  @override
  Future<AppUser> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;

      final batch = _db.batch();
      batch.set(_db.collection('users').doc(uid), {
        'name': name.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'role': 'client',
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Fiche affichée dans "Gestion des clients" du responsable.
      batch.set(_db.collection('clients').doc(uid), {
        'name': name.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();

      return AppUser(
        uid: uid,
        name: name.trim(),
        phone: phone.trim(),
        email: email.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw _failure(e);
    }
  }

  @override
  Future<AppUser> login({required String email, required String password}) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;
      return await loadProfile(uid) ??
          AppUser(uid: uid, name: email.trim(), phone: '', email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _failure(e);
    }
  }

  @override
  Future<AppUser?> loadProfile(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    final data = snap.data();
    if (data == null) return null;
    return AppUser(
      uid: uid,
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
    );
  }

  @override
  Future<void> logout() => _auth.signOut();
}