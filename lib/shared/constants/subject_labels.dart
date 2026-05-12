/// Subject code → 사용자 노출 한글 라벨 매핑.
///
/// 내부 식별자(예: '수학I', '수학II') 는 영문 I/II 를 그대로 사용해 코드 전반의
/// 비교·매칭·Firestore 데이터 호환성을 유지하고, 화면 표시에서만 유니코드
/// 로마숫자(Ⅰ, Ⅱ) 로 변환한다.
class SubjectLabels {
  SubjectLabels._();

  static const Map<String, String> _display = {
    '기초수학': '기초수학',
    '중학수학': '중학수학',
    '공통수학1': '공통수학1',
    '공통수학2': '공통수학2',
    '수학I': '수학Ⅰ',
    '수학II': '수학Ⅱ',
    '확률과통계': '확률과통계',
    '미적분': '미적분',
    '기하': '기하',
  };

  /// 코드에 해당하는 한글 표시명을 반환. 매핑 없으면 code 자체 반환 (fallback).
  static String displayOf(String code) => _display[code] ?? code;
}
