import 'subscription_service.dart';

/// 프리미엄 기능 게이팅 서비스
///
/// 각 기능별로 프리미엄 사용 여부를 확인하고,
/// 기능 접근을 제어합니다.
class PremiumFeatureService {
  final SubscriptionService _subscriptionService;

  PremiumFeatureService({SubscriptionService? subscriptionService})
      : _subscriptionService = subscriptionService ?? SubscriptionService();

  // ========================================
  // 프리미엄 기능 목록 (Feature List)
  // ========================================

  /// 무제한 하트 (Unlimited Hearts)
  ///
  /// 무료 사용자: 하트 5개 제한
  /// 프리미엄 사용자: 무제한 하트
  static const String featureUnlimitedHearts = 'unlimited_hearts';

  /// 광고 제거 (Ad-Free Experience)
  ///
  /// 무료 사용자: 광고 표시
  /// 프리미엄 사용자: 광고 없음
  static const String featureAdFree = 'ad_free';

  /// 오프라인 모드 (Offline Mode)
  ///
  /// 무료 사용자: 온라인 전용
  /// 프리미엄 사용자: 오프라인 학습 가능
  static const String featureOfflineMode = 'offline_mode';

  /// 고급 통계 (Advanced Statistics)
  ///
  /// 무료 사용자: 기본 통계만 (주간)
  /// 프리미엄 사용자: 고급 통계 (월간, 연간, 상세 분석)
  static const String featureAdvancedStats = 'advanced_stats';

  /// 커스텀 테마 (Custom Themes)
  ///
  /// 무료 사용자: 기본 테마만
  /// 프리미엄 사용자: 다양한 커스텀 테마
  static const String featureCustomThemes = 'custom_themes';

  /// 우선 지원 (Priority Support)
  ///
  /// 무료 사용자: 일반 지원 (24-48시간)
  /// 프리미엄 사용자: 우선 지원 (6-12시간)
  static const String featurePrioritySupport = 'priority_support';

  /// 프리미엄 배지 (Premium Badge)
  ///
  /// 무료 사용자: 없음
  /// 프리미엄 사용자: 프로필에 프리미엄 뱃지 표시
  static const String featurePremiumBadge = 'premium_badge';

  /// 무제한 연습 모드 (Unlimited Practice)
  ///
  /// 무료 사용자: 일일 연습 제한 (10문제)
  /// 프리미엄 사용자: 무제한 연습 가능
  static const String featureUnlimitedPractice = 'unlimited_practice';

  /// 문제 내보내기 (Problem Export)
  ///
  /// 무료 사용자: 불가능
  /// 프리미엄 사용자: PDF로 문제 내보내기 가능
  static const String featureProblemExport = 'problem_export';

  /// 복수 프로필 (Multiple Profiles)
  ///
  /// 무료 사용자: 1개 프로필
  /// 프리미엄 사용자: 최대 5개 프로필 (가족 공유)
  static const String featureMultipleProfiles = 'multiple_profiles';

  // ========================================
  // 기능 접근 검증 (Feature Access Check)
  // ========================================

  /// 특정 기능이 활성화되어 있는지 확인
  ///
  /// userId의 프리미엄 구독 상태를 확인하고,
  /// 해당 기능에 접근할 수 있는지 반환합니다.
  Future<bool> isFeatureEnabled(String userId, String featureId) async {
    // 프리미엄 활성 상태 확인
    final isPremium = await _subscriptionService.isPremiumActive(userId);

    // 프리미엄이 아니면 모든 기능 비활성화
    if (!isPremium) return false;

    // 프리미엄 사용자는 모든 기능 활성화
    return true;
  }

  /// 여러 기능이 모두 활성화되어 있는지 확인
  Future<bool> areAllFeaturesEnabled(
      String userId, List<String> featureIds) async {
    for (final featureId in featureIds) {
      final isEnabled = await isFeatureEnabled(userId, featureId);
      if (!isEnabled) return false;
    }
    return true;
  }

  /// 활성화된 기능 목록 조회
  Future<List<String>> getEnabledFeatures(String userId) async {
    final isPremium = await _subscriptionService.isPremiumActive(userId);

    if (!isPremium) return [];

    // 프리미엄 사용자는 모든 기능 활성화
    return [
      featureUnlimitedHearts,
      featureAdFree,
      featureOfflineMode,
      featureAdvancedStats,
      featureCustomThemes,
      featurePrioritySupport,
      featurePremiumBadge,
      featureUnlimitedPractice,
      featureProblemExport,
      featureMultipleProfiles,
    ];
  }

