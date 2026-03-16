# 🔐 Security Implementation Guide

**Project**: MathLab Flutter App
**Last Updated**: 2026-01-25
**Priority**: CRITICAL - Implement Immediately

---

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [Environment Setup](#environment-setup)
3. [Code Integration](#code-integration)
4. [Credential Rotation](#credential-rotation)
5. [Git History Cleanup](#git-history-cleanup)
6. [Security Testing](#security-testing)
7. [Deployment Checklist](#deployment-checklist)

---

## 🚀 Quick Start

### Step 1: Add Security Dependencies

Update `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Environment variables
  flutter_dotenv: ^5.1.0

  # Secure storage
  flutter_secure_storage: ^9.0.0

  # HTTP client with SSL pinning (optional but recommended)
  dio: ^5.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Static code analysis
  flutter_lints: ^3.0.1
```

### Step 2: Install Dependencies

```bash
cd /Users/yeojoonsoo02/Desktop/Work_Project/Gomath/MathLab
flutter pub get
```

### Step 3: Update .gitignore

Ensure these entries exist in `.gitignore`:

```gitignore
# Environment variables
.env
.env.local
.env.production
.env.*.local

# Firebase configuration
android/app/google-services.json
ios/Runner/GoogleService-Info.plist

# Security files
**/secrets.json
**/credentials.json
api_keys.dart
secrets.dart
```

---

## 🔧 Environment Setup

### Step 1: Create Development Environment File

Create `.env` (already exists, needs cleanup):

```bash
# Copy template
cp .env.example .env

# Edit with real values
# ⚠️  NEVER commit this file to Git
```

### Step 2: Create Production Environment File

Create `.env.production`:

```bash
# Copy production template
cp .env.production.example .env.production

# Edit with PRODUCTION values
# ⚠️  NEVER commit this file to Git
```

### Step 3: Environment File Structure

**Development (.env)**:
```env
# API Configuration
API_BASE_URL=http://localhost:8080/api/v1

# Social Login - Development Keys
KAKAO_NATIVE_APP_KEY=your_dev_kakao_key
GOOGLE_WEB_CLIENT_ID=your_dev_google_client_id

# Firebase Cloud Messaging - Development
FCM_WEB_PUSH_KEY=your_dev_fcm_key
FCM_SENDER_ID=your_dev_sender_id

# App Configuration
APP_ENV=development
ENABLE_LOGGING=true

# OpenAI (Development Only)
OPENAI_API_KEY=your_dev_openai_key
```

**Production (.env.production)**:
```env
# API Configuration
API_BASE_URL=https://api.mathlab.app/api/v1

# Social Login - Production Keys
KAKAO_NATIVE_APP_KEY=your_prod_kakao_key
GOOGLE_WEB_CLIENT_ID=your_prod_google_client_id

# Firebase Cloud Messaging - Production
FCM_WEB_PUSH_KEY=your_prod_fcm_key
FCM_SENDER_ID=your_prod_sender_id

# App Configuration
APP_ENV=production
ENABLE_LOGGING=false
```

---

## 💻 Code Integration

### Step 1: Update main.dart

Update your `main.dart` to initialize environment configuration:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/env_config.dart';
import 'core/security/secure_storage_service.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Load environment configuration
    // Use .env for development, .env.production for production
    const environment = String.fromEnvironment('ENV', defaultValue: 'development');
    final envFile = environment == 'production' ? '.env.production' : '.env';

    await EnvConfig.initialize(fileName: envFile);

    // 2. Validate environment variables
    EnvConfig.validateEnvironment();

    // 3. Print config in development only
    if (EnvConfig.isDevelopment) {
      EnvConfig.printConfig();
    }

    // 4. Test secure storage accessibility
    final storage = SecureStorageService();
    final isAccessible = await storage.isAccessible();

    if (!isAccessible) {
      throw Exception('Secure storage is not accessible');
    }

    // 5. Run app
    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    // Log initialization error
    debugPrint('=== App Initialization Failed ===');
    debugPrint('Error: $e');
    debugPrint('Stack trace: $stackTrace');

    // Show error screen
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    '앱 초기화 실패',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '환경 설정 파일을 확인해주세요.\n\n$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MathLab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Your existing splash screen
    );
  }
}
```

### Step 2: Update Authentication Handler

Update `lib/features/auth/logic/auth_handler.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/env_config.dart';
import '../../../core/security/secure_storage_service.dart';
import '../../../core/security/input_validator.dart';
import '../../../data/providers/auth/auth_provider.dart';
import '../../../data/services/temp_profile_storage.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_durations.dart';
import '../../profile/onboarding_profile_setup_screen.dart';

/// 인증 관련 로직 핸들러 (보안 강화 버전)
class AuthHandler {
  // Secure storage instance
  static final _secureStorage = SecureStorageService();

  /// 게스트로 시작
  static Future<bool> handleGuestStart({
    required BuildContext context,
    required WidgetRef ref,
    required bool mounted,
  }) async {
    try {
      // 게스트 계정 생성
      final success = await ref.read(authProvider.notifier).signInAsGuest();

      if (!mounted) return false;

      if (success) {
        // ✅ Validated default profile
        final defaultProfile = TempProfileData(
          name: InputValidator.sanitizeName('테스터'),
          birthDate: DateTime.now().subtract(const Duration(days: 365 * 15)),
          gender: null,
          currentGrade: '중1', // Already validated constant
          schoolName: null,
          bio: null,
        );

        await ref
            .read(authProvider.notifier)
            .applyTempProfileToAccount(defaultProfile);

        // ✅ Record login time for session management
        await _secureStorage.recordLoginTime();

        // Success feedback
        if (mounted) {
          _showSuccessSnackBar(
            context: context,
            message: '${defaultProfile.name}님, 환영합니다! 🎉',
          );
        }

        return true;
      } else {
        if (mounted) {
          _showErrorSnackBar(
            context: context,
            message: '게스트 계정 생성에 실패했습니다. 다시 시도해주세요.',
          );
        }
        return false;
      }
    } catch (e) {
      // ✅ Secure error handling - no stack trace exposure
      debugPrint('Guest login error: $e');

      if (mounted) {
        _showErrorSnackBar(
          context: context,
          message: '예상치 못한 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
        );
      }
      return false;
    }
  }

  /// Google 로그인 (보안 강화 버전)
  static Future<bool> handleGoogleLogin({
    required BuildContext context,
    required WidgetRef ref,
    required bool mounted,
  }) async {
    try {
      // ✅ Check session timeout
      if (await _secureStorage.isSessionExpired()) {
        await _secureStorage.clearAll();
      }

      // 1. 구글 로그인 먼저 실행
      final success = await ref.read(authProvider.notifier).signInWithGoogle();

      if (!mounted) return false;

      if (success) {
        // 2. 로그인 성공 후 프로필 설정 화면으로 이동
        final profileResult = await Navigator.of(context).push<TempProfileData>(
          MaterialPageRoute(
            builder: (context) => const OnboardingProfileSetupScreen(),
          ),
        );

        if (profileResult == null || !mounted) return false;

        // ✅ Validate profile data before saving
        final validation = InputValidator.validateProfileData(
          name: profileResult.name,
          grade: profileResult.currentGrade,
          schoolName: profileResult.schoolName,
          bio: profileResult.bio,
        );

        if (!validation.isValid) {
          if (mounted) {
            _showErrorSnackBar(
              context: context,
              message: validation.errors.values.first,
            );
          }
          return false;
        }

        // ✅ Sanitize profile data
        final sanitizedProfile = TempProfileData(
          name: InputValidator.sanitizeName(profileResult.name),
          birthDate: profileResult.birthDate,
          gender: profileResult.gender,
          currentGrade: profileResult.currentGrade, // Already validated
          schoolName: profileResult.schoolName != null
              ? InputValidator.sanitizeSchoolName(profileResult.schoolName!)
              : null,
          bio: profileResult.bio != null
              ? InputValidator.sanitizeBio(profileResult.bio!)
              : null,
        );

        // 3. 프로필 정보를 사용자 계정에 업데이트
        await ref.read(authProvider.notifier).applyTempProfileToAccount(
              sanitizedProfile,
            );

        if (!mounted) return false;

        // 4. 임시 프로필 정보 삭제
        final tempStorage = ref.read(tempProfileStorageProvider);
        await tempStorage.clearTempProfile();

        // ✅ Record login time
        await _secureStorage.recordLoginTime();

        // Success feedback
        if (mounted) {
          _showSuccessSnackBar(
            context: context,
            message: '${sanitizedProfile.name}님, 환영합니다! 🎉',
          );
        }

        return true;
      } else {
        if (mounted) {
          _showErrorSnackBar(
            context: context,
            message: 'Google 로그인에 실패했습니다. 다시 시도해주세요.',
          );
        }
        return false;
      }
    } catch (e) {
      // ✅ Secure error handling
      debugPrint('Google login error: $e');

      if (mounted) {
        _showErrorSnackBar(
          context: context,
          message: 'Google 로그인 중 문제가 발생했습니다. 네트워크를 확인해주세요.',
        );
      }
      return false;
    }
  }

  /// Kakao 로그인 (보안 강화 버전)
  static Future<bool> handleKakaoLogin({
    required BuildContext context,
    required WidgetRef ref,
    required bool mounted,
  }) async {
    try {
      // ✅ Check session timeout
      if (await _secureStorage.isSessionExpired()) {
        await _secureStorage.clearAll();
      }

      final success = await ref.read(authProvider.notifier).signInWithKakao();

      if (!mounted) return false;

      if (success) {
        // ✅ Record login time
        await _secureStorage.recordLoginTime();
        return true;
      }

      if (mounted) {
        _showErrorSnackBar(
          context: context,
          message: 'Kakao 로그인에 실패했습니다',
        );
      }
      return false;
    } catch (e) {
      // ✅ Secure error handling - no error details to user
      debugPrint('Kakao login error: $e');

      if (mounted) {
        _showErrorSnackBar(
          context: context,
          message: 'Kakao 로그인 실패. 다시 시도해주세요.',
        );
      }
      return false;
    }
  }

  /// 성공 스낵바 표시
  static void _showSuccessSnackBar({
    required BuildContext context,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.mathGreen,
        behavior: SnackBarBehavior.floating,
        duration: AppDurations.snackBarShort,
      ),
    );
  }

  /// 에러 스낵바 표시
  static void _showErrorSnackBar({
    required BuildContext context,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
```

### Step 3: Create Rate Limiter

Create `lib/core/security/rate_limiter.dart`:

```dart
/// 🛡️ Rate Limiter
///
/// Prevents brute force attacks by limiting authentication attempts
///
/// Usage:
/// ```dart
/// if (!RateLimiter.isAllowed('user@email.com')) {
///   throw Exception('Too many attempts. Try again later.');
/// }
/// ```

class RateLimiter {
  static final Map<String, List<DateTime>> _attempts = {};

  /// Check if request is allowed based on rate limit
  static bool isAllowed(
    String identifier, {
    int maxAttempts = 5,
    Duration window = const Duration(minutes: 15),
  }) {
    _attempts.putIfAbsent(identifier, () => []);
    final now = DateTime.now();

    // Remove old attempts outside time window
    _attempts[identifier]!.removeWhere(
      (time) => now.difference(time) > window,
    );

    // Check if exceeded max attempts
    if (_attempts[identifier]!.length >= maxAttempts) {
      return false;
    }

    // Record this attempt
    _attempts[identifier]!.add(now);
    return true;
  }

  /// Get remaining attempts for identifier
  static int getRemainingAttempts(
    String identifier, {
    int maxAttempts = 5,
  }) {
    final attempts = _attempts[identifier]?.length ?? 0;
    return maxAttempts - attempts;
  }

  /// Get time until rate limit resets
  static Duration? getTimeUntilReset(
    String identifier, {
    Duration window = const Duration(minutes: 15),
  }) {
    final attempts = _attempts[identifier];
    if (attempts == null || attempts.isEmpty) {
      return null;
    }

    final oldestAttempt = attempts.first;
    final resetTime = oldestAttempt.add(window);
    final now = DateTime.now();

    if (resetTime.isAfter(now)) {
      return resetTime.difference(now);
    }

    return null;
  }

  /// Clear attempts for identifier (e.g., after successful login)
  static void clearAttempts(String identifier) {
    _attempts.remove(identifier);
  }

  /// Clear all rate limit data
  static void clearAll() {
    _attempts.clear();
  }
}
```

---

## 🔄 Credential Rotation

### Immediate Actions (Do this NOW)

#### 1. Kakao Developers Console

1. Go to https://developers.kakao.com
2. Select your app
3. Go to **설정 > 일반**
4. Click **앱 키 재발급**
5. Update both `.env` and `.env.production` with new keys

#### 2. Google Cloud Console

1. Go to https://console.cloud.google.com
2. Navigate to **APIs & Services > Credentials**
3. Find your OAuth 2.0 Client ID
4. Click **Delete** (or create new one)
5. Create new OAuth 2.0 Client ID
6. Update `.env` and `.env.production`

#### 3. Firebase Console

1. Go to https://console.firebase.google.com
2. Select your project
3. Go to **Project Settings > Cloud Messaging**
4. Regenerate FCM server key
5. Update `.env` and `.env.production`

#### 4. OpenAI Platform

1. Go to https://platform.openai.com/api-keys
2. Find the exposed key: `sk-proj-RRrda...`
3. Click **Revoke**
4. Create new API key with usage limits:
   - Set monthly budget: $50
   - Set rate limits
5. Update `.env` only (DO NOT use in production)

---

## 🧹 Git History Cleanup

### ⚠️  WARNING: This will rewrite Git history

```bash
# 1. Backup your repository first
cd /Users/yeojoonsoo02/Desktop/Work_Project/Gomath/MathLab
cp -r . ../MathLab_backup

# 2. Install git-filter-repo (if not installed)
brew install git-filter-repo

# 3. Remove sensitive files from history
git filter-repo --path .env --invert-paths --force
git filter-repo --path android/app/google-services.json --invert-paths --force
git filter-repo --path ios/Runner/GoogleService-Info.plist --invert-paths --force

# 4. Verify .gitignore includes these files
cat .gitignore | grep -E "\.env|google-services|GoogleService-Info"

# 5. Force push to remote (⚠️  Coordinate with team)
git push --force --all origin
git push --force --tags origin

# 6. Notify team members to re-clone repository
echo "All team members must delete their local copy and re-clone!"
```

### Post-Cleanup Actions

1. **Verify cleanup**:
```bash
# Search for API keys in history
git log --all --full-history --source --all -- "*env*"
git log -S "sk-proj" --all
git log -S "KAKAO_NATIVE_APP_KEY" --all
```

2. **Rotate all credentials** (they're still exposed in old history)

3. **Add new Firebase config files**:
```bash
# Download new google-services.json from Firebase Console
# Place in android/app/google-services.json

# Download new GoogleService-Info.plist from Firebase Console
# Place in ios/Runner/GoogleService-Info.plist

# Verify they're in .gitignore
git status  # Should NOT show these files
```

---

## 🧪 Security Testing

### Test 1: Environment Variables

```bash
# Run with development environment
flutter run --dart-define=ENV=development

# Run with production environment
flutter run --dart-define=ENV=production
```

### Test 2: Secure Storage

```dart
// Add test in your app
void testSecureStorage() async {
  final storage = SecureStorageService();

  // Test save
  await storage.saveAuthToken('test_token_12345');

  // Test retrieve
  final token = await storage.getAuthToken();
  assert(token == 'test_token_12345');

  // Test delete
  await storage.deleteAuthToken();
  final deletedToken = await storage.getAuthToken();
  assert(deletedToken == null);

  print('✅ Secure storage test passed');
}
```

### Test 3: Input Validation

```dart
// Add validation tests
void testInputValidation() {
  // Test name sanitization
  final maliciousName = '<script>alert("XSS")</script>테스터';
  final sanitized = InputValidator.sanitizeName(maliciousName);
  assert(!sanitized.contains('<script>'));

  // Test email validation
  assert(InputValidator.isValidEmail('test@example.com'));
  assert(!InputValidator.isValidEmail('invalid-email'));

  // Test grade validation
  assert(InputValidator.isValidGrade('중1'));
  assert(!InputValidator.isValidGrade('invalid'));

  print('✅ Input validation test passed');
}
```

### Test 4: Rate Limiting

```dart
// Test rate limiter
void testRateLimiter() {
  final email = 'test@example.com';

  // Should allow first 5 attempts
  for (int i = 0; i < 5; i++) {
    assert(RateLimiter.isAllowed(email));
  }

  // Should block 6th attempt
  assert(!RateLimiter.isAllowed(email));

  print('✅ Rate limiter test passed');
}
```

---

## 🚀 Deployment Checklist

### Pre-Deployment Security Audit

- [ ] All dependencies updated to latest secure versions
- [ ] `.env` files NOT in Git repository
- [ ] Firebase config files NOT in Git history
- [ ] All credentials rotated after exposure
- [ ] SSL certificate pinning enabled (if using custom API)
- [ ] Code obfuscation enabled
- [ ] ProGuard rules configured (Android)
- [ ] Bitcode disabled (iOS - if using obfuscation)
- [ ] Input validation on all user inputs
- [ ] Secure storage for authentication tokens
- [ ] Rate limiting on authentication endpoints
- [ ] Error messages sanitized (no stack traces)
- [ ] Session timeout configured
- [ ] Security logging enabled
- [ ] Firebase security rules reviewed
- [ ] API security headers configured

### Build Commands

**Development Build**:
```bash
# Android
flutter build apk --debug --dart-define=ENV=development

# iOS
flutter build ios --debug --dart-define=ENV=development
```

**Production Build with Obfuscation**:
```bash
# Android
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=ENV=production

# iOS
flutter build ios --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=ENV=production
```

### Post-Deployment

- [ ] Monitor error logs for security issues
- [ ] Track failed authentication attempts
- [ ] Review API usage for anomalies
- [ ] Check Firebase usage for spikes
- [ ] Verify SSL certificate validity
- [ ] Test authentication flows
- [ ] Verify input validation working
- [ ] Check session timeout working

---

## 📞 Support

If you encounter issues during implementation:

1. Check the detailed error messages
2. Review the Security Audit Report (`SECURITY_AUDIT_REPORT.md`)
3. Test each component individually
4. Contact security team if critical issues found

---

**Generated by**: Security Sentinel - Claude Code
**Guide Version**: 1.0
**Classification**: INTERNAL - DEVELOPMENT USE ONLY
