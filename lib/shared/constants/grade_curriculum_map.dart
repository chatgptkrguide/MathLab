/// Grade-to-subject mapping for curriculum filtering.
///
/// Maps each grade level to the list of subject codes available for that grade.
/// 빈 리스트는 전체 과목 접근(대학생/성인) 의미.
///
/// 한국 교육과정 (2025 개정):
///   - 초등 (1~6학년): '기초수학' — 사칙연산·분수·소수·도형 기초.
///   - 중학 (1~3학년): '중학수학' — 정수·유리수·일차/이차방정식·함수·기하 기본.
///   - 고1: '공통수학1', '공통수학2' — 다항식·방정식·도형의 방정식·집합 등.
///   - 고2: '수학I', '수학II', '확률과통계'.
///   - 고3: '수학I', '수학II', '확률과통계', '미적분', '기하'.
///   - 대학생/성인: 전체.
///
/// curriculum_data.dart 에는 현재 고등 7개 과목 콘텐츠만 포함되어 있어
/// 초/중학 학년은 학습 화면에 빈 상태가 노출된다. HomeSubjectRow /
/// ProfileSubjectSection / LessonsScreen 측에서 '준비 중' 안내를 제공한다.
class GradeCurriculumMap {
  /// 정책: 학년 무관 — 모든 사용자에게 전체 단원·과목 노출.
  /// (이전엔 학년별 필터링했으나 사용자 결정으로 해제)
  static List<String> getSubjectsForGrade(String grade) => const [];

  /// 항상 true — 학년 필터 자체 비활성화. (호출 위치 호환성 위해 메서드 유지)
  static bool hasFullAccess(String grade) => true;

  /// curriculum_data.dart 에 콘텐츠가 존재하는 과목 코드.
  /// 매핑 결과 중 이 집합 밖의 과목은 학습 화면 진입 시 '준비 중' 으로 처리.
  /// (기초수학·중학수학 은 초·중학생 학년용 단원으로 추가됨 — 427914b)
  static const Set<String> availableSubjectsInData = {
    '기초수학',
    '중학수학',
    '공통수학1',
    '공통수학2',
    '수학I',
    '수학II',
    '확률과통계',
    '미적분',
    '기하',
  };

  /// 항상 true — 학년 필터 해제 후 모든 학년이 전체 콘텐츠 접근.
  static bool hasContentForGrade(String grade) => true;
}