  // ========================================
  // 편의 메서드 (Convenience Methods)
  // ========================================

  /// 무제한 하트 사용 가능 여부
  Future<bool> hasUnlimitedHearts(String userId) async {
    return await isFeatureEnabled(userId, featureUnlimitedHearts);
  }

  /// 광고 없는 경험 활성화 여부
  Future<bool> isAdFree(String userId) async {
    return await isFeatureEnabled(userId, featureAdFree);
  }

  /// 오프라인 모드 사용 가능 여부
  Future<bool> canUseOfflineMode(String userId) async {
    return await isFeatureEnabled(userId, featureOfflineMode);
  }

  /// 고급 통계 접근 가능 여부
  Future<bool> canAccessAdvancedStats(String userId) async {
    return await isFeatureEnabled(userId, featureAdvancedStats);
  }

  /// 커스텀 테마 사용 가능 여부
  Future<bool> canUseCustomThemes(String userId) async {
    return await isFeatureEnabled(userId, featureCustomThemes);
  }

  /// 우선 지원 사용 가능 여부
  Future<bool> hasPrioritySupport(String userId) async {
    return await isFeatureEnabled(userId, featurePrioritySupport);
  }

  /// 프리미엄 배지 표시 여부
  Future<bool> canShowPremiumBadge(String userId) async {
    return await isFeatureEnabled(userId, featurePremiumBadge);
  }

  /// 무제한 연습 가능 여부
  Future<bool> hasUnlimitedPractice(String userId) async {
    return await isFeatureEnabled(userId, featureUnlimitedPractice);
  }

  /// 문제 내보내기 가능 여부
  Future<bool> canExportProblems(String userId) async {
    return await isFeatureEnabled(userId, featureProblemExport);
  }

  /// 복수 프로필 사용 가능 여부
  Future<bool> canUseMultipleProfiles(String userId) async {
    return await isFeatureEnabled(userId, featureMultipleProfiles);
  }

  // ========================================
  // 기능별 제한 확인 (Feature Limits)
  // ========================================

  /// 하트 개수 제한 조회
  ///
  /// 무료 사용자: 5개
  /// 프리미엄 사용자: -1 (무제한)
  Future<int> getHeartLimit(String userId) async {
    final hasUnlimited = await hasUnlimitedHearts(userId);
    return hasUnlimited ? -1 : 5;
  }

  /// 일일 연습 문제 제한 조회
  ///
  /// 무료 사용자: 10문제
  /// 프리미엄 사용자: -1 (무제한)
  Future<int> getDailyPracticeLimit(String userId) async {
    final hasUnlimited = await hasUnlimitedPractice(userId);
    return hasUnlimited ? -1 : 10;
  }

  /// 프로필 개수 제한 조회
  ///
  /// 무료 사용자: 1개
  /// 프리미엄 사용자: 5개
  Future<int> getProfileLimit(String userId) async {
    final canUseMultiple = await canUseMultipleProfiles(userId);
    return canUseMultiple ? 5 : 1;
  }

  /// 통계 기간 제한 조회
  ///
  /// 무료 사용자: 7일 (1주일)
  /// 프리미엄 사용자: 365일 (1년)
  Future<int> getStatsPeriodLimit(String userId) async {
    final hasAdvanced = await canAccessAdvancedStats(userId);
    return hasAdvanced ? 365 : 7;
  }

  // ========================================
  // 기능 게이팅 헬퍼 (Feature Gating Helpers)
  // ========================================

  /// 기능 접근 시도 with 프리미엄 유도
  ///
  /// 기능에 접근하려 할 때, 프리미엄이 아니면 업그레이드 유도
  /// 반환값:
  /// - true: 기능 사용 가능
  /// - false: 프리미엄 업그레이드 필요
  Future<FeatureAccessResult> tryAccessFeature(
    String userId,
    String featureId,
  ) async {
    final isEnabled = await isFeatureEnabled(userId, featureId);

    if (isEnabled) {
      return FeatureAccessResult.allowed();
    }

    // 프리미엄이 아닐 때
    final isPremium = await _subscriptionService.isPremiumActive(userId);
    if (!isPremium) {
      return FeatureAccessResult.requiresUpgrade(
        featureId: featureId,
        message: _getUpgradeMessage(featureId),
      );
    }

    // 이론상 여기에 도달하면 안 됨
    return FeatureAccessResult.denied('알 수 없는 오류가 발생했습니다');
  }

