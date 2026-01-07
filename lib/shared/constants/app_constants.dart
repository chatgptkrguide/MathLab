/// 앱 전체에서 사용되는 일반 상수 정의
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // ============================================
  // 학년 정보
  // ============================================

  /// 학년별 정보 맵
  static const Map<String, Map<String, String>> gradeInfoMap = {
    '중1': {
      'emoji': '📚',
      'fullName': '중학교 1학년',
    },
    '중2': {
      'emoji': '📖',
      'fullName': '중학교 2학년',
    },
    '중3': {
      'emoji': '📕',
      'fullName': '중학교 3학년',
    },
    '고1': {
      'emoji': '📘',
      'fullName': '고등학교 1학년',
    },
    '고2': {
      'emoji': '📙',
      'fullName': '고등학교 2학년',
    },
    '고3': {
      'emoji': '📗',
      'fullName': '고등학교 3학년',
    },
  };

  // ============================================
  // 모달 및 UI 상수
  // ============================================

  /// 모달 최대 높이 비율 (화면 대비)
  static const double modalMaxHeightRatio = 0.8;

  /// 모달 핸들바 너비
  static const double modalHandleWidth = 40.0;

  /// 모달 핸들바 높이
  static const double modalHandleHeight = 4.0;

  /// 모달 상단 여백
  static const double modalTopMargin = 12.0;

  /// 모달 하단 여백
  static const double modalBottomMargin = 8.0;
}
