import 'package:flutter/material.dart';

class WaveformStrip extends StatelessWidget {
  const WaveformStrip({
    super.key,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 74,
      width: double.infinity,
      child: CustomPaint(
        painter: _WaveformPainter(
          progress: progress,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  @override
  void paint(Canvas canvas, Size size) {
    const bars = 54;
    final barWidth = size.width / (bars * 1.8);
    final gap = barWidth * .8;
    final center = size.height / 2;
    final activeLimit = bars * progress.clamp(0.0, 1.0);

    for (var i = 0; i < bars; i++) {
      final phase = i / bars;
      final shaped =
          .28 +
          (.42 * (1 + _sin(phase * 6.28 * 3)) / 2) +
          (.3 * (1 + _sin(phase * 6.28 * 9)) / 2);
      final height = (size.height * shaped).clamp(12.0, size.height);
      final left = i * (barWidth + gap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, center - height / 2, barWidth, height),
        Radius.circular(barWidth),
      );
      final paint = Paint()
        ..color = i <= activeLimit ? activeColor : inactiveColor;
      canvas.drawRRect(rect, paint);
    }
  }

  double _sin(double value) {
    return Sinusoid.value(value);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}

class Sinusoid {
  const Sinusoid._();

  static double value(double x) {
    const pi = 3.1415926535897932;
    x = x % (2 * pi);

    if (x > pi) {
      x -= 2 * pi;
    }

    final x2 = x * x;
    return x * (1 - x2 / 6 + x2 * x2 / 120);
  }
}
