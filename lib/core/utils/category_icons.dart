import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/app_colors.dart';

/// Associe une clé (stockée dans Firestore) à une icône et des couleurs.
class CategoryIcons {
  CategoryIcons._();

  // Kept for backward compatibility (fallback if a key has no SVG)
  static const Map<String, FaIconData> icons = {
    'coffee': FontAwesomeIcons.mugSaucer,
    'drink': FontAwesomeIcons.glassWater,
    'fastfood': FontAwesomeIcons.burger,
    'dish': FontAwesomeIcons.utensils,
    'dessert': FontAwesomeIcons.cakeCandles,
    'bakery': FontAwesomeIcons.breadSlice,
    'icecream': FontAwesomeIcons.iceCream,
    'lunch': FontAwesomeIcons.bowlFood,
    'salad': FontAwesomeIcons.bowlFood,
    'pizza': FontAwesomeIcons.pizzaSlice,
    'bar': FontAwesomeIcons.martiniGlass,
  };

  static FaIconData byKey(String key) =>
      icons[key] ?? FontAwesomeIcons.utensils;

  // ───────────────────────── Colors ─────────────────────────

  static const Map<String, Color> _pastels = {
    'coffee': Color(0xFFD8D9A3),
    'drink': Color(0xFFF2C4C4),
    'fastfood': Color(0xFFF6C46E),
    'dish': Color(0xFFD9BED3),
    'dessert': Color(0xFFF2B5B2),
    'bakery': Color(0xFFEBCB9B),
    'icecream': Color(0xFFBFDDEB),
    'lunch': Color(0xFFC9DDB0),
    'salad': Color(0xFFC9DDB0),
    'pizza': Color(0xFFF3B98F),
    'bar': Color(0xFFC9C3E6),
  };

  static const Color _defaultPastel = Color(0xFFE6D5C3);

  // Même vert que le bouton "Catégories" actif.
  static const Color _greenLight = AppColors.forestGreen;
  static const Color _greenDark = Color(0xFF9DBA92);
  static const Color _accentLight = AppColors.forestGreen;
  static const Color _accentDark = Color(0xFF9DBA92);

  /// Couleur de fond et couleur de l'icône pour une clé donnée.
  static ({Color bg, Color fg}) styleOf(String key) {
    final base = _pastels[key] ?? _defaultPastel;
    final dark = AppColors.isDarkMode;
    return (
      bg: dark ? base.withValues(alpha: 0.28) : base,
      fg: dark ? _greenDark : _greenLight,
    );
  }

  // ───────────────────────── SVG line icons ─────────────────────────
  // {main} = line color, {accent} = lighter green fill for details

  static String _svg(String body) =>
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" '
      'fill="none" stroke="{main}" stroke-width="3" '
      'stroke-linecap="round" stroke-linejoin="round">$body</svg>';

