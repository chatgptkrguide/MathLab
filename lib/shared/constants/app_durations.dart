/// MathLab 앱의 애니메이션 및 시간 상수 정의
class AppDurations {
  AppDurations._(); // private constructor

  // ==========================================
  // 1. Animation Durations (애니메이션 시간)
  // ==========================================

  /// 매우 빠른 애니메이션 (150ms)
  static const Duration animationFastest = Duration(milliseconds: 150);

  /// 빠른 애니메이션 (300ms)
  static const Duration animationFast = Duration(milliseconds: 300);

  /// 일반 애니메이션 (400ms)
  static const Duration animationNormal = Duration(milliseconds: 400);

  /// 중간 애니메이션 (600ms)
  static const Duration animationMedium = Duration(milliseconds: 600);

  /// 느린 애니메이션 (800ms)
  static const Duration animationSlow = Duration(milliseconds: 800);

  /// Auth 화면 애니메이션 (1500ms)
  static const Duration authAnimation = Duration(milliseconds: 1500);

  // ==========================================
  // 2. UI Feedback Durations (UI 피드백 시간)
  // ==========================================

  /// 스낵바 표시 시간 (2초)
  static const Duration snackBarShort = Duration(seconds: 2);

  /// 스낵바 긴 표시 시간 (4초)
  static const Duration snackBarLong = Duration(seconds: 4);

  /// 툴팁 표시 시간 (1.5초)
  static const Duration tooltipDisplay = Duration(milliseconds: 1500);

  /// 성공 메시지 표시 시간 (2초)
  static const Duration successMessage = Duration(seconds: 2);

  /// 에러 메시지 표시 시간 (3초)
  static const Duration errorMessage = Duration(seconds: 3);

  // ==========================================
  // 3. Delayed Actions (지연 실행)
  // ==========================================

  /// 자동 로그인 지연 (3초) - 개발 환경 전용
  static const Duration autoLoginDelay = Duration(seconds: 3);

  /// 화면 전환 지연 (500ms)
  static const Duration screenTransitionDelay = Duration(milliseconds: 500);

  /// 스플래시 화면 최소 표시 시간 (2초)
  static const Duration splashScreenMinDuration = Duration(seconds: 2);

  // ==========================================
  // 4. Loading & Progress (로딩 및 진행)
  // ==========================================

  /// 최소 로딩 시간 (500ms)
  static const Duration minLoadingDuration = Duration(milliseconds: 500);

  /// 일반 로딩 시간 (1초)
  static const Duration normalLoadingDuration = Duration(seconds: 1);

  /// 긴 로딩 시간 (3초)
  static const Duration longLoadingDuration = Duration(seconds: 3);

  // ==========================================
  // 5. Debounce & Throttle (디바운스 & 스로틀)
  // ==========================================

  /// 검색 입력 디바운스 (300ms)
  static const Duration searchDebounce = Duration(milliseconds: 300);

  /// 버튼 클릭 스로틀 (500ms)
  static const Duration buttonThrottle = Duration(milliseconds: 500);

  /// 스크롤 디바운스 (100ms)
  static const Duration scrollDebounce = Duration(milliseconds: 100);

  // ==========================================
  // 6. Cache & Sync (캐시 & 동기화)
  // ==========================================

  /// 캐시 유효 시간 (5분)
  static const Duration cacheValidity = Duration(minutes: 5);

  /// 동기화 간격 (30초)
  static const Duration syncInterval = Duration(seconds: 30);

  /// 네트워크 재시도 간격 (5초)
  static const Duration networkRetryInterval = Duration(seconds: 5);

  // ==========================================
  // 7. Timeout (타임아웃)
  // ==========================================

  /// API 요청 타임아웃 (30초)
  static const Duration apiTimeout = Duration(seconds: 30);

  /// 짧은 타임아웃 (10초)
  static const Duration shortTimeout = Duration(seconds: 10);

  /// 긴 타임아웃 (60초)
  static const Duration longTimeout = Duration(seconds: 60);

  // ==========================================
  // 8. Gamification (게이미피케이션)
  // ==========================================

  /// XP 획득 애니메이션 (800ms)
  static const Duration xpAnimation = Duration(milliseconds: 800);

  /// 레벨업 애니메이션 (1200ms)
  static const Duration levelUpAnimation = Duration(milliseconds: 1200);

  /// 스트릭 애니메이션 (600ms)
  static const Duration streakAnimation = Duration(milliseconds: 600);

  /// 뱃지 획득 애니메이션 (1000ms)
  static const Duration badgeAnimation = Duration(milliseconds: 1000);
}
