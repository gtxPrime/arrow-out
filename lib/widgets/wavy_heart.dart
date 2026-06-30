import 'package:flutter/material.dart';
import 'dart:math';

/// A custom widget that displays a heart filled with an animating pinkish-red liquid.
/// Used to represent lives in the game's top bar.
class WavyHeart extends StatefulWidget {
  final bool isFull;
  final double size;

  const WavyHeart({super.key, required this.isFull, this.size = 24});

  @override
  State<WavyHeart> createState() => _WavyHeartState();
}

class _WavyHeartState extends State<WavyHeart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isFull) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(WavyHeart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFull && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isFull && _controller.isAnimating) {
      _controller.stop();
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
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _HeartLiquidPainter(
            animationValue: _controller.value,
            isFull: widget.isFull,
          ),
        );
      },
    );
  }
}

class _HeartLiquidPainter extends CustomPainter {
  final double animationValue;
  final bool isFull;

  _HeartLiquidPainter({
    required this.animationValue,
    required this.isFull,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Heart Path coordinates scaled to fitting container size
    final heartPath = Path();
    heartPath.moveTo(width / 2, height * 0.27);
    heartPath.cubicTo(
        width * 0.15, height * -0.05,
        -width * 0.05, height * 0.42,
        width / 2, height * 0.95
    );
    heartPath.cubicTo(
        width * 1.05, height * 0.42,
        width * 0.85, height * -0.05,
        width / 2, height * 0.27
    );
    heartPath.close();

    // Draw background filling (soft pink if full, dark grey if empty)
    final outlinePaint = Paint()
      ..color = isFull ? const Color(0xFFFF2D55).withValues(alpha: 0.12) : Colors.white10
      ..style = PaintingStyle.fill;
    canvas.drawPath(heartPath, outlinePaint);

    // Draw the borders
    final borderPaint = Paint()
      ..color = isFull ? const Color(0xFFFF2D55).withValues(alpha: 0.6) : Colors.white30
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawPath(heartPath, borderPaint);

    if (isFull) {
      canvas.save();
      // Clip to heart shape
      canvas.clipPath(heartPath);

      // Draw liquid gradient
      final liquidPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFF527B), // Vibrant light pinkish-red
            Color(0xFFE91E63), // Deep rose pinkish-red
            Color(0xFFC2185B), // Shadow pinkish-red
          ],
        ).createShader(Rect.fromLTWH(0, 0, width, height));

      // Build wave path
      final wavePath = Path();
      // Liquid level (filled to 82% height of the container)
      final fillLevel = height * 0.22; 
      final waveHeight = height * 0.06;

      wavePath.moveTo(0, fillLevel);
      for (double x = 0; x <= width; x++) {
        // Sine wave offset by animationValue
        final y = fillLevel + sin((x / width * 2 * pi) + (animationValue * 2 * pi)) * waveHeight;
        wavePath.lineTo(x, y);
      }
      wavePath.lineTo(width, height);
      wavePath.lineTo(0, height);
      wavePath.close();

      canvas.drawPath(wavePath, liquidPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _HeartLiquidPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.isFull != isFull;
  }
}
