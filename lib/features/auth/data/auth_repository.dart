import '../models/app_user.dart';

/// Erreur d'authentification avec un message prêt à afficher.
class AuthFailure implements Exception {
  final String message;
  const AuthFailure(this.message);

  @override
  String toString() => message;
}

abstract class AuthRepository {
  /// Émet l'uid de l'utilisateur connecté (null = déconnecté).
  Stream<String?> authStateChanges();

  Future<AppUser> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  });

  Future<AppUser> login({required String email, required String password});

  Future<AppUser?> loadProfile(String uid);

  Future<void> logout();
}