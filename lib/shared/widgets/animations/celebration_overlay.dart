import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Full-screen celebration overlay with Lottie animation support.
///
/// Attempts to load a Lottie animation from [assets/animations/].
/// Falls back to a built-in particle burst when no animation file exists.
///
/// Usage:
/// ```dart
/// CelebrationOverlay.show(context, type: CelebrationType.levelUp);
/// ```
enum CelebrationType {
  levelUp,
  streak,
  achievement,
  perfect,
}

class CelebrationOverlay extends StatefulWidget {
  final CelebrationType type;
  final VoidCallback? onComplete;

  const CelebrationOverlay({
    super.key,
    required this.type,
    this.onComplete,
  });

  static Future<void> show(
    BuildContext context, {
    required CelebrationType type,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (ctx) => CelebrationOverlay(
        type: type,
        onComplete: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _lottieAvailable = false;

  String get _assetPath {
    switch (widget.type) {
      case CelebrationType.levelUp:
        return 'assets/animations/level_up.json';
      case CelebrationType.streak:
        return 'assets/animations/streak.json';
      case CelebrationType.achievement:
        return 'assets/animations/achievement.json';
      case CelebrationType.perfect:
        return 'assets/animations/perfect.json';
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
          ),
        ),
        child: _lottieAvailable
            ? _buildLottie()
            : _buildFallbackParticles(),
      ),
    );
  }

  Widget _buildLottie() {
    return Center(
      child: Lottie.asset(
        _assetPath,
        controller: _controller,
        width: 300,
        height: 300,
        errorBuilder: (context, error, stackTrace) {
          // Lottie file not found — use fallback
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _lottieAvailable = false);
          });
          return _buildFallbackParticles();
        },
        onLoaded: (composition) {
          setState(() => _lottieAvailable = true);
          _controller.duration = composition.duration;
          _controller.forward(from: 0);
        },
      ),
    );
  }

  Widget _buildFallbackParticles() {
    return SizedBox.expand(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ParticleBurstPainter(
              progress: _controller.value,
              type: widget.type,
            ),
          );
        },
      ),
    );
  }
}

/// Animated particle burst fallback (when no Lottie file is available).
class _ParticleBurstPainter extends CustomPainter {
  final double progress;
  final CelebrationType type;

  _ParticleBurstPainter({
    required this.progress,
    required this.type,
  });

  List<Color> get _colors {
    switch (type) {
      case CelebrationType.levelUp:
        return [
          const Color(0xFF58CC02),
          const Color(0xFF1CB0F6),
          const Color(0xFFFFD700),
        ];
      case CelebrationType.streak:
        return [
          const Color(0xFFFF9600),
          const Color(0xFFFF4B4B),
          const Color(0xFFFFD700),
        ];
      case CelebrationType.achievement:
        return [
          const Color(0xFFCE82FF),
          const Color(0xFF1CB0F6),
          const Color(0xFFFFD700),
        ];
      case CelebrationType.perfect:
        return [
          const Color(0xFFFFD700),
          const Color(0xFF58CC02),
          const Color(0xFFFF9600),
        ];
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.6;
    final particleCount = 24;
    final paint = Paint();

    for (var i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 3.14159 * 2;
      final speed = 0.6 + (i % 3) * 0.2;
      final radius = maxRadius * progress * speed;
      final particleSize = 6.0 * (1 - progress * 0.7);

      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle) - (progress * 60);

      final colorIndex = i % _colors.length;
      paint.color = _colors[colorIndex].withValues(alpha: 1.0 - progress);

      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleBurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
