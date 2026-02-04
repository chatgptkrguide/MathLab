/// 사용자 레벨에 따른 배지 정보 매퍼
/// 레벨 범위에 따라 적절한 배지 이미지 경로와 이름을 반환합니다
class LevelBadgeMapper {
  /// 레벨에 해당하는 배지 이미지 경로 반환
  static String getBadgeImagePath(int level) {
    final badge = getBadgeForLevel(level);
    return 'assets/images/badges/${badge.assetName}.png';
  }

  /// 레벨에 해당하는 배지 정보 반환
  static LevelBadge getBadgeForLevel(int level) {
    if (level >= 50) {
      return LevelBadge.diamond;
    } else if (level >= 30) {
      return LevelBadge.gold;
    } else if (level >= 15) {
      return LevelBadge.silver;
    } else {
      return LevelBadge.bronze;
    }
  }

  /// 레벨에 해당하는 배지 이름 반환 (한국어)
  static String getBadgeName(int level) {
    return getBadgeForLevel(level).displayName;
  }
}

/// 레벨 배지 열거형
enum LevelBadge {
  bronze(assetName: 'badge_bronze', displayName: '브론즈'),
  silver(assetName: 'badge_silver', displayName: '실버'),
  gold(assetName: 'badge_gold', displayName: '골드'),
  diamond(assetName: 'badge_diamond', displayName: '다이아몬드');

  final String assetName;
  final String displayName;

  const LevelBadge({
    required this.assetName,
    required this.displayName,
  });
}
