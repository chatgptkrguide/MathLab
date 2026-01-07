/// 레벨을 배지 이미지로 매핑하는 유틸리티
class LevelBadgeMapper {
  /// 레벨에 따른 랭크 아이콘 경로 반환 (Figma 디자인 기반)
  static String getBadgeImagePath(int level) {
    if (level <= 0) {
      // 레벨 0 이하: A Lv1
      return 'assets/images/ranks/a_lv1.png';
    } else if (level <= 3) {
      // A Tier Lv1 (1-3)
      return 'assets/images/ranks/a_lv1.png';
    } else if (level <= 6) {
      // A Tier Lv2 (4-6)
      return 'assets/images/ranks/a_lv2.png';
    } else if (level <= 10) {
      // A Tier Lv3 (7-10)
      return 'assets/images/ranks/a_lv3.png';
    } else if (level <= 13) {
      // H Tier Lv1 (11-13)
      return 'assets/images/ranks/h_lv1.png';
    } else if (level <= 16) {
      // H Tier Lv2 (14-16)
      return 'assets/images/ranks/h_lv2.png';
    } else if (level <= 20) {
      // H Tier Lv3 (17-20)
      return 'assets/images/ranks/h_lv3.png';
    } else if (level <= 23) {
      // GT Tier Lv1 (21-23)
      return 'assets/images/ranks/gt_lv1.png';
    } else if (level <= 26) {
      // GT Tier Lv2 (24-26)
      return 'assets/images/ranks/gt_lv2.png';
    } else if (level <= 30) {
      // GT Tier Lv3 (27-30)
      return 'assets/images/ranks/gt_lv3.png';
    } else {
      // Legendary Tier (31+): 최고 등급
      return 'assets/images/ranks/gt_레전드.png';
    }
  }

  /// 레벨에 따른 티어 이름 반환
  static String getTierName(int level) {
    if (level <= 0) return '초보자';
    if (level <= 10) return 'A Tier'; // A Lv1-3
    if (level <= 20) return 'H Tier'; // H Lv1-3
    if (level <= 30) return 'GT Tier'; // GT Lv1-3
    return 'Legend'; // 레전드
  }

  /// 레벨에 따른 세부 랭크 이름 반환
  static String getRankName(int level) {
    if (level <= 0) return 'A Lv1';
    if (level <= 3) return 'A Lv1';
    if (level <= 6) return 'A Lv2';
    if (level <= 10) return 'A Lv3';
    if (level <= 13) return 'H Lv1';
    if (level <= 16) return 'H Lv2';
    if (level <= 20) return 'H Lv3';
    if (level <= 23) return 'GT Lv1';
    if (level <= 26) return 'GT Lv2';
    if (level <= 30) return 'GT Lv3';
    return '레전드';
  }

  /// 레벨에 따른 티어 색상 반환 (hex)
  static int getTierColor(int level) {
    if (level <= 0) return 0xFF9E9E9E; // Gray
    if (level <= 10) return 0xFF9C27B0; // A - Purple
    if (level <= 20) return 0xFF2196F3; // H - Blue
    if (level <= 30) return 0xFF4CAF50; // GT - Green
    return 0xFFFFD700; // Legend - Gold
  }
}
