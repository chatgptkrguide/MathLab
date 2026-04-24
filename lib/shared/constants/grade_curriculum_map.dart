/// Grade-to-subject mapping for curriculum filtering.
///
/// Maps each grade level to the list of accessible subjects.
/// An empty list means full access to all subjects.
class GradeCurriculumMap {
  static List<String> getSubjectsForGrade(String grade) {
    switch (grade) {
      case '초1':
      case '초2':
      case '초3':
      case '초4':
      case '초5':
      case '초6':
        return ['공통수학1'];
      case '중1':
      case '중2':
      case '중3':
        return ['공통수학1', '공통수학2'];
      case '고1':
        return ['공통수학1', '공통수학2'];
      case '고2':
        return ['공통수학1', '공통수학2', '수학I', '수학II', '확률과통계'];
      case '고3':
        return ['공통수학1', '공통수학2', '수학I', '수학II', '확률과통계', '미적분', '기하'];
      case '대학생':
      case '성인':
        return []; // empty list = full access
      default:
        return ['공통수학1'];
    }
  }

  /// Returns true if the grade has full access (no filtering).
  static bool hasFullAccess(String grade) {
    return getSubjectsForGrade(grade).isEmpty;
  }
}
