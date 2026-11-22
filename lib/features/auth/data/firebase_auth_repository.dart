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
        return const AuthFailure(
          'Mot de passe trop faible (6 caractères minimum).',
        );
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthFailure('E-mail ou mot de passe incorrect.');
      case 'network-request-failed':
        return const AuthFailure('Problème de connexion internet.');
      case 'too-many-requests':
        return const AuthFailure('Trop de tentatives. Réessayez plus tard.');
      case 'requires-recent-login':
        return const AuthFailure(
          'Reconnectez-vous avant de modifier ces informations sensibles.',
        );
      case 'operation-not-allowed':
        return const AuthFailure(
          "Cette opération n'est pas activée dans Firebase.",
        );
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
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;
      final profile = await loadProfile(uid);
      if (profile == null) {
        await _auth.signOut();
        throw const AuthFailure(
          'Ce compte ne peut pas accéder à l’espace client.',
        );
      }
      return profile;
    } on FirebaseAuthException catch (e) {
      throw _failure(e);
    }
  }

  @override
  Future<AppUser?> loadProfile(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    final data = snap.data();
    if (data == null) return null;
    if (data['role'] == 'admin') {
      await _auth.signOut();
      return null;
    }
    final authUser = _auth.currentUser;
    final authEmail = authUser?.uid == uid ? authUser?.email : null;
    final email = authEmail ?? data['email'] as String? ?? '';
    if (authEmail != null && authEmail != data['email']) {
      final batch = _db.batch();
      batch.set(_db.collection('users').doc(uid), {
        'email': authEmail,
      }, SetOptions(merge: true));
      batch.set(_db.collection('clients').doc(uid), {
        'email': authEmail,
      }, SetOptions(merge: true));
      await batch.commit();
    }
    return AppUser(
      uid: uid,
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: email,
    );
  }

  @override
  Future<bool> validateCredentials({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _auth.signOut();
      return true;
    } on FirebaseAuthException catch (e) {
      await _auth.signOut();
      // Preserve local credentials when Firebase cannot be reached or is
      // temporarily blocking verification.
      if (e.code == 'network-request-failed' || e.code == 'too-many-requests') {
        return true;
      }
      return false;
    } catch (_) {
      await _auth.signOut();
      return false;
    }
  }

  @override
  Future<AppUser> updateProfile({
    required AppUser user,
    required String name,
    required String phone,
    required String email,
    String? currentPassword,
    String? newPassword,
  }) async {
    final trimmedName = name.trim();
    final trimmedPhone = phone.trim();
    final trimmedEmail = email.trim();
    final authUser = _auth.currentUser;
    if (authUser == null ||
        authUser.uid != user.uid ||
        authUser.email == null) {
      throw const AuthFailure('Aucun compte connecté.');
    }

    final emailChanged = trimmedEmail != user.email;
    final passwordChanged = newPassword != null && newPassword.isNotEmpty;

    try {
      if (emailChanged || passwordChanged) {
        if (currentPassword == null || currentPassword.isEmpty) {
          throw const AuthFailure(
            'Saisissez votre mot de passe actuel pour continuer.',
          );
        }
        final credential = EmailAuthProvider.credential(
          email: authUser.email!,
          password: currentPassword,
        );
        await authUser.reauthenticateWithCredential(credential);
      }

      if (emailChanged) {
        await authUser.verifyBeforeUpdateEmail(trimmedEmail);
      }
      if (passwordChanged) {
        await authUser.updatePassword(newPassword);
      }

      final batch = _db.batch();
      batch.set(_db.collection('users').doc(user.uid), {
        'name': trimmedName,
        'phone': trimmedPhone,
      }, SetOptions(merge: true));
      batch.set(_db.collection('clients').doc(user.uid), {
        'name': trimmedName,
        'phone': trimmedPhone,
      }, SetOptions(merge: true));
      await batch.commit();
    } on AuthFailure {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw _failure(e);
    } on FirebaseException {
      throw const AuthFailure('Impossible d’enregistrer le profil. Réessayez.');
    }

    return AppUser(
      uid: user.uid,
      name: trimmedName,
      phone: trimmedPhone,
      email: user.email,
      tableNumber: user.tableNumber,
    );
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw const AuthFailure('Aucun compte connecté.');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      final batch = _db.batch();
      batch.delete(_db.collection('users').doc(user.uid));
      batch.delete(_db.collection('clients').doc(user.uid));
      await batch.commit();

      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _failure(e);
    } on FirebaseException catch (e) {
      throw AuthFailure(
        'Impossible de supprimer les données du compte '
        '(code ${e.code}). Réessayez.',
      );
    }
  }

  @override
  Future<void> logout() => _auth.signOut();
}
