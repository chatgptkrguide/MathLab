/// 앱 전체에서 사용하는 애니메이션 지속시간 상수
class AppDurations {
  // 애니메이션 지속시간 (밀리초)
  static const int short = 200;
  static const int medium = 300;
  static const int long = 400;
  static const int xLong = 600;

  // Duration 객체
  static const Duration shortDuration = Duration(milliseconds: short);
  static const Duration mediumDuration = Duration(milliseconds: medium);
  static const Duration longDuration = Duration(milliseconds: long);
  static const Duration xLongDuration = Duration(milliseconds: xLong);

  // 인증 화면 애니메이션
  static const Duration authAnimation = Duration(milliseconds: 800);

  // 스낵바 표시 시간
  static const Duration snackBarShort = Duration(seconds: 2);
  static const Duration snackBarLong = Duration(seconds: 4);
}
