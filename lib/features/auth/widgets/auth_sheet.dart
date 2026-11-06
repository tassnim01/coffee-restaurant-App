import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_text_field.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late bool _login;
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    _login = widget.startWithLogin;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final ok = _login
        ? await auth.login(email: _email.text, password: _password.text)
        : await auth.register(
            name: _name.text,
            phone: _phone.text,
            email: _email.text,
            password: _password.text,
          );
    if (ok && mounted) Navigator.of(context).pop(true);
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

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
                _login
                    ? 'Connectez-vous pour valider votre commande.'
                    : 'Pour valider votre commande, le restaurant a besoin de savoir qui vous êtes.',
                style: AppTextStyles.body.copyWith(color: AppColors.gray),
              ),
              const SizedBox(height: 18),
              if (!_login) ...[
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
                      RegExp(r'^\d{8}$').hasMatch(Formatters.normalizePhone(v ?? ''))
                          ? null
                          : 'Numéro invalide (8 chiffres)',
                ),
              ],
              _field(
                'E-mail',
                _email,
                hint: 'exemple@mail.com',
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((v ?? '').trim())
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
              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    auth.error!,
                    style: AppTextStyles.chip
                        .copyWith(color: AppColors.burgundy, fontSize: 12.5),
                  ),
                ),
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
                              : "S'inscrire et valider",
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