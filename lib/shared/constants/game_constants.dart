/// 게임 관련 상수 정의
/// 매직 넘버/문자열을 방지하고 유지보수성을 향상시키기 위한 파일
class GameConstants {
  // Private constructor to prevent instantiation
  GameConstants._();

  // ========== XP 시스템 ==========
  /// 레벨당 필요한 XP
  static const int xpPerLevel = 100;

  /// 일일 목표 XP
  static const int dailyGoalXP = 100;

  /// 문제당 기본 XP 보상
  static const int baseXPReward = 10;

  // ========== 하트 시스템 ==========
  /// 최대 하트 개수
  static const int maxHearts = 5;

  /// 하트 회복 시간 (분)
  static const int heartRecoveryMinutes = 30;

  // ========== 스트릭 시스템 ==========
  /// 스트릭 프리즈 가능 횟수
  static const int maxStreakFreezes = 2;

  /// 주간 스트릭 보상 임계값
  static const int weeklyStreakThreshold = 7;

  // ========== 레벨 시스템 ==========
  /// 초급 레벨 범위
  static const int beginnerLevelMax = 5;

  /// 중급 레벨 범위
  static const int intermediateLevelMax = 10;

  /// 고급 레벨 시작
  static const int advancedLevelMin = 11;

  // ========== 난이도 시스템 ==========
  /// 최소 난이도
  static const int minDifficulty = 1;

  /// 최대 난이도
  static const int maxDifficulty = 5;

  // ========== 문제 설정 ==========
  /// 기본 레슨당 문제 수
  static const int defaultProblemsPerLesson = 10;

  /// 추천 문제 개수
  static const int recommendedProblemCount = 5;

  /// 최소 문제 수
  static const int minProblemCount = 1;

  /// 최대 문제 수
  static const int maxProblemCount = 20;

  // ========== 기본값 ==========
  /// 기본 레슨 ID
  static const String defaultLessonId = 'lesson001';

  /// 기본 사용자 이름
  static const String defaultUserName = '학습자';

  /// 기본 학년
  static const String defaultGrade = '중1';

  // ========== UI 투명도 값 ==========
  /// 높은 투명도
  static const double highOpacity = 0.9;

  /// 중간 투명도
  static const double mediumOpacity = 0.7;

  /// 낮은 투명도
  static const double lowOpacity = 0.5;

  /// 매우 낮은 투명도
  static const double veryLowOpacity = 0.3;

  /// 최소 투명도
  static const double minimalOpacity = 0.1;

  // ========== 애니메이션 지속 시간 ==========
  /// 빠른 애니메이션 (ms)
  static const int fastAnimationMs = 150;

  /// 일반 애니메이션 (ms)
  static const int normalAnimationMs = 300;

  /// 느린 애니메이션 (ms)
  static const int slowAnimationMs = 500;

  // ========== 타이밍 ==========
  /// SnackBar 표시 시간 (초)
  static const int snackBarDurationSeconds = 2;

  /// 다이얼로그 자동 닫기 시간 (초)
  static const int autoCloseDialogSeconds = 3;

  // ========== 스토리지 키 ==========
  /// 사용자 데이터 저장 키
  static const String userStorageKey = 'user';

  /// 마지막 학습 날짜 저장 키
  static const String lastStudyDateKey = 'lastStudyDate';

  /// 문제 결과 저장 키
  static const String problemResultsKey = 'problemResults';

  /// 오답 노트 저장 키
  static const String errorNotesKey = 'errorNotes';

  /// 업적 저장 키
  static const String achievementsKey = 'achievements';

  // ========== 검증 규칙 ==========
  /// 최소 사용자 이름 길이
  static const int minUserNameLength = 2;

  /// 최대 사용자 이름 길이
  static const int maxUserNameLength = 20;

  // ========== 리더보드 ==========
  /// 리더보드 표시 인원
  static const int leaderboardDisplayCount = 10;

  /// 리더보드 업데이트 주기 (시간)
  static const int leaderboardUpdateHours = 24;

  // ========== 업적 시스템 ==========
  /// 첫 문제 풀기 업적 ID
  static const String achievementFirstProblem = 'achievement001';

  /// 10문제 풀기 업적 ID
  static const String achievement10Problems = 'achievement002';

  /// 7일 연속 학습 업적 ID
  static const String achievement7DayStreak = 'achievement003';

  // ========== 디버그 ==========
  /// 디버그 모드에서 문제 수 제한
  static const int debugMaxProblems = 5;

  /// 디버그 모드에서 빠른 레벨업 (XP 감소)
  static const int debugXPPerLevel = 50;
}
