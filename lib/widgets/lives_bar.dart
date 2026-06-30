import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
        final heartIcon = Icon(
          Icons.favorite,
          key: ValueKey('heart_${i}_$isFull'),
          color: isFull ? const Color(0xFFFF2D55) : const Color(0xFFDDD5C3),
          size: 25, // Little bigger (was 20)
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: isFull
                ? heartIcon
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.07, 1.07), // Very subtle, non-distracting beat
                      duration: 1200.ms,
                      curve: Curves.easeInOut,
                    )
                : heartIcon,
          ),
        );
      }),
    );
  }
}
