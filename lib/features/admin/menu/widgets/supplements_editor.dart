import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../models/supplement.dart';

class _Row {
  final TextEditingController name;
  final TextEditingController price;
  _Row(String n, String p)
      : name = TextEditingController(text: n),
        price = TextEditingController(text: p);

  void dispose() {
    name.dispose();
    price.dispose();
  }
}

/// Liste modifiable de suppléments (nom + prix) pour le formulaire produit.
class SupplementsEditor extends StatefulWidget {
  final List<Supplement> initial;
  final ValueChanged<List<Supplement>> onChanged;

  const SupplementsEditor({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  @override
  State<SupplementsEditor> createState() => _SupplementsEditorState();
}

class _SupplementsEditorState extends State<SupplementsEditor> {
  late final List<_Row> _rows;

  @override
  void initState() {
    super.initState();
    _rows = widget.initial
        .map((s) => _Row(s.name, s.price.toStringAsFixed(3)))
        .toList();
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  /// Ne transmet que les lignes valides (nom non vide, prix numérique).
  void _emit() {
    final list = <Supplement>[];
    for (final r in _rows) {
      final name = r.name.text.trim();
      final price = double.tryParse(r.price.text.trim().replaceAll(',', '.'));
      if (name.isNotEmpty && price != null && price >= 0) {
        list.add(Supplement(name: name, price: price));
      }
    }
    widget.onChanged(list);
  }

  void _add() {
    setState(() => _rows.add(_Row('', '')));
  }

  void _remove(int index) {
    final removed = _rows.removeAt(index);
    setState(() {});
    removed.dispose();
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('Suppléments (optionnel)'),
        for (var i = 0; i < _rows.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _rows[i].name,
                    style: AppTextStyles.body,
                    onChanged: (_) => _emit(),
                    decoration: appInputDecoration(hint: 'Ex. Caramel'),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 96,
                  child: TextField(
                    controller: _rows[i].price,
                    style: AppTextStyles.body,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    onChanged: (_) => _emit(),
                    decoration: appInputDecoration(hint: '0.500'),
                  ),
                ),
                IconButton(
                  onPressed: () => _remove(i),
                  tooltip: 'Retirer',
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.burgundy, size: 21),
                ),
              ],
            ),
          ),
        OutlinedButton.icon(
          onPressed: _add,
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text('Ajouter un supplément'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.forestGreen,
            side: const BorderSide(color: AppColors.forestGreen),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}