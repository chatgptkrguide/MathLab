/// 구독 상태
///
/// 사용자의 구독 활성 상태를 나타냅니다.
enum SubscriptionStatus {
  /// 활성 구독 (정상 이용 중)
  active('active', '활성', '정상 이용 중'),

  /// 만료됨 (기간 종료)
  expired('expired', '만료', '구독이 만료되었습니다'),

  /// 취소됨 (사용자가 취소했지만 기간까지는 사용 가능)
  cancelled('cancelled', '취소됨', '기간 종료 시 만료됩니다'),

  /// 무료 체험 중
  trial('trial', '체험 중', '무료 체험 기간입니다'),

  /// 일시 정지 (결제 실패 등)
  paused('paused', '일시정지', '구독이 일시 정지되었습니다');

  /// Firestore 저장용 문자열 값
  final String value;

  /// 한글 표시명 (짧은 버전)
  final String displayName;

  /// 상세 설명
  final String description;

  const SubscriptionStatus(this.value, this.displayName, this.description);

  /// 문자열로부터 SubscriptionStatus 변환
  static SubscriptionStatus fromString(String value) {
    return SubscriptionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => SubscriptionStatus.expired,
    );
  }

  /// 활성 상태인지 확인 (프리미엄 기능 사용 가능)
  bool get isUsable {
    return this == SubscriptionStatus.active ||
        this == SubscriptionStatus.trial ||
        this == SubscriptionStatus.cancelled; // 취소해도 기간 종료까지는 사용 가능
  }

  /// 만료 상태인지 확인
  bool get isExpired => this == SubscriptionStatus.expired;

  /// 일시 정지 상태인지 확인
  bool get isPaused => this == SubscriptionStatus.paused;

  /// 취소 상태인지 확인
  bool get isCancelled => this == SubscriptionStatus.cancelled;

  /// 체험 상태인지 확인
  bool get isTrial => this == SubscriptionStatus.trial;

  /// 상태 색상 (UI 표시용)
  String get colorHex {
    switch (this) {
      case SubscriptionStatus.active:
        return '#58CC02'; // mathGreen
      case SubscriptionStatus.trial:
        return '#FFD900'; // mathYellow
      case SubscriptionStatus.cancelled:
        return '#FF9600'; // mathOrange
      case SubscriptionStatus.paused:
      case SubscriptionStatus.expired:
        return '#FF4B4B'; // mathRed
    }
  }

  @override
  String toString() => value;
}
