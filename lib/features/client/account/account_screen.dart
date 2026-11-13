import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../auth/models/app_user.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/auth_sheet.dart';
import '../orders/screens/my_orders_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _editProfile(BuildContext context, AppUser user) async {
    final changes = await showDialog<_ProfileChanges>(
      context: context,
      builder: (_) => _EditProfileDialog(user: user),
    );
    if (changes == null || !context.mounted) return;

    final auth = context.read<AuthProvider>();
    if (await auth.updateProfile(
      name: changes.name,
      phone: changes.phone,
      email: changes.email,
      currentPassword: changes.currentPassword,
      newPassword: changes.newPassword,
    )) {
      if (context.mounted) {
        _showInfo(
          context,
          changes.email.trim() != user.email
              ? 'Profil modifié. Vérifiez le lien envoyé à votre nouvelle adresse e-mail.'
              : 'Profil modifié.',
        );
      }
    } else if (context.mounted) {
      _showInfo(context, auth.error ?? 'Erreur lors de la modification.');
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final password = await showDialog<String>(
      context: context,
      builder: (_) => const _DeleteAccountDialog(),
    );
    if (password == null || !context.mounted) return;

    final auth = context.read<AuthProvider>();
    if (await auth.deleteAccount(password: password)) {
      if (context.mounted) _showInfo(context, 'Votre compte a été supprimé.');
    } else if (context.mounted) {
      _showInfo(context, auth.error ?? 'Erreur lors de la suppression.');
    }
  }

  void _showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Compte', style: AppTextStyles.screenTitle),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.chipBackground,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 30,
                        color: AppColors.gray,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: user == null
                          ? Text(
                              'Vous n\'êtes pas connecté.',
                              style: AppTextStyles.body,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: AppTextStyles.productName,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.email,
                                  style: AppTextStyles.chip.copyWith(
                                    color: AppColors.gray,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  user.phone,
                                  style: AppTextStyles.chip.copyWith(
                                    color: AppColors.gray,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (user == null) ...[
                _button(
                  "S'inscrire",
                  filled: true,
                  onTap: () => showAuthSheet(context),
                ),
                const SizedBox(height: 10),
                _button(
                  'Se connecter',
                  onTap: () => showAuthSheet(context, startWithLogin: true),
                ),
              ] else ...[
                _button(
                  'Mes commandes',
                  filled: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                  ),
                ),
                const SizedBox(height: 10),
                _button(
                  'Modifier mes informations',
                  onTap: auth.isLoading
                      ? null
                      : () => _editProfile(context, user),
                ),
                const SizedBox(height: 10),
                _button(
                  'Se déconnecter',
                  onTap: auth.isLoading ? null : () => auth.logout(),
                ),
                const SizedBox(height: 10),
                _button(
                  'Supprimer mon compte',
                  color: AppColors.burgundy,
                  onTap: auth.isLoading ? null : () => _deleteAccount(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _button(
    String label, {
    bool filled = false,
    required VoidCallback? onTap,
    Color color = AppColors.forestGreen,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: filled
          ? FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(label, style: AppTextStyles.button),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color, width: 1.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                label,
                style: AppTextStyles.toggle.copyWith(color: color),
              ),
            ),
    );
  }
}

class _ProfileChanges {
  final String name;
  final String phone;
  final String email;
  final String? currentPassword;
  final String? newPassword;

  const _ProfileChanges({
    required this.name,
    required this.phone,
    required this.email,
    this.currentPassword,
    this.newPassword,
  });
}

class _EditProfileDialog extends StatefulWidget {
  final AppUser user;

  const _EditProfileDialog({required this.user});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.user.name);
  late final _phone = TextEditingController(text: widget.user.phone);
  late final _email = TextEditingController(text: widget.user.email);
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool get _sensitiveFieldsChanged =>
      _email.text.trim() != widget.user.email || _newPassword.text.isNotEmpty;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AppColors.surface,
    title: Text('Modifier mes informations', style: AppTextStyles.screenTitle),
    content: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Nom complet',
              controller: _name,
              maxLength: 40,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Le nom est obligatoire.'
                  : null,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Téléphone',
              controller: _phone,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
              ],
              validator: (value) =>
                  RegExp(r'^\d{8}$')
                      .hasMatch(Formatters.normalizePhone(value ?? ''))
                  ? null
                  : 'Numéro invalide (8 chiffres).',
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Adresse e-mail',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) =>
                  RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(value?.trim() ?? '')
                  ? null
                  : 'Adresse e-mail invalide.',
            ),
            const SizedBox(height: 14),
            Text(
              'Laissez les champs de mot de passe vides si vous ne souhaitez '
              'pas le modifier.',
              style: AppTextStyles.body.copyWith(color: AppColors.gray),
            ),
            const SizedBox(height: 12),
            _passwordField(
              label: 'Mot de passe actuel',
              controller: _currentPassword,
              validator: (value) =>
                  _sensitiveFieldsChanged && (value == null || value.isEmpty)
                  ? 'Obligatoire pour modifier l’e-mail ou le mot de passe.'
                  : null,
            ),
            const SizedBox(height: 14),
            _passwordField(
              label: 'Nouveau mot de passe',
              controller: _newPassword,
              validator: (value) =>
                  value != null && value.isNotEmpty && value.length < 6
                  ? '6 caractères minimum.'
                  : null,
            ),
            const SizedBox(height: 14),
            _passwordField(
              label: 'Confirmer le nouveau mot de passe',
              controller: _confirmPassword,
              validator: (value) =>
                  _newPassword.text.isNotEmpty && value != _newPassword.text
                  ? 'Les mots de passe ne correspondent pas.'
                  : null,
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          Navigator.of(context).pop(
            _ProfileChanges(
              name: _name.text,
              phone: _phone.text,
              email: _email.text,
              currentPassword: _currentPassword.text.isEmpty
                  ? null
                  : _currentPassword.text,
              newPassword: _newPassword.text.isEmpty ? null : _newPassword.text,
            ),
          );
        },
        style: FilledButton.styleFrom(backgroundColor: AppColors.forestGreen),
        child: const Text('Enregistrer'),
      ),
    ],
  );

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FieldLabel(label),
      TextFormField(
        controller: controller,
        obscureText: true,
        validator: validator,
        decoration: appInputDecoration(),
      ),
    ],
  );
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AppColors.surface,
    title: Text('Supprimer mon compte', style: AppTextStyles.screenTitle),
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cette action est définitive. Saisissez votre mot de passe '
            'pour confirmer la suppression.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _password,
            obscureText: true,
            autofocus: true,
            decoration: appInputDecoration(hint: 'Mot de passe'),
            validator: (value) => value == null || value.isEmpty
                ? 'Le mot de passe est obligatoire.'
                : null,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          Navigator.of(context).pop(_password.text);
        },
        style: FilledButton.styleFrom(backgroundColor: AppColors.burgundy),
        child: const Text('Supprimer'),
      ),
    ],
  );
}
