/// 날짜 관련 유틸리티
class AppDateUtils {
  AppDateUtils._();

  /// 나이 계산
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// 생년월일로부터 DateTime 생성
  static DateTime? createBirthDate(int? year, int? month, int? day) {
    if (year == null || month == null || day == null) {
      return null;
    }
    try {
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  /// 유효한 생년월일 범위 확인
  static bool isValidBirthDateRange(int? year, int? month, int? day) {
    if (year == null || month == null || day == null) {
      return false;
    }

    final now = DateTime.now();
    final minYear = now.year - 100; // 100세
    final maxYear = now.year - 5; // 5세

    // 년도 범위 확인
    if (year < minYear || year > maxYear) {
      return false;
    }

    // 월 범위 확인
    if (month < 1 || month > 12) {
      return false;
    }

    // 일 범위 확인
    final daysInMonth = _getDaysInMonth(year, month);
    if (day < 1 || day > daysInMonth) {
      return false;
    }

    return true;
  }

  /// 해당 월의 일수 반환
  static int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      return _isLeapYear(year) ? 29 : 28;
    }
    if (month == 4 || month == 6 || month == 9 || month == 11) {
      return 30;
    }
    return 31;
  }

  /// 윤년 확인
  static bool _isLeapYear(int year) {
    if (year % 4 != 0) return false;
    if (year % 100 != 0) return true;
    return year % 400 == 0;
  }

  /// 년도 목록 생성 (현재 - 100년 ~ 현재 - 5년)
  static List<int> getYearOptions() {
    final now = DateTime.now();
    final minYear = now.year - 100;
    final maxYear = now.year - 5;
    return List.generate(
      maxYear - minYear + 1,
      (index) => maxYear - index,
    );
  }

  /// 월 목록 생성 (1-12)
  static List<int> getMonthOptions() {
    return List.generate(12, (index) => index + 1);
  }

  /// 일 목록 생성 (해당 월에 맞는 일수)
  static List<int> getDayOptions(int? year, int? month) {
    if (year == null || month == null) {
      return List.generate(31, (index) => index + 1);
    }
    final daysInMonth = _getDaysInMonth(year, month);
    return List.generate(daysInMonth, (index) => index + 1);
  }

  /// 날짜를 문자열로 포맷 (YYYY년 MM월 DD일)
  static String formatBirthDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  /// 날짜를 짧은 문자열로 포맷 (YYYY.MM.DD)
  static String formatBirthDateShort(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}.$month.$day';
  }

  /// 오늘 날짜 확인
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 어제 날짜 확인
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// 날짜 차이 (일)
  static int daysDifference(DateTime date1, DateTime date2) {
    final diff = date1.difference(date2);
    return diff.inDays.abs();
  }

  /// 시작 날짜로부터 경과한 일수
  static int daysSince(DateTime startDate) {
    final now = DateTime.now();
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final current = DateTime(now.year, now.month, now.day);
    return current.difference(start).inDays;
  }

  /// 남은 일수
  static int daysUntil(DateTime targetDate) {
    final now = DateTime.now();
    final current = DateTime(now.year, now.month, now.day);
    final target =
        DateTime(targetDate.year, targetDate.month, targetDate.day);
    return target.difference(current).inDays;
  }
}
