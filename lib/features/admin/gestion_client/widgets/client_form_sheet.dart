import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../models/restaurant_client.dart';

/// Formulaire d'ajout/modification d'un client.
/// Retourne le client saisi (id vide pour un nouveau), ou null si annulé.
/// [isPhoneTaken] permet de refuser un numéro déjà utilisé.
Future<RestaurantClient?> showClientFormSheet(
  BuildContext context, {
  RestaurantClient? client,
  required bool Function(String phone) isPhoneTaken,
}) {
  return showModalBottomSheet<RestaurantClient>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ClientFormSheet(client: client, isPhoneTaken: isPhoneTaken),
  );
}

class _ClientFormSheet extends StatefulWidget {
  final RestaurantClient? client;
  final bool Function(String phone) isPhoneTaken;

  const _ClientFormSheet({this.client, required this.isPhoneTaken});

  @override
  State<_ClientFormSheet> createState() => _ClientFormSheetState();
}

class _ClientFormSheetState extends State<_ClientFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;

  bool get _isEdit => widget.client != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.client?.name ?? '');
    _phoneCtrl = TextEditingController(text: widget.client?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      RestaurantClient(
        id: widget.client?.id ?? '',
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        createdAt: widget.client?.createdAt ?? DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEdit ? 'Modifier le client' : 'Ajouter un client',
              style: AppTextStyles.screenTitle,
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: 'Nom du client',
              controller: _nameCtrl,
              hint: 'Ex. Ahmed Ben Ali',
              maxLength: 40,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Le nom est obligatoire'
                  : null,
            ),
            const SizedBox(height: 8),
            AppTextField(
              label: 'Téléphone',
              controller: _phoneCtrl,
              hint: 'Ex. +216 98 123 456',
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
              ],
              validator: (v) {
                final phone = Formatters.normalizePhone(v ?? '');
                if (!RegExp(r'^\d{8}$').hasMatch(phone)) {
                  return 'Numéro invalide (8 chiffres)';
                }
                if (widget.isPhoneTaken(v!)) {
                  return 'Ce numéro est déjà utilisé';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _isEdit ? 'Enregistrer' : 'Ajouter',
                  style: AppTextStyles.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}