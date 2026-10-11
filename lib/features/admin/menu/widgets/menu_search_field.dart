import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class MenuSearchField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String hint;

  const MenuSearchField({
    super.key,
    required this.onChanged,
    this.hint = 'Rechercher un produit',
  });

  @override
  State<MenuSearchField> createState() => _MenuSearchFieldState();
}

class _MenuSearchFieldState extends State<MenuSearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: AppTextStyles.body,
      cursorColor: AppColors.forestGreen,
      onChanged: (value) {
        setState(() {}); // refresh the clear button
        widget.onChanged(value);
      },
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTextStyles.hint,
        prefixIcon:
            const Icon(Icons.search_rounded, color: AppColors.gray, size: 22),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.gray, size: 20),
                onPressed: () {
                  _controller.clear();
                  setState(() {});
                  widget.onChanged('');
                },
              ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.forestGreen, width: 1.4),
        ),
      ),
    );
  }
}