  /// 기능별 업그레이드 메시지
  String _getUpgradeMessage(String featureId) {
    switch (featureId) {
      case featureUnlimitedHearts:
        return '무제한 하트를 사용하려면 프리미엄으로 업그레이드하세요!';
      case featureAdFree:
        return '광고 없이 학습하려면 프리미엄으로 업그레이드하세요!';
      case featureOfflineMode:
        return '오프라인 모드를 사용하려면 프리미엄으로 업그레이드하세요!';
      case featureAdvancedStats:
        return '고급 통계를 보려면 프리미엄으로 업그레이드하세요!';
      case featureCustomThemes:
        return '커스텀 테마를 사용하려면 프리미엄으로 업그레이드하세요!';
      case featurePrioritySupport:
        return '우선 지원을 받으려면 프리미엄으로 업그레이드하세요!';
      case featureUnlimitedPractice:
        return '무제한 연습을 하려면 프리미엄으로 업그레이드하세요!';
      case featureProblemExport:
        return '문제를 내보내려면 프리미엄으로 업그레이드하세요!';
      case featureMultipleProfiles:
        return '가족 프로필을 추가하려면 프리미엄으로 업그레이드하세요!';
      default:
        return '이 기능을 사용하려면 프리미엄으로 업그레이드하세요!';
    }
  }

  // ========================================
  // 프리미엄 비교 (Premium Comparison)
  // ========================================

  /// 무료 vs 프리미엄 기능 비교 목록
  List<FeatureComparison> getFeatureComparisons() {
    return [
      FeatureComparison(
        featureId: featureUnlimitedHearts,
        name: '하트',
        freeValue: '5개 제한',
        premiumValue: '무제한',
        icon: '❤️',
      ),
      FeatureComparison(
        featureId: featureAdFree,
        name: '광고',
        freeValue: '광고 표시',
        premiumValue: '광고 없음',
        icon: '🚫',
      ),
      FeatureComparison(
        featureId: featureOfflineMode,
        name: '오프라인 모드',
        freeValue: '불가능',
        premiumValue: '가능',
        icon: '📴',
      ),
      FeatureComparison(
        featureId: featureAdvancedStats,
        name: '통계',
        freeValue: '기본 (주간)',
        premiumValue: '고급 (월간/연간)',
        icon: '📊',
      ),
      FeatureComparison(
        featureId: featureCustomThemes,
        name: '테마',
        freeValue: '기본 테마',
        premiumValue: '커스텀 테마',
        icon: '🎨',
      ),
      FeatureComparison(
        featureId: featurePrioritySupport,
        name: '지원',
        freeValue: '일반 (24-48h)',
        premiumValue: '우선 (6-12h)',
        icon: '🎧',
      ),
      FeatureComparison(
        featureId: featureUnlimitedPractice,
        name: '연습',
        freeValue: '일 10문제',
        premiumValue: '무제한',
        icon: '📝',
      ),
      FeatureComparison(
        featureId: featureProblemExport,
        name: '문제 내보내기',
        freeValue: '불가능',
        premiumValue: 'PDF 내보내기',
        icon: '📄',
      ),
      FeatureComparison(
        featureId: featureMultipleProfiles,
        name: '프로필',
        freeValue: '1개',
        premiumValue: '최대 5개',
        icon: '👥',
      ),
    ];
  }
}

// ========================================
// 헬퍼 클래스 (Helper Classes)
// ========================================

/// 기능 접근 결과
class FeatureAccessResult {
  final bool allowed;
  final String? reason;
  final String? featureId;
  final String? message;

  const FeatureAccessResult._({
    required this.allowed,
    this.reason,
    this.featureId,
    this.message,
  });

  factory FeatureAccessResult.allowed() {
    return const FeatureAccessResult._(allowed: true);
  }

  factory FeatureAccessResult.requiresUpgrade({
    required String featureId,
    required String message,
  }) {
    return FeatureAccessResult._(
      allowed: false,
      reason: 'requires_upgrade',
      featureId: featureId,
      message: message,
    );
  }

  factory FeatureAccessResult.denied(String reason) {
    return FeatureAccessResult._(
      allowed: false,
      reason: reason,
    );
  }
}

/// 기능 비교 데이터
class FeatureComparison {
  final String featureId;
  final String name;
  final String freeValue;
  final String premiumValue;
  final String icon;

  const FeatureComparison({
    required this.featureId,
    required this.name,
    required this.freeValue,
    required this.premiumValue,
    required this.icon,
  });
}
