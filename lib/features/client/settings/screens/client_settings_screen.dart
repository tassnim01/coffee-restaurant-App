import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../auth/data/biometric_service.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/widgets/auth_sheet.dart';
import 'profile_screen.dart';

/// Paramètres du compte client connecté.
class ClientSettingsScreen extends StatefulWidget {
  final VoidCallback? onEditProfile;

  const ClientSettingsScreen({super.key, this.onEditProfile});

  @override
  State<ClientSettingsScreen> createState() => _ClientSettingsScreenState();
}

class _ClientSettingsScreenState extends State<ClientSettingsScreen> {
  static const _notifKey = 'notifications_enabled';
  bool _notifications = true;
  bool _biometricsAvailable = false;
  bool _biometricsEnabled = false;

  @override
  void initState() {
    super.initState();
    _load();
    _loadBiometrics();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _notifications = prefs.getBool(_notifKey) ?? true);
  }

  Future<void> _setNotifications(bool value) async {
    setState(() => _notifications = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifKey, value);
  }

  Future<void> _loadBiometrics() async {
    final available = await BiometricService.isAvailable();
    final enabled = available && await BiometricService.isEnabled();
    if (!mounted) return;
    setState(() {
      _biometricsAvailable = available;
      _biometricsEnabled = enabled;
    });
  }

  Future<void> _setBiometrics(bool value) async {
    if (!value) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Face ID est obligatoire après l’inscription et ne peut pas être désactivé.',
              ),
            ),
          );
      }
      return;
    }

    if (value) {
      final available = await BiometricService.isAvailable();
      if (!mounted) return;
      setState(() => _biometricsAvailable = available);
      if (!available) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Configurez d’abord la reconnaissance faciale ou une empreinte dans les paramètres du téléphone.',
              ),
            ),
          );
        return;
      }

      await showAuthSheet(context, startWithLogin: true);
      if (mounted) await _loadBiometrics();
      return;
    }

    await BiometricService.clear();
    if (mounted) setState(() => _biometricsEnabled = false);
  }

  void _showSheet(String title, List<Widget> children) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          24 + MediaQuery.of(ctx).viewPadding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.screenTitle),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  void _showLanguage() {
    Widget option(String name, {required bool selected, String? hint}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.body.copyWith(
                  color: selected ? AppColors.textPrimary : AppColors.gray,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_rounded, color: AppColors.forestGreen),
            if (hint != null)
              Text(
                hint,
                style: AppTextStyles.chip.copyWith(
                  color: AppColors.gray,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      );
    }

    _showSheet('Langue', [
      option('Français', selected: true),
      option('English', selected: false, hint: 'Bientôt'),
      option('العربية', selected: false, hint: 'Bientôt'),
    ]);
  }

  void _showHelp() {
    Widget qa(String q, String a) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q, style: AppTextStyles.productName.copyWith(fontSize: 14)),
          const SizedBox(height: 3),
          Text(a, style: AppTextStyles.body.copyWith(color: AppColors.gray)),
        ],
      ),
    );

    _showSheet('Aide et support', [
      qa(
        'Comment passer une commande ?',
        'Ajoutez des plats au panier, puis touchez « Valider la commande ».',
      ),
      qa(
        'Comment payer ?',
        "Le paiement se fait uniquement en espèces, auprès du responsable, après réception de votre commande.",
      ),
      qa(
        'Puis-je modifier ma commande ?',
        "Oui, tant qu'elle est en attente : ouvrez-la dans « Mes commandes », puis touchez « Modifier ».",
      ),
    ]);
  }

  void _showTerms() {
    _showSheet('Conditions générales', [
      Text(
        'En utilisant cette application, vous pouvez consulter le menu et '
        'passer des commandes au restaurant. Les informations de compte servent '
        'à gérer votre profil et vos commandes.',
        style: AppTextStyles.body.copyWith(color: AppColors.gray),
      ),
    ]);
  }

  void _showAbout() {
    _showSheet('À propos de l\'application', [
      Text(
        'Good Food Good Mood',
        style: AppTextStyles.productName.copyWith(fontSize: 16),
      ),
      const SizedBox(height: 4),
      Text(
        'Version 1.0.0',
        style: AppTextStyles.chip.copyWith(color: AppColors.gray),
      ),
      const SizedBox(height: 12),
      Text(
        'Application de commande en restaurant développée avec Flutter et Firebase par le Groupe 5, dans le cadre du module Développement Mobile Cross-plateformes.',
        style: AppTextStyles.body.copyWith(color: AppColors.gray),
      ),
    ]);
  }

  Future<void> _changePassword() async {
    final result = await showDialog<_PasswordChange>(
      context: context,
      builder: (_) => const _ChangePasswordDialog(),
    );
    if (result == null || !mounted) return;

    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;
    final updated = await auth.updateProfile(
      name: user.name,
      phone: user.phone,
      email: user.email,
      currentPassword: result.current,
      newPassword: result.next,
    );
    if (!mounted) return;
    if (updated && await BiometricService.isEnabled()) {
      await BiometricService.enable(user.email, result.next);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            updated
                ? 'Mot de passe modifié.'
                : auth.error ?? 'Impossible de modifier le mot de passe.',
          ),
        ),
      );
  }

  Future<void> _deleteAccount() async {
    final password = await showDialog<String>(
      context: context,
      builder: (_) => const _DeleteAccountDialog(),
    );
    if (password == null || !mounted) return;
    final deleted = await context.read<AuthProvider>().deleteAccount(
      password: password,
    );
    if (!mounted) return;
    if (!deleted) {
      final error = context.read<AuthProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Impossible de supprimer le compte.')),
      );
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
    await BiometricService.clear();
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final themeMode = context.watch<ThemeModeProvider>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.chevron_left_rounded, size: 28),
                  ),
                  Expanded(
                    child: Text('Paramètres', style: AppTextStyles.screenTitle),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  if (user != null) ...[
                    _group([
                      _tile(
                        Icons.person_outline_rounded,
                        'Modifier le profil',
                        onTap:
                            widget.onEditProfile ??
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProfileScreen(onEdit: widget.onEditProfile),
                              ),
                            ),
                      ),
                      _tile(
                        Icons.lock_outline_rounded,
                        'Changer le mot de passe',
                        onTap: _changePassword,
                      ),
                      _tile(
                        Icons.fingerprint_rounded,
                        BiometricService.label,
                        value: !_biometricsAvailable
                            ? 'Non disponible'
                            : _biometricsEnabled
                            ? 'Activée'
                            : 'Désactivée',
                        trailing: Switch(
                          value: _biometricsEnabled,
                          onChanged: _setBiometrics,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                  ],
                  _group([
                    _tile(
                      Icons.language_rounded,
                      'Langue',
                      value: 'Français',
                      onTap: _showLanguage,
                    ),
                    _tile(
                      Icons.notifications_none_rounded,
                      'Notifications',
                      trailing: Switch(
                        value: _notifications,
                        onChanged: _setNotifications,
                      ),
                    ),
                    _tile(
                      Icons.dark_mode_outlined,
                      'Mode sombre',
                      trailing: Switch(
                        value: themeMode.themeMode == ThemeMode.dark,
                        onChanged: themeMode.setDarkMode,
                      ),
                    ),
                    _tile(
                      Icons.description_outlined,
                      'Conditions générales',
                      onTap: _showTerms,
                    ),
                    _tile(
                      Icons.help_outline_rounded,
                      'Aide et support',
                      onTap: _showHelp,
                    ),
                    _tile(
                      Icons.info_outline_rounded,
                      "À propos de l'application",
                      onTap: _showAbout,
                    ),
                  ]),
                  const SizedBox(height: 18),
                  if (user == null)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: () =>
                            showAuthSheet(context, startWithLogin: true),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.forestGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Se connecter'),
                      ),
                    )
                  else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _logout,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.burgundy,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Se déconnecter'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _deleteAccount,
                      child: Text(
                        'Supprimer mon compte',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.burgundy,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _group(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            tiles[i],
            if (i < tiles.length - 1)
              Divider(height: 1, indent: 54, color: AppColors.border),
          ],
        ],
      ),
    );
  }

  Widget _tile(
    IconData icon,
    String label, {
    String? value,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.forestGreen),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: AppTextStyles.body)),
            if (value != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  value,
                  style: AppTextStyles.chip.copyWith(
                    color: AppColors.gray,
                    fontSize: 12.5,
                  ),
                ),
              ),
            trailing ??
                (onTap != null
                    ? const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.gray,
                      )
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

