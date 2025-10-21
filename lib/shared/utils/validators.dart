/// 입력 검증 유틸리티 클래스
///
/// 이메일, 비밀번호, 텍스트 입력 등의 검증 로직을 제공합니다.
/// XSS 방지를 위한 sanitize 기능도 포함합니다.
class Validators {
  Validators._(); // private constructor

  /// 이메일 검증
  ///
  /// 올바른 이메일 형식인지 확인합니다.
  ///
  /// 반환값:
  /// - null: 검증 통과
  /// - String: 에러 메시지
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    }

    // 이메일 정규식
    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(value)) {
      return '올바른 이메일 형식이 아닙니다';
    }

    return null;
  }

  /// 비밀번호 검증
  ///
  /// 비밀번호 요구사항:
  /// - 최소 8자 이상
  /// - 대문자 포함
  /// - 소문자 포함
  /// - 숫자 포함
  ///
  /// 반환값:
  /// - null: 검증 통과
  /// - String: 에러 메시지
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }

    if (value.length < 8) {
      return '비밀번호는 최소 8자 이상이어야 합니다';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return '대문자를 포함해야 합니다';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return '소문자를 포함해야 합니다';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return '숫자를 포함해야 합니다';
    }

    return null;
  }

  /// 이름 검증
  ///
  /// 이름 요구사항:
  /// - 2자 이상 20자 이하
  /// - 한글, 영문만 허용
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return '이름을 입력해주세요';
    }

    if (value.length < 2 || value.length > 20) {
      return '이름은 2자 이상 20자 이하여야 합니다';
    }

    // 한글, 영문, 공백만 허용
    final nameRegex = RegExp(r'^[가-힣a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return '한글 또는 영문만 입력 가능합니다';
    }

    return null;
  }

  /// 필수 입력 검증
  ///
  /// 값이 비어있지 않은지 확인합니다.
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? '값'}을 입력해주세요';
    }
    return null;
  }

  /// 최소 길이 검증
  static String? minLength(String? value, int minLength) {
    if (value == null || value.isEmpty) {
      return null; // required와 함께 사용
    }

    if (value.length < minLength) {
      return '최소 $minLength자 이상 입력해주세요';
    }

    return null;
  }

  /// 최대 길이 검증
  static String? maxLength(String? value, int maxLength) {
    if (value == null || value.isEmpty) {
      return null; // required와 함께 사용
    }

    if (value.length > maxLength) {
      return '최대 $maxLength자까지 입력 가능합니다';
    }

    return null;
  }

  /// 숫자 검증
  static String? number(String? value) {
    if (value == null || value.isEmpty) {
      return null; // required와 함께 사용
    }

    if (int.tryParse(value) == null) {
      return '숫자만 입력 가능합니다';
    }

    return null;
  }

  /// 범위 검증 (숫자)
  static String? range(String? value, int min, int max) {
    if (value == null || value.isEmpty) {
      return null; // required와 함께 사용
    }

    final numValue = int.tryParse(value);
    if (numValue == null) {
      return '숫자만 입력 가능합니다';
    }

    if (numValue < min || numValue > max) {
      return '$min부터 $max 사이의 값을 입력해주세요';
    }

    return null;
  }

  /// XSS 방지를 위한 입력 정제
  ///
  /// HTML 태그 및 특수문자를 이스케이프 처리합니다.
  static String sanitize(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('&', '&amp;')
        .replaceAll('/', '&#x2F;');
  }

  /// 복수 검증 조합
  ///
  /// 여러 검증 함수를 순차적으로 실행합니다.
  ///
  /// Example:
  /// ```dart
  /// validator: Validators.compose([
  ///   (value) => Validators.required(value, fieldName: '이메일'),
  ///   Validators.email,
  /// ]),
  /// ```
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result; // 첫 번째 에러 반환
        }
      }
      return null; // 모두 통과
    };
  }
}
