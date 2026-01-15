/// 입력 유효성 검사 유틸리티
class ValidationUtils {
  ValidationUtils._();

  /// 이름 유효성 검사
  static bool isValidName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return false;
    }
    final trimmed = name.trim();
    return trimmed.length >= 2 && trimmed.length <= 20;
  }

  /// 학교명 유효성 검사 (선택사항)
  static bool isValidSchool(String? school) {
    if (school == null || school.trim().isEmpty) {
      return true; // 선택사항이므로 빈 값도 허용
    }
    return school.trim().length <= 50;
  }

  /// 자기소개 유효성 검사 (선택사항)
  static bool isValidBio(String? bio) {
    if (bio == null || bio.trim().isEmpty) {
      return true; // 선택사항이므로 빈 값도 허용
    }
    return bio.trim().length <= 150;
  }

  /// 생년월일 유효성 검사
  static bool isValidBirthDate(DateTime? birthDate) {
    if (birthDate == null) {
      return false;
    }
    final now = DateTime.now();
    final minAge = now.subtract(const Duration(days: 365 * 100)); // 100세
    final maxAge = now.subtract(const Duration(days: 365 * 5)); // 5세

    return birthDate.isAfter(minAge) && birthDate.isBefore(maxAge);
  }

  /// 이메일 유효성 검사
  static bool isValidEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return false;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  /// 사용자명 유효성 검사 (알파벳, 숫자, 언더스코어만)
  static bool isValidUsername(String? username) {
    if (username == null || username.trim().isEmpty) {
      return false;
    }
    final trimmed = username.trim();
    if (trimmed.length < 3 || trimmed.length > 20) {
      return false;
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    return usernameRegex.hasMatch(trimmed);
  }

  /// 비밀번호 유효성 검사
  static bool isValidPassword(String? password) {
    if (password == null || password.isEmpty) {
      return false;
    }
    // 최소 8자, 영문 대소문자, 숫자 포함
    if (password.length < 8) {
      return false;
    }
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));

    return hasUppercase && hasLowercase && hasDigits;
  }

  /// 비밀번호 강도 확인 (0-4)
  static int getPasswordStrength(String? password) {
    if (password == null || password.isEmpty) {
      return 0;
    }

    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    return (strength / 6 * 4).round().clamp(0, 4);
  }

  /// 전화번호 유효성 검사 (한국)
  static bool isValidPhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return false;
    }
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    // 010-XXXX-XXXX 형식
    return cleaned.length == 11 && cleaned.startsWith('010');
  }
}
