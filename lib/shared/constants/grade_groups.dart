/// 과목 → 학년 분류 (2022 개정 교육과정 기준).
///
/// 드롭다운 그룹 헤더와 학년 단위 필터링에 공유 사용.
class GradeGroups {
  GradeGroups._();

  /// 학년 라벨 → 해당 학년의 과목 코드 리스트.
  /// 순서 유지를 위해 LinkedHashMap 의미로 const Map 사용.
  static const Map<String, List<String>> map = {
    '초등': ['기초수학'],
    '중등': ['중학수학'],
    '고1': ['공통수학1', '공통수학2'],
    '고2': ['수학I', '수학II'],
    '고3 (선택)': ['확률과통계', '미적분', '기하'],
  };

  /// 필터 sentinel value prefix — selectedSubject 가 이 prefix 로
  /// 시작하면 학년 필터로 해석.
  static const String sentinelPrefix = '__grade_';

  /// sentinel 인지 확인.
  static bool isGradeSentinel(String? value) =>
      value != null && value.startsWith(sentinelPrefix);

  /// sentinel 에서 학년 라벨 추출. '__grade_고1' → '고1'.
  static String? gradeFromSentinel(String? value) =>
      isGradeSentinel(value) ? value!.substring(sentinelPrefix.length) : null;

  /// 학년 라벨 → sentinel value.
  static String sentinelFor(String grade) => '$sentinelPrefix$grade';

  /// 학년에 속한 과목 코드 집합. 없는 학년이면 빈 set.
  static Set<String> subjectsOf(String grade) =>
      (map[grade] ?? const []).toSet();
}
