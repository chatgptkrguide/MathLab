/// 💎 Premium Tier Model
///
/// Defines the premium subscription tiers and their pricing.

/// 프리미엄 구독 티어
enum PremiumTier {
  /// 무료 플랜
  free,

  /// 월간 구독
  monthly,

  /// 연간 구독
  yearly,

  /// 평생 구독
  lifetime,

  /// 프리미엄 (일반 프리미엄 참조용)
  premium,

  /// 프로 (상위 프리미엄 참조용)
  pro;

  /// 티어별 가격 (원)
  double get price {
    switch (this) {
      case PremiumTier.free:
        return 0;
      case PremiumTier.monthly:
        return 9900;
      case PremiumTier.yearly:
        return 79900;
      case PremiumTier.lifetime:
        return 199000;
      case PremiumTier.premium:
        return 9900;
      case PremiumTier.pro:
        return 19900;
    }
  }

  /// 포맷된 가격 문자열
  String get formattedPrice {
    if (this == PremiumTier.free) return '무료';

    final priceInt = price.toInt();
    if (priceInt >= 10000) {
      final man = priceInt ~/ 10000;
      final remainder = priceInt % 10000;
      if (remainder == 0) {
        return '${man}만원';
      }
      return '${man}만 ${_formatNumber(remainder)}원';
    }
    return '${_formatNumber(priceInt)}원';
  }

  /// 월 환산 가격 (연간/평생만 해당)
  double get monthlyEquivalent {
    switch (this) {
      case PremiumTier.yearly:
        return price / 12;
      case PremiumTier.lifetime:
        return price / 24; // 2년 기준 환산
      default:
        return price;
    }
  }

  /// 포맷된 월 환산 가격
  String get formattedMonthlyEquivalent {
    final equivalent = monthlyEquivalent.toInt();
    return '${_formatNumber(equivalent)}원';
  }

  /// 할인율 (월간 대비)
  double get discountPercentage {
    if (this == PremiumTier.free || this == PremiumTier.monthly) return 0;

    final monthlyPrice = PremiumTier.monthly.price;
    switch (this) {
      case PremiumTier.yearly:
        return ((monthlyPrice * 12 - price) / (monthlyPrice * 12)) * 100;
      case PremiumTier.lifetime:
        return ((monthlyPrice * 24 - price) / (monthlyPrice * 24)) * 100;
      default:
        return 0;
    }
  }

  /// 표시 이름
  String get displayName {
    switch (this) {
      case PremiumTier.free:
        return '무료';
      case PremiumTier.monthly:
        return '월간';
      case PremiumTier.yearly:
        return '연간';
      case PremiumTier.lifetime:
        return '평생';
      case PremiumTier.premium:
        return '프리미엄';
      case PremiumTier.pro:
        return '프로';
    }
  }

  /// 구독 기간 (일)
  int get durationDays {
    switch (this) {
      case PremiumTier.free:
        return 0;
      case PremiumTier.monthly:
        return 30;
      case PremiumTier.yearly:
        return 365;
      case PremiumTier.lifetime:
        return 36500; // ~100 years
      case PremiumTier.premium:
        return 30;
      case PremiumTier.pro:
        return 30;
    }
  }

  /// 구독 플랜 ID (앱 스토어 연동용)
  String get productId {
    switch (this) {
      case PremiumTier.free:
        return '';
      case PremiumTier.monthly:
        return 'mathlab_premium_monthly';
      case PremiumTier.yearly:
        return 'mathlab_premium_yearly';
      case PremiumTier.lifetime:
        return 'mathlab_premium_lifetime';
      case PremiumTier.premium:
        return 'mathlab_premium_monthly';
      case PremiumTier.pro:
        return 'mathlab_pro_monthly';
    }
  }

  /// 숫자 포맷 헬퍼 (천 단위 콤마)
  static String _formatNumber(int number) {
    final str = number.toString();
    final result = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        result.write(',');
      }
      result.write(str[i]);
    }
    return result.toString();
  }
}