  static final Map<String, String> _svgs = {
    'coffee': _svg('''
      <path d="M25 9c-3 3 2 5-1 9M34 9c-3 3 2 5-1 9"/>
      <path d="M13 27h31v9a15 15 0 0 1-15 15h-1a15 15 0 0 1-15-15z" fill="{accent}"/>
      <path d="M44 30h3a6 6 0 0 1 0 12h-5"/>
      <path d="M9 56h40"/>'''),
    'drink': _svg('''
      <path d="M37 18l4-11h9"/>
      <path d="M17 18h30"/>
      <path d="M20 18h24l-3 35a3 3 0 0 1-3 3H26a3 3 0 0 1-3-3z"/>
      <path d="M22 30h20l-1.6 21H23.6z" fill="{accent}"/>'''),
    'fastfood': _svg('''
      <path d="M11 29c0-10 9-17 21-17s21 7 21 17z"/>
      <path d="M23 20h.01M32 17h.01M41 20h.01"/>
      <rect x="9" y="34" width="46" height="7" rx="3.5" fill="{accent}"/>
      <path d="M11 45h42v1a8 8 0 0 1-8 8H19a8 8 0 0 1-8-8z"/>'''),
    'dish': _svg('''
      <circle cx="33" cy="32" r="14"/>
      <circle cx="33" cy="32" r="8" fill="{accent}"/>
      <path d="M8 12v11a4.5 4.5 0 0 0 9 0V12M12.5 12v40"/>
      <path d="M56 12c-5 3-6 10-6 18h6zM56 30v22"/>'''),
    'dessert': _svg(
      '''
      <path d="M32 24v-8"/>
      <path d="M32 8c-2.5 2.5-2.5 5 0 6.5 2.5-1.5 2.5-4 0-6.5z" fill="{accent}"/>
      <path d="M12 34a8 8 0 0 1 8-8h24a8 8 0 0 1 8 8v16a4 4 0 0 1-4 4H16a4 4 0 0 1-4-4z"/>
      <path d="M12.5 41h39v6h-39z" fill="{accent}"/>
      <path d="M12 34c4 4 8 4 10 0 3 4 7 4 10 0 3 4 7 4 10 0 2 3 6 4 10 0"/>''',
    ),
    'bakery': _svg('''
      <path d="M17 26a10 10 0 0 1 3-18h24a10 10 0 0 1 3 18v25a4 4 0 0 1-4 4H21a4 4 0 0 1-4-4z" fill="{accent}"/>
      <path d="M25 26v17M39 26v17"/>'''),
    'icecream': _svg('''
      <path d="M21 32l11 24 11-24"/>
      <path d="M26 40l8 4M30 49l5 2"/>
      <path d="M19 32a13 13 0 1 1 26 0z" fill="{accent}"/>
      <circle cx="32" cy="9" r="3" fill="{main}"/>'''),
    'lunch': _svg('''
      <path d="M9 30h46c0 13-10 23-23 23S9 43 9 30z" fill="{accent}"/>
      <path d="M22 30c0-7 4-11 8-11M36 30c0-6 3-9 7-10"/>
      <path d="M26 58h12"/>'''),
    'salad': _svg('''
      <path d="M10 32c8-3 14-1 18-7 4-6 10-7 15-4 5 2 8 7 11 11"/>
      <path d="M15 24c-5-6-1-12 6-10 2-7 10-8 14-3 5-6 12-4 14 3"/>
      <path d="M34 14c-1 7-5 11-11 14"/>
      <circle cx="24" cy="29" r="7"/>
      <path d="M21 28c2-2 5-1 6 1M20 32c3 2 6 2 9 0"/>
      <path d="M8 32h48c-1 12-9 20-20 23H28C17 52 9 44 8 32z" fill="{accent}"/>
      <path d="M18 55v2c0 3 3 5 6 5h16c3 0 6-2 6-5v-2"/>
      <path d="M24 40h16"/>'''),
    'pizza': _svg('''
      <path d="M8 18c15-7 33-7 48 0L32 57z"/>
      <path d="M10 25c14-5 30-5 44 0"/>
      <circle cx="27" cy="31" r="3.5" fill="{accent}"/>
      <circle cx="38" cy="33" r="3.5" fill="{accent}"/>
      <circle cx="32" cy="43" r="3.5" fill="{accent}"/>'''),
    'bar': _svg('''
      <path d="M10 12h44L32 36z"/>
      <path d="M32 36v18M22 54h20"/>
      <circle cx="38" cy="20" r="3.5" fill="{accent}"/>'''),
  };

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  static Widget iconWidget(String key, {required double size, Color? color}) {
    final svg = _svgs[key];
    if (svg == null) {
      return FaIcon(byKey(key), size: size, color: color);
    }
    final dark = AppColors.isDarkMode;
    final main = color ?? (dark ? _greenDark : _greenLight);
    final accent = dark ? _accentDark : _accentLight;

    return SvgPicture.string(
      svg.replaceAll('{main}', _hex(main)).replaceAll('{accent}', _hex(accent)),
      width: size,
      height: size,
    );
  }

  /// Pastille ronde : dégradé doux + ombre légère + icône verte.
  static Widget badge(String key, {double size = 64, double? iconSize}) {
    final s = styleOf(key);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 1.0,
          colors: [
            Color.lerp(s.bg, Colors.white, 0.35)!,
            s.bg,
            Color.lerp(s.bg, Colors.black, 0.06)!,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: s.bg.withValues(alpha: 0.45),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: iconWidget(key, size: iconSize ?? size * 0.55, color: s.fg),
    );
  }
}
