/// Subject code → 사용자 노출 한글 라벨 매핑.
///
/// 내부 식별자(예: '수학I', '수학II', '공통수학1') 는 그대로 유지하여 코드 전반의
/// 비교·매칭·Firestore 데이터 호환성을 유지하고, **화면 표시에서만 한글 띄어쓰기
/// + 한글 숫자(1/2)** 로 변환한다. 한국 학습자에게 가장 자연스러운 표기.
class SubjectLabels {
  SubjectLabels._();

  static const Map<String, String> _display = {
    '기초수학': '기초수학',
    '중학수학': '중학수학',
    '공통수학1': '공통수학 1',
    '공통수학2': '공통수학 2',
    '수학I': '수학 1',
    '수학II': '수학 2',
    '확률과통계': '확률과 통계',
    '미적분': '미적분',
    '기하': '기하',
  };

  /// 코드에 해당하는 한글 표시명을 반환. 매핑 없으면 code 자체 반환 (fallback).
  static String displayOf(String code) => _display[code] ?? code;
}
