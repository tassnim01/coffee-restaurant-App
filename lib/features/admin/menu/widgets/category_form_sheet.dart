import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/category_icons.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../models/category.dart';

/// Ouvre le formulaire d'ajout/modification d'une catégorie.
/// Retourne la catégorie saisie (id vide pour une nouvelle), ou null si annulé.
Future<Category?> showCategoryFormSheet(
  BuildContext context, {
  Category? category,
}) {
  return showModalBottomSheet<Category>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _CategoryFormSheet(category: category),
  );
}

class _CategoryFormSheet extends StatefulWidget {
  final Category? category;
  const _CategoryFormSheet({this.category});

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late String _iconKey;

  bool get _isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.category?.name ?? '');
    _iconKey = widget.category?.iconKey ?? 'coffee';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      Category(
        id: widget.category?.id ?? '',
        name: _nameCtrl.text.trim(),
        iconKey: _iconKey,
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
              _isEdit ? 'Modifier la catégorie' : 'Ajouter une catégorie',
              style: AppTextStyles.screenTitle,
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: 'Nom de la catégorie',
              controller: _nameCtrl,
              hint: 'Ex. Salades',
              maxLength: 30,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Le nom est obligatoire'
                  : null,
            ),
            const SizedBox(height: 8),
            const FieldLabel('Icône'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: CategoryIcons.icons.entries.map((e) {
                final selected = e.key == _iconKey;
                final style = CategoryIcons.styleOf(e.key);
                return GestureDetector(
                  onTap: () => setState(() => _iconKey = e.key),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: style.bg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? AppColors.forestGreen
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(e.value, color: style.fg, size: 22),
                  ),
                );
              }).toList(),
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