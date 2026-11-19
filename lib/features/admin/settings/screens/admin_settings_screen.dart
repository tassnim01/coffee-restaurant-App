import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../core/widgets/app_text_field.dart';

class AdminSettingsScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const AdminSettingsScreen({super.key, this.onMenuTap});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  static const _days = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  final _profileForm = GlobalKey<FormState>();
  final _restaurantForm = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _photoUrl = TextEditingController();
  final _restaurantName = TextEditingController();
  final _logoUrl = TextEditingController();
  final _address = TextEditingController();
  final _locationUrl = TextEditingController();
  final _restaurantPhone = TextEditingController();
  final _restaurantEmail = TextEditingController();
  final _openingTime = TextEditingController();
  final _closingTime = TextEditingController();

  Set<String> _workingDays = {};
  bool _loading = true;
  bool _savingProfile = false;
  bool _savingRestaurant = false;
  bool _notificationsEnabled = true;

  DocumentReference<Map<String, dynamic>> get _restaurantDocument =>
      FirebaseFirestore.instance.collection('settings').doc('restaurant');

  @override
  void initState() {
    super.initState();
    _photoUrl.addListener(_refreshImagePreview);
    _logoUrl.addListener(_refreshImagePreview);
    _loadSettings();
  }

  void _refreshImagePreview() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _photoUrl.removeListener(_refreshImagePreview);
    _logoUrl.removeListener(_refreshImagePreview);
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _photoUrl.dispose();
    _restaurantName.dispose();
    _logoUrl.dispose();
    _address.dispose();
    _locationUrl.dispose();
    _restaurantPhone.dispose();
    _restaurantEmail.dispose();
    _openingTime.dispose();
    _closingTime.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final preferences = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _notificationsEnabled =
              preferences.getBool('admin_order_notifications_enabled') ?? true;
          _loading = false;
        });
      }
      return;
    }

    try {
      final results = await Future.wait([
        FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        _restaurantDocument.get(),
      ]);
      if (!mounted) return;

      final profile = results[0].data() ?? {};
      final restaurant = results[1].data() ?? {};
      _name.text = profile['name'] as String? ?? user.displayName ?? '';
      _email.text = user.email ?? profile['email'] as String? ?? '';
      _phone.text = profile['phone'] as String? ?? '';
      _photoUrl.text = profile['photoUrl'] as String? ?? user.photoURL ?? '';
      _restaurantName.text =
          restaurant['name'] as String? ?? 'Capucine Restaurant';
      _logoUrl.text = restaurant['logoUrl'] as String? ?? '';
      _address.text = restaurant['address'] as String? ?? '';
      _locationUrl.text = restaurant['locationUrl'] as String? ?? '';
      _restaurantPhone.text = restaurant['phone'] as String? ?? '';
      _restaurantEmail.text = restaurant['email'] as String? ?? '';
      _openingTime.text = restaurant['openingTime'] as String? ?? '';
      _closingTime.text = restaurant['closingTime'] as String? ?? '';
      _workingDays = Set<String>.from(
        restaurant['workingDays'] as List<dynamic>? ?? const [],
      );
      setState(() {
        _notificationsEnabled =
            preferences.getBool('admin_order_notifications_enabled') ?? true;
        _loading = false;
      });
    } on FirebaseException {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage('Impossible de charger les paramètres depuis Firebase.');
    }
  }

  Future<void> _saveProfile() async {
    if (!_profileForm.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage('Votre session administrateur a expiré.');
      return;
    }

    setState(() => _savingProfile = true);
    var emailChangePending = false;
    try {
      final newEmail = _email.text.trim();
      if (newEmail != (user.email ?? '')) {
        final password = await _askCurrentPassword();
        if (password == null || !mounted) return;
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        await user.verifyBeforeUpdateEmail(newEmail);
        emailChangePending = true;
      }

      final name = _name.text.trim();
      final phone = _phone.text.trim();
      final photoUrl = _photoUrl.text.trim();
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'phone': phone,
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await user.updateDisplayName(name);
      await user.updatePhotoURL(photoUrl.isEmpty ? null : photoUrl);
      if (!mounted) return;
      _showMessage(
        emailChangePending
            ? 'Profil enregistré. Confirmez le lien envoyé par e-mail pour changer votre adresse.'
            : 'Profil administrateur enregistré.',
      );
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        _showMessage(switch (error.code) {
          'wrong-password' ||
          'invalid-credential' => 'Mot de passe actuel incorrect.',
          'requires-recent-login' =>
            'Reconnectez-vous avant de modifier cette information.',
          'email-already-in-use' => 'Cette adresse e-mail est déjà utilisée.',
          'invalid-email' => 'Adresse e-mail invalide.',
          _ => 'Impossible de modifier le profil Firebase.',
        });
      }
    } on FirebaseException {
      if (mounted) _showMessage('Impossible d’enregistrer le profil.');
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  Future<String?> _askCurrentPassword() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer votre identité'),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: appInputDecoration(label: 'Mot de passe actuel'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Continuer'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      _showMessage('Votre session administrateur a expiré.');
      return;
    }

    final credentials = await showDialog<(String, String)>(
      context: context,
      builder: (context) => const _ChangePasswordDialog(),
    );
    if (credentials == null || !mounted) return;

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: credentials.$1,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(credentials.$2);
      if (mounted) _showMessage('Mot de passe modifié.');
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        _showMessage(switch (error.code) {
          'wrong-password' ||
          'invalid-credential' => 'Mot de passe actuel incorrect.',
          'weak-password' => 'Le nouveau mot de passe est trop faible.',
          'requires-recent-login' =>
            'Reconnectez-vous avant de modifier le mot de passe.',
          _ => 'Impossible de modifier le mot de passe.',
        });
      }
    }
  }

  Future<void> _saveRestaurant() async {
    if (!_restaurantForm.currentState!.validate()) return;
    setState(() => _savingRestaurant = true);
    try {
      await _restaurantDocument.set({
        'name': _restaurantName.text.trim(),
        'logoUrl': _logoUrl.text.trim(),
        'address': _address.text.trim(),
        'locationUrl': _locationUrl.text.trim(),
        'phone': _restaurantPhone.text.trim(),
        'email': _restaurantEmail.text.trim(),
        'openingTime': _openingTime.text.trim(),
        'closingTime': _closingTime.text.trim(),
        'workingDays': _days.where(_workingDays.contains).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) _showMessage('Informations du restaurant enregistrées.');
    } on FirebaseException {
      if (mounted) {
        _showMessage(
          'Impossible d’enregistrer les informations du restaurant.',
        );
      }
    } finally {
      if (mounted) setState(() => _savingRestaurant = false);
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final initial =
        _parseTime(controller.text) ?? const TimeOfDay(hour: 9, minute: 0);
    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (selected == null || !mounted) return;
    controller.text = selected.format(context);
  }

  TimeOfDay? _parseTime(String value) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})(?:\s*(AM|PM))?$',
      caseSensitive: false,
    ).firstMatch(value.trim());
    if (match == null) return null;
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final meridiem = match.group(3)?.toUpperCase();
    if (minute > 59) return null;
    if (meridiem != null) {
      if (hour < 1 || hour > 12) return null;
      hour %= 12;
      if (meridiem == 'PM') hour += 12;
    } else if (hour > 23) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException {
      if (mounted) _showMessage('Impossible de fermer la session Firebase.');
    }
  }

  Future<void> _setNotificationsEnabled(bool value) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool('admin_order_notifications_enabled', value);
      if (mounted) setState(() => _notificationsEnabled = value);
    } catch (_) {
      if (mounted) _showMessage('Impossible d’enregistrer cette préférence.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final darkMode =
        context.watch<ThemeModeProvider>().themeMode == ThemeMode.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onMenuTap,
                    icon: const Icon(Icons.menu_rounded, size: 28),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('Paramètres', style: AppTextStyles.screenTitle),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        _section(
                          title: '1. Profil administrateur',
                          subtitle: 'Informations personnelles et compte',
                          child: Form(
                            key: _profileForm,
                            child: Column(
                              children: [
                                _photoPreview(_photoUrl.text, profile: true),
                                _field('Nom et prénom', _name, required: true),
                                _field(
                                  'Photo de profil (URL)',
                                  _photoUrl,
                                  keyboardType: TextInputType.url,
                                ),
                                _field(
                                  'Adresse e-mail',
                                  _email,
                                  required: true,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _validateEmail,
                                ),
                                _field(
                                  'Numéro de téléphone',
                                  _phone,
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 12),
                                _wideButton(
                                  label: 'Enregistrer le profil',
                                  busy: _savingProfile,
                                  onPressed: _saveProfile,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: _changePassword,
                                        icon: const Icon(Icons.lock_outline),
                                        label: const Text(
                                          'Modifier le mot de passe',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: _logout,
                                        icon: const Icon(Icons.logout_rounded),
                                        label: const Text('Déconnexion'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _section(
                          title: '2. Informations du restaurant',
                          subtitle: 'Configuration générale du restaurant',
                          child: Form(
                            key: _restaurantForm,
                            child: Column(
                              children: [
                                _photoPreview(_logoUrl.text),
                                _field(
                                  'Nom du restaurant',
                                  _restaurantName,
                                  required: true,
                                ),
                                _field(
                                  'Logo du restaurant (URL)',
                                  _logoUrl,
                                  keyboardType: TextInputType.url,
                                ),
                                _field('Adresse', _address),
                                _field(
                                  'Lien de localisation (URL)',
                                  _locationUrl,
                                  keyboardType: TextInputType.url,
                                ),
                                _field(
                                  'Téléphone',
                                  _restaurantPhone,
                                  keyboardType: TextInputType.phone,
                                ),
                                _field(
                                  'E-mail',
                                  _restaurantEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty
                                      ? null
                                      : _validateEmail(value),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _timeField(
                                        'Ouverture',
                                        _openingTime,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _timeField(
                                        'Fermeture',
                                        _closingTime,
                                      ),
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      bottom: 8,
                                    ),
                                    child: Text(
                                      'Jours de travail et jours de repos',
                                      style: AppTextStyles.body,
                                    ),
                                  ),
                                ),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    for (final day in _days)
                                      FilterChip(
                                        label: Text(day),
                                        selected: _workingDays.contains(day),
                                        onSelected: (selected) => setState(() {
                                          if (selected) {
                                            _workingDays.add(day);
                                          } else {
                                            _workingDays.remove(day);
                                          }
                                        }),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _wideButton(
                                  label: 'Enregistrer les informations',
                                  busy: _savingRestaurant,
                                  onPressed: _saveRestaurant,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _section(
                          title: 'Préférences',
                          subtitle: 'Apparence et notifications',
                          child: Column(
                            children: [
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Mode sombre'),
                                subtitle: Text(
                                  darkMode ? 'Activé' : 'Désactivé',
                                ),
                                value: darkMode,
                                onChanged: context
                                    .read<ThemeModeProvider>()
                                    .setDarkMode,
                                secondary: const Icon(Icons.dark_mode_outlined),
                              ),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text(
                                  'Notifications des commandes',
                                ),
                                value: _notificationsEnabled,
                                onChanged: _setNotificationsEnabled,
                                secondary: const Icon(
                                  Icons.notifications_none_rounded,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (user == null)
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text('Session administrateur inactive.'),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.productName.copyWith(fontSize: 16)),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: AppTextStyles.chip.copyWith(color: AppColors.gray),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool required = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: appInputDecoration(label: label),
        validator:
            validator ??
            (required
                ? (value) => value == null || value.trim().isEmpty
                      ? '$label obligatoire.'
                      : null
                : null),
      ),
    );
  }

  Widget _timeField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _pickTime(controller),
        decoration: appInputDecoration(label: label)
            .copyWith(suffixIcon: const Icon(Icons.access_time_rounded)),
      ),
    );
  }

  Widget _photoPreview(String url, {bool profile = false}) {
    final image = url.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Center(
        child: Container(
          width: profile ? 86 : 140,
          height: profile ? 86 : 88,
          decoration: BoxDecoration(
            color: AppColors.chipBackground,
            shape: profile ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: profile ? null : BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: image.isEmpty
              ? Icon(
                  profile ? Icons.person_rounded : Icons.restaurant_rounded,
                  size: 38,
                  color: AppColors.forestGreen,
                )
              : Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.gray,
                    size: 32,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _wideButton({
    required String label,
    required bool busy,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(backgroundColor: AppColors.forestGreen),
        child: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label, style: AppTextStyles.button),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
        ? null
        : 'Adresse e-mail invalide.';
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le mot de passe'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _current,
              obscureText: true,
              decoration: appInputDecoration(label: 'Mot de passe actuel'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Champ obligatoire.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _new,
              obscureText: true,
              decoration: appInputDecoration(label: 'Nouveau mot de passe'),
              validator: (value) => value == null || value.length < 6
                  ? '6 caractères minimum.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirm,
              obscureText: true,
              decoration: appInputDecoration(
                label: 'Confirmer le mot de passe',
              ),
              validator: (value) => value != _new.text
                  ? 'Les mots de passe ne correspondent pas.'
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, (_current.text, _new.text));
          },
          child: const Text('Modifier'),
        ),
      ],
    );
  }
}
