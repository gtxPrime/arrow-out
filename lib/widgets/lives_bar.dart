import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_colors.dart';

class LivesBar extends StatelessWidget {
  final int lives;
  final int maxLives;

  const LivesBar({super.key, required this.lives, required this.maxLives});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLives, (i) {
        final isFull = i < lives;

        final heartWidget = Stack(
          alignment: Alignment.center,
          children: [
            // Soft drop shadow for 3D depth
            if (isFull)
              Icon(
                Icons.favorite,
                color: Colors.black.withValues(alpha: 0.15),
                size: 27,
              ),
            // Heart body
            isFull
                ? ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF829079), Color(0xFF5E6B56)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 25,
                    ),
                  )
                : const Icon(
                    Icons.favorite_border,
                    color: AppColors.surfaceLight,
                    size: 24,
                  ),
            // Glass/glossy reflection dot on top-left of active heart
            if (isFull)
              Positioned(
                top: 5,
                left: 5,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: isFull
                ? heartWidget
                    .animate(
                      key: ValueKey('heart_${i}_full'),
                      onPlay: (c) => c.repeat(reverse: true),
                    )
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.05, 1.05),
                      duration: 1800.ms,
                      curve: Curves.easeInOut,
                    )
                : SizedBox(
                    key: ValueKey('heart_${i}_empty'),
                    child: heartWidget,
                  ),
          ),
        );
      }),
    );
  }
}
