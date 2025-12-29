// Asset 경로 관리
//
// 모든 asset 경로를 중앙에서 관리하여 오타 방지 및 유지보수성 향상

/// Asset 경로 상수
class AppAssets {
  // ==================== 이미지 ====================

  /// 기본 placeholder 이미지 (이미지 로딩 실패 시)
  static const String imagePlaceholder = 'assets/images/general/placeholder.png';

  /// 프로필 기본 이미지
  static const String profilePlaceholder = 'assets/images/general/profile_default.png';

  /// 문제 이미지 placeholder
  static const String problemImagePlaceholder = 'assets/images/general/problem_placeholder.png';

  // ==================== 로그인/소셜 ====================

  /// Google 로고
  static const String googleLogo = 'assets/images/login/google_logo.png';

  /// Kakao 로고
  static const String kakaoLogo = 'assets/images/login/kakao_logo.png';

  /// Apple 로고
  static const String appleLogo = 'assets/images/login/apple_logo.png';

  // ==================== 캐릭터 & 일러스트 ====================

  /// 로봇 캐릭터
  static const String robotCharacter = 'assets/images/robot_character.png';

  /// 승리 일러스트
  static const String winnerIllustration = 'assets/images/winner.png';

  /// 책과 연필
  static const String bookPencil = 'assets/images/book_pencil.png';

  /// 책
  static const String book = 'assets/images/book.png';

  /// 칠판
  static const String blackboard = 'assets/images/blackboard.png';

  /// 현미경
  static const String microscope = 'assets/images/microscope.png';

  /// 자
  static const String rulers = 'assets/images/rulers.png';

  /// 시계
  static const String clock = 'assets/images/clock.png';

  /// 지구본
  static const String globe = 'assets/images/globe.png';

  /// 노트북
  static const String laptop = 'assets/images/laptop.png';

  /// 가방
  static const String bag = 'assets/images/bag.png';

  /// 벡터 이미지
  static const String vexel = 'assets/images/vexel.png';

  // ==================== 뱃지 ====================

  /// 뱃지 기본 경로
  static const String badgesPath = 'assets/badges/';

  /// 잠긴 뱃지 placeholder
  static const String badgeLocked = 'assets/badges/badge_locked.png';

  // ==================== 리그 순위 아이콘 ====================

  /// 리그 순위 아이콘 기본 경로
  static const String ranksPath = 'assets/images/ranks/';

  /// 1등 트로피
  static const String rank1Trophy = 'assets/images/ranks/trophy_1st.png';

  /// 2등 트로피
  static const String rank2Trophy = 'assets/images/ranks/trophy_2nd.png';

  /// 3등 트로피
  static const String rank3Trophy = 'assets/images/ranks/trophy_3rd.png';

  // ==================== 아이콘 ====================

  /// 아이콘 기본 경로
  static const String iconsPath = 'assets/icons/';

  // ==================== 문제 이미지 ====================

  /// 문제 이미지 기본 경로
  static const String problemsPath = 'assets/problems/';

  /// 소인수분해 문제 이미지
  static const String problemsMs1Path = 'assets/problems/ms1_소인수분해/';

  // ==================== 폰트 ====================

  /// Pretendard 폰트 패밀리
  static const String fontPretendard = 'Pretendard';

  // ==================== 사운드 ====================

  /// 사운드 기본 경로
  static const String soundsPath = 'assets/sounds/';

  /// 정답 사운드
  static const String soundCorrect = 'assets/sounds/correct.mp3';

  /// 오답 사운드
  static const String soundWrong = 'assets/sounds/wrong.mp3';

  /// 성공 사운드
  static const String soundSuccess = 'assets/sounds/success.mp3';

  /// 실패 사운드
  static const String soundFail = 'assets/sounds/fail.mp3';

  // ==================== 데이터 ====================

  /// 레슨 데이터 경로
  static const String lessonsData = 'assets/data/lessons.json';

  /// 문제 데이터 경로
  static const String problemsData = 'assets/data/problems.json';

  // ==================== 헬퍼 메서드 ====================

  /// 뱃지 경로 생성
  static String getBadgePath(String badgeName) {
    return '$badgesPath$badgeName.png';
  }

  /// 순위 아이콘 경로 생성
  static String getRankIconPath(int rank) {
    if (rank == 1) return rank1Trophy;
    if (rank == 2) return rank2Trophy;
    if (rank == 3) return rank3Trophy;
    return '$ranksPath/rank_$rank.png';
  }

  /// 문제 이미지 경로 생성
  static String getProblemImagePath(String category, String imageName) {
    return '$problemsPath$category/$imageName';
  }

  /// 아이콘 경로 생성
  static String getIconPath(String iconName) {
    return '$iconsPath$iconName.png';
  }

  /// Asset 존재 여부 확인을 위한 fallback 처리
  static String getImageWithFallback(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return imagePlaceholder;
    }
    return imagePath;
  }

  /// 프로필 이미지 fallback
  static String getProfileImageWithFallback(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return profilePlaceholder;
    }
    return imagePath;
  }
}
