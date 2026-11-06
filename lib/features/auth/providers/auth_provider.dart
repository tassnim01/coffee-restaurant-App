import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/auth_repository.dart';
import '../models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  StreamSubscription<String?>? _subscription;

  AppUser? _user;
  bool _isLoading = false;
  bool _busy = false; // inscription ou connexion en cours
  String? _error;

  AuthProvider(this._repository) {
    _subscription = _repository.authStateChanges().listen(_onAuthChanged);
  }

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Restaure la session au démarrage de l'application.
  Future<void> _onAuthChanged(String? uid) async {
    if (_busy) return;
    if (uid == null) {
      _user = null;
    } else if (_user?.uid != uid) {
      final profile = await _repository.loadProfile(uid);
      if (profile != null) _user = profile;
    }
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) {
    return _run(() => _repository.register(
          name: name,
          phone: phone,
          email: email,
          password: password,
        ));
  }

  Future<bool> login({required String email, required String password}) {
    return _run(() => _repository.login(email: email, password: password));
  }

  Future<bool> _run(Future<AppUser> Function() action) async {
    _busy = true;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await action();
      return true;
    } on AuthFailure catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Une erreur est survenue. Réessayez.';
      return false;
    } finally {
      _busy = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}