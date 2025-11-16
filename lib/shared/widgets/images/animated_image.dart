import 'package:flutter/material.dart';
import '../../constants/app_animations.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../loading/loading_indicators.dart';

/// 애니메이션이 적용된 이미지 로더
class AnimatedImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration fadeInDuration;

  const AnimatedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedImage> createState() => _AnimatedImageState();
}

class _AnimatedImageState extends State<AnimatedImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _hasError = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.fadeInDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 플레이스홀더
            if (!_isLoaded && !_hasError)
              widget.placeholder ??
                  SkeletonLoading(
                    width: widget.width ?? double.infinity,
                    height: widget.height ?? 200,
                    borderRadius: widget.borderRadius != null
                        ? (widget.borderRadius!.topLeft.x)
                        : 0,
                  ),

            // 실제 이미지
            Image.network(
              widget.imageUrl,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) {
                  _isLoaded = true;
                  return child;
                }

                if (frame != null && !_isLoaded) {
                  _isLoaded = true;
                  _controller.forward();
                }

                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: child,
                );
              },
              errorBuilder: (context, error, stackTrace) {
                _hasError = true;
                return widget.errorWidget ??
                    Container(
                      color: AppColors.borderLight,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: AppColors.textTertiary,
                          size: 48,
                        ),
                      ),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 원형 애니메이션 이미지 (프로필 사진용)
class CircularAnimatedImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final Color? borderColor;
  final double borderWidth;

  const CircularAnimatedImage({
    super.key,
    required this.imageUrl,
    this.size = 80,
    this.borderColor,
    this.borderWidth = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? AppColors.mathGreen,
                width: borderWidth,
              )
            : null,
      ),
      child: ClipOval(
        child: AnimatedImage(
          imageUrl: imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: Container(
            color: AppColors.borderLight,
            child: const Icon(
              Icons.person,
              color: AppColors.textTertiary,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}

/// 로컬 애셋 이미지 (페이드 인 애니메이션)
class AnimatedAssetImage extends StatefulWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Duration fadeInDuration;

  const AnimatedAssetImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.fadeInDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedAssetImage> createState() => _AnimatedAssetImageState();
}

class _AnimatedAssetImageState extends State<AnimatedAssetImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.fadeInDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.spring,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Image.asset(
          widget.assetPath,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
        ),
      ),
    );
  }
}

/// 배지/뱃지 이미지 (잠김/활성 애니메이션)
class BadgeImage extends StatefulWidget {
  final String imageUrl;
  final bool isUnlocked;
  final double size;
  final VoidCallback? onTap;

  const BadgeImage({
    super.key,
    required this.imageUrl,
    this.isUnlocked = false,
    this.size = 80,
    this.onTap,
  });

  @override
  State<BadgeImage> createState() => _BadgeImageState();
}

class _BadgeImageState extends State<BadgeImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.elastic,
      ),
    );

    _rotateAnimation = Tween<double>(
      begin: -0.2,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    if (widget.isUnlocked) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(BadgeImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isUnlocked && !oldWidget.isUnlocked) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isUnlocked ? _scaleAnimation.value : 1.0,
            child: Transform.rotate(
              angle: widget.isUnlocked ? _rotateAnimation.value : 0.0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 배지 이미지
                  AnimatedImage(
                    imageUrl: widget.imageUrl,
                    width: widget.size,
                    height: widget.size,
                    fit: BoxFit.contain,
                  ),

                  // 잠김 오버레이
                  if (!widget.isUnlocked)
                    Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),

                  // 언락 반짝임 효과
                  if (widget.isUnlocked && _controller.isAnimating)
                    Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.mathGold.withValues(
                            alpha: 1.0 - _controller.value,
                          ),
                          width: 3,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 이미지 갤러리 (스와이프 애니메이션)
class ImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final BorderRadius? borderRadius;

  const ImageGallery({
    super.key,
    required this.imageUrls,
    this.height = 250,
    this.borderRadius,
  });

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppDimensions.paddingS),
                child: AnimatedImage(
                  imageUrl: widget.imageUrls[index],
                  height: widget.height,
                  borderRadius: widget.borderRadius ??
                      BorderRadius.circular(AppDimensions.radiusL),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        // 페이지 인디케이터
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.imageUrls.length,
            (index) => AnimatedContainer(
              duration: AppAnimations.fast,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentPage == index
                    ? AppColors.mathGreen
                    : AppColors.borderLight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
