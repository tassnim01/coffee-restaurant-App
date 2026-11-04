import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const SettingsScreen({super.key, this.onMenuTap});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _presets = <double>[0, 7, 13, 19];

  final _customCtrl = TextEditingController();
  bool _initialized = false;
  bool _custom = false;
  double _selected = 13;
  bool _saving = false;

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Initialise le formulaire avec le taux enregistré.
  void _syncFrom(double current) {
    _selected = current;
    _custom = !_presets.contains(current);
    if (_custom) _customCtrl.text = percent(current);
  }

  double? get _value => _custom
      ? double.tryParse(_customCtrl.text.trim().replaceAll(',', '.'))
      : _selected;

  Future<void> _save() async {
    final value = _value;
    if (value == null || value < 0 || value > 100) {
      _showInfo('Entrez un taux compris entre 0 et 100.');
      return;
    }
    final provider = context.read<SettingsProvider>();
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await provider.updateVat(value);
      if (mounted) _showInfo('Taux de TVA enregistré : ${percent(value)} %.');
    } catch (_) {
      if (mounted) _showInfo("Erreur lors de l'enregistrement.");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    if (!_initialized && !settings.isLoading) {
      _initialized = true;
      _syncFrom(settings.vatPercent);
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
              const SizedBox(height: 16),
              Expanded(
                child: settings.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(child: _buildVatCard(settings)),
              ),
              if (!settings.isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.forestGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text('Enregistrer', style: AppTextStyles.button),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVatCard(SettingsProvider settings) {
    final preview = _value ?? 0;
    const sample = 20.0;
    final vat = sample * preview / 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TVA', style: AppTextStyles.screenTitle),
          const SizedBox(height: 4),
          Text(
            'Taux appliqué au sous-total du panier de vos clients.',
            style: AppTextStyles.body.copyWith(color: AppColors.gray),
          ),
          const SizedBox(height: 4),
          Text(
            'Taux actuel : ${percent(settings.vatPercent)} %',
            style: AppTextStyles.chip.copyWith(
              color: AppColors.forestGreen,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final p in _presets)
                _pill('${percent(p)} %', !_custom && _selected == p, () {
                  setState(() {
                    _custom = false;
                    _selected = p;
                  });
                }),
              _pill('Autre', _custom, () => setState(() => _custom = true)),
            ],
          ),
          if (_custom) ...[
            const SizedBox(height: 14),
            const FieldLabel('Taux personnalisé (%)'),
            TextField(
              controller: _customCtrl,
              style: AppTextStyles.body,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              onChanged: (_) => setState(() {}),
              decoration: appInputDecoration(hint: 'Ex. 10').copyWith(
                suffixText: '%',
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Text(
            'Exemple : un sous-total de ${money(sample)} donne '
            '${money(vat)} de TVA, soit ${money(sample + vat)} au total.',
            style: AppTextStyles.chip.copyWith(color: AppColors.gray, fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.forestGreen : AppColors.chipBackground,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: AppTextStyles.toggle.copyWith(
            fontSize: 13.5,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}