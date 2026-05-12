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
  static List<String> getSubjectsForGrade(String grade) {
    switch (grade) {
      case '초1':
      case '초2':
      case '초3':
      case '초4':
      case '초5':
      case '초6':
        return const ['기초수학'];
      case '중1':
      case '중2':
      case '중3':
        return const ['중학수학'];
      case '고1':
        return const ['공통수학1', '공통수학2'];
      case '고2':
        return const ['수학I', '수학II', '확률과통계'];
      case '고3':
        return const ['수학I', '수학II', '확률과통계', '미적분', '기하'];
      case '대학생':
      case '성인':
        return const []; // empty list = full access
      default:
        return const ['공통수학1'];
    }
  }

  /// Returns true if the grade has full access (no filtering).
  static bool hasFullAccess(String grade) {
    return getSubjectsForGrade(grade).isEmpty;
  }

  /// curriculum_data.dart 에 콘텐츠가 존재하는 과목 코드.
  /// 매핑 결과 중 이 집합 밖의 과목은 학습 화면 진입 시 '준비 중' 으로 처리.
  static const Set<String> availableSubjectsInData = {
    '공통수학1',
    '공통수학2',
    '수학I',
    '수학II',
    '확률과통계',
    '미적분',
    '기하',
  };

  /// 해당 학년이 현재 학습 콘텐츠가 준비된 학년인지.
  /// (초·중학생은 false — 매핑은 정상이지만 데이터 미보유.)
  static bool hasContentForGrade(String grade) {
    final subjects = getSubjectsForGrade(grade);
    if (subjects.isEmpty) return true; // full access
    return subjects.any(availableSubjectsInData.contains);
  }
}
