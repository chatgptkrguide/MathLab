/// 학교급 (초등/중등/고등)
enum SchoolLevel {
  elementary('초등학교', 'elementary'),
  middle('중학교', 'middle'),
  high('고등학교', 'high');

  final String displayName;
  final String code;

  const SchoolLevel(this.displayName, this.code);

  /// 학년 문자열로부터 학교급 추출
  /// 예: '초1' -> SchoolLevel.elementary, '중2' -> SchoolLevel.middle
  static SchoolLevel fromGrade(String grade) {
    if (grade.startsWith('초')) {
      return SchoolLevel.elementary;
    } else if (grade.startsWith('중')) {
      return SchoolLevel.middle;
    } else if (grade.startsWith('고')) {
      return SchoolLevel.high;
    }
    // 기본값은 중학교
    return SchoolLevel.middle;
  }

  /// 학교급별 학년 목록
  List<String> get grades {
    switch (this) {
      case SchoolLevel.elementary:
        return ['초1', '초2', '초3', '초4', '초5', '초6'];
      case SchoolLevel.middle:
        return ['중1', '중2', '중3'];
      case SchoolLevel.high:
        return ['고1', '고2', '고3'];
    }
  }

  /// 학년 번호 추출 (1-6 또는 1-3)
  static int getGradeNumber(String grade) {
    final numberStr = grade.substring(1); // '초1' -> '1'
    return int.tryParse(numberStr) ?? 1;
  }

  /// 해당 학년이 이 학교급에 속하는지 확인
  bool containsGrade(String grade) {
    return grades.contains(grade);
  }

  /// 파일 경로용 학교급 코드
  /// 예: elementary -> 'elementary', middle -> 'middle'
  String get pathCode => code;

  /// JSON 직렬화
  String toJson() => code;

  /// JSON 역직렬화
  static SchoolLevel fromJson(String json) {
    return SchoolLevel.values.firstWhere(
      (e) => e.code == json,
      orElse: () => SchoolLevel.middle,
    );
  }
}
