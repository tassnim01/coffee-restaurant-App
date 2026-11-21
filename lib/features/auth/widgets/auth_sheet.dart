import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/biometric_service.dart';
import '../providers/auth_provider.dart';

/// Ouvre la fenêtre d'inscription (ou de connexion).
/// Retourne true si le client est connecté à la fermeture.
Future<bool?> showAuthSheet(
  BuildContext context, {
  bool startWithLogin = false,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _AuthSheet(startWithLogin: startWithLogin),
  );
}

class _AuthSheet extends StatefulWidget {
  final bool startWithLogin;
  const _AuthSheet({required this.startWithLogin});

  @override
  State<_AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<_AuthSheet> {
  static const _badCredentials = 'E-mail ou mot de passe incorrect.';

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late bool _login;
  bool _hidePassword = true;

  bool _bioAvailable = false; // le téléphone sait faire de la biométrie
  bool _bioEnabled = false; // Face ID déjà activé sur ce téléphone
  String? _biometricError;

  IconData get _bioIcon => defaultTargetPlatform == TargetPlatform.iOS
      ? Icons.face_unlock_outlined
      : Icons.fingerprint;

  @override
  void initState() {
    super.initState();
    _login = widget.startWithLogin;
    _loadBiometrics();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _loadBiometrics() async {
    final available = await BiometricService.isAvailable();
    var enabled = available && await BiometricService.isEnabled();
    if (enabled) {
      final creds = await BiometricService.read();
      if (creds != null) {
        if (!mounted) return;
        final valid = await context.read<AuthProvider>().validateCredentials(
          email: creds.email,
          password: creds.password,
        );
        if (!valid) {
          await BiometricService.clear();
          enabled = false;
        }
      } else {
        await BiometricService.clear();
        enabled = false;
      }
    }
    if (!mounted) return;
    setState(() {
      _bioAvailable = available;
      _bioEnabled = enabled;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _biometricError = null);

    if (!_bioAvailable) {
      setState(() {
        _biometricError = 'Configurez Face ID ou une empreinte dans les paramètres du téléphone. Cette authentification est obligatoire.';
      });
      return;
    }

    if (!_login && _bioEnabled) {
      setState(() {
        _biometricError = 'Le compte actuel est déjà enregistré avec Face ID sur cet appareil.';
      });
      return;
    }

    final email = _email.text.trim();
    final password = _password.text;
    final auth = context.read<AuthProvider>();
    final verified = await BiometricService.authenticate(
      _login
          ? 'Confirmez votre identité pour enregistrer Face ID.'
          : 'Confirmez votre identité pour créer votre compte avec Face ID.',
    );
    if (!verified) {
      if (mounted) {
        setState(() {
          _biometricError =
              '${BiometricService.label} est obligatoire pour continuer.';
        });
      }
      return;
    }

    final ok = _login
        ? await auth.login(email: email, password: password)
        : await auth.register(
            name: _name.text,
            phone: _phone.text,
            email: email,
            password: password,
          );
    if (!ok || !mounted) return;

    await BiometricService.enable(email, password);
    if (mounted) setState(() => _bioEnabled = true);
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _loginWithBiometrics() async {
    final auth = context.read<AuthProvider>();
    auth.clearError();

    final verified = await BiometricService.authenticate(
      'Connectez-vous avec ${BiometricService.label}.',
    );
    if (!verified || !mounted) return;

    final creds = await BiometricService.read();
    if (creds == null) {
      if (mounted) setState(() => _bioEnabled = false);
      return;
    }

    final ok = await auth.login(email: creds.email, password: creds.password);
    if (ok && mounted) {
      Navigator.of(context).pop(true);
      return;
    }

    // Mot de passe changé depuis : on désactive Face ID.
    if (auth.error == _badCredentials) {
      await BiometricService.clear();
      if (mounted) setState(() => _bioEnabled = false);
    }
  }

  void _toggleMode() {
    context.read<AuthProvider>().clearError();
    setState(() => _login = !_login);
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
    bool password = false,
  }) {
    var decoration = appInputDecoration(hint: hint);
    if (password) {
      decoration = decoration.copyWith(
        suffixIcon: IconButton(
          onPressed: () => setState(() => _hidePassword = !_hidePassword),
          icon: Icon(
            _hidePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.gray,
            size: 21,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(label, required: true),
          TextFormField(
            controller: controller,
            style: AppTextStyles.body,
            cursorColor: AppColors.forestGreen,
            keyboardType: keyboardType,
            inputFormatters: formatters,
            obscureText: password && _hidePassword,
            validator: validator,
            decoration: decoration,
          ),
        ],
      ),
    );
  }

  Widget _faceIdButton(bool busy) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: busy ? null : _loginWithBiometrics,
        icon: Icon(_bioIcon, color: AppColors.forestGreen, size: 24),
        label: Text(
          'Se connecter avec ${BiometricService.label}',
          style: AppTextStyles.toggle.copyWith(color: AppColors.forestGreen),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.forestGreen, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final showFaceIdLogin = _login && _bioAvailable && _bioEnabled;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _login ? 'Connexion' : 'Créez votre compte',
                style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 6),
              Text(
                _login ? 'Connectez-vous pour valider votre commande.' : 'Pour valider votre commande, le restaurant a besoin de savoir qui vous êtes.',
                style: AppTextStyles.body.copyWith(color: AppColors.gray),
              ),
              const SizedBox(height: 18),
              if (showFaceIdLogin) ...[_faceIdButton(auth.isLoading)],
              if (!showFaceIdLogin && !_login) ...[
                _field(
                  'Nom complet',
                  _name,
                  hint: 'Ex. Ahmed Ben Ali',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Le nom est obligatoire'
                      : null,
                ),
                _field(
                  'Téléphone',
                  _phone,
                  hint: 'Ex. +216 98 123 456',
                  keyboardType: TextInputType.phone,
                  formatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                  ],
                  validator: (v) =>
                      RegExp(r'^\d{8}$')
                          .hasMatch(Formatters.normalizePhone(v ?? ''))
                      ? null
                      : 'Numéro invalide (8 chiffres)',
                ),
              ],
              if (!showFaceIdLogin) ...[
                _field(
                  'E-mail',
                  _email,
                  hint: 'exemple@mail.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch((v ?? '').trim())
                      ? null
                      : 'Adresse e-mail invalide',
                ),
                _field(
                  'Mot de passe',
                  _password,
                  hint: '6 caractères minimum',
                  password: true,
                  validator: (v) => (v == null || v.length < 6)
                      ? '6 caractères minimum'
                      : null,
                ),
              ],
              if (_biometricError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _biometricError!,
                    style: AppTextStyles.chip.copyWith(
                      color: AppColors.burgundy,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    auth.error!,
                    style: AppTextStyles.chip.copyWith(
                      color: AppColors.burgundy,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              if (!showFaceIdLogin)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: auth.isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.forestGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _login
                                ? 'Se connecter et valider'
                                : "S'inscrire avec Face ID",
                            style: AppTextStyles.button,
                          ),
                  ),
                ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _toggleMode,
                  child: Text(
                    _login
                        ? "Pas encore de compte ? S'inscrire"
                        : 'Déjà un compte ? Se connecter',
                    style: AppTextStyles.toggle.copyWith(
                      fontSize: 13,
                      color: AppColors.forestGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
