/// 프리미엄 등급
///
/// 사용자의 구독 등급을 나타냅니다.
enum PremiumTier {
  /// 무료 사용자 (기본)
  free('free', '무료', 0),

  /// 월간 구독 (₩9,900/월)
  monthly('monthly', '월간', 9900),

  /// 연간 구독 (₩89,000/년, ~25% 할인)
  yearly('yearly', '연간', 89000),

  /// 평생 구독 (₩199,000, 일회성 결제)
  lifetime('lifetime', '평생', 199000);

  /// Firestore 저장용 문자열 값
  final String value;

  /// 한글 표시명
  final String displayName;

  /// 가격 (원)
  final int price;

  const PremiumTier(this.value, this.displayName, this.price);

  /// 문자열로부터 PremiumTier 변환
  static PremiumTier fromString(String value) {
    return PremiumTier.values.firstWhere(
      (tier) => tier.value == value,
      orElse: () => PremiumTier.free,
    );
  }

  /// 가격 포맷팅 (예: "₩9,900")
  String get formattedPrice {
    if (price == 0) return '무료';
    return '₩${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        )}';
  }

  /// 월간 환산 가격 (연간의 경우 12개월로 나눔)
  int get monthlyEquivalentPrice {
    switch (this) {
      case PremiumTier.free:
        return 0;
      case PremiumTier.monthly:
        return price;
      case PremiumTier.yearly:
        return (price / 12).round();
      case PremiumTier.lifetime:
        return 0; // 평생 구독은 월 단위 계산 불가
    }
  }

  /// 할인율 계산 (월간 대비)
  double get discountPercentage {
    if (this == PremiumTier.free || this == PremiumTier.monthly) return 0.0;
    if (this == PremiumTier.yearly) {
      final yearlyMonthlyPrice = monthlyEquivalentPrice;
      final monthlyPrice = PremiumTier.monthly.price;
      return ((monthlyPrice - yearlyMonthlyPrice) / monthlyPrice) * 100;
    }
    return 0.0; // 평생 구독은 할인율 계산 불가
  }

  /// 할인 표시 문구 (예: "25% 절감")
  String? get discountLabel {
    if (discountPercentage > 0) {
      return '${discountPercentage.round()}% 절감';
    }
    return null;
  }

  /// 프리미엄 여부 확인
  bool get isPremium => this != PremiumTier.free;

  /// 정기 구독 여부 (자동 갱신 가능)
  bool get isRecurring => this == PremiumTier.monthly || this == PremiumTier.yearly;

  @override
  String toString() => value;
}
