/// Curriculum metadata.
///
/// 학년별 과목 필터 정책은 사용자 결정으로 제거됨 — 모든 사용자가 전체
/// 단원·과목에 접근한다. 과거 `getSubjectsForGrade` / `hasFullAccess` /
/// `hasContentForGrade` 등 stub 메서드는 모두 dead-stub 이라 제거했다.
///
/// 현재는 curriculum_data.dart 에 실제 콘텐츠가 들어있는 과목 코드 집합만
/// 메타 상수로 유지한다.
class GradeCurriculumMap {
  /// curriculum_data.dart 에 콘텐츠가 존재하는 과목 코드.
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
}
