import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Anneau de statuts avec le total au centre.
class StatusDonut extends StatelessWidget {
  final List<double> values;
  final List<Color> colors;
  final double size;

  const StatusDonut({
    super.key,
    required this.values,
    required this.colors,
    this.size = 124,
  });

  @override
  Widget build(BuildContext context) {
    final total = values.fold<double>(0, (a, b) => a + b);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutPainter(values: values, colors: colors),
          ),
          Text(
            total.round().toString(),
            style: AppTextStyles.screenTitle.copyWith(fontSize: 24),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _DonutPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 22.0;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    final total = values.fold<double>(0, (a, b) => a + b);

    // Anneau gris quand il n'y a aucune commande.
    if (total == 0) {
      paint.color = AppColors.border;
      canvas.drawArc(rect, 0, math.pi * 2, false, paint);
      return;
    }

    final visible = values.where((v) => v > 0).length;
    final gap = visible > 1 ? 0.05 : 0.0;
    var start = -math.pi / 2;

    for (var i = 0; i < values.length; i++) {
      if (values[i] <= 0) continue;
      final sweep = values[i] / total * math.pi * 2;
      paint.color = colors[i];
      canvas.drawArc(rect, start + gap / 2, sweep - gap, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.values != values || old.colors != colors;
}