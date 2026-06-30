import 'package:flutter/material.dart';
import 'wavy_heart.dart';

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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: WavyHeart(
              key: ValueKey('heart_${i}_$isFull'),
              isFull: isFull,
              size: 26,
            ),
          ),
        );
      }),
    );
  }
}
