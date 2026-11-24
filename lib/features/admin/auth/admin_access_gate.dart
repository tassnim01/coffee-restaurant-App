import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../shell/admin_shell.dart';

class AdminAccessGate extends StatelessWidget {
  const AdminAccessGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AdminLoadingScreen();
        }
        final user = snapshot.data;
        if (user == null) return const AdminLoginScreen();
        return _AdminSessionCheck(key: ValueKey(user.uid), user: user);
      },
    );
  }
}

class _AdminSessionCheck extends StatefulWidget {
  final User user;

  const _AdminSessionCheck({super.key, required this.user});

  @override
  State<_AdminSessionCheck> createState() => _AdminSessionCheckState();
}

class _AdminSessionCheckState extends State<_AdminSessionCheck> {
  late Future<bool> _isAdmin = _checkRole();

  Future<bool> _checkRole() async {
    final firestore = FirebaseFirestore.instance;
    debugPrint(
      '[AdminAccess] Checking role for UID ${widget.user.uid} '
      'in project ${firestore.app.options.projectId}',
    );
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(widget.user.uid)
          .get();
      final role = snapshot.data()?['role'];
      debugPrint(
        '[AdminAccess] Document exists: ${snapshot.exists}; '
        'role: ${role ?? '<missing>'}',
      );
      return role == 'admin';
    } on FirebaseException catch (error) {
      debugPrint(
        '[AdminAccess] Firestore check failed: '
        '${error.code}: ${error.message ?? '<no message>'}',
      );
      rethrow;
    }
  }

  void _retryRoleCheck() {
    debugPrint('[AdminAccess] Retry button pressed for UID ${widget.user.uid}');
    final check = _checkRole();
    setState(() {
      _isAdmin = check;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAdmin,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error;
          final permissionDenied =
              error is FirebaseException && error.code == 'permission-denied';
          return _AdminCheckError(
            message: permissionDenied
                ? 'Firestore refuse la lecture du profil. Vérifiez les règles de sécurité Firestore. UID du compte : ${widget.user.uid}'
                : 'Impossible de vérifier les droits administrateur. Vérifiez la connexion puis réessayez. UID du compte : ${widget.user.uid}',
            onRetry: _retryRoleCheck,
            onSignOut: _signOut,
          );
        }
        if (!snapshot.hasData) return const _AdminLoadingScreen();
        if (snapshot.data!) return const AdminShell();
        return _AdminCheckError(
          message:
              'Ce compte n’a pas le rôle administrateur. Dans Firestore, créez ou corrigez users/${widget.user.uid} avec le champ role (string) = admin.',
          onRetry: _retryRoleCheck,
          onSignOut: _signOut,
        );
      },
    );
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de fermer la session.')),
        );
      }
    }
  }
}

class AdminLoginScreen extends StatefulWidget {
  final String? initialError;

  const AdminLoginScreen({super.key, this.initialError});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _hidePassword = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _error = widget.initialError;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (credential.user == null) {
        throw StateError('La connexion Firebase n’a retourné aucun compte.');
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() {
          _error = switch (error.code) {
            'invalid-credential' ||
            'wrong-password' ||
            'user-not-found' => 'Adresse e-mail ou mot de passe incorrect.',
            'network-request-failed' =>
              'Connexion réseau impossible. Réessayez.',
            'operation-not-allowed' => 'Activez la connexion par e-mail/mot de passe dans Firebase Authentication.',
            _ => 'Connexion impossible. Vérifiez vos identifiants.',
          };
          _busy = false;
        });
      }
    } on FirebaseException {
      if (mounted) {
        setState(() {
          _error = 'Impossible de vérifier les droits administrateur.';
          _busy = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Une erreur est survenue pendant la connexion.';
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.restaurant_rounded,
                      size: 56,
                      color: AppColors.forestGreen,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Espace administrateur',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.screenTitle.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connectez-vous avec un compte administrateur.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(color: AppColors.gray),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: appInputDecoration(
                        label: 'Adresse e-mail',
                        hint: 'admin@restaurant.com',
                      ),
                      validator: (value) =>
                          value == null || !value.contains('@')
                          ? 'Adresse e-mail invalide.'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: _hidePassword,
                      decoration: appInputDecoration(label: 'Mot de passe')
                          .copyWith(
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _hidePassword = !_hidePassword,
                              ),
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                          ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Mot de passe obligatoire.'
                          : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.burgundy,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _busy ? null : _signIn,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.forestGreen,
                        ),
                        child: _busy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text('Se connecter', style: AppTextStyles.button),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminLoadingScreen extends StatelessWidget {
  const _AdminLoadingScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _AdminCheckError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSignOut;

  const _AdminCheckError({
    required this.message,
    required this.onRetry,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
              TextButton(
                onPressed: onSignOut,
                child: const Text('Se déconnecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
