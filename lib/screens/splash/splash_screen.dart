import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/menu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated arrows flying in from edges
              _ArrowsBackground(),
              const SizedBox(height: 32),

              // Logo
              _buildLogo(),

              const SizedBox(height: 16),

              // Tagline
              Text(
                'Slide. Clear. Conquer.',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              )
                  .animate(delay: 600.ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 60),

              // Loading dots
              _LoadingDots().animate(delay: 1200.ms).fadeIn(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Arrow icon cluster
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ArrowIcon(direction: '←', color: AppColors.arrowLeft, delay: 0),
            _ArrowIcon(direction: '↑', color: AppColors.arrowUp, delay: 100),
            _ArrowIcon(direction: '→', color: AppColors.arrowRight, delay: 200),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'ARROW OUT',
          style: GoogleFonts.nunito(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: 4,
            shadows: [
              Shadow(
                color: AppColors.primary.withValues(alpha: 0.8),
                blurRadius: 24,
              ),
            ],
          ),
        )
            .animate(delay: 300.ms)
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
      ],
    );
  }
}

class _ArrowIcon extends StatelessWidget {
  final String direction;
  final Color color;
  final int delay;

  const _ArrowIcon(
      {required this.direction, required this.color, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12)
        ],
      ),
      child: Center(
        child: Text(
          direction,
          style: TextStyle(fontSize: 26, color: color),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 400.ms)
        .scale(
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
            curve: Curves.elasticOut);
  }
}

class _ArrowsBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final phase = (_controller.value + i * 0.33) % 1.0;
            final scale =
                0.5 + 0.5 * (1 - (phase * 2 - 1).abs()).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8 * scale,
              height: 8 * scale,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.5 + 0.5 * scale),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
