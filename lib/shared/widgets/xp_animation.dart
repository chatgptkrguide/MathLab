import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';

/// XP 획득 애니메이션 위젯
/// 듀오링고 스타일의 화려한 XP 획득 효과
class XPAnimation extends StatefulWidget {
  final int xpAmount;
  final VoidCallback? onCompleted;
  final Duration duration;

  const XPAnimation({
    Key? key,
    required this.xpAmount,
    this.onCompleted,
    this.duration = const Duration(milliseconds: 2000),
  }) : super(key: key);

  @override
  State<XPAnimation> createState() => _XPAnimationState();
}

class _XPAnimationState extends State<XPAnimation>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 스케일 애니메이션 (튀어나오는 효과)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.elasticOut,
    ));

    // 페이드 애니메이션
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 20,
      ),
    ]).animate(_mainController);

    // 슬라이드 애니메이션 (위로 올라가는 효과)
    _slideAnimation = Tween<double>(begin: 0.0, end: -50.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // 애니메이션 시작
    _mainController.forward().then((_) {
      widget.onCompleted?.call();
    });

    _particleController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 메인 XP 표시
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                      vertical: AppDimensions.paddingM,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFE082),
                          Color(0xFFFFD900),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.duolingoYellow.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '⚡',
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: AppDimensions.spacingS),
                        Text(
                          '+${widget.xpAmount} XP',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 파티클 효과
                  ...List.generate(6, (index) {
                    return _buildParticle(index);
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticle(int index) {
    final angle = (index * 60.0) * (math.pi / 180); // 60도씩 분산
    final radius = 40.0 + (index * 10.0); // 반지름 조절

    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final progress = _particleController.value;
        final x = math.cos(angle) * radius * progress;
        final y = math.sin(angle) * radius * progress;
        final opacity = (1.0 - progress).clamp(0.0, 1.0);

        return Positioned(
          left: 50 + x,
          top: 20 + y,
          child: Opacity(
            opacity: opacity,
            child: Transform.rotate(
              angle: progress * math.pi * 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.duolingoYellow,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.duolingoYellow.withOpacity(0.6),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 레벨업 축하 애니메이션
class LevelUpAnimation extends StatefulWidget {
  final int newLevel;
  final VoidCallback? onCompleted;

  const LevelUpAnimation({
    Key? key,
    required this.newLevel,
    this.onCompleted,
  }) : super(key: key);

  @override
  State<LevelUpAnimation> createState() => _LevelUpAnimationState();
}

class _LevelUpAnimationState extends State<LevelUpAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.3),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: math.pi * 2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8),
    ));

    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(begin: AppColors.duolingoYellow, end: AppColors.duolingoOrange),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: AppColors.duolingoOrange, end: AppColors.duolingoPurple),
        weight: 50,
      ),
    ]).animate(_controller);

    _controller.forward().then((_) {
      widget.onCompleted?.call();
    });
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingXL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _colorAnimation.value ?? AppColors.duolingoYellow,
                    (_colorAnimation.value ?? AppColors.duolingoYellow).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
                boxShadow: [
                  BoxShadow(
                    color: (_colorAnimation.value ?? AppColors.duolingoYellow).withOpacity(0.5),
                    blurRadius: 24,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🎉',
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  Text(
                    '레벨 업!',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '레벨 ${widget.newLevel}',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}