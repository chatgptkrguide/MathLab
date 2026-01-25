/// 🛡️ Input Validation and Sanitization
///
/// Provides comprehensive input validation and sanitization to prevent
/// injection attacks, XSS, and other security vulnerabilities.
///
/// Usage:
/// ```dart
/// // Validate user input
/// final validator = InputValidator();
///
/// if (!validator.isValidEmail(email)) {
///   throw ValidationException('Invalid email format');
/// }
///
/// final sanitizedName = validator.sanitizeName(userInput);
/// ```

import 'dart:math';

class InputValidator {
  // ========================================
  // Email Validation
  // ========================================

  /// Validate email format (RFC 5322 compliant)
  static bool isValidEmail(String email) {
    if (email.isEmpty || email.length > 254) {
      return false;
    }

    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );

    return emailRegex.hasMatch(email);
  }

  // ========================================
  // Name Validation and Sanitization
  // ========================================

  /// Sanitize user name (remove dangerous characters)
  static String sanitizeName(String name) {
    if (name.isEmpty) return '';

    // Remove HTML/script tags
    String sanitized = _removeHtmlTags(name);

    // Remove special characters that could be used for injection
    sanitized = sanitized.replaceAll(RegExp(r'[<>{}[\]\\|`]'), '');

    // Remove multiple spaces
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    // Trim whitespace
    sanitized = sanitized.trim();

    // Limit length
    const maxLength = 50;
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }

    return sanitized;
  }

  /// Validate name format
  static bool isValidName(String name) {
    if (name.isEmpty || name.length > 50) {
      return false;
    }

    // Allow letters, spaces, hyphens, apostrophes
    // Support Korean, English, Japanese, Chinese characters
    // Unicode ranges: Korean (AC00-D7AF), Japanese Hiragana/Katakana (3040-30FF),
    // Chinese (4E00-9FFF), Latin (0041-007A, 0061-007A)
    final nameRegex = RegExp(
      "^[a-zA-Z\\u3040-\\u30FF\\u4E00-\\u9FFF\\uAC00-\\uD7AF\\s'-]+\$",
      unicode: true,
    );

    return nameRegex.hasMatch(name);
  }

  // ========================================
  // Grade Validation
  // ========================================

  /// Valid grade options
  static const List<String> validGrades = [
    '초1', '초2', '초3', '초4', '초5', '초6',
    '중1', '중2', '중3',
    '고1', '고2', '고3',
  ];

  /// Validate grade selection
  static bool isValidGrade(String grade) {
    return validGrades.contains(grade);
  }

  /// Sanitize grade input
  static String? sanitizeGrade(String? grade) {
    if (grade == null || !isValidGrade(grade)) {
      return null;
    }
    return grade;
  }

  // ========================================
  // School Name Validation
  // ========================================

  /// Sanitize school name
  static String sanitizeSchoolName(String schoolName) {
    if (schoolName.isEmpty) return '';

    // Remove HTML/script tags
    String sanitized = _removeHtmlTags(schoolName);

    // Remove special characters
    sanitized = sanitized.replaceAll(RegExp(r'[<>{}[\]\\|`]'), '');

    // Remove multiple spaces
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    // Trim whitespace
    sanitized = sanitized.trim();

    // Limit length
    const maxLength = 100;
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }

    return sanitized;
  }

  /// Validate school name
  static bool isValidSchoolName(String? schoolName) {
    if (schoolName == null || schoolName.isEmpty) {
      return true; // Optional field
    }

    if (schoolName.length > 100) {
      return false;
    }

    // Allow letters, numbers, spaces, basic punctuation
    // Unicode ranges: Korean, Japanese, Chinese, Latin, digits
    final schoolRegex = RegExp(
      "^[a-zA-Z0-9\\u3040-\\u30FF\\u4E00-\\u9FFF\\uAC00-\\uD7AF\\s'-.]+\$",
      unicode: true,
    );

    return schoolRegex.hasMatch(schoolName);
  }

  // ========================================
  // Bio/Description Validation
  // ========================================

  /// Sanitize bio text
  static String sanitizeBio(String bio) {
    if (bio.isEmpty) return '';

    // Remove HTML/script tags
    String sanitized = _removeHtmlTags(bio);

    // Remove dangerous characters
    sanitized = sanitized.replaceAll(RegExp(r'[<>{}[\]\\|`]'), '');

    // Normalize whitespace
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    // Trim whitespace
    sanitized = sanitized.trim();

    // Limit length
    const maxLength = 500;
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }

    return sanitized;
  }

  /// Validate bio text
  static bool isValidBio(String? bio) {
    if (bio == null || bio.isEmpty) {
      return true; // Optional field
    }

    if (bio.length > 500) {
      return false;
    }

    // Check for suspicious patterns
    if (_containsSuspiciousPatterns(bio)) {
      return false;
    }

    return true;
  }

  // ========================================
  // Password Validation
  // ========================================

  /// Validate password strength
  static bool isValidPassword(String password) {
    if (password.length < 8 || password.length > 128) {
      return false;
    }

    // Must contain at least:
    // - One uppercase letter
    // - One lowercase letter
    // - One number
    // - One special character
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasUppercase && hasLowercase && hasNumber && hasSpecial;
  }

  /// Get password strength (0.0 to 1.0)
  static double getPasswordStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0.0;

    // Length score (max 0.3)
    strength += min(password.length / 20, 0.3);

    // Character variety score (max 0.7)
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.15;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.15;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;

    return min(strength, 1.0);
  }

  // ========================================
  // Phone Number Validation
  // ========================================

  /// Validate Korean phone number format
  static bool isValidPhoneNumber(String phone) {
    // Remove spaces and hyphens
    final cleaned = phone.replaceAll(RegExp(r'[\s-]'), '');

    // Korean phone number patterns
    final patterns = [
      RegExp(r'^01[016789]\d{7,8}$'), // Mobile
      RegExp(r'^02\d{7,8}$'), // Seoul landline
      RegExp(r'^0[3-6][1-5]\d{7,8}$'), // Other landlines
    ];

    return patterns.any((pattern) => pattern.hasMatch(cleaned));
  }

  /// Sanitize phone number (remove non-numeric characters)
  static String sanitizePhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  // ========================================
  // URL Validation
  // ========================================

  /// Validate URL format
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isScheme('http') || uri.isScheme('https');
    } catch (e) {
      return false;
    }
  }

  /// Sanitize URL (ensure safe protocols)
  static String? sanitizeUrl(String url) {
    try {
      final uri = Uri.parse(url);

      // Only allow http and https
      if (!uri.isScheme('http') && !uri.isScheme('https')) {
        return null;
      }

      return uri.toString();
    } catch (e) {
      return null;
    }
  }

  // ========================================
  // Private Helper Methods
  // ========================================

  /// Remove HTML tags from string
  static String _removeHtmlTags(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Check for suspicious injection patterns
  static bool _containsSuspiciousPatterns(String text) {
    final suspiciousPatterns = [
      RegExp(r'<script', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false), // onclick=, onerror=, etc.
      RegExp(r'eval\s*\(', caseSensitive: false),
      RegExp(r'expression\s*\(', caseSensitive: false),
      RegExp(r'vbscript:', caseSensitive: false),
      RegExp(r'<iframe', caseSensitive: false),
      RegExp(r'<embed', caseSensitive: false),
      RegExp(r'<object', caseSensitive: false),
    ];

    return suspiciousPatterns.any((pattern) => pattern.hasMatch(text));
  }

  // ========================================
  // Batch Validation
  // ========================================

  /// Validate all profile fields at once
  static ValidationResult validateProfileData({
    required String name,
    required String grade,
    String? schoolName,
    String? bio,
  }) {
    final errors = <String, String>{};

    // Validate name
    if (!isValidName(name)) {
      errors['name'] = '이름 형식이 올바르지 않습니다 (최대 50자)';
    }

    // Validate grade
    if (!isValidGrade(grade)) {
      errors['grade'] = '학년을 선택해주세요';
    }

    // Validate school name (optional)
    if (schoolName != null && !isValidSchoolName(schoolName)) {
      errors['schoolName'] = '학교명 형식이 올바르지 않습니다 (최대 100자)';
    }

    // Validate bio (optional)
    if (bio != null && !isValidBio(bio)) {
      errors['bio'] = '소개글 형식이 올바르지 않습니다 (최대 500자)';
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

// ========================================
// Validation Result Model
// ========================================

class ValidationResult {
  final bool isValid;
  final Map<String, String> errors;

  ValidationResult({
    required this.isValid,
    required this.errors,
  });

  String? getError(String field) => errors[field];

  bool hasError(String field) => errors.containsKey(field);
}

// ========================================
// Custom Exception
// ========================================

class ValidationException implements Exception {
  final String message;
  final String? field;

  ValidationException(this.message, {this.field});

  @override
  String toString() {
    if (field != null) {
      return 'ValidationException [$field]: $message';
    }
    return 'ValidationException: $message';
  }
}