class _PasswordChange {
  final String current;
  final String next;

  const _PasswordChange(this.current, this.next);
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AppColors.surface,
    title: Text('Changer le mot de passe', style: AppTextStyles.screenTitle),
    content: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _passwordField(_current, 'Mot de passe actuel'),
            const SizedBox(height: 12),
            _passwordField(
              _next,
              'Nouveau mot de passe',
              validator: (value) => value == null || value.length < 6
                  ? '6 caractères minimum.'
                  : null,
            ),
            const SizedBox(height: 12),
            _passwordField(
              _confirmation,
              'Confirmer le mot de passe',
              validator: (value) => value != _next.text
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
          Navigator.of(context).pop(_PasswordChange(_current.text, _next.text));
        },
        style: FilledButton.styleFrom(backgroundColor: AppColors.forestGreen),
        child: const Text('Enregistrer'),
      ),
    ],
  );

  Widget _passwordField(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    obscureText: true,
    decoration: InputDecoration(labelText: label),
    validator:
        validator ??
        (value) =>
            value == null || value.isEmpty ? 'Ce champ est obligatoire.' : null,
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
            decoration: const InputDecoration(labelText: 'Mot de passe'),
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

class _DeliveryAddressesScreen extends StatefulWidget {
  const _DeliveryAddressesScreen();

  @override
  State<_DeliveryAddressesScreen> createState() =>
      _DeliveryAddressesScreenState();
}

class _DeliveryAddressesScreenState extends State<_DeliveryAddressesScreen> {
  List<String> _addresses = [];

  String? get _addressKey {
    final uid = context.read<AuthProvider>().user?.uid;
    return uid == null ? null : 'client_delivery_addresses_$uid';
  }

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final key = _addressKey;
    if (key == null) return;
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _addresses = preferences.getStringList(key) ?? []);
  }

  Future<void> _addAddress() async {
    final controller = TextEditingController();
    final address = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle adresse'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'Adresse de livraison'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (address == null || !mounted) return;
    final updated = [..._addresses, address];
    final key = _addressKey;
    if (key == null) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(key, updated);
    if (mounted) setState(() => _addresses = updated);
  }

  Future<void> _removeAddress(int index) async {
    final updated = [..._addresses]..removeAt(index);
    final key = _addressKey;
    if (key == null) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(key, updated);
    if (mounted) setState(() => _addresses = updated);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.chevron_left_rounded, size: 28),
                ),
                Expanded(
                  child: Text(
                    'Adresses de livraison',
                    style: AppTextStyles.screenTitle,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_addresses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'Aucune adresse enregistrée.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(color: AppColors.gray),
                    ),
                  ),
                for (var i = 0; i < _addresses.length; i++)
                  Card(
                    color: AppColors.surface,
                    child: ListTile(
                      leading: const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.forestGreen,
                      ),
                      title: Text(_addresses[i]),
                      trailing: IconButton(
                        tooltip: 'Supprimer',
                        onPressed: () => _removeAddress(i),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.burgundy,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _addAddress,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Ajouter une adresse'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
