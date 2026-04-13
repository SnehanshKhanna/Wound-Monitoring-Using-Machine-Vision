import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme.dart';
import '../models/wound_data.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedArcGauge extends StatefulWidget {
  final RiskLevel riskLevel;
  final double value; // 0.0 to 1.0

  const AnimatedArcGauge({
    super.key,
    required this.riskLevel,
    required this.value,
  });

  @override
  State<AnimatedArcGauge> createState() => _AnimatedArcGaugeState();
}

class _AnimatedArcGaugeState extends State<AnimatedArcGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedArcGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(begin: _animation.value, end: widget.value)
          .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 100),
          painter: _ArcGaugePainter(
            value: _animation.value,
            color: widget.riskLevel.color,
          ),
          child: SizedBox(
            width: 200,
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${(_animation.value * 100).toInt()}%',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ArcGaugePainter extends CustomPainter {
  final double value;
  final Color color;

  _ArcGaugePainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    // Background Arc
    final bgPaint = Paint()
      ..color = AppTheme.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );

    // Value Arc
    final valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        center: Alignment.bottomCenter,
        startAngle: math.pi,
        endAngle: math.pi * 2,
        colors: [color.withOpacity(0.5), color],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * value,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcGaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
