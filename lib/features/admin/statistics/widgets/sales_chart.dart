import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SalesChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final double height;

  const SalesChart({
    super.key,
    required this.values,
    required this.labels,
    this.height = 190,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(painter: _ChartPainter(values, labels)),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;

  _ChartPainter(this.values, this.labels);

  /// Valeur maximale « ronde » divisible en 4 graduations.
  static double _niceMax(double m) {
    if (m <= 0) return 100;
    final raw = m / 4;
    final mag = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    final f = raw / mag;
    final step = (f <= 1 ? 1 : f <= 2 ? 2 : f <= 5 ? 5 : 10) * mag;
    return step * 4;
  }

  void _text(Canvas canvas, String s, Offset o, {int align = 0}) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: AppTextStyles.chip.copyWith(color: AppColors.gray, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    // align : -1 = à droite du point, 0 = centré
    final dx = align < 0 ? o.dx - tp.width : o.dx - tp.width / 2;
    tp.paint(canvas, Offset(dx, o.dy - tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    const left = 40.0, right = 10.0, top = 8.0, bottom = 24.0;
    final w = size.width - left - right;
    final h = size.height - top - bottom;
    final n = values.length;
    if (n == 0 || w <= 0 || h <= 0) return;

    final maxValue = values.fold<double>(0, (a, b) => math.max(a, b));
    final niceMax = _niceMax(maxValue);

    // Grille et graduations verticales.
    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = top + h * (1 - i / 4);
      canvas.drawLine(Offset(left, y), Offset(left + w, y), grid);
      _text(canvas, (niceMax * i / 4).round().toString(), Offset(left - 8, y),
          align: -1);
    }

    double x(int i) => n == 1 ? left + w / 2 : left + w * i / (n - 1);
    double y(double v) => top + h * (1 - v / niceMax);

    // Courbe et zone dégradée.
    final line = Path()..moveTo(x(0), y(values[0]));
    for (var i = 1; i < n; i++) {
      line.lineTo(x(i), y(values[i]));
    }

    final area = Path.from(line)
      ..lineTo(x(n - 1), top + h)
      ..lineTo(x(0), top + h)
      ..close();

    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.forestGreen.withValues(alpha: 0.28),
            AppColors.forestGreen.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(left, top, w, h)),
    );

    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.forestGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // Points (seulement quand il y en a peu).
    if (n <= 8) {
      for (var i = 0; i < n; i++) {
        canvas.drawCircle(Offset(x(i), y(values[i])), 3.6,
            Paint()..color = Colors.white);
        canvas.drawCircle(
          Offset(x(i), y(values[i])),
          3.6,
          Paint()
            ..color = AppColors.forestGreen
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8,
        );
      }
    }

    // Étiquettes horizontales (espacées si la période est longue).
    final step = (n / 7).ceil().clamp(1, 100);
    for (var i = 0; i < n; i += step) {
      _text(canvas, labels[i], Offset(x(i), top + h + 13));
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.values != values || old.labels != labels;
}