/// 레벨을 배지 이미지로 매핑하는 유틸리티
class LevelBadgeMapper {
  /// 레벨에 따른 배지 이미지 경로 반환
  static String getBadgeImagePath(int level) {
    if (level <= 0) {
      return 'assets/badges/badge_locked_1.png';
    } else if (level <= 5) {
      // Bronze Tier (1-5): Locked badges
      final badgeNumber = ((level - 1) % 3) + 1;
      return 'assets/badges/badge_locked_$badgeNumber.png';
    } else if (level <= 10) {
      // Silver Tier (6-10): Checkmark clipboard
      return 'assets/badges/badge_checkmark_clipboard.png';
    } else if (level <= 15) {
      // Gold Tier (11-15): Checkmark certified
      return 'assets/badges/badge_checkmark_certified.png';
    } else if (level <= 20) {
      // Platinum Tier (16-20): Star certified
      return 'assets/badges/badge_star_certified.png';
    } else if (level <= 30) {
      // Diamond Tier (21-30): Achievement success
      return 'assets/badges/badge_achievement_success.png';
    } else {
      // Legendary Tier (31+): Achievement trophy
      return 'assets/badges/badge_achievement_trophy.png';
    }
  }

  /// 레벨에 따른 티어 이름 반환
  static String getTierName(int level) {
    if (level <= 0) return '초보자';
    if (level <= 5) return 'Bronze';
    if (level <= 10) return 'Silver';
    if (level <= 15) return 'Gold';
    if (level <= 20) return 'Platinum';
    if (level <= 30) return 'Diamond';
    return 'Legendary';
  }

  /// 레벨에 따른 티어 색상 반환 (hex)
  static int getTierColor(int level) {
    if (level <= 0) return 0xFF9E9E9E;
    if (level <= 5) return 0xFFCD7F32;  // Bronze
    if (level <= 10) return 0xFFC0C0C0; // Silver
    if (level <= 15) return 0xFFFFD700; // Gold
    if (level <= 20) return 0xFFE5E4E2; // Platinum
    if (level <= 30) return 0xFFB9F2FF; // Diamond Blue
    return 0xFFFF6B6B;                   // Legendary Red
  }
}
