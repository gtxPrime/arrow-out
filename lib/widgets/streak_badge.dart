import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/constants.dart';

class StreakBadge extends StatelessWidget {
  final int days;

  const StreakBadge({super.key, required this.days});

  Color get _color {
    if (days >= AppConstants.streakMilestone3) return AppColors.accent;
    if (days >= AppConstants.streakMilestone2) return AppColors.accentOrange;
    if (days >= AppConstants.streakMilestone1) return AppColors.accentGold;
    return AppColors.textSecondary;
  }

  String get _emoji {
    if (days >= AppConstants.streakMilestone2) return '🔥';
    if (days >= AppConstants.streakMilestone1) return '🔥';
    return '📅';
  }

  @override
  Widget build(BuildContext context) {
    if (days == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.35)),
        boxShadow: days >= AppConstants.streakMilestone1
            ? [
                BoxShadow(
                    color: _color.withValues(alpha: 0.25), blurRadius: 10),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_emoji, style: const TextStyle(fontSize: 16))
              .animate(onPlay: (c) => c.repeat())
              .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.1, 1.1),
                  duration: 800.ms,
                  curve: Curves.easeInOut)
              .then()
              .scale(
                  begin: const Offset(1.1, 1.1),
                  end: const Offset(0.9, 0.9),
                  duration: 800.ms),
          const SizedBox(width: 6),
          Text('$days',
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _color,
              )),
          const SizedBox(width: 2),
          Text('days',
              style: GoogleFonts.nunito(
                fontSize: 11,
                color: _color.withValues(alpha: 0.7),
              )),
        ],
      ),
    );
  }
}
