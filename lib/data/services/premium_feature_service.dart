// 💎 Premium Feature Service
//
// Service for managing premium feature comparisons
// between free and premium tiers.

// 기능 비교 항목 모델
class FeatureComparison {
  /// 기능 아이콘
  final String icon;

  /// 기능 이름
  final String name;

  /// 무료 플랜 값
  final String freeValue;

  /// 프리미엄 플랜 값
  final String premiumValue;

  const FeatureComparison({
    required this.icon,
    required this.name,
    required this.freeValue,
    required this.premiumValue,
  });
}

/// 프리미엄 기능 비교 서비스
class PremiumFeatureService {
  /// 기능 비교 목록 반환
  List<FeatureComparison> getFeatureComparisons() {
    return const [
      FeatureComparison(
        icon: '❤️',
        name: '하트',
        freeValue: '5개',
        premiumValue: '무제한',
      ),
      FeatureComparison(
        icon: '📚',
        name: '레슨',
        freeValue: '기본',
        premiumValue: '전체',
      ),
      FeatureComparison(
        icon: '🔄',
        name: '복습',
        freeValue: '1일 3회',
        premiumValue: '무제한',
      ),
      FeatureComparison(
        icon: '💡',
        name: '힌트',
        freeValue: '1일 5회',
        premiumValue: '무제한',
      ),
      FeatureComparison(
        icon: '📊',
        name: '통계',
        freeValue: '기본',
        premiumValue: '상세',
      ),
      FeatureComparison(
        icon: '🎯',
        name: '맞춤 학습',
        freeValue: '—',
        premiumValue: 'AI 추천',
      ),
      FeatureComparison(
        icon: '📝',
        name: '오답 노트',
        freeValue: '최근 10개',
        premiumValue: '무제한',
      ),
      FeatureComparison(
        icon: '🏆',
        name: '리그 보상',
        freeValue: '기본',
        premiumValue: '2배',
      ),
      FeatureComparison(
        icon: '🚫',
        name: '광고',
        freeValue: '있음',
        premiumValue: '없음',
      ),
      FeatureComparison(
        icon: '⬇️',
        name: '오프라인 모드',
        freeValue: '—',
        premiumValue: '지원',
      ),
    ];
  }
}
