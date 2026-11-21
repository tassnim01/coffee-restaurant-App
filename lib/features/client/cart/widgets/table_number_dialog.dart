import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projet_test/core/theme/app_colors.dart';
import 'package:projet_test/core/theme/app_text_styles.dart';
import 'package:projet_test/core/widgets/app_text_field.dart';
import 'package:projet_test/features/auth/models/app_user.dart';

/// Demande le numéro de table. Retourne le numéro saisi, ou null si annulé.
/// [user] peut être un AppUser ou directement le nom du client.
Future<String?> showTableNumberDialog(BuildContext context, [Object? user]) {
  final name = user is AppUser ? user.name : (user is String ? user : null);
  return showDialog<String>(
    context: context,
    builder: (_) => _TableNumberDialog(name: name),
  );
}

class _TableNumberDialog extends StatefulWidget {
  final String? name;
  const _TableNumberDialog({this.name});

  @override
  State<_TableNumberDialog> createState() => _TableNumberDialogState();
}

class _TableNumberDialogState extends State<_TableNumberDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final text = _controller.text.trim();
    final number = int.tryParse(text);
    if (number == null || number <= 0) {
      setState(() => _error = 'Entrez un numéro de table valide.');
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.name;
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        name == null || name.isEmpty ? 'Bienvenue' : 'Bienvenue, $name',
        style: AppTextStyles.screenTitle.copyWith(fontSize: 22),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Veuillez saisir votre numéro de table.',
            style: AppTextStyles.body.copyWith(color: AppColors.gray),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            style: AppTextStyles.body,
            onSubmitted: (_) => _confirm(),
            decoration: appInputDecoration(hint: 'Ex. 5')
                .copyWith(errorText: _error),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: _confirm,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.forestGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text('Confirmer', style: AppTextStyles.button),
        ),
      ],
    );
  }
}