import 'package:flutter/material.dart';
import 'dart:math';

class CircularGauge extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final String unit;
  final double size;
  final Color startColor;
  final Color endColor;

  const CircularGauge({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.unit = '',
    this.size = 150,
    this.startColor = const Color(0xFF7C3AED),
    this.endColor = const Color(0xFFEC4899),
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(min, max);
    final pct = (clamped - min) / (max - min);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GaugePainter(pct, startColor, endColor),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                clamped.round().toString(),
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(unit, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double pct;
  final Color start;
  final Color end;

  _GaugePainter(this.pct, this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - 20) / 2;
    final bgPaint = Paint()
      ..color = const Color(0xFF1A0B1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -pi / 2,
      endAngle: -pi / 2 + 2 * pi * pct,
      colors: [start, end],
    );

    final fgPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweep = 2 * pi * pct;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, sweep, false, fgPaint);

    // withOpacity deprecated -> withAlpha kullanıldı
    final glowPaint = Paint()
      ..color = start.withAlpha((0.12 * 255).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, sweep, false, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.pct != pct || old.start != start || old.end != end;
}
