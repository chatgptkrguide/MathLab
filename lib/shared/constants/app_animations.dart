import 'package:flutter/animation.dart';

/// MathLab 앱의 애니메이션 상수 정의
class AppAnimations {
  AppAnimations._(); // private constructor

  // 애니메이션 지속 시간
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 400); // 중간 속도
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // 커브
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceIn = Curves.bounceIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve spring = Curves.easeOutBack; // 스프링 효과
  static const Curve elastic = Curves.elasticOut; // 탄성 효과

  // 페이드 애니메이션
  static const Duration fadeIn = Duration(milliseconds: 300);
  static const Duration fadeOut = Duration(milliseconds: 200);

  // 스케일 애니메이션
  static const Duration scaleUp = Duration(milliseconds: 200);
  static const Duration scaleDown = Duration(milliseconds: 150);

  // 슬라이드 애니메이션
  static const Duration slideIn = Duration(milliseconds: 300);
  static const Duration slideOut = Duration(milliseconds: 250);

  // 회전 애니메이션
  static const Duration rotation = Duration(milliseconds: 400);

  // 특수 애니메이션
  static const Duration confetti = Duration(milliseconds: 3000);
  static const Duration shimmer = Duration(milliseconds: 1500);
  static const Duration pulse = Duration(milliseconds: 1000);

  // XP 획득 애니메이션
  static const Duration xpGain = Duration(milliseconds: 800);
  static const Curve xpGainCurve = Curves.elasticOut;

  // 레벨업 애니메이션
  static const Duration levelUp = Duration(milliseconds: 1200);
  static const Curve levelUpCurve = Curves.bounceOut;

  // 카드 플립 애니메이션
  static const Duration cardFlip = Duration(milliseconds: 600);
  static const Curve cardFlipCurve = Curves.easeInOut;

  // 리스트 아이템 애니메이션
  static const Duration listItemFade = Duration(milliseconds: 200);
  static Duration listItemDelay(int index) =>
      Duration(milliseconds: 50 * index);

  // 스낵바 애니메이션
  static const Duration snackbarSlideIn = Duration(milliseconds: 300);
  static const Duration snackbarSlideOut = Duration(milliseconds: 200);
  static const Curve snackbarCurve = Curves.easeOut;

  // 다이얼로그 애니메이션
  static const Duration dialogFadeIn = Duration(milliseconds: 200);
  static const Duration dialogScaleIn = Duration(milliseconds: 200);
  static const Curve dialogCurve = Curves.easeOut;

  // 드로어 애니메이션
  static const Duration drawerSlide = Duration(milliseconds: 250);
  static const Curve drawerCurve = Curves.easeOut;

  // 페이지 전환 애니메이션
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Curve pageTransitionCurve = Curves.easeInOut;

  // 로딩 애니메이션
  static const Duration loadingRotation = Duration(milliseconds: 1000);
  static const Duration loadingPulse = Duration(milliseconds: 800);

  // 스켈레톤 로딩
  static const Duration skeletonShimmer = Duration(milliseconds: 1500);

  // 버튼 애니메이션
  static const Duration buttonPress = Duration(milliseconds: 100);
  static const Duration buttonRelease = Duration(milliseconds: 150);
  static const Curve buttonCurve = Curves.easeInOut;

  // 프로그레스 바 애니메이션
  static const Duration progressUpdate = Duration(milliseconds: 500);
  static const Curve progressCurve = Curves.easeOut;

  // 하트 애니메이션 (목숨 시스템)
  static const Duration heartBeat = Duration(milliseconds: 400);
  static const Duration heartLoss = Duration(milliseconds: 600);
  static const Curve heartBeatCurve = Curves.elasticOut;

  // 스트릭 플레임 애니메이션
  static const Duration streakFlame = Duration(milliseconds: 800);
  static const Curve streakFlameCurve = Curves.easeOut;

  // 배지 획득 애니메이션
  static const Duration badgeAppear = Duration(milliseconds: 600);
  static const Curve badgeAppearCurve = Curves.bounceOut;

  // 리그 순위 변경 애니메이션
  static const Duration rankChange = Duration(milliseconds: 500);
  static const Curve rankChangeCurve = Curves.easeInOut;
}
