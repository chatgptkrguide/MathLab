import 'package:flutter/material.dart';

/// 부드러운 페이지 전환 애니메이션들
/// 듀오링고 스타일의 매끄러운 전환 효과
class AppPageTransitions {
  AppPageTransitions._(); // private constructor

  /// 슬라이드 + 페이드 전환 (메인)
  static Route<T> slideAndFade<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutCubic,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 슬라이드 애니메이션
        final slideAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        // 페이드 애니메이션
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.7),
        ));

        // 스케일 애니메이션 (살짝 축소에서 시작)
        final scaleAnimation = Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// 스케일 + 페이드 전환 (모달)
  static Route<T> scaleAndFade<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      opaque: false, // 배경 투명
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(animation);

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// 바운스 전환 (성공, 완료 화면)
  static Route<T> bounceIn<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final bounceAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.5),
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: bounceAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// 회전 + 페이드 전환 (특별한 경우)
  static Route<T> rotateAndFade<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final rotationAnimation = Tween<double>(
          begin: 0.25, // 90도 회전에서 시작
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(animation);

        final scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(animation);

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: RotationTransition(
              turns: rotationAnimation,
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// 슬라이드 업 전환 (하단에서 올라오기)
  static Route<T> slideUp<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(animation);

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }
}

/// 커스텀 페이지 전환 확장
extension PageTransitionExtensions on Widget {
  /// 슬라이드 + 페이드로 페이지 전환
  Route<T> slideAndFadeRoute<T extends Object?>() {
    return AppPageTransitions.slideAndFade<T>(this);
  }

  /// 스케일 + 페이드로 페이지 전환
  Route<T> scaleAndFadeRoute<T extends Object?>() {
    return AppPageTransitions.scaleAndFade<T>(this);
  }

  /// 바운스 인으로 페이지 전환
  Route<T> bounceInRoute<T extends Object?>() {
    return AppPageTransitions.bounceIn<T>(this);
  }

  /// 회전 + 페이드로 페이지 전환
  Route<T> rotateAndFadeRoute<T extends Object?>() {
    return AppPageTransitions.rotateAndFade<T>(this);
  }

  /// 슬라이드 업으로 페이지 전환
  Route<T> slideUpRoute<T extends Object?>() {
    return AppPageTransitions.slideUp<T>(this);
  }
}