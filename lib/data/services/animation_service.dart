import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../shared/utils/logger.dart';

/// 애니메이션 효과 서비스
/// Duolingo 스타일의 시각적 피드백 제공
class AnimationService {
  // 싱글톤 패턴
  static final AnimationService _instance = AnimationService._internal();
  factory AnimationService() => _instance;
  AnimationService._internal();

  /// 축하 애니메이션 표시
  void showCelebration(BuildContext context, {VoidCallback? onComplete}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _CelebrationOverlay(
        onComplete: () {
          onComplete?.call();
        },
      ),
    );

    overlay.insert(overlayEntry);

    // 3초 후 자동 제거
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });

    Logger.debug('Celebration animation shown', tag: 'AnimationService');
  }

  /// Confetti 애니메이션 표시
  void showConfetti(BuildContext context, {VoidCallback? onComplete}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _ConfettiOverlay(
        onComplete: () {
          onComplete?.call();
        },
      ),
    );

    overlay.insert(overlayEntry);

    // 2.5초 후 자동 제거
    Future.delayed(const Duration(milliseconds: 2500), () {
      overlayEntry.remove();
    });

    Logger.debug('Confetti animation shown', tag: 'AnimationService');
  }

  /// XP 획득 애니메이션 표시
  void showXPGain(
    BuildContext context,
    int xpAmount, {
    Offset? startPosition,
    VoidCallback? onComplete,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _XPGainOverlay(
        xpAmount: xpAmount,
        startPosition: startPosition,
        onComplete: () {
          onComplete?.call();
        },
      ),
    );

    overlay.insert(overlayEntry);

    // 1.5초 후 자동 제거
    Future.delayed(const Duration(milliseconds: 1500), () {
      overlayEntry.remove();
    });

    Logger.debug('XP gain animation shown: +$xpAmount XP',
        tag: 'AnimationService');
  }

  /// 하트 깨짐 애니메이션 표시
  void showHeartBreak(BuildContext context, {VoidCallback? onComplete}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _HeartBreakOverlay(
        onComplete: () {
          onComplete?.call();
        },
      ),
    );

    overlay.insert(overlayEntry);

    // 1초 후 자동 제거
    Future.delayed(const Duration(seconds: 1), () {
      overlayEntry.remove();
    });

    Logger.debug('Heart break animation shown', tag: 'AnimationService');
  }

  /// 스타 버스트 애니메이션 (작은 성취감용)
  void showStarBurst(BuildContext context,
      {Offset? position, VoidCallback? onComplete}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _StarBurstOverlay(
        position: position,
        onComplete: () {
          onComplete?.call();
        },
      ),
    );

    overlay.insert(overlayEntry);

    // 1초 후 자동 제거
    Future.delayed(const Duration(seconds: 1), () {
      overlayEntry.remove();
    });

    Logger.debug('Star burst animation shown', tag: 'AnimationService');
  }
}

/// Celebration 오버레이
class _CelebrationOverlay extends StatefulWidget {
  final VoidCallback? onComplete;

  const _CelebrationOverlay({this.onComplete});

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _controller.forward().then((_) => widget.onComplete?.call());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Lottie.asset(
          'assets/lottie/confetti.json',
          controller: _controller,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.cover,
          // 파일이 없으면 대체 위젯 표시
          errorBuilder: (context, error, stackTrace) {
            return Container(); // 에러 시 빈 컨테이너
          },
        ),
      ),
    );
  }
}

/// Confetti 오버레이
class _ConfettiOverlay extends StatefulWidget {
  final VoidCallback? onComplete;

  const _ConfettiOverlay({this.onComplete});

  @override
  State<_ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<_ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _controller.forward().then((_) => widget.onComplete?.call());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Lottie.asset(
          'assets/lottie/confetti.json',
          controller: _controller,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.8,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container();
          },
        ),
      ),
    );
  }
}

/// XP 획득 오버레이
class _XPGainOverlay extends StatefulWidget {
  final int xpAmount;
  final Offset? startPosition;
  final VoidCallback? onComplete;

  const _XPGainOverlay({
    required this.xpAmount,
    this.startPosition,
    this.onComplete,
  });

  @override
  State<_XPGainOverlay> createState() => _XPGainOverlayState();
}

class _XPGainOverlayState extends State<_XPGainOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition ?? const Offset(0, 0),
      end: const Offset(0, -100),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0),
    ));

    _controller.forward().then((_) => widget.onComplete?.call());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: _positionAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '+${widget.xpAmount} XP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 하트 깨짐 오버레이
class _HeartBreakOverlay extends StatefulWidget {
  final VoidCallback? onComplete;

  const _HeartBreakOverlay({this.onComplete});

  @override
  State<_HeartBreakOverlay> createState() => _HeartBreakOverlayState();
}

class _HeartBreakOverlayState extends State<_HeartBreakOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.forward().then((_) => widget.onComplete?.call());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Lottie.asset(
          'assets/lottie/heart_break.json',
          controller: _controller,
          width: 150,
          height: 150,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // 애니메이션 파일이 없으면 간단한 대체 애니메이션
            return ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 0.0).animate(_controller),
              child: const Icon(
                Icons.favorite_border,
                color: Colors.red,
                size: 100,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 스타 버스트 오버레이
class _StarBurstOverlay extends StatefulWidget {
  final Offset? position;
  final VoidCallback? onComplete;

  const _StarBurstOverlay({this.position, this.onComplete});

  @override
  State<_StarBurstOverlay> createState() => _StarBurstOverlayState();
}

class _StarBurstOverlayState extends State<_StarBurstOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.forward().then((_) => widget.onComplete?.call());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: widget.position != null
            ? Alignment(
                widget.position!.dx / MediaQuery.of(context).size.width * 2 -
                    1,
                widget.position!.dy / MediaQuery.of(context).size.height * 2 -
                    1,
              )
            : Alignment.center,
        child: Lottie.asset(
          'assets/lottie/star_burst.json',
          controller: _controller,
          width: 100,
          height: 100,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return ScaleTransition(
              scale: Tween<double>(begin: 0.0, end: 1.5).animate(_controller),
              child: const Icon(
                Icons.star,
                color: Colors.amber,
                size: 50,
              ),
            );
          },
        ),
      ),
    );
  }
}